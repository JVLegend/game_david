import Foundation
import SpriteKit

final class GameManager {
    static let shared = GameManager()

    var playerData: PlayerData?
    var isLoggedIn: Bool { playerData != nil }

    private init() {}

    // MARK: - Safe mutation helper
    private func mutate(_ block: (inout PlayerData) -> Void) {
        guard var p = playerData else { return }
        block(&p)
        playerData = p
    }

    // MARK: - Computed Stats
    func computedStats() -> CharacterStats {
        guard let player = playerData else { return CharacterStats.baseStats(level: 1) }

        var stats = CharacterStats.baseStats(level: player.level)

        // Add character passive bonus
        stats = stats + player.activeCharacter.passiveBonus

        // Add equipment stats
        for (_, itemId) in player.equippedItems {
            if let item = EquipmentDatabase.shared.item(withId: itemId) {
                stats = stats + item.stats
            }
        }

        // Ensure currentHP doesn't exceed maxHP
        stats.currentHP = min(stats.currentHP, stats.maxHP)

        return stats
    }

    var powerScore: Int {
        let stats = computedStats()
        let offenseScore = (stats.damageMin + stats.damageMax) / 2 * 3
            + Int(stats.critChance * 200)
            + Int(stats.critDamage * 100)
            + Int(stats.attackSpeedBonus * 150)
            + Int(stats.lifeSteal * 200)
        let defenseScore = stats.maxHP
            + stats.armor * 2
            + Int(stats.dodgeMelee * 150)
            + Int(stats.dodgeRanged * 150)
        return offenseScore + defenseScore + (playerData?.level ?? 1) * 10
    }

    // MARK: - Gold / Ruby
    func addGold(_ amount: Int) {
        mutate { p in
            p.gold += amount
            p.totalGoldEarned += amount
        }
        save()
    }

    func spendGold(_ amount: Int) -> Bool {
        guard let player = playerData, player.gold >= amount else { return false }
        mutate { p in p.gold -= amount }
        save()
        return true
    }

    func addRubies(_ amount: Int) {
        mutate { p in p.rubies += amount }
        save()
    }

    // MARK: - Equipment
    @discardableResult
    func equipItem(_ itemId: String) -> String? {
        guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return nil }
        guard playerData != nil else { return nil }

        let slot = item.slot
        let previousItemId = playerData!.equippedItems[slot]

        mutate { p in
            // If two-hand weapon, also clear offHand and mainHand
            if slot == .twoHand {
                if let offHandId = p.equippedItems[.offHand] {
                    p.equippedItems.removeValue(forKey: .offHand)
                    p.inventory.append(offHandId)
                }
                if let mainHandId = p.equippedItems[.mainHand] {
                    p.equippedItems.removeValue(forKey: .mainHand)
                    p.inventory.append(mainHandId)
                }
            }
            // If equipping mainHand or offHand, clear twoHand
            if (slot == .mainHand || slot == .offHand),
               let twoHandId = p.equippedItems[.twoHand] {
                p.equippedItems.removeValue(forKey: .twoHand)
                p.inventory.append(twoHandId)
            }

            p.equippedItems[slot] = itemId
            if let idx = p.inventory.firstIndex(of: itemId) {
                p.inventory.remove(at: idx)
            }
            if let prevId = previousItemId {
                p.inventory.append(prevId)
            }
        }

        mutate { p in p.powerScore = self.powerScore }
        save()
        return previousItemId
    }

    // MARK: - Food
    func useFood(_ foodType: FoodType) -> Food? {
        guard let player = playerData,
              let count = player.foodInventory[foodType],
              count > 0,
              let food = FoodDatabase.shared.food(for: foodType) else { return nil }

        mutate { p in
            let current = p.foodInventory[foodType] ?? 1
            let newCount = current - 1
            if newCount <= 0 {
                p.foodInventory.removeValue(forKey: foodType)
            } else {
                p.foodInventory[foodType] = newCount
            }
        }
        return food
    }

    func buyFood(_ foodType: FoodType) -> Bool {
        guard let food = FoodDatabase.shared.food(for: foodType) else { return false }
        guard spendGold(food.price) else { return false }
        mutate { p in
            let current = p.foodInventory[foodType] ?? 0
            p.foodInventory[foodType] = current + 1
        }
        save()
        return true
    }

    // MARK: - Characters
    func buyCharacter(_ character: PlayableCharacter) -> Bool {
        guard let player = playerData else { return false }
        guard !player.unlockedCharacters.contains(character) else { return false }
        guard player.highestMapCompleted >= character.requiredMap else { return false }
        guard spendGold(character.price) else { return false }

        mutate { p in p.unlockedCharacters.append(character) }
        save()
        return true
    }

    func selectCharacter(_ character: PlayableCharacter) -> Bool {
        guard let player = playerData,
              player.unlockedCharacters.contains(character) else { return false }
        mutate { p in p.activeCharacter = character }
        save()
        return true
    }

    // MARK: - Battle Results
    func completeBattle(mapId: Int, battleId: Int, stars: Int, goldEarned: Int, xpEarned: Int, enemiesKilled: Int) {
        mutate { p in
            p.setStars(mapId: mapId, battleId: battleId, stars: stars)
            p.totalEnemiesKilled += enemiesKilled
            _ = p.addExperience(xpEarned)
        }
        addGold(goldEarned)

        // Check if map is completed (all 4 battles done)
        if let map = EnemyDatabase.shared.map(withId: mapId) {
            let allCompleted = map.battles.allSatisfy { battle in
                (playerData?.starsForBattle(mapId: mapId, battleId: battle.battleId) ?? 0) > 0
            }
            if allCompleted, let current = playerData?.highestMapCompleted, mapId > current {
                mutate { p in p.highestMapCompleted = mapId }
            }
        }

        let ps = powerScore
        mutate { p in p.powerScore = ps }
        save()
    }

    // MARK: - Save
    func save() {
        mutate { p in p.lastSaved = Date() }
        guard let data = playerData else { return }

        // Save locally
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "player_data_\(data.userId)")
        }

        // TODO: Save to Firestore
    }

    func loadLocal(userId: String) -> PlayerData? {
        guard let data = UserDefaults.standard.data(forKey: "player_data_\(userId)"),
              let player = try? JSONDecoder().decode(PlayerData.self, from: data) else { return nil }
        return player
    }

    func initializePlayer(userId: String, displayName: String, language: GameLanguage) {
        if let existing = loadLocal(userId: userId) {
            playerData = existing
        } else {
            var newPlayer = PlayerData.newPlayer(userId: userId, displayName: displayName, language: language)
            newPlayer.inventory.append("weapon_01")
            // Equip starter weapon directly on the local copy
            if let item = EquipmentDatabase.shared.item(withId: "weapon_01") {
                newPlayer.equippedItems[item.slot] = "weapon_01"
                if let idx = newPlayer.inventory.firstIndex(of: "weapon_01") {
                    newPlayer.inventory.remove(at: idx)
                }
            }
            playerData = newPlayer
            let ps = powerScore
            mutate { p in p.powerScore = ps }
        }
        save()
    }
}
