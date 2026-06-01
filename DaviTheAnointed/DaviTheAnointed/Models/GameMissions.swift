import Foundation

struct GameMissionDefinition {
    enum Metric {
        case totalStars
        case enemiesKilled
        case totalGoldEarned
        case itemCount
        case level
        case highestMapCompleted
    }

    let id: String
    let titlePT: String
    let titleEN: String
    let descriptionPT: String
    let descriptionEN: String
    let metric: Metric
    let target: Int
    let rewardGold: Int
    let rewardXP: Int

    func title(language: GameLanguage) -> String {
        language == .portuguese ? titlePT : titleEN
    }

    func description(language: GameLanguage) -> String {
        language == .portuguese ? descriptionPT : descriptionEN
    }

    func progressValue(for player: PlayerData) -> Int {
        switch metric {
        case .totalStars:
            return player.totalStars
        case .enemiesKilled:
            return player.totalEnemiesKilled
        case .totalGoldEarned:
            return player.totalGoldEarned
        case .itemCount:
            return player.inventory.count + player.equippedItems.count
        case .level:
            return player.level
        case .highestMapCompleted:
            return player.highestMapCompleted
        }
    }

    func isComplete(for player: PlayerData) -> Bool {
        progressValue(for: player) >= target
    }

    func progressText(for player: PlayerData) -> String {
        "\(min(progressValue(for: player), target))/\(target)"
    }
}

struct MissionCompletion {
    let title: String
    let rewardGold: Int
    let rewardXP: Int

    var rewardText: String {
        "+\(rewardGold) Gold  +\(rewardXP) XP"
    }
}

struct DailyMissionDefinition {
    enum Metric {
        case wins
        case enemiesKilled
        case goldEarned
    }

    let id: String
    let titlePT: String
    let titleEN: String
    let metric: Metric
    let target: Int
    let rewardGold: Int
    let rewardXP: Int

    func title(language: GameLanguage) -> String {
        language == .portuguese ? titlePT : titleEN
    }
}

enum DailyMissionManager {
    private static let prefix = "daily_mission"

    static let missions: [DailyMissionDefinition] = [
        DailyMissionDefinition(id: "daily_win_2", titlePT: "Diária: 2 vitórias", titleEN: "Daily: 2 wins", metric: .wins, target: 2, rewardGold: 90, rewardXP: 35),
        DailyMissionDefinition(id: "daily_enemies_8", titlePT: "Diária: 8 inimigos", titleEN: "Daily: 8 enemies", metric: .enemiesKilled, target: 8, rewardGold: 120, rewardXP: 45),
        DailyMissionDefinition(id: "daily_gold_250", titlePT: "Diária: 250 ouro", titleEN: "Daily: 250 gold", metric: .goldEarned, target: 250, rewardGold: 150, rewardXP: 55)
    ]

    static func recordBattleResult(userId: String?, victory: Bool, goldEarned: Int, enemiesKilled: Int) {
        let id = userId ?? "local"
        if victory {
            increment("wins", by: 1, userId: id)
        }
        increment("enemies", by: enemiesKilled, userId: id)
        increment("gold", by: goldEarned, userId: id)
    }

    static func completeReadyMissions(for player: PlayerData) -> [MissionCompletion] {
        missions.compactMap { mission in
            guard !isClaimed(mission, userId: player.userId),
                  progressValue(for: mission, userId: player.userId) >= mission.target else { return nil }
            UserDefaults.standard.set(true, forKey: key("claimed_\(mission.id)", userId: player.userId))
            return MissionCompletion(
                title: mission.title(language: player.language),
                rewardGold: mission.rewardGold,
                rewardXP: mission.rewardXP
            )
        }
    }

    static func progressText(for mission: DailyMissionDefinition, userId: String) -> String {
        "\(min(progressValue(for: mission, userId: userId), mission.target))/\(mission.target)"
    }

    static func nextVisibleMission(for player: PlayerData) -> DailyMissionDefinition? {
        missions.first { mission in
            !isClaimed(mission, userId: player.userId)
        }
    }

    private static func progressValue(for mission: DailyMissionDefinition, userId: String) -> Int {
        switch mission.metric {
        case .wins:
            return UserDefaults.standard.integer(forKey: key("wins", userId: userId))
        case .enemiesKilled:
            return UserDefaults.standard.integer(forKey: key("enemies", userId: userId))
        case .goldEarned:
            return UserDefaults.standard.integer(forKey: key("gold", userId: userId))
        }
    }

