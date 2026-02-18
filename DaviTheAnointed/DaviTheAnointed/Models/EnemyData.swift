import Foundation

struct EnemyData: Codable {
    let id: String
    let nameKey: String
    let hp: Int
    let damageMin: Int
    let damageMax: Int
    let armor: Int
    let attackType: EnemyAttackType
    let attackSpeed: Double
    let abilities: [EnemyAbility]
    let textureName: String
    let isBoss: Bool
    let isSubBoss: Bool

    var localizedName: String {
        return LocalizationManager.shared.localize(nameKey)
    }
}

struct EnemyAbility: Codable {
    let nameKey: String
    let descriptionKey: String
    let cooldown: TimeInterval
    let damageMultiplier: Double
    let effectType: EnemyEffectType
    let effectValue: Double
    let effectDuration: TimeInterval
}

enum EnemyEffectType: String, Codable {
    case none
    case bleed          // DoT
    case poison         // DoT
    case stun           // CC
    case slow           // reduce speed
    case buffAllies     // buff nearby enemies
    case armorReduce    // debuff player armor
    case heal           // heal allies
    case block          // temporary armor boost
    case reflect        // reflect damage
    case summon         // spawn additional enemy
    case grab           // hold + continuous damage
    case ignoreArmor    // bypasses armor
}

// MARK: - Boss Phase
struct BossPhase: Codable {
    let hpThreshold: Double // 0.5 = activates below 50% HP
    let abilities: [EnemyAbility]
    let statMultiplier: Double // 1.5 = 50% more damage/speed
}

struct BossData: Codable {
    let enemy: EnemyData
    let phases: [BossPhase]
    let guaranteedDropId: String
    let goldReward: Int
    let xpReward: Int
    let rubyReward: Int
}

// MARK: - Battle Definition
struct BattleDefinition: Codable {
    let mapId: Int
    let battleId: Int
    let nameKey: String
    let enemies: [String] // enemy IDs in order
    let goldReward: Int
    let xpReward: Int
    let possibleDropIds: [String]
    let isBossBattle: Bool

    var localizedName: String {
        return LocalizationManager.shared.localize(nameKey)
    }
}

// MARK: - Map Definition
struct MapDefinition: Codable {
    let id: Int
    let nameKey: String
    let backgroundTexture: String
    let battles: [BattleDefinition]

    var localizedName: String {
        return LocalizationManager.shared.localize(nameKey)
    }
}

// MARK: - Enemy Database (Maps 1 & 2)
struct EnemyDatabase {
    static let shared = EnemyDatabase()

    let allEnemies: [String: EnemyData]
    let allBosses: [String: BossData]
    let maps: [MapDefinition]

