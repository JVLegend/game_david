import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

final class CloudGameService {
    static let shared = CloudGameService()

    private let databaseId = "(default)"
    private let session = URLSession.shared

    private init() {}

    var isAvailable: Bool {
        #if canImport(FirebaseAuth)
        return Auth.auth().currentUser != nil && projectId != nil
        #else
        return false
        #endif
    }

    func loadPlayer(userId: String, completion: @escaping (PlayerData?) -> Void) {
        authorizedRequest(path: "players/\(userId)", method: "GET") { [weak self] request in
            guard let self, let request else {
                completion(nil)
                return
            }

            self.perform(request) { result in
                switch result {
                case .success(let data):
                    guard
                        let document = try? JSONDecoder().decode(FirestoreDocument.self, from: data),
                        let payload = document.fields["payload"]?.stringValue,
                        let payloadData = payload.data(using: .utf8)
                    else {
                        completion(nil)
                        return
                    }
                    completion(try? JSONDecoder().decode(PlayerData.self, from: payloadData))
                case .failure:
                    completion(nil)
                }
            }
        }
    }

    func savePlayer(_ player: PlayerData, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard
            let encoded = try? JSONEncoder().encode(player),
            let payload = String(data: encoded, encoding: .utf8)
        else {
            completion?(.failure(CloudGameError.encodingFailed))
            return
        }

        let fields: [String: FirestoreValue] = [
            "userId": .string(player.userId),
            "displayName": .string(player.displayName),
            "payload": .string(payload),
            "updatedAt": .timestamp(Date())
        ]

        patchDocument(collection: "players", documentId: player.userId, fields: fields, completion: completion)
    }

    func updateLeaderboard(player: PlayerData, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let fields: [String: FirestoreValue] = [
            "userId": .string(player.userId),
            "displayName": .string(player.displayName),
            "powerScore": .integer(player.powerScore),
            "level": .integer(player.level),
            "totalStars": .integer(player.totalStars),
            "totalEnemiesKilled": .integer(player.totalEnemiesKilled),
            "totalGoldEarned": .integer(player.totalGoldEarned),
            "highestMapCompleted": .integer(player.highestMapCompleted),
            "updatedAt": .timestamp(Date())
        ]

        patchDocument(collection: "leaderboard", documentId: player.userId, fields: fields, completion: completion)
    }

    func fetchTopPlayers(limit: Int = 50, completion: @escaping ([RankingEntry]) -> Void) {
        let body = FirestoreRunQueryRequest(
            structuredQuery: FirestoreStructuredQuery(
                from: [FirestoreCollectionSelector(collectionId: "leaderboard")],
                orderBy: [FirestoreOrder(field: FirestoreFieldReference(fieldPath: "powerScore"), direction: "DESCENDING")],
                limit: limit
            )
        )

        authorizedRequest(path: ":runQuery", method: "POST", body: body) { [weak self] request in
            guard let self, let request else {
                completion([])
                return
            }

            self.perform(request) { result in
                switch result {
                case .success(let data):
                    let rows = (try? JSONDecoder().decode([FirestoreRunQueryResponse].self, from: data)) ?? []
                    let entries = rows.compactMap { response -> RankingEntry? in
                        guard let fields = response.document?.fields else { return nil }
                        return RankingEntry(
	                            userId: fields["userId"]?.stringValue ?? "",
	                            displayName: fields["displayName"]?.stringValue ?? "Jogador",
	                            powerScore: fields["powerScore"]?.intValue ?? 0,
	                            level: fields["level"]?.intValue ?? 1,
                                totalStars: fields["totalStars"]?.intValue ?? 0,
                                totalEnemiesKilled: fields["totalEnemiesKilled"]?.intValue ?? 0,
                                totalGoldEarned: fields["totalGoldEarned"]?.intValue ?? 0,
                                highestMapCompleted: fields["highestMapCompleted"]?.intValue ?? 0
	                        )
                    }
                    completion(entries.filter { !$0.userId.isEmpty })
                case .failure:
                    completion([])
                }
            }
        }
    }