    private static func isClaimed(_ mission: DailyMissionDefinition, userId: String) -> Bool {
        UserDefaults.standard.bool(forKey: key("claimed_\(mission.id)", userId: userId))
    }

    private static func increment(_ metric: String, by amount: Int, userId: String) {
        guard amount > 0 else { return }
        let storageKey = key(metric, userId: userId)
        let current = UserDefaults.standard.integer(forKey: storageKey)
        UserDefaults.standard.set(current + amount, forKey: storageKey)
    }

    private static func key(_ metric: String, userId: String) -> String {
        "\(prefix):\(userId):\(todayKey):\(metric)"
    }

    private static var todayKey: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

enum GameMissionManager {
    static let achievementPrefix = "mission:"

    static let missions: [GameMissionDefinition] = [
        GameMissionDefinition(
            id: "first_victory",
            titlePT: "Primeira vitória",
            titleEN: "First Victory",
            descriptionPT: "Vença uma batalha.",
            descriptionEN: "Win one battle.",
            metric: .totalStars,
            target: 1,
            rewardGold: 60,
            rewardXP: 25
        ),
        GameMissionDefinition(
            id: "ten_enemies",
            titlePT: "Pastor corajoso",
            titleEN: "Brave Shepherd",
            descriptionPT: "Derrote 10 inimigos.",
            descriptionEN: "Defeat 10 enemies.",
            metric: .enemiesKilled,
            target: 10,
            rewardGold: 120,
            rewardXP: 50
        ),
        GameMissionDefinition(
            id: "first_extra_item",
            titlePT: "Novo equipamento",
            titleEN: "New Gear",
            descriptionPT: "Tenha 2 itens no total.",
            descriptionEN: "Own 2 total items.",
            metric: .itemCount,
            target: 2,
            rewardGold: 90,
            rewardXP: 35
        ),
        GameMissionDefinition(
            id: "save_gold",
            titlePT: "Reserva de ouro",
            titleEN: "Gold Reserve",
            descriptionPT: "Ganhe 500 de ouro jogando.",
            descriptionEN: "Earn 500 gold by playing.",
            metric: .totalGoldEarned,
            target: 500,
            rewardGold: 160,
            rewardXP: 60
        ),
        GameMissionDefinition(
            id: "complete_bethlehem",
            titlePT: "Campos protegidos",
            titleEN: "Fields Protected",
            descriptionPT: "Complete os Campos de Belém.",
            descriptionEN: "Complete the Fields of Bethlehem.",
            metric: .highestMapCompleted,
            target: 1,
            rewardGold: 260,
            rewardXP: 110
        ),
        GameMissionDefinition(
            id: "reach_level_5",
            titlePT: "Mais experiente",
            titleEN: "More Experienced",
            descriptionPT: "Chegue ao nível 5.",
            descriptionEN: "Reach level 5.",
            metric: .level,
            target: 5,
            rewardGold: 320,
            rewardXP: 140
        )
    ]

    static func isClaimed(_ mission: GameMissionDefinition, by player: PlayerData) -> Bool {
        player.achievements.contains(achievementPrefix + mission.id)
    }

    static func visibleMissions(for player: PlayerData, limit: Int = 3) -> [GameMissionDefinition] {
        let incomplete = missions.filter { !isClaimed($0, by: player) }
        return Array(incomplete.prefix(limit))
    }
}

extension GameManager {
    @discardableResult
    func completeReadyMissions() -> [MissionCompletion] {
        guard var player = playerData else { return [] }

        let language = player.language
        var completions: [MissionCompletion] = []

        for mission in GameMissionManager.missions {
            let achievementId = GameMissionManager.achievementPrefix + mission.id
            guard !player.achievements.contains(achievementId),
                  mission.isComplete(for: player) else { continue }

            player.achievements.append(achievementId)
            player.gold += mission.rewardGold
            player.totalGoldEarned += mission.rewardGold
            _ = player.addExperience(mission.rewardXP)
            completions.append(MissionCompletion(
                title: mission.title(language: language),
                rewardGold: mission.rewardGold,
                rewardXP: mission.rewardXP
            ))
        }

        for completion in DailyMissionManager.completeReadyMissions(for: player) {
            player.gold += completion.rewardGold
            player.totalGoldEarned += completion.rewardGold
            _ = player.addExperience(completion.rewardXP)
            completions.append(completion)
        }

        guard !completions.isEmpty else { return [] }
        playerData = player
        save()
        return completions
    }
}
