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
                      stats: CharacterStats(maxHP: 5, armor: 1), price: 50, minLevel: 1, textureName: "head_01"),
            Equipment(id: "head_02", nameKey: "item.head.simple_headband", slot: .head, rarity: .common,
                      stats: CharacterStats(armor: 2, dodgeMelee: 0.03), price: 120, minLevel: 2, textureName: "head_02"),
            Equipment(id: "head_03", nameKey: "item.head.leather_hood", slot: .head, rarity: .common,
                      stats: CharacterStats(maxHP: 8, armor: 3), price: 250, minLevel: 3, textureName: "head_03"),
            Equipment(id: "head_04", nameKey: "item.head.light_bronze_helm", slot: .head, rarity: .uncommon,
                      stats: CharacterStats(armor: 7, dodgeRanged: 0.02), price: 500, minLevel: 4, textureName: "head_04"),
            Equipment(id: "head_05", nameKey: "item.head.philistine_bronze_helm", slot: .head, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 12, armor: 7, critChance: 0.05), price: 800, minLevel: 5, textureName: "head_05"),
            Equipment(id: "head_06", nameKey: "item.head.simple_iron_helmet", slot: .head, rarity: .uncommon,
                      stats: CharacterStats(armor: 13), price: 1200, minLevel: 7, textureName: "head_06"),
            Equipment(id: "head_07", nameKey: "item.head.desert_helm", slot: .head, rarity: .rare,
                      stats: CharacterStats(maxHP: 10, armor: 8, dodgeRanged: 0.05), price: 1500, minLevel: 8, textureName: "head_07"),
            Equipment(id: "head_08", nameKey: "item.head.bronze_crown", slot: .head, rarity: .rare,
                      stats: CharacterStats(armor: 10, critChance: 0.05, lifeSteal: 0.03), price: 2000, minLevel: 10, textureName: "head_08"),
            Equipment(id: "head_09", nameKey: "item.head.warrior_helm", slot: .head, rarity: .rare,
                      stats: CharacterStats(maxHP: 15, armor: 18), price: 3000, minLevel: 12, textureName: "head_09"),
            Equipment(id: "head_10", nameKey: "item.head.royal_silver_helmet", slot: .head, rarity: .epic,
                      stats: CharacterStats(armor: 14, critDamage: 0.05, dodgeMelee: 0.08), price: 4500, minLevel: 15, textureName: "head_10"),
            Equipment(id: "head_11", nameKey: "item.head.faith_helm", slot: .head, rarity: .epic,
                      stats: CharacterStats(maxHP: 20, armor: 11, dodgeRanged: 0.08), price: 5500, minLevel: 17, textureName: "head_11"),
            Equipment(id: "head_12", nameKey: "item.head.anointed_iron_crown", slot: .head, rarity: .epic,
                      stats: CharacterStats(armor: 21, critChance: 0.10), price: 7000, minLevel: 20, textureName: "head_12"),
            Equipment(id: "head_13", nameKey: "item.head.goliath_helm_adapted", slot: .head, rarity: .epic,
                      stats: CharacterStats(maxHP: 10, armor: 26, runSpeed: -7.5), price: 9000, minLevel: 22, textureName: "head_13"),
            Equipment(id: "head_14", nameKey: "item.head.seraph_helmet", slot: .head, rarity: .legendary,
                      stats: CharacterStats(maxHP: 25, armor: 15, dodgeMelee: 0.10, lifeSteal: 0.05), price: 12000, minLevel: 25, textureName: "head_14"),
            Equipment(id: "head_15", nameKey: "item.head.crown_of_the_anointed", slot: .head, rarity: .legendary,
                      stats: CharacterStats(maxHP: 30, armor: 30, critChance: 0.12), price: 18000, minLevel: 30, textureName: "head_15"),
        ])

        // MARK: - MAIN HAND (15 items)
        items.append(contentsOf: [
            Equipment(id: "weapon_01", nameKey: "item.weapon.shepherd_staff", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 2, damageMax: 4), price: 0, minLevel: 1, textureName: "weapon_01"),
            Equipment(id: "weapon_02", nameKey: "item.weapon.reinforced_staff", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 3, damageMax: 6, critChance: 0.03), price: 200, minLevel: 2, textureName: "weapon_02"),
            Equipment(id: "weapon_03", nameKey: "item.weapon.shearing_knife", slot: .mainHand, rarity: .common,
                      stats: CharacterStats(damageMin: 4, damageMax: 7, attackSpeedBonus: 0.05), price: 400, minLevel: 3, textureName: "weapon_03"),
            Equipment(id: "weapon_04", nameKey: "item.weapon.wooden_club", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 5, damageMin: 5, damageMax: 9, critChance: 0.05), price: 650, minLevel: 4, textureName: "weapon_04"),
            Equipment(id: "weapon_05", nameKey: "item.weapon.bronze_dagger", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 6, damageMax: 10, critChance: 0.05, attackSpeedBonus: 0.08), price: 1000, minLevel: 5, textureName: "weapon_05"),
            Equipment(id: "weapon_06", nameKey: "item.weapon.short_bronze_sword", slot: .mainHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 8, damageMax: 13, critChance: 0.05, lifeSteal: 0.02), price: 1600, minLevel: 7, textureName: "weapon_06"),
            Equipment(id: "weapon_07", nameKey: "item.weapon.iron_mace", slot: .mainHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 10, damageMax: 15, critDamage: 0.10), price: 2400, minLevel: 9, textureName: "weapon_07"),
            Equipment(id: "weapon_08", nameKey: "item.weapon.philistine_sword", slot: .mainHand, rarity: .rare,
                      stats: CharacterStats(damageMin: 11, damageMax: 17, critChance: 0.08, attackSpeedBonus: 0.05), price: 3500, minLevel: 11, textureName: "weapon_08"),
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
        ])

        // MARK: - BODY (15 items)
        items.append(contentsOf: [
            Equipment(id: "body_01", nameKey: "item.body.shepherd_tunic", slot: .body, rarity: .common,
                      stats: CharacterStats(maxHP: 8, armor: 1), price: 60, minLevel: 1, textureName: "body_01"),
            Equipment(id: "body_02", nameKey: "item.body.tanned_leather_vest", slot: .body, rarity: .common,
                      stats: CharacterStats(maxHP: 12, armor: 3), price: 200, minLevel: 2, textureName: "body_02"),
            Equipment(id: "body_03", nameKey: "item.body.reinforced_leather", slot: .body, rarity: .common,
                      stats: CharacterStats(maxHP: 5, armor: 8), price: 400, minLevel: 3, textureName: "body_03"),
            Equipment(id: "body_04", nameKey: "item.body.lion_skin", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 10, armor: 8, dodgeMelee: 0.05), price: 0, minLevel: 4, textureName: "body_04"),
            Equipment(id: "body_05", nameKey: "item.body.light_chainmail", slot: .body, rarity: .uncommon,
                      stats: CharacterStats(armor: 12), price: 900, minLevel: 5, textureName: "body_05"),
            Equipment(id: "body_06", nameKey: "item.body.bronze_cuirass", slot: .body, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 20, armor: 10, dodgeRanged: 0.03), price: 1500, minLevel: 7, textureName: "body_06"),
            Equipment(id: "body_07", nameKey: "item.body.scale_armor", slot: .body, rarity: .rare,
                      stats: CharacterStats(armor: 19, dodgeMelee: 0.05), price: 2200, minLevel: 9, textureName: "body_07"),
            Equipment(id: "body_08", nameKey: "item.body.philistine_chainmail", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 10, armor: 22), price: 3200, minLevel: 11, textureName: "body_08"),
            Equipment(id: "body_09", nameKey: "item.body.desert_cuirass", slot: .body, rarity: .rare,
                      stats: CharacterStats(maxHP: 25, armor: 13, lifeSteal: 0.05), price: 4000, minLevel: 13, textureName: "body_09"),
            Equipment(id: "body_10", nameKey: "item.body.royal_bronze_armor", slot: .body, rarity: .epic,
                      stats: CharacterStats(armor: 26, critChance: 0.05), price: 5500, minLevel: 16, textureName: "body_10"),
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

        // MARK: - SHIELD (15 items)
        items.append(contentsOf: [
            Equipment(id: "shield_01", nameKey: "item.shield.wooden_shield", slot: .offHand, rarity: .common,
                      stats: CharacterStats(maxHP: 5, armor: 2), price: 80, minLevel: 1, textureName: "shield_01"),
            Equipment(id: "shield_02", nameKey: "item.shield.leather_shield", slot: .offHand, rarity: .common,
                      stats: CharacterStats(maxHP: 8, armor: 3, dodgeMelee: 0.02), price: 250, minLevel: 2, textureName: "shield_02"),
            Equipment(id: "shield_03", nameKey: "item.shield.bronze_round_shield", slot: .offHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 5, armor: 8), price: 500, minLevel: 4, textureName: "shield_03"),
            Equipment(id: "shield_04", nameKey: "item.shield.plank_shield", slot: .offHand, rarity: .common,
                      stats: CharacterStats(maxHP: 10, armor: 4, dodgeRanged: 0.05), price: 700, minLevel: 5, textureName: "shield_04"),
            Equipment(id: "shield_05", nameKey: "item.shield.iron_buckler", slot: .offHand, rarity: .uncommon,
                      stats: CharacterStats(armor: 11), price: 1100, minLevel: 6, textureName: "shield_05"),
            Equipment(id: "shield_06", nameKey: "item.shield.philistine_bronze_shield", slot: .offHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 15, armor: 8, dodgeMelee: 0.03), price: 1700, minLevel: 8, textureName: "shield_06"),
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
                      stats: CharacterStats(maxHP: 5, damageMin: 4, damageMax: 8), price: 150, minLevel: 1, textureName: "twohand_01"),
            Equipment(id: "twohand_02", nameKey: "item.twohand.wooden_spear", slot: .twoHand, rarity: .common,
                      stats: CharacterStats(damageMin: 6, damageMax: 10, critChance: 0.05, attackSpeedBonus: 0.03), price: 400, minLevel: 3, textureName: "twohand_02"),
            Equipment(id: "twohand_03", nameKey: "item.twohand.simple_bow", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 5, damageMax: 12), price: 600, minLevel: 4, textureName: "twohand_03"),
            Equipment(id: "twohand_04", nameKey: "item.twohand.bronze_spear", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(damageMin: 9, damageMax: 15, critChance: 0.08, critDamage: 0.10), price: 1000, minLevel: 5, textureName: "twohand_04"),
            Equipment(id: "twohand_05", nameKey: "item.twohand.lumber_axe", slot: .twoHand, rarity: .uncommon,
                      stats: CharacterStats(maxHP: 5, damageMin: 12, damageMax: 18, critDamage: 0.15), price: 1800, minLevel: 7, textureName: "twohand_05"),
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