    func deletePlayer(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var capturedError: Error?

        ["players", "leaderboard"].forEach { collection in
            group.enter()
            authorizedRequest(path: "\(collection)/\(userId)", method: "DELETE") { [weak self] request in
                guard let self, let request else {
                    capturedError = CloudGameError.notAuthenticated
                    group.leave()
                    return
                }

                self.perform(request) { result in
                    if case .failure(let error) = result {
                        capturedError = error
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            if let capturedError {
                completion(.failure(capturedError))
            } else {
                completion(.success(()))
            }
        }
    }

    private func patchDocument(collection: String, documentId: String, fields: [String: FirestoreValue], completion: ((Result<Void, Error>) -> Void)?) {
        let body = FirestoreDocument(fields: fields)
        authorizedRequest(path: "\(collection)/\(documentId)", method: "PATCH", body: body) { [weak self] request in
            guard let self, let request else {
                completion?(.failure(CloudGameError.notAuthenticated))
                return
            }

            self.perform(request) { result in
                switch result {
                case .success:
                    completion?(.success(()))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        }
    }

    private func authorizedRequest<T: Encodable>(path: String, method: String, body: T, completion: @escaping (URLRequest?) -> Void) {
        guard let bodyData = try? JSONEncoder().encode(body) else {
            completion(nil)
            return
        }
        authorizedRequest(path: path, method: method, bodyData: bodyData, completion: completion)
    }

    private func authorizedRequest(path: String, method: String, completion: @escaping (URLRequest?) -> Void) {
        authorizedRequest(path: path, method: method, bodyData: nil, completion: completion)
    }

    private func authorizedRequest(path: String, method: String, bodyData: Data?, completion: @escaping (URLRequest?) -> Void) {
        guard let projectId, let baseURL = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/\(databaseId)/documents") else {
            completion(nil)
            return
        }

        #if canImport(FirebaseAuth)
        Auth.auth().currentUser?.getIDToken { token, _ in
            guard let token else {
                completion(nil)
                return
            }

            let url = baseURL.appendingPathComponent(path)
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData
            completion(request)
        }
        #else
        completion(nil)
        #endif
    }

    private func perform(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                    return
                }

                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard (200..<300).contains(statusCode) else {
                    completion(.failure(CloudGameError.requestFailed(statusCode)))
                    return
                }

                completion(.success(data ?? Data()))
            }
        }.resume()
    }

    private var projectId: String? {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let id = plist["PROJECT_ID"] as? String {
            return id
        }
        return nil
    }
}

private enum CloudGameError: Error {
    case encodingFailed
    case notAuthenticated
    case requestFailed(Int)
}

private struct FirestoreDocument: Codable {
    var fields: [String: FirestoreValue]
}

private struct FirestoreValue: Codable {
    var stringValue: String?
    var integerValue: String?
    var timestampValue: String?

    static func string(_ value: String) -> FirestoreValue {
        FirestoreValue(stringValue: value, integerValue: nil, timestampValue: nil)
    }

    static func integer(_ value: Int) -> FirestoreValue {
        FirestoreValue(stringValue: nil, integerValue: "\(value)", timestampValue: nil)
    }

    static func timestamp(_ value: Date) -> FirestoreValue {
        FirestoreValue(stringValue: nil, integerValue: nil, timestampValue: ISO8601DateFormatter().string(from: value))
    }

    var intValue: Int? {
        if let integerValue {
            return Int(integerValue)
        }
        return nil
    }
}

private struct FirestoreRunQueryRequest: Codable {
    let structuredQuery: FirestoreStructuredQuery
}

private struct FirestoreStructuredQuery: Codable {
    let from: [FirestoreCollectionSelector]
    let orderBy: [FirestoreOrder]
    let limit: Int
}

private struct FirestoreCollectionSelector: Codable {
    let collectionId: String
}

private struct FirestoreOrder: Codable {
    let field: FirestoreFieldReference
    let direction: String
}

private struct FirestoreFieldReference: Codable {
    let fieldPath: String
}

private struct FirestoreRunQueryResponse: Codable {
    let document: FirestoreDocument?
}
