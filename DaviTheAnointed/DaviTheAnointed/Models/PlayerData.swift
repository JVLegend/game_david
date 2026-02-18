import Foundation

struct PlayerData: Codable {
    var userId: String
    var displayName: String
    var language: GameLanguage
    var level: Int
    var experience: Int
    var gold: Int
    var rubies: Int
    var activeCharacter: PlayableCharacter
    var unlockedCharacters: [PlayableCharacter]
    var highestMapCompleted: Int
    var mapStars: [String: Int] // "map_battle" -> stars (1-3)
    var equippedItems: [EquipmentSlot: String] // slot -> item ID
    var inventory: [String] // item IDs
    var foodInventory: [FoodType: Int] // food -> quantity
    var powerScore: Int
    var totalEnemiesKilled: Int
    var totalGoldEarned: Int
    var pvpRating: Int
    var pvpWins: Int
    var clanId: String?
    var achievements: [String]
    var createdAt: Date
    var lastSaved: Date

    static func newPlayer(userId: String, displayName: String, language: GameLanguage) -> PlayerData {
        return PlayerData(
            userId: userId,
            displayName: displayName,
            language: language,
            level: 1,
            experience: 0,
            gold: 100,
            rubies: 0,
            activeCharacter: .davi,
            unlockedCharacters: [.davi],
            highestMapCompleted: 0,
            mapStars: [:],
            equippedItems: [:],
            inventory: [],
            foodInventory: [.barleyBread: 3],
            powerScore: 0,
            totalEnemiesKilled: 0,
            totalGoldEarned: 0,
            pvpRating: 1000,
            pvpWins: 0,
            clanId: nil,
            achievements: [],
            createdAt: Date(),
            lastSaved: Date()
        )
    }

    var experienceForNextLevel: Int {
        return level * 100 + (level * level * 10)
    }

    mutating func addExperience(_ xp: Int) -> Bool {
        experience += xp
        var leveledUp = false
        while experience >= experienceForNextLevel {
            experience -= experienceForNextLevel
            level += 1
            leveledUp = true
        }
        return leveledUp
    }

    func starsForBattle(mapId: Int, battleId: Int) -> Int {
        let key = "\(mapId)_\(battleId)"
        return mapStars[key] ?? 0
    }

    mutating func setStars(mapId: Int, battleId: Int, stars: Int) {
        let key = "\(mapId)_\(battleId)"
        let current = mapStars[key] ?? 0
        if stars > current {
            mapStars[key] = stars
        }
    }

    var totalStars: Int {
        mapStars.values.reduce(0, +)
    }
}
