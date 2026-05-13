import Foundation

struct RankingEntry: Codable {
    let userId: String
    let displayName: String
    let powerScore: Int
    let level: Int
}

final class RankingManager {
    static let shared = RankingManager()
    
    private init() {}
    
    func fetchTopPlayers(completion: @escaping ([RankingEntry]) -> Void) {
        // Mocked global ranking
        let mockData = [
            RankingEntry(userId: "1", displayName: "Davi", powerScore: 5000, level: 50),
            RankingEntry(userId: "2", displayName: "Golias", powerScore: 4500, level: 45),
            RankingEntry(userId: "3", displayName: "Saul", powerScore: 4000, level: 40)
        ]
        completion(mockData)
    }
    
    func updatePlayerScore(player: PlayerData) {
        print("[MOCK] Ranking update skipped in dev mode.")
    }
}
