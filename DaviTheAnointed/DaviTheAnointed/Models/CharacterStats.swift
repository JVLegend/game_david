import Foundation

struct CharacterStats: Codable {
    var maxHP: Int
    var currentHP: Int
    var damageMin: Int
    var damageMax: Int
    var critChance: Double
    var critDamage: Double
    var armor: Int
    var dodgeMelee: Double
    var dodgeRanged: Double
    var attackSpeed: Double
    var runSpeed: Double
    var lifeSteal: Double

    // Bonus fields for passive/equipment deltas
    var damageMultiplier: Double
    var attackSpeedBonus: Double

    init(
        maxHP: Int = 0,
        currentHP: Int = 0,
        damageMin: Int = 0,
        damageMax: Int = 0,
        critChance: Double = 0,
        critDamage: Double = 0,
        armor: Int = 0,
        dodgeMelee: Double = 0,
        dodgeRanged: Double = 0,
        attackSpeed: Double = 0,
        runSpeed: Double = 0,
        lifeSteal: Double = 0,
        damageMultiplier: Double = 0,
        attackSpeedBonus: Double = 0
    ) {
        self.maxHP = maxHP
        self.currentHP = currentHP
        self.damageMin = damageMin
        self.damageMax = damageMax
        self.critChance = critChance
        self.critDamage = critDamage
        self.armor = armor
        self.dodgeMelee = dodgeMelee
        self.dodgeRanged = dodgeRanged
        self.attackSpeed = attackSpeed
        self.runSpeed = runSpeed
        self.lifeSteal = lifeSteal
        self.damageMultiplier = damageMultiplier
        self.attackSpeedBonus = attackSpeedBonus
    }

    static func baseStats(level: Int) -> CharacterStats {
        return CharacterStats(
            maxHP: 50 + (level - 1) * 5,
            currentHP: 50 + (level - 1) * 5,
            damageMin: 2 + (level - 1),
            damageMax: 4 + (level - 1),
            critChance: 0.05,
            critDamage: 1.5,
            armor: 0,
            dodgeMelee: 0.05,
            dodgeRanged: 0.05,
            attackSpeed: 1.0,
            runSpeed: 150.0,
            lifeSteal: 0
        )
    }

    static func + (lhs: CharacterStats, rhs: CharacterStats) -> CharacterStats {
        return CharacterStats(
            maxHP: lhs.maxHP + rhs.maxHP,
            currentHP: lhs.currentHP + rhs.currentHP,
            damageMin: lhs.damageMin + rhs.damageMin,
            damageMax: lhs.damageMax + rhs.damageMax,
            critChance: lhs.critChance + rhs.critChance,
            critDamage: lhs.critDamage + rhs.critDamage,
            armor: lhs.armor + rhs.armor,
            dodgeMelee: lhs.dodgeMelee + rhs.dodgeMelee,
            dodgeRanged: lhs.dodgeRanged + rhs.dodgeRanged,
            attackSpeed: lhs.attackSpeed + rhs.attackSpeed,
            runSpeed: lhs.runSpeed + rhs.runSpeed,
            lifeSteal: lhs.lifeSteal + rhs.lifeSteal,
            damageMultiplier: lhs.damageMultiplier + rhs.damageMultiplier,
            attackSpeedBonus: lhs.attackSpeedBonus + rhs.attackSpeedBonus
        )
    }

    func rollDamage() -> Int {
        guard damageMax >= damageMin else { return damageMin }
        let baseDmg = Int.random(in: damageMin...damageMax)
        let multiplied = Double(baseDmg) * (1.0 + damageMultiplier)
        return Int(multiplied)
    }

    func rollCrit(baseDamage: Int) -> (isCrit: Bool, damage: Int) {
        let roll = Double.random(in: 0...1)
        if roll < critChance {
            return (true, Int(Double(baseDamage) * critDamage))
        }
        return (false, baseDamage)
    }

    func rollDodge(attackType: EnemyAttackType) -> Bool {
        let chance = attackType == .melee ? dodgeMelee : dodgeRanged
        return Double.random(in: 0...1) < chance
    }

    func applyArmor(rawDamage: Int) -> Int {
        let reduction = Double(armor) / (Double(armor) + 100.0)
        let finalDamage = Double(rawDamage) * (1.0 - reduction)
        return max(1, Int(finalDamage))
    }

    var effectiveAttackInterval: Double {
        let base = 1.0 / attackSpeed
        return base / (1.0 + attackSpeedBonus)
    }
}
