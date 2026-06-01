import Foundation

struct RankingEntry: Codable {
    let userId: String
    let displayName: String
    let powerScore: Int
    let level: Int
    let totalStars: Int
    let totalEnemiesKilled: Int
    let totalGoldEarned: Int
    let highestMapCompleted: Int
}

final class RankingManager {
    static let shared = RankingManager()
    
    private init() {}
    
    func fetchTopPlayers(completion: @escaping ([RankingEntry]) -> Void) {
        CloudGameService.shared.fetchTopPlayers { results in
            if !results.isEmpty {
                completion(results)
                return
            }

            var localResults: [RankingEntry] = []
            if let player = GameManager.shared.playerData {
                localResults.append(RankingEntry(
                    userId: player.userId,
                    displayName: player.displayName,
                    powerScore: player.powerScore,
                    level: player.level,
                    totalStars: player.totalStars,
                    totalEnemiesKilled: player.totalEnemiesKilled,
                    totalGoldEarned: player.totalGoldEarned,
                    highestMapCompleted: player.highestMapCompleted
                ))
            }

            completion(localResults)
        }
    }
    
    func updatePlayerScore(player: PlayerData) {
        CloudGameService.shared.updateLeaderboard(player: player)
    }
}
