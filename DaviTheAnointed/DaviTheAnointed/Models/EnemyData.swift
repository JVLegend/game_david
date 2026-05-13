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
            textureName: "lobocinzento", isBoss: false, isSubBoss: false)

        enemies["alpha_wolf"] = EnemyData(
            id: "alpha_wolf", nameKey: "enemy.alpha_wolf", hp: 50, damageMin: 8, damageMax: 12,
            armor: 2, attackType: .melee, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.howl", descriptionKey: "ability.howl.desc",
                                     cooldown: 10, damageMultiplier: 0, effectType: .buffAllies, effectValue: 0.20, effectDuration: 5)],
            textureName: "lobocinzento", isBoss: false, isSubBoss: false)

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

        // MARK: Map 3 Enemies
        enemies["saul_guard"] = EnemyData(
            id: "saul_guard", nameKey: "enemy.saul_guard", hp: 90, damageMin: 12, damageMax: 18,
            armor: 6, attackType: .melee, attackSpeed: 0.9,
            abilities: [], textureName: "enemy_saul_guard", isBoss: false, isSubBoss: false)

        enemies["saul_archer"] = EnemyData(
            id: "saul_archer", nameKey: "enemy.saul_archer", hp: 60, damageMin: 10, damageMax: 15,
            armor: 3, attackType: .ranged, attackSpeed: 1.1,
            abilities: [], textureName: "enemy_saul_archer", isBoss: false, isSubBoss: false)

        enemies["saul_spearman"] = EnemyData(
            id: "saul_spearman", nameKey: "enemy.saul_spearman", hp: 110, damageMin: 15, damageMax: 22,
            armor: 8, attackType: .melee, attackSpeed: 0.8,
            abilities: [], textureName: "enemy_saul_spearman", isBoss: false, isSubBoss: false)

        enemies["saul_advisor"] = EnemyData(
            id: "saul_advisor", nameKey: "enemy.saul_advisor", hp: 75, damageMin: 8, damageMax: 12,
            armor: 4, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.heal_allies", descriptionKey: "ability.heal_allies.desc",
                                     cooldown: 8, damageMultiplier: 0, effectType: .heal, effectValue: 25, effectDuration: 0)],
            textureName: "enemy_saul_advisor", isBoss: false, isSubBoss: false)

        // MARK: Map 4 Enemies
        enemies["desert_bandit"] = EnemyData(
            id: "desert_bandit", nameKey: "enemy.desert_bandit", hp: 130, damageMin: 18, damageMax: 28,
            armor: 10, attackType: .melee, attackSpeed: 1.0,
            abilities: [], textureName: "enemy_desert_bandit", isBoss: false, isSubBoss: false)

        enemies["bandit_archer"] = EnemyData(
            id: "bandit_archer", nameKey: "enemy.bandit_archer", hp: 90, damageMin: 15, damageMax: 25,
            armor: 5, attackType: .ranged, attackSpeed: 1.1,
            abilities: [], textureName: "enemy_bandit_archer", isBoss: false, isSubBoss: false)

        enemies["giant_spider"] = EnemyData(
            id: "giant_spider", nameKey: "enemy.giant_spider", hp: 150, damageMin: 22, damageMax: 35,
            armor: 12, attackType: .melee, attackSpeed: 0.8,
            abilities: [EnemyAbility(nameKey: "ability.venom", descriptionKey: "ability.venom.desc",
                                     cooldown: 7, damageMultiplier: 1.2, effectType: .poison, effectValue: 5, effectDuration: 4)],
            textureName: "enemy_giant_spider", isBoss: false, isSubBoss: false)

        enemies["desert_stalker"] = EnemyData(
            id: "desert_stalker", nameKey: "enemy.desert_stalker", hp: 120, damageMin: 25, damageMax: 40,
            armor: 8, attackType: .melee, attackSpeed: 1.2,
            abilities: [EnemyAbility(nameKey: "ability.stun_strike", descriptionKey: "ability.stun_strike.desc",
                                     cooldown: 10, damageMultiplier: 1.5, effectType: .stun, effectValue: 1, effectDuration: 1.5)],
            textureName: "enemy_desert_stalker", isBoss: false, isSubBoss: false)

        // MARK: Map 5 Enemies
        enemies["philistine_heavy_guard"] = EnemyData(
            id: "philistine_heavy_guard", nameKey: "enemy.philistine_heavy_guard", hp: 180, damageMin: 25, damageMax: 40,
            armor: 20, attackType: .melee, attackSpeed: 0.7,
            abilities: [], textureName: "enemy_philistine_heavy_guard", isBoss: false, isSubBoss: false)

        enemies["philistine_war_archer"] = EnemyData(
            id: "philistine_war_archer", nameKey: "enemy.philistine_war_archer", hp: 140, damageMin: 20, damageMax: 35,
            armor: 10, attackType: .ranged, attackSpeed: 1.0,
            abilities: [], textureName: "enemy_philistine_war_archer", isBoss: false, isSubBoss: false)

        enemies["philistine_giant"] = EnemyData(
            id: "philistine_giant", nameKey: "enemy.philistine_giant", hp: 300, damageMin: 35, damageMax: 55,
            armor: 15, attackType: .melee, attackSpeed: 0.6,
            abilities: [EnemyAbility(nameKey: "ability.ground_slam", descriptionKey: "ability.ground_slam.desc",
                                     cooldown: 12, damageMultiplier: 1.8, effectType: .stun, effectValue: 1, effectDuration: 2)],
            textureName: "enemy_philistine_giant", isBoss: false, isSubBoss: false)

        enemies["philistine_priest"] = EnemyData(
            id: "philistine_priest", nameKey: "enemy.philistine_priest", hp: 150, damageMin: 15, damageMax: 25,
            armor: 12, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.curse", descriptionKey: "ability.curse.desc",
                                     cooldown: 9, damageMultiplier: 0, effectType: .armorReduce, effectValue: 10, effectDuration: 10)],
            textureName: "enemy_philistine_priest", isBoss: false, isSubBoss: false)

        // MARK: Map 6 Enemies
        enemies["jebusite_defender"] = EnemyData(
            id: "jebusite_defender", nameKey: "enemy.jebusite_defender", hp: 250, damageMin: 35, damageMax: 50,
            armor: 30, attackType: .melee, attackSpeed: 0.7,
            abilities: [EnemyAbility(nameKey: "ability.block", descriptionKey: "ability.block.desc",
                                     cooldown: 10, damageMultiplier: 0, effectType: .block, effectValue: 20, effectDuration: 5)],
            textureName: "enemy_jebusite_defender", isBoss: false, isSubBoss: false)

        enemies["jebusite_slinger"] = EnemyData(
            id: "jebusite_slinger", nameKey: "enemy.jebusite_slinger", hp: 180, damageMin: 30, damageMax: 45,
            armor: 15, attackType: .ranged, attackSpeed: 1.2,
            abilities: [], textureName: "enemy_jebusite_slinger", isBoss: false, isSubBoss: false)

        enemies["jebusite_elite"] = EnemyData(
            id: "jebusite_elite", nameKey: "enemy.jebusite_elite", hp: 350, damageMin: 45, damageMax: 70,
            armor: 25, attackType: .melee, attackSpeed: 0.8,
            abilities: [], textureName: "enemy_jebusite_elite", isBoss: false, isSubBoss: false)

        enemies["jebusite_shaman"] = EnemyData(
            id: "jebusite_shaman", nameKey: "enemy.jebusite_shaman", hp: 200, damageMin: 25, damageMax: 40,
            armor: 20, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.ancestral_buff", descriptionKey: "ability.ancestral_buff.desc",
                                     cooldown: 15, damageMultiplier: 0, effectType: .buffAllies, effectValue: 0.30, effectDuration: 8)],
            textureName: "enemy_jebusite_shaman", isBoss: false, isSubBoss: false)

        // MARK: Map 7 Enemies
        enemies["absalom_rebel"] = EnemyData(
            id: "absalom_rebel", nameKey: "enemy.absalom_rebel", hp: 400, damageMin: 50, damageMax: 80,
            armor: 40, attackType: .melee, attackSpeed: 0.9,
            abilities: [], textureName: "enemy_absalom_rebel", isBoss: false, isSubBoss: false)

        enemies["absalom_assassin"] = EnemyData(
            id: "absalom_assassin", nameKey: "enemy.absalom_assassin", hp: 300, damageMin: 70, damageMax: 110,
            armor: 25, attackType: .melee, attackSpeed: 1.3,
            abilities: [EnemyAbility(nameKey: "ability.backstab", descriptionKey: "ability.backstab.desc",
                                     cooldown: 6, damageMultiplier: 2.0, effectType: .bleed, effectValue: 10, effectDuration: 3)],
            textureName: "enemy_absalom_assassin", isBoss: false, isSubBoss: false)

        enemies["absalom_knight"] = EnemyData(
            id: "absalom_knight", nameKey: "enemy.absalom_knight", hp: 500, damageMin: 60, damageMax: 100,
            armor: 50, attackType: .melee, attackSpeed: 0.7,
            abilities: [], textureName: "enemy_absalom_knight", isBoss: false, isSubBoss: false)

        enemies["absalom_tactician"] = EnemyData(
            id: "absalom_tactician", nameKey: "enemy.absalom_tactician", hp: 350, damageMin: 40, damageMax: 70,
            armor: 35, attackType: .ranged, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.disorient", descriptionKey: "ability.disorient.desc",
                                     cooldown: 12, damageMultiplier: 1.0, effectType: .stun, effectValue: 2, effectDuration: 2)],
            textureName: "enemy_absalom_tactician", isBoss: false, isSubBoss: false)

        self.allEnemies = enemies

        // MARK: Bosses
        var bosses: [String: BossData] = [:]

        // Lion Boss (Map 1)
        let lionEnemy = EnemyData(
            id: "lion_boss", nameKey: "enemy.lion_boss", hp: 250, damageMin: 15, damageMax: 25,
            armor: 10, attackType: .melee, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.paw_swipe", descriptionKey: "ability.paw_swipe.desc",
                                     cooldown: 4, damageMultiplier: 1.3, effectType: .none, effectValue: 0, effectDuration: 0)],
            textureName: "leao", isBoss: true, isSubBoss: false)

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

        // Saul Mad Boss (Map 3)
        let saulEnemy = EnemyData(
            id: "saul_mad", nameKey: "enemy.saul_mad", hp: 800, damageMin: 35, damageMax: 55,
            armor: 25, attackType: .melee, attackSpeed: 0.9,
            abilities: [EnemyAbility(nameKey: "ability.javelin_throw", descriptionKey: "ability.javelin_throw.desc",
                                     cooldown: 6, damageMultiplier: 1.5, effectType: .none, effectValue: 0, effectDuration: 0)],
            textureName: "boss_saul", isBoss: true, isSubBoss: false)

        bosses["saul_mad"] = BossData(
            enemy: saulEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.5, abilities: [
                    EnemyAbility(nameKey: "ability.mad_fury", descriptionKey: "ability.mad_fury.desc",
                                 cooldown: 15, damageMultiplier: 0, effectType: .none, effectValue: 0, effectDuration: 0)
                ], statMultiplier: 1.4)
            ],
            guaranteedDropId: "head_08", // Coroa de Bronze
            goldReward: 800, xpReward: 400, rubyReward: 5)

        // Saul's General (Map 4)
        let generalEnemy = EnemyData(
            id: "saul_general", nameKey: "enemy.saul_general", hp: 1200, damageMin: 45, damageMax: 70,
            armor: 35, attackType: .melee, attackSpeed: 0.8,
            abilities: [EnemyAbility(nameKey: "ability.strategic_strike", descriptionKey: "ability.strategic_strike.desc",
                                     cooldown: 8, damageMultiplier: 2.0, effectType: .armorReduce, effectValue: 10, effectDuration: 5)],
            textureName: "boss_general", isBoss: true, isSubBoss: false)

        bosses["saul_general"] = BossData(
            enemy: generalEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.4, abilities: [
                    EnemyAbility(nameKey: "ability.call_reinforcements", descriptionKey: "ability.call_reinforcements.desc",
                                 cooldown: 20, damageMultiplier: 0, effectType: .summon, effectValue: 1, effectDuration: 0)
                ], statMultiplier: 1.25)
            ],
            guaranteedDropId: "body_13", // Armadura do General
            goldReward: 1200, xpReward: 700, rubyReward: 10)

        // Philistine Prince (Map 5)
        let princeEnemy = EnemyData(
            id: "philistine_prince", nameKey: "enemy.philistine_prince", hp: 2000, damageMin: 60, damageMax: 90,
            armor: 45, attackType: .melee, attackSpeed: 0.7,
            abilities: [EnemyAbility(nameKey: "ability.prince_slash", descriptionKey: "ability.prince_slash.desc",
                                     cooldown: 5, damageMultiplier: 1.8, effectType: .bleed, effectValue: 15, effectDuration: 4)],
            textureName: "boss_prince", isBoss: true, isSubBoss: false)

        bosses["philistine_prince"] = BossData(
            enemy: princeEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.5, abilities: [
                    EnemyAbility(nameKey: "ability.royal_pride", descriptionKey: "ability.royal_pride.desc",
                                 cooldown: 12, damageMultiplier: 0, effectType: .block, effectValue: 100, effectDuration: 5)
                ], statMultiplier: 1.3)
            ],
            guaranteedDropId: "head_10", // Capacete Real de Prata
            goldReward: 2000, xpReward: 1200, rubyReward: 15)

        // Jebusite Commander (Map 6)
        let commanderEnemy = EnemyData(
            id: "jebusite_commander", nameKey: "enemy.jebusite_commander", hp: 3000, damageMin: 80, damageMax: 120,
            armor: 55, attackType: .melee, attackSpeed: 0.6,
            abilities: [EnemyAbility(nameKey: "ability.commander_impale", descriptionKey: "ability.commander_impale.desc",
                                     cooldown: 10, damageMultiplier: 3.0, effectType: .stun, effectValue: 2, effectDuration: 2)],
            textureName: "boss_commander", isBoss: true, isSubBoss: false)

        bosses["jebusite_commander"] = BossData(
            enemy: commanderEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.3, abilities: [
                    EnemyAbility(nameKey: "ability.fortress_wall", descriptionKey: "ability.fortress_wall.desc",
                                 cooldown: 0, damageMultiplier: 0.5, effectType: .reflect, effectValue: 0.40, effectDuration: 0)
                ], statMultiplier: 1.5)
            ],
            guaranteedDropId: "shield_11", // Escudo do General
            goldReward: 3500, xpReward: 2000, rubyReward: 20)

        // Absalom (Map 7)
        let absalomEnemy = EnemyData(
            id: "absalom", nameKey: "enemy.absalom", hp: 5000, damageMin: 120, damageMax: 180,
            armor: 70, attackType: .melee, attackSpeed: 1.0,
            abilities: [EnemyAbility(nameKey: "ability.rebel_charge", descriptionKey: "ability.rebel_charge.desc",
                                     cooldown: 8, damageMultiplier: 2.2, effectType: .none, effectValue: 0, effectDuration: 0)],
            textureName: "boss_absalom", isBoss: true, isSubBoss: false)

        bosses["absalom"] = BossData(
            enemy: absalomEnemy,
            phases: [
                BossPhase(hpThreshold: 1.0, abilities: [], statMultiplier: 1.0),
                BossPhase(hpThreshold: 0.6, abilities: [
                    EnemyAbility(nameKey: "ability.golden_locks", descriptionKey: "ability.golden_locks.desc",
                                 cooldown: 15, damageMultiplier: 0, effectType: .stun, effectValue: 3, effectDuration: 3)
                ], statMultiplier: 1.2),
                BossPhase(hpThreshold: 0.2, abilities: [
                    EnemyAbility(nameKey: "ability.throne_claim", descriptionKey: "ability.throne_claim.desc",
                                 cooldown: 0, damageMultiplier: 0.5, effectType: .heal, effectValue: 1000, effectDuration: 0)
                ], statMultiplier: 1.8)
            ],
            guaranteedDropId: "weapon_15", // Espada do Rei Davi
            goldReward: 6000, xpReward: 4000, rubyReward: 50)

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

        let map3 = MapDefinition(id: 3, nameKey: "map.saul_court", backgroundTexture: "bg_saul_court", battles: [
            BattleDefinition(mapId: 3, battleId: 1, nameKey: "battle.royal_hall",
                             enemies: ["saul_guard", "saul_guard", "saul_archer"],
                             goldReward: 250, xpReward: 100, possibleDropIds: ["ring_02"], isBossBattle: false),
            BattleDefinition(mapId: 3, battleId: 2, nameKey: "battle.conspiracy",
                             enemies: ["saul_guard", "saul_spearman", "saul_advisor"],
                             goldReward: 300, xpReward: 150, possibleDropIds: ["head_06"], isBossBattle: false),
            BattleDefinition(mapId: 3, battleId: 3, nameKey: "battle.betrayal",
                             enemies: ["saul_spearman", "saul_spearman", "saul_advisor", "saul_guard"],
                             goldReward: 400, xpReward: 200, possibleDropIds: ["weapon_07"], isBossBattle: false),
            BattleDefinition(mapId: 3, battleId: 4, nameKey: "battle.saul_boss",
                             enemies: ["saul_mad"],
                             goldReward: 800, xpReward: 400, possibleDropIds: ["head_08"], isBossBattle: true),
        ])

        let map4 = MapDefinition(id: 4, nameKey: "map.en_gedi", backgroundTexture: "bg_en_gedi", battles: [
            BattleDefinition(mapId: 4, battleId: 1, nameKey: "battle.burning_dunes",
                             enemies: ["desert_bandit", "desert_bandit", "bandit_archer"],
                             goldReward: 450, xpReward: 300, possibleDropIds: ["feet_09"], isBossBattle: false),
            BattleDefinition(mapId: 4, battleId: 2, nameKey: "battle.cave_path",
                             enemies: ["giant_spider", "giant_spider", "desert_stalker"],
                             goldReward: 500, xpReward: 350, possibleDropIds: ["head_07"], isBossBattle: false),
            BattleDefinition(mapId: 4, battleId: 3, nameKey: "battle.en_gedi_oasis",
                             enemies: ["desert_bandit", "bandit_archer", "desert_stalker", "giant_spider"],
                             goldReward: 600, xpReward: 400, possibleDropIds: ["weapon_09"], isBossBattle: false),
            BattleDefinition(mapId: 4, battleId: 4, nameKey: "battle.general_boss",
                             enemies: ["saul_general"],
                             goldReward: 1200, xpReward: 700, possibleDropIds: ["body_13"], isBossBattle: true),
        ])

        let map5 = MapDefinition(id: 5, nameKey: "map.philistine_land", backgroundTexture: "bg_philistine_land", battles: [
            BattleDefinition(mapId: 5, battleId: 1, nameKey: "battle.philistine_border",
                             enemies: ["philistine_heavy_guard", "philistine_heavy_guard", "philistine_war_archer"],
                             goldReward: 700, xpReward: 500, possibleDropIds: ["head_05"], isBossBattle: false),
            BattleDefinition(mapId: 5, battleId: 2, nameKey: "battle.road_to_gath",
                             enemies: ["philistine_giant", "philistine_war_archer", "philistine_priest"],
                             goldReward: 800, xpReward: 600, possibleDropIds: ["body_08"], isBossBattle: false),
            BattleDefinition(mapId: 5, battleId: 3, nameKey: "battle.war_camp",
                             enemies: ["philistine_heavy_guard", "philistine_giant", "philistine_priest", "philistine_war_archer"],
                             goldReward: 1000, xpReward: 800, possibleDropIds: ["weapon_08"], isBossBattle: false),
            BattleDefinition(mapId: 5, battleId: 4, nameKey: "battle.prince_boss",
                             enemies: ["philistine_prince"],
                             goldReward: 2000, xpReward: 1200, possibleDropIds: ["head_10"], isBossBattle: true),
        ])

        let map6 = MapDefinition(id: 6, nameKey: "map.jerusalem_siege", backgroundTexture: "bg_jerusalem_siege", battles: [
            BattleDefinition(mapId: 6, battleId: 1, nameKey: "battle.jebus_walls",
                             enemies: ["jebusite_defender", "jebusite_defender", "jebusite_slinger"],
                             goldReward: 1200, xpReward: 1000, possibleDropIds: ["feet_12"], isBossBattle: false),
            BattleDefinition(mapId: 6, battleId: 2, nameKey: "battle.water_tunnels",
                             enemies: ["jebusite_elite", "jebusite_slinger", "jebusite_shaman"],
                             goldReward: 1500, xpReward: 1200, possibleDropIds: ["head_12"], isBossBattle: false),
            BattleDefinition(mapId: 6, battleId: 3, nameKey: "battle.city_gates",
                             enemies: ["jebusite_defender", "jebusite_elite", "jebusite_shaman", "jebusite_slinger"],
                             goldReward: 2000, xpReward: 1500, possibleDropIds: ["weapon_11"], isBossBattle: false),
            BattleDefinition(mapId: 6, battleId: 4, nameKey: "battle.commander_boss",
                             enemies: ["jebusite_commander"],
                             goldReward: 3500, xpReward: 2000, possibleDropIds: ["shield_11"], isBossBattle: true),
        ])

        let map7 = MapDefinition(id: 7, nameKey: "map.throne_israel", backgroundTexture: "bg_throne_israel", battles: [
            BattleDefinition(mapId: 7, battleId: 1, nameKey: "battle.jerusalem_rebellion",
                             enemies: ["absalom_rebel", "absalom_rebel", "absalom_assassin"],
                             goldReward: 3000, xpReward: 2500, possibleDropIds: ["ring_13"], isBossBattle: false),
            BattleDefinition(mapId: 7, battleId: 2, nameKey: "battle.kidron_path",
                             enemies: ["absalom_knight", "absalom_assassin", "absalom_tactician"],
                             goldReward: 3500, xpReward: 3000, possibleDropIds: ["head_15"], isBossBattle: false),
            BattleDefinition(mapId: 7, battleId: 3, nameKey: "battle.civil_war",
                             enemies: ["absalom_rebel", "absalom_knight", "absalom_tactician", "absalom_assassin"],
                             goldReward: 4500, xpReward: 3500, possibleDropIds: ["body_15"], isBossBattle: false),
            BattleDefinition(mapId: 7, battleId: 4, nameKey: "battle.absalom_boss",
                             enemies: ["absalom"],
                             goldReward: 6000, xpReward: 4000, possibleDropIds: ["weapon_15"], isBossBattle: true),
        ])

        self.maps = [map1, map2, map3, map4, map5, map6, map7]
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
