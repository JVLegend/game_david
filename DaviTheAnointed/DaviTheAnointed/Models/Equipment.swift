import Foundation

struct Equipment: Codable, Identifiable {
    let id: String
    let nameKey: String // localization key
    let slot: EquipmentSlot
    let rarity: ItemRarity
    let stats: CharacterStats
    let price: Int
    let minLevel: Int
    let textureName: String

    var localizedName: String {
        return LocalizationManager.shared.localize(nameKey)
    }
}

// MARK: - Equipment Database
struct EquipmentDatabase {
    static let shared = EquipmentDatabase()

    let allItems: [Equipment]

    private init() {
        var items: [Equipment] = []

        // MARK: - HEAD (15 items)
        items.append(contentsOf: [
            Equipment(id: "head_01", nameKey: "item.head.pastor_band", slot: .head, rarity: .common,
                      stats: CharacterStats(maxHP: 8, armor: 2), price: 80, minLevel: 1, textureName: "head_01"),
            Equipment(id: "head_02", nameKey: "item.head.simple_headband", slot: .head, rarity: .common,
                      stats: CharacterStats(maxHP: 6, armor: 3, dodgeMelee: 0.03), price: 140, minLevel: 1, textureName: "head_02"),
            Equipment(id: "head_03", nameKey: "item.head.leather_hood", slot: .head, rarity: .common,
                      stats: CharacterStats(maxHP: 14, armor: 5), price: 300, minLevel: 2, textureName: "head_03"),
            Equipment(id: "head_04", nameKey: "item.head.light_bronze_helm", slot: .head, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 8, armor: 9, dodgeRanged: 0.03), price: 520, minLevel: 3, textureName: "head_04"),
            Equipment(id: "head_05", nameKey: "item.head.philistine_bronze_helm", slot: .head, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 18, critChance: 0.05, armor: 10), price: 800, minLevel: 4, textureName: "head_05"),
            Equipment(id: "head_06", nameKey: "item.head.simple_iron_helmet", slot: .head, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 12, armor: 16), price: 1150, minLevel: 5, textureName: "head_06"),
            Equipment(id: "head_07", nameKey: "item.head.desert_helm", slot: .head, rarity: .rare,
                      stats: CharacterStats(maxHP: 22, armor: 14, dodgeRanged: 0.05), price: 1550, minLevel: 6, textureName: "head_07"),
            Equipment(id: "head_08", nameKey: "item.head.bronze_crown", slot: .head, rarity: .rare,
                      stats: CharacterStats(maxHP: 18, critChance: 0.07, armor: 18, lifeSteal: 0.03), price: 2100, minLevel: 7, textureName: "head_08"),
            Equipment(id: "head_09", nameKey: "item.head.warrior_helm", slot: .head, rarity: .rare,
                      stats: CharacterStats(maxHP: 15, armor: 18), price: 3000, minLevel: 12, textureName: "head_09"),
            Equipment(id: "head_10", nameKey: "item.head.royal_silver_helmet", slot: .head, rarity: .epic,
                      stats: CharacterStats(critDamage: 0.05, armor: 14, dodgeMelee: 0.08), price: 4500, minLevel: 15, textureName: "head_10"),
            Equipment(id: "head_11", nameKey: "item.head.faith_helm", slot: .head, rarity: .epic,
                      stats: CharacterStats(maxHP: 20, armor: 11, dodgeRanged: 0.08), price: 5500, minLevel: 17, textureName: "head_11"),
            Equipment(id: "head_12", nameKey: "item.head.anointed_iron_crown", slot: .head, rarity: .epic,
                      stats: CharacterStats(critChance: 0.10, armor: 21), price: 7000, minLevel: 20, textureName: "head_12"),
            Equipment(id: "head_13", nameKey: "item.head.goliath_helm_adapted", slot: .head, rarity: .epic,
                      stats: CharacterStats(maxHP: 10, armor: 26, runSpeed: -7.5), price: 9000, minLevel: 22, textureName: "head_13"),
            Equipment(id: "head_14", nameKey: "item.head.seraph_helmet", slot: .head, rarity: .legendary,
                      stats: CharacterStats(maxHP: 25, armor: 15, dodgeMelee: 0.10, lifeSteal: 0.05), price: 12000, minLevel: 25, textureName: "head_14"),
            Equipment(id: "head_15", nameKey: "item.head.crown_of_the_anointed", slot: .head, rarity: .legendary,
                      stats: CharacterStats(maxHP: 30, critChance: 0.12, armor: 30), price: 18000, minLevel: 30, textureName: "head_15"),
        ])

        // MARK: - MAIN HAND (15 items)
        items.append(contentsOf: [
            Equipment(id: "weapon_01", nameKey: "item.weapon.shepherd_staff", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 2, damageMax: 4), price: 0, minLevel: 1, textureName: "weapon_01"),
            Equipment(id: "weapon_02", nameKey: "item.weapon.reinforced_staff", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 4, damageMax: 7, critChance: 0.03), price: 160, minLevel: 1, textureName: "weapon_02"),
            Equipment(id: "weapon_03", nameKey: "item.weapon.shearing_knife", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 5, damageMax: 9, attackSpeedBonus: 0.05), price: 320, minLevel: 2, textureName: "weapon_03"),
            Equipment(id: "weapon_04", nameKey: "item.weapon.wooden_club", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 8, damageMin: 7, damageMax: 11, critChance: 0.05), price: 620, minLevel: 3, textureName: "weapon_04"),
            Equipment(id: "weapon_05", nameKey: "item.weapon.bronze_dagger", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 8, damageMax: 13, critChance: 0.05, attackSpeedBonus: 0.08), price: 900, minLevel: 4, textureName: "weapon_05"),
            Equipment(id: "weapon_06", nameKey: "item.weapon.short_bronze_sword", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 10, damageMax: 16, critChance: 0.05, lifeSteal: 0.03), price: 1350, minLevel: 5, textureName: "weapon_06"),
            Equipment(id: "weapon_07", nameKey: "item.weapon.iron_mace", slot: .mainHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 12, damageMax: 19, critDamage: 0.15), price: 2200, minLevel: 6, textureName: "weapon_07"),
            Equipment(id: "weapon_08", nameKey: "item.weapon.philistine_sword", slot: .mainHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 14, damageMax: 22, critChance: 0.08, attackSpeedBonus: 0.05), price: 3200, minLevel: 7, textureName: "weapon_08"),
            Equipment(id: "weapon_09", nameKey: "item.weapon.desert_scimitar", slot: .mainHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 13, damageMax: 19, lifeSteal: 0.03, attackSpeedBonus: 0.10), price: 4800, minLevel: 13, textureName: "weapon_09"),
            Equipment(id: "weapon_10", nameKey: "item.weapon.iron_sword", slot: .mainHand, rarity: .epic,
                      stats: CharacterStats(damageMin: 15, damageMax: 22, critChance: 0.10, critDamage: 0.15), price: 6500, minLevel: 16, textureName: "weapon_10"),
            Equipment(id: "weapon_11", nameKey: "item.weapon.captain_blade", slot: .mainHand, rarity: .epic,
                      stats: CharacterStats(damageMin: 17, damageMax: 25, critChance: 0.12, attackSpeedBonus: 0.08), price: 8500, minLevel: 19, textureName: "weapon_11"),
            Equipment(id: "weapon_12", nameKey: "item.weapon.royal_silver_sword", slot: .mainHand, rarity: .epic,
                      stats: CharacterStats(damageMin: 19, damageMax: 28, critDamage: 0.20, lifeSteal: 0.05), price: 11000, minLevel: 22, textureName: "weapon_12"),
            Equipment(id: "weapon_13", nameKey: "item.weapon.oath_sword", slot: .mainHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 22, damageMax: 32, critChance: 0.15, attackSpeedBonus: 0.10), price: 14000, minLevel: 25, textureName: "weapon_13"),
            Equipment(id: "weapon_14", nameKey: "item.weapon.seraph_blade", slot: .mainHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 25, damageMax: 35, critDamage: 0.25, lifeSteal: 0.08), price: 17000, minLevel: 27, textureName: "weapon_14"),
            Equipment(id: "weapon_15", nameKey: "item.weapon.king_david_sword", slot: .mainHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 28, damageMax: 40, critChance: 0.18, critDamage: 0.30, lifeSteal: 0.05), price: 22000, minLevel: 30, textureName: "weapon_15"),
            Equipment(id: "weapon_sling_01", nameKey: "item.weapon.reinforced_sling", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 4, damageMax: 8, critChance: 0.06, dodgeRanged: 0.03), price: 220, minLevel: 1, textureName: "weapon_sling_reinforced"),
            Equipment(id: "weapon_sling_02", nameKey: "item.weapon.bronze_sling", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 8, damageMax: 14, critChance: 0.10, critDamage: 0.10, attackSpeedBonus: 0.04), price: 780, minLevel: 3, textureName: "weapon_sling_bronze"),
            Equipment(id: "weapon_staff_01", nameKey: "item.weapon.oak_staff", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 8, damageMin: 9, damageMax: 15, armor: 2), price: 1050, minLevel: 4, textureName: "weapon_staff_oak"),
            Equipment(id: "weapon_staff_02", nameKey: "item.weapon.anointed_staff", slot: .mainHand, rarity: .rare,
                      stats: CharacterStats(maxHP: 15, damageMin: 14, damageMax: 23, critChance: 0.08, lifeSteal: 0.04), price: 3400, minLevel: 7, textureName: "weapon_staff_anointed"),
        ])

        // MARK: - BODY (15 items)
        items.append(contentsOf: [
            Equipment(id: "body_01", nameKey: "item.body.shepherd_tunic", slot: .body, rarity: .common,
                      stats: CharacterStats(maxHP: 12, armor: 2), price: 90, minLevel: 1, textureName: "body_01"),
            Equipment(id: "body_02", nameKey: "item.body.tanned_leather_vest", slot: .body, rarity: .common,
                      stats: CharacterStats(maxHP: 18, armor: 5), price: 180, minLevel: 1, textureName: "body_02"),
            Equipment(id: "body_03", nameKey: "item.body.reinforced_leather", slot: .body, rarity: .common,
                      stats: CharacterStats(maxHP: 14, armor: 10), price: 350, minLevel: 2, textureName: "body_03"),
            Equipment(id: "body_04", nameKey: "item.body.lion_skin", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 18, armor: 10, dodgeMelee: 0.05), price: 0, minLevel: 3, textureName: "body_04"),
            Equipment(id: "body_05", nameKey: "item.body.light_chainmail", slot: .body, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 10, armor: 14), price: 800, minLevel: 4, textureName: "body_05"),
            Equipment(id: "body_06", nameKey: "item.body.bronze_cuirass", slot: .body, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 25, armor: 14, dodgeRanged: 0.03), price: 1300, minLevel: 5, textureName: "body_06"),
            Equipment(id: "body_07", nameKey: "item.body.scale_armor", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 15, armor: 22, dodgeMelee: 0.05), price: 2000, minLevel: 6, textureName: "body_07"),
            Equipment(id: "body_08", nameKey: "item.body.philistine_chainmail", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 25, armor: 25), price: 2900, minLevel: 7, textureName: "body_08"),
            Equipment(id: "body_09", nameKey: "item.body.desert_cuirass", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 25, armor: 13, lifeSteal: 0.05), price: 4000, minLevel: 13, textureName: "body_09"),
            Equipment(id: "body_10", nameKey: "item.body.royal_bronze_armor", slot: .body, rarity: .epic,
                      stats: CharacterStats(critChance: 0.05, armor: 26), price: 5500, minLevel: 16, textureName: "body_10"),
            Equipment(id: "body_11", nameKey: "item.body.forged_iron_cuirass", slot: .body, rarity: .epic,
                      stats: CharacterStats(maxHP: 15, armor: 30), price: 7000, minLevel: 18, textureName: "body_11"),
            Equipment(id: "body_12", nameKey: "item.body.covenant_breastplate", slot: .body, rarity: .epic,
                      stats: CharacterStats(maxHP: 30, armor: 15, dodgeMelee: 0.08, dodgeRanged: 0.05), price: 9000, minLevel: 21, textureName: "body_12"),
            Equipment(id: "body_13", nameKey: "item.body.general_armor", slot: .body, rarity: .legendary,
                      stats: CharacterStats(maxHP: 20, armor: 35), price: 11500, minLevel: 24, textureName: "body_13"),
            Equipment(id: "body_14", nameKey: "item.body.archangel_cuirass", slot: .body, rarity: .legendary,
                      stats: CharacterStats(maxHP: 35, armor: 32, lifeSteal: 0.10), price: 14000, minLevel: 27, textureName: "body_14"),
            Equipment(id: "body_15", nameKey: "item.body.sacred_king_mantle", slot: .body, rarity: .legendary,
                      stats: CharacterStats(maxHP: 40, armor: 40, dodgeMelee: 0.10), price: 20000, minLevel: 30, textureName: "body_15"),
        ])

        // MARK: - FEET
        items.append(contentsOf: [
            Equipment(id: "feet_sandals_01", nameKey: "item.feet.leather_sandals", slot: .feet, rarity: .common,
                      stats: CharacterStats(maxHP: 6, runSpeed: 4), price: 120, minLevel: 1, textureName: "feet_sandals_leather"),
            Equipment(id: "feet_sandals_02", nameKey: "item.feet.traveler_sandals", slot: .feet, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 8, dodgeMelee: 0.03, runSpeed: 8), price: 520, minLevel: 3, textureName: "feet_sandals_traveler"),
            Equipment(id: "feet_sandals_03", nameKey: "item.feet.desert_sandals", slot: .feet, rarity: .rare,
                      stats: CharacterStats(maxHP: 14, dodgeMelee: 0.05, dodgeRanged: 0.04, runSpeed: 12), price: 2200, minLevel: 7, textureName: "feet_sandals_desert"),
        ])

        // MARK: - WAIST
        items.append(contentsOf: [
            Equipment(id: "waist_01", nameKey: "item.waist.rope_belt", slot: .waist, rarity: .common,
                      stats: CharacterStats(maxHP: 6, armor: 1), price: 90, minLevel: 1, textureName: "waist_belt_rope"),
            Equipment(id: "waist_02", nameKey: "item.waist.leather_belt", slot: .waist, rarity: .common,
                      stats: CharacterStats(maxHP: 10, armor: 3), price: 240, minLevel: 2, textureName: "waist_belt_leather"),
            Equipment(id: "waist_03", nameKey: "item.waist.warrior_belt", slot: .waist, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 14, damageMin: 1, damageMax: 2, armor: 5), price: 900, minLevel: 4, textureName: "waist_belt_warrior"),
            Equipment(id: "waist_04", nameKey: "item.waist.royal_belt", slot: .waist, rarity: .rare,
                      stats: CharacterStats(maxHP: 18, damageMin: 2, damageMax: 3, critChance: 0.05, armor: 7), price: 2800, minLevel: 8, textureName: "waist_belt_royal"),
        ])

        // MARK: - GLOVES
        items.append(contentsOf: [
            Equipment(id: "gloves_01", nameKey: "item.gloves.shepherd_wraps", slot: .gloves, rarity: .common,
                      stats: CharacterStats(maxHP: 4, damageMin: 1, damageMax: 1, attackSpeedBonus: 0.03), price: 140, minLevel: 1, textureName: "gloves_shepherd_wraps"),
            Equipment(id: "gloves_02", nameKey: "item.gloves.slinger_grips", slot: .gloves, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 2, damageMax: 3, critChance: 0.04, attackSpeedBonus: 0.06), price: 760, minLevel: 3, textureName: "gloves_slinger_grips"),
            Equipment(id: "gloves_03", nameKey: "item.gloves.anointed_gauntlets", slot: .gloves, rarity: .rare,
                      stats: CharacterStats(maxHP: 8, damageMin: 3, damageMax: 5, critChance: 0.06, armor: 4, attackSpeedBonus: 0.08), price: 2600, minLevel: 7, textureName: "gloves_anointed_gauntlets"),
        ])

        // MARK: - SHIELD (15 items)
        items.append(contentsOf: [
            Equipment(id: "shield_01", nameKey: "item.shield.wooden_shield", slot: .offHand, rarity: .common,
                      stats: CharacterStats(maxHP: 8, armor: 3), price: 90, minLevel: 1, textureName: "shield_01"),
            Equipment(id: "shield_02", nameKey: "item.shield.leather_shield", slot: .offHand, rarity: .common,
                      stats: CharacterStats(maxHP: 12, armor: 5, dodgeMelee: 0.02), price: 170, minLevel: 1, textureName: "shield_02"),
            Equipment(id: "shield_03", nameKey: "item.shield.bronze_round_shield", slot: .offHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 10, armor: 10), price: 420, minLevel: 3, textureName: "shield_03"),
            Equipment(id: "shield_04", nameKey: "item.shield.plank_shield", slot: .offHand, rarity: .common,
                      stats: CharacterStats(maxHP: 16, armor: 8, dodgeRanged: 0.05), price: 620, minLevel: 4, textureName: "shield_04"),
            Equipment(id: "shield_05", nameKey: "item.shield.iron_buckler", slot: .offHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 10, armor: 15), price: 950, minLevel: 5, textureName: "shield_05"),
            Equipment(id: "shield_06", nameKey: "item.shield.philistine_bronze_shield", slot: .offHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 20, armor: 13, dodgeMelee: 0.03), price: 1450, minLevel: 6, textureName: "shield_06"),
            Equipment(id: "shield_07", nameKey: "item.shield.sentinel_shield", slot: .offHand, rarity: .rare,
                      stats: CharacterStats(armor: 15, dodgeRanged: 0.05), price: 2600, minLevel: 10, textureName: "shield_07"),
            Equipment(id: "shield_08", nameKey: "item.shield.iron_shield", slot: .offHand, rarity: .rare,
                      stats: CharacterStats(maxHP: 10, armor: 19), price: 3800, minLevel: 12, textureName: "shield_08"),
            Equipment(id: "shield_09", nameKey: "item.shield.desert_shield", slot: .offHand, rarity: .rare,
                      stats: CharacterStats(maxHP: 20, armor: 10, dodgeMelee: 0.08), price: 5000, minLevel: 14, textureName: "shield_09"),
            Equipment(id: "shield_10", nameKey: "item.shield.royal_bronze_shield", slot: .offHand, rarity: .epic,
                      stats: CharacterStats(armor: 23, dodgeRanged: 0.05), price: 6500, minLevel: 17, textureName: "shield_10"),
            Equipment(id: "shield_11", nameKey: "item.shield.general_shield", slot: .offHand, rarity: .epic,
                      stats: CharacterStats(maxHP: 15, armor: 27), price: 8500, minLevel: 19, textureName: "shield_11"),
            Equipment(id: "shield_12", nameKey: "item.shield.iron_tower_shield", slot: .offHand, rarity: .epic,
                      stats: CharacterStats(maxHP: 10, armor: 33, dodgeMelee: 0.05), price: 11000, minLevel: 22, textureName: "shield_12"),
            Equipment(id: "shield_13", nameKey: "item.shield.covenant_shield", slot: .offHand, rarity: .legendary,
                      stats: CharacterStats(maxHP: 25, armor: 14, dodgeMelee: 0.10, dodgeRanged: 0.08), price: 13500, minLevel: 25, textureName: "shield_13"),
            Equipment(id: "shield_14", nameKey: "item.shield.seraphic_shield", slot: .offHand, rarity: .legendary,
                      stats: CharacterStats(maxHP: 20, armor: 29, lifeSteal: 0.05), price: 16000, minLevel: 27, textureName: "shield_14"),
            Equipment(id: "shield_15", nameKey: "item.shield.ark_sacred_shield", slot: .offHand, rarity: .legendary,
                      stats: CharacterStats(maxHP: 30, armor: 35, dodgeMelee: 0.10), price: 20000, minLevel: 30, textureName: "shield_15"),
        ])

        // MARK: - TWO-HAND WEAPONS (15 items)
        items.append(contentsOf: [
            Equipment(id: "twohand_01", nameKey: "item.twohand.cedar_staff", slot: .twoHand, rarity: .common,
                      stats: CharacterStats(maxHP: 8, damageMin: 5, damageMax: 9), price: 120, minLevel: 1, textureName: "twohand_01"),
            Equipment(id: "twohand_02", nameKey: "item.twohand.wooden_spear", slot: .twoHand, rarity: .common,
                      stats: CharacterStats(damageMin: 7, damageMax: 12, critChance: 0.05, attackSpeedBonus: 0.03), price: 350, minLevel: 2, textureName: "twohand_02"),
            Equipment(id: "twohand_03", nameKey: "item.twohand.simple_bow", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 8, damageMax: 14), price: 550, minLevel: 3, textureName: "twohand_03"),
            Equipment(id: "twohand_04", nameKey: "item.twohand.bronze_spear", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 11, damageMax: 18, critChance: 0.08, critDamage: 0.15), price: 900, minLevel: 4, textureName: "twohand_04"),
            Equipment(id: "twohand_05", nameKey: "item.twohand.lumber_axe", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 10, damageMin: 15, damageMax: 23, critDamage: 0.20), price: 1550, minLevel: 5, textureName: "twohand_05"),
            Equipment(id: "twohand_06", nameKey: "item.twohand.goliath_sword", slot: .twoHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 20, damageMax: 30, critChance: 0.10, critDamage: 0.20), price: 0, minLevel: 8, textureName: "twohand_06"),
            Equipment(id: "twohand_07", nameKey: "item.twohand.composite_war_bow", slot: .twoHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 10, damageMax: 20, attackSpeedBonus: 0.10), price: 3000, minLevel: 10, textureName: "twohand_07"),
            Equipment(id: "twohand_08", nameKey: "item.twohand.iron_halberd", slot: .twoHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 18, damageMax: 26, critChance: 0.12, critDamage: 0.15), price: 4500, minLevel: 12, textureName: "twohand_08"),
            Equipment(id: "twohand_09", nameKey: "item.twohand.desert_lance", slot: .twoHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 20, damageMax: 30, lifeSteal: 0.05, attackSpeedBonus: 0.10), price: 6000, minLevel: 15, textureName: "twohand_09"),
            Equipment(id: "twohand_10", nameKey: "item.twohand.war_axe", slot: .twoHand, rarity: .epic,
                      stats: CharacterStats(damageMin: 24, damageMax: 35, critChance: 0.08, critDamage: 0.20), price: 8000, minLevel: 18, textureName: "twohand_10"),
            Equipment(id: "twohand_11", nameKey: "item.twohand.royal_longbow", slot: .twoHand, rarity: .epic,
                      stats: CharacterStats(damageMin: 16, damageMax: 30, critChance: 0.15, attackSpeedBonus: 0.15), price: 10000, minLevel: 20, textureName: "twohand_11"),
            Equipment(id: "twohand_12", nameKey: "item.twohand.iron_bastard_sword", slot: .twoHand, rarity: .epic,
                      stats: CharacterStats(damageMin: 28, damageMax: 40, critChance: 0.15, critDamage: 0.25), price: 13000, minLevel: 23, textureName: "twohand_12"),
            Equipment(id: "twohand_13", nameKey: "item.twohand.judgment_lance", slot: .twoHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 30, damageMax: 44, critChance: 0.18, lifeSteal: 0.12), price: 16000, minLevel: 25, textureName: "twohand_13"),
            Equipment(id: "twohand_14", nameKey: "item.twohand.divine_axe", slot: .twoHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 34, damageMax: 48, critChance: 0.15, critDamage: 0.30), price: 19000, minLevel: 28, textureName: "twohand_14"),
            Equipment(id: "twohand_15", nameKey: "item.twohand.moses_staff", slot: .twoHand, rarity: .legendary,
                      stats: CharacterStats(damageMin: 38, damageMax: 55, critChance: 0.20, critDamage: 0.35, lifeSteal: 0.10), price: 25000, minLevel: 30, textureName: "twohand_15"),
            Equipment(id: "twohand_staff_01", nameKey: "item.twohand.acacia_staff", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 18, damageMin: 13, damageMax: 21, armor: 4), price: 1350, minLevel: 4, textureName: "twohand_staff_acacia"),
            Equipment(id: "twohand_staff_02", nameKey: "item.twohand.prophet_staff", slot: .twoHand, rarity: .rare,
                      stats: CharacterStats(maxHP: 24, damageMin: 22, damageMax: 34, critChance: 0.08, lifeSteal: 0.06), price: 5400, minLevel: 12, textureName: "twohand_staff_prophet"),
        ])

        self.allItems = items
    }

    func items(for slot: EquipmentSlot) -> [Equipment] {
        return allItems.filter { $0.slot == slot }
    }

    func item(withId id: String) -> Equipment? {
        return allItems.first { $0.id == id }
    }

    func availableItems(forLevel level: Int, slot: EquipmentSlot? = nil) -> [Equipment] {
        return allItems.filter { item in
            item.minLevel <= level && (slot == nil || item.slot == slot)
        }
    }
}
