import Foundation

// MARK: - Language
enum GameLanguage: String, Codable, CaseIterable {
    case portuguese = "pt-BR"
    case english = "en"

    var displayName: String {
        switch self {
        case .portuguese: return "Português (BR)"
        case .english: return "English"
        }
    }
}

// MARK: - Item Rarity
enum ItemRarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var color: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "gold"
        }
    }

    var bonusAttributes: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }

    var dropChance: Double {
        switch self {
        case .common: return 0.60
        case .uncommon: return 0.25
        case .rare: return 0.10
        case .epic: return 0.04
        case .legendary: return 0.01
        }
    }
}

// MARK: - Equipment Slot
enum EquipmentSlot: String, Codable, CaseIterable {
    case head
    case body
    case feet
    case mainHand
    case offHand
    case twoHand
    case ring1
    case ring2
    case necklace
    case gloves
}

// MARK: - Enemy Type
enum EnemyAttackType: String, Codable {
    case melee
    case ranged
}

// MARK: - Character ID
enum PlayableCharacter: String, Codable, CaseIterable {
    case davi
    case bigJ
    case sansao
    case josue
    case debora
    case elias
    case gideao

    var price: Int {
        switch self {
        case .davi: return 0
        case .bigJ: return 10_000
        case .sansao: return 15_000
        case .josue: return 25_000
        case .debora: return 30_000
        case .elias: return 40_000
        case .gideao: return 50_000
        }
    }

    var requiredMap: Int {
        switch self {
        case .davi: return 0
        case .bigJ: return 1
        case .sansao: return 2
        case .josue: return 3
        case .debora: return 4
        case .elias: return 5
        case .gideao: return 6
        }
    }

    var passiveBonus: CharacterStats {
        switch self {
        case .davi: return CharacterStats()
        case .bigJ: return CharacterStats(critChance: 0.05)
        case .sansao: return CharacterStats(damageMultiplier: 0.10)
        case .josue: return CharacterStats(armor: 8)
        case .debora: return CharacterStats(attackSpeedBonus: 0.10)
        case .elias: return CharacterStats(lifeSteal: 0.08)
        case .gideao: return CharacterStats(dodgeMelee: 0.12)
        }
    }

    var textureName: String {
        return rawValue
    }
}

// MARK: - Food Type
enum FoodType: String, Codable, CaseIterable {
    case barleyBread
    case grapes
    case driedFigs
    case olives
    case honeyBread
    case pomegranate
    case goatCheese
    case dates
    case cookedLentils
    case roastedFish
    case raisinCake
    case roastedLamb
    case manna
    case kingsFeast
    case celestialBanquet
}

// MARK: - Bonus Card Rarity
enum CardRarity: String, Codable {
    case common
    case uncommon
    case rare
    case epic
}

// MARK: - Battle State
enum BattleState {
    case idle
    case running
    case fighting
    case victory
    case defeat
    case paused
}

// MARK: - Scene Transition
enum GameScene {
    case languageSelection
    case login
    case mainMenu
    case overworld
    case battle(mapId: Int, battleId: Int)
    case inventory
    case shop
    case ranking
    case pvp
    case clan
    case challenges
    case settings
}