    private init() {
        var enemies: [String: EnemyData] = [:]

        // MARK: Map 1 Enemies
        enemies["grey_wolf"] = EnemyData(
            id: "grey_wolf", nameKey: "enemy.grey_wolf", hp: 30, damageMin: 5, damageMax: 8,
            armor: 0, attackType: .melee, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.bite", descriptionKey: "ability.bite.desc",
                                     cooldown: 5, damageMultiplier: 1.2, effectType: .bleed, effectValue: 2, effectDuration: 3)],
            textureName: "enemy_grey_wolf", isBoss: false, isSubBoss: false)

        enemies["alpha_wolf"] = EnemyData(
            id: "alpha_wolf", nameKey: "enemy.alpha_wolf", hp: 50, damageMin: 8, damageMax: 12,
            armor: 2, attackType: .melee, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.howl", descriptionKey: "ability.howl.desc",
                                     cooldown: 10, damageMultiplier: 0, effectType: .buffAllies, effectValue: 0.20, effectDuration: 5)],
            textureName: "enemy_alpha_wolf", isBoss: false, isSubBoss: false)

        enemies["rabid_fox"] = EnemyData(
            id: "rabid_fox", nameKey: "enemy.rabid_fox", hp: 25, damageMin: 4, damageMax: 7,
            armor: 0, attackType: .melee, attackSpeed: 1.3,
            abilities: [], textureName: "enemy_rabid_fox", isBoss: false, isSubBoss: false)

        enemies["hungry_jackal"] = EnemyData(
            id: "hungry_jackal", nameKey: "enemy.hungry_jackal", hp: 35, damageMin: 6, damageMax: 9,
            armor: 0, attackType: .melee, attackSpeed: 1.5,
            abilities: [], textureName: "enemy_hungry_jackal", isBoss: false, isSubBoss: false)

        enemies["wild_boar"] = EnemyData(
            id: "wild_boar", nameKey: "enemy.wild_boar", hp: 60, damageMin: 10, damageMax: 14,
            armor: 3, attackType: .melee, attackSpeed: 0.8,
            abilities: [EnemyAbility(nameKey: "ability.charge", descriptionKey: "ability.charge.desc",
                                     cooldown: 8, damageMultiplier: 1.5, effectType: .stun, effectValue: 1, effectDuration: 1)],
            textureName: "enemy_wild_boar", isBoss: false, isSubBoss: false)

        enemies["venomous_snake"] = EnemyData(
            id: "venomous_snake", nameKey: "enemy.venomous_snake", hp: 20, damageMin: 3, damageMax: 5,
            armor: 0, attackType: .ranged, attackSpeed: 1.2,
            abilities: [EnemyAbility(nameKey: "ability.venom", descriptionKey: "ability.venom.desc",
                                     cooldown: 6, damageMultiplier: 1.0, effectType: .poison, effectValue: 3, effectDuration: 3)],
            textureName: "enemy_venomous_snake", isBoss: false, isSubBoss: false)

        enemies["hunting_eagle"] = EnemyData(
            id: "hunting_eagle", nameKey: "enemy.hunting_eagle", hp: 25, damageMin: 7, damageMax: 10,
            armor: 0, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.dive", descriptionKey: "ability.dive.desc",
                                     cooldown: 7, damageMultiplier: 1.8, effectType: .ignoreArmor, effectValue: 1, effectDuration: 0)],
            textureName: "enemy_hunting_eagle", isBoss: false, isSubBoss: false)

        enemies["giant_scorpion"] = EnemyData(
            id: "giant_scorpion", nameKey: "enemy.giant_scorpion", hp: 40, damageMin: 6, damageMax: 9,
            armor: 2, attackType: .melee, attackSpeed: 0.9,
            abilities: [EnemyAbility(nameKey: "ability.sting", descriptionKey: "ability.sting.desc",
                                     cooldown: 6, damageMultiplier: 1.3, effectType: .poison, effectValue: 2, effectDuration: 4)],
            textureName: "enemy_giant_scorpion", isBoss: false, isSubBoss: false)

        enemies["pack_hyena"] = EnemyData(
            id: "pack_hyena", nameKey: "enemy.pack_hyena", hp: 35, damageMin: 5, damageMax: 8,
            armor: 0, attackType: .melee, attackSpeed: 1.1,
            abilities: [EnemyAbility(nameKey: "ability.summon_pup", descriptionKey: "ability.summon_pup.desc",
                                     cooldown: 12, damageMultiplier: 0, effectType: .summon, effectValue: 1, effectDuration: 0)],
            textureName: "enemy_pack_hyena", isBoss: false, isSubBoss: false)

        enemies["hyena_pup"] = EnemyData(
            id: "hyena_pup", nameKey: "enemy.hyena_pup", hp: 15, damageMin: 3, damageMax: 5,
            armor: 0, attackType: .melee, attackSpeed: 1.3,
            abilities: [], textureName: "enemy_hyena_pup", isBoss: false, isSubBoss: false)

        // MARK: Map 2 Enemies
        enemies["bear_cub"] = EnemyData(
            id: "bear_cub", nameKey: "enemy.bear_cub", hp: 40, damageMin: 6, damageMax: 9,
            armor: 1, attackType: .melee, attackSpeed: 1.0,
            abilities: [], textureName: "enemy_bear_cub", isBoss: false, isSubBoss: false)

        enemies["philistine_scout_spear"] = EnemyData(
            id: "philistine_scout_spear", nameKey: "enemy.philistine_scout_spear", hp: 50, damageMin: 8, damageMax: 12,
            armor: 3, attackType: .melee, attackSpeed: 0.9,
            abilities: [], textureName: "enemy_philistine_spear", isBoss: false, isSubBoss: false)

        enemies["philistine_scout_bow"] = EnemyData(
            id: "philistine_scout_bow", nameKey: "enemy.philistine_scout_bow", hp: 35, damageMin: 6, damageMax: 10,
            armor: 1, attackType: .ranged, attackSpeed: 1.1,
            abilities: [], textureName: "enemy_philistine_bow", isBoss: false, isSubBoss: false)

        enemies["philistine_scout_shield"] = EnemyData(
            id: "philistine_scout_shield", nameKey: "enemy.philistine_scout_shield", hp: 70, damageMin: 5, damageMax: 8,
            armor: 8, attackType: .melee, attackSpeed: 0.7,
            abilities: [EnemyAbility(nameKey: "ability.block", descriptionKey: "ability.block.desc",
                                     cooldown: 8, damageMultiplier: 0, effectType: .block, effectValue: 10, effectDuration: 3)],
            textureName: "enemy_philistine_shield", isBoss: false, isSubBoss: false)

        enemies["philistine_soldier"] = EnemyData(
            id: "philistine_soldier", nameKey: "enemy.philistine_soldier", hp: 60, damageMin: 10, damageMax: 14,
            armor: 5, attackType: .melee, attackSpeed: 0.9,
            abilities: [], textureName: "enemy_philistine_soldier", isBoss: false, isSubBoss: false)

        enemies["philistine_archer"] = EnemyData(
            id: "philistine_archer", nameKey: "enemy.philistine_archer", hp: 40, damageMin: 8, damageMax: 12,
            armor: 2, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.fire_arrow", descriptionKey: "ability.fire_arrow.desc",
                                     cooldown: 7, damageMultiplier: 1.3, effectType: .bleed, effectValue: 3, effectDuration: 2)],
            textureName: "enemy_philistine_archer", isBoss: false, isSubBoss: false)

        enemies["philistine_elite"] = EnemyData(
            id: "philistine_elite", nameKey: "enemy.philistine_elite", hp: 80, damageMin: 12, damageMax: 18,
            armor: 7, attackType: .melee, attackSpeed: 0.8,
            abilities: [EnemyAbility(nameKey: "ability.counter", descriptionKey: "ability.counter.desc",
                                     cooldown: 0, damageMultiplier: 0.2, effectType: .reflect, effectValue: 0.20, effectDuration: 0)],
            textureName: "enemy_philistine_elite", isBoss: false, isSubBoss: false)

        enemies["philistine_healer"] = EnemyData(
            id: "philistine_healer", nameKey: "enemy.philistine_healer", hp: 45, damageMin: 4, damageMax: 6,
            armor: 2, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.heal_allies", descriptionKey: "ability.heal_allies.desc",
                                     cooldown: 5, damageMultiplier: 0, effectType: .heal, effectValue: 15, effectDuration: 0)],
            textureName: "enemy_philistine_healer", isBoss: false, isSubBoss: false)

        self.allEnemies = enemies

        // MARK: Bosses
        var bosses: [String: BossData] = [:]

        // Lion Boss (Map 1)
        let lionEnemy = EnemyData(
            id: "lion_boss", nameKey: "enemy.lion_boss", hp: 250, damageMin: 15, damageMax: 25,
            armor: 10, attackType: .melee, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.paw_swipe", descriptionKey: "ability.paw_swipe.desc",
                                     cooldown: 4, damageMultiplier: 1.3, effectType: .none, effectValue: 0, effectDuration: 0)],
            textureName: "boss_lion", isBoss: true, isSubBoss: false)

        bosses["lion_boss"] = BossData(
            enemy: lionEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [
                    EnemyAbility(nameKey: "ability.roar", descriptionKey: "ability.roar.desc",
                                 cooldown: 10, damageMultiplier: 0, effectType: .slow, effectValue: 0.15, effectDuration: 5)
                ], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.5, abilities: [
                    EnemyAbility(nameKey: "ability.death_leap", descriptionKey: "ability.death_leap.desc",
                                 cooldown: 8, damageMultiplier: 2.5, effectType: .stun, effectValue: 1, effectDuration: 1)
                ], statMultiplier: 1.5)
            ],
            guaranteedDropId: "body_04", // Lion Skin
            goldReward: 300, xpReward: 100, rubyReward: 0)

        // Bear Sub-Boss (Map 2, Battle 1)
        let bearEnemy = EnemyData(
            id: "brown_bear", nameKey: "enemy.brown_bear", hp: 180, damageMin: 12, damageMax: 20,
            armor: 5, attackType: .melee, attackSpeed: 0.8,
            abilities: [
                EnemyAbility(nameKey: "ability.bear_hug", descriptionKey: "ability.bear_hug.desc",
                             cooldown: 10, damageMultiplier: 0.5, effectType: .grab, effectValue: 5, effectDuration: 3),
                EnemyAbility(nameKey: "ability.claw_strike", descriptionKey: "ability.claw_strike.desc",
                             cooldown: 6, damageMultiplier: 1.5, effectType: .armorReduce, effectValue: 5, effectDuration: 8)
            ],
            textureName: "boss_bear", isBoss: false, isSubBoss: true)

        bosses["brown_bear"] = BossData(
            enemy: bearEnemy, phases: [],
            guaranteedDropId: "", goldReward: 200, xpReward: 60, rubyReward: 0)

        // Goliath Boss (Map 2)
        let goliathEnemy = EnemyData(
            id: "goliath", nameKey: "enemy.goliath", hp: 500, damageMin: 25, damageMax: 40,
            armor: 20, attackType: .melee, attackSpeed: 0.6,
            abilities: [EnemyAbility(nameKey: "ability.spear_throw", descriptionKey: "ability.spear_throw.desc",
                                     cooldown: 6, damageMultiplier: 2.0, effectType: .none, effectValue: 0, effectDuration: 0)],
            textureName: "boss_goliath", isBoss: true, isSubBoss: false)

        bosses["goliath"] = BossData(
            enemy: goliathEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [
                    EnemyAbility(nameKey: "ability.giant_shield", descriptionKey: "ability.giant_shield.desc",
                                 cooldown: 12, damageMultiplier: 0, effectType: .block, effectValue: 50, effectDuration: 3)
                ], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.6, abilities: [
                    EnemyAbility(nameKey: "ability.stomp", descriptionKey: "ability.stomp.desc",
                                 cooldown: 10, damageMultiplier: 1.8, effectType: .stun, effectValue: 1, effectDuration: 2)
                ], statMultiplier: 1.15),
                BossPhase(hpThreshold: 0.3, abilities: [
                    EnemyAbility(nameKey: "ability.giant_fury", descriptionKey: "ability.giant_fury.desc",
                                 cooldown: 8, damageMultiplier: 2.5, effectType: .none, effectValue: 0, effectDuration: 0)
                ], statMultiplier: 1.3)
            ],
            guaranteedDropId: "twohand_06", // Goliath's Sword
            goldReward: 500, xpReward: 200, rubyReward: 5)

        self.allBosses = bosses

        // MARK: Map Definitions
        let map1 = MapDefinition(id: 1, nameKey: "map.bethlehem_fields", backgroundTexture: "bg_bethlehem", battles: [
            BattleDefinition(mapId: 1, battleId: 1, nameKey: "battle.wolf_pack",
                             enemies: ["grey_wolf", "grey_wolf", "alpha_wolf"],
                             goldReward: 50, xpReward: 20, possibleDropIds: ["feet_02"], isBossBattle: false),
            BattleDefinition(mapId: 1, battleId: 2, nameKey: "battle.night_invaders",
                             enemies: ["rabid_fox", "hungry_jackal", "wild_boar", "venomous_snake"],
                             goldReward: 80, xpReward: 30, possibleDropIds: ["head_02"], isBossBattle: false),
            BattleDefinition(mapId: 1, battleId: 3, nameKey: "battle.mountain_trail",
                             enemies: ["hunting_eagle", "giant_scorpion", "pack_hyena", "pack_hyena"],
                             goldReward: 100, xpReward: 40, possibleDropIds: ["weapon_02"], isBossBattle: false),
            BattleDefinition(mapId: 1, battleId: 4, nameKey: "battle.lion_boss",
                             enemies: ["lion_boss"],
                             goldReward: 300, xpReward: 100, possibleDropIds: ["body_04"], isBossBattle: true),
        ])

        let map2 = MapDefinition(id: 2, nameKey: "map.valley_of_elah", backgroundTexture: "bg_valley_elah", battles: [
            BattleDefinition(mapId: 2, battleId: 1, nameKey: "battle.mountain_bear",
                             enemies: ["bear_cub", "bear_cub", "brown_bear"],
                             goldReward: 200, xpReward: 60, possibleDropIds: [], isBossBattle: false),
            BattleDefinition(mapId: 2, battleId: 2, nameKey: "battle.philistine_scouts",
                             enemies: ["philistine_scout_spear", "philistine_scout_bow", "philistine_scout_shield", "philistine_scout_spear"],
                             goldReward: 150, xpReward: 50, possibleDropIds: ["head_05"], isBossBattle: false),
            BattleDefinition(mapId: 2, battleId: 3, nameKey: "battle.advance_guard",
                             enemies: ["philistine_soldier", "philistine_archer", "philistine_elite", "philistine_healer"],
                             goldReward: 200, xpReward: 70, possibleDropIds: ["weapon_06"], isBossBattle: false),
            BattleDefinition(mapId: 2, battleId: 4, nameKey: "battle.goliath_boss",
                             enemies: ["goliath"],
                             goldReward: 500, xpReward: 200, possibleDropIds: ["twohand_06"], isBossBattle: true),
        ])

        self.maps = [map1, map2]
    }

    func enemy(withId id: String) -> EnemyData? {
        return allEnemies[id]
    }

    func boss(withId id: String) -> BossData? {
        return allBosses[id]
    }

    func map(withId id: Int) -> MapDefinition? {
        return maps.first { $0.id == id }
    }
}
