import Foundation
import SpriteKit

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

    var color: SKColor {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return SKColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1)
        case .epic: return .purple
        case .legendary: return .orange
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
    case waist
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

    var rosterTextureName: String {
        switch self {
        case .davi:
            return "davijovem"
        case .bigJ:
            return "character_jv"
        case .josue:
            return "character_faithtech"
        default:
            return "davirei"
        }
    }

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
        case .davi:
            return CharacterStats(maxHP: 8, damageMin: 1, damageMax: 1, runSpeed: 4)
        case .bigJ:
            return CharacterStats(critChance: 0.08, critDamage: 0.20, attackSpeedBonus: 0.04)
        case .sansao:
            return CharacterStats(maxHP: 18, damageMin: 2, damageMax: 4, damageMultiplier: 0.08)
        case .josue:
            return CharacterStats(maxHP: 14, armor: 10, dodgeRanged: 0.04)
        case .debora:
            return CharacterStats(critChance: 0.04, runSpeed: 8, attackSpeedBonus: 0.12)
        case .elias:
            return CharacterStats(maxHP: 10, lifeSteal: 0.06, damageMultiplier: 0.05)
        case .gideao:
            return CharacterStats(critChance: 0.03, dodgeMelee: 0.10, dodgeRanged: 0.08)
        }
    }

    var textureName: String {
        return rawValue
    }
}

// MARK: - Food Type
enum FoodType: String, Codable, CaseIterable {
    case barleyBread
    case waterSkin
    case grapes
    case grapeJuice
    case freshFigs
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
    case running   // carregando
    case walking   // player andando até próximo inimigo
    case fighting  // em combate
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
