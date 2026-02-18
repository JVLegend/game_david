import Foundation
import SpriteKit

final class GameManager {
    static let shared = GameManager()

    var playerData: PlayerData?
    var isLoggedIn: Bool { playerData != nil }

    private init() {}

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
        playerData?.gold += amount
        playerData?.totalGoldEarned += amount
        save()
    }

    func spendGold(_ amount: Int) -> Bool {
        guard let player = playerData, player.gold >= amount else { return false }
        playerData?.gold -= amount
        save()
        return true
    }

    func addRubies(_ amount: Int) {
        playerData?.rubies += amount
        save()
    }

    // MARK: - Equipment
    func equipItem(_ itemId: String) -> String? {
        guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return nil }

        let slot = item.slot
        let previousItemId = playerData?.equippedItems[slot]

        // If two-hand weapon, also clear offHand
        if slot == .twoHand {
            if let offHandId = playerData?.equippedItems[.offHand] {
                playerData?.equippedItems.removeValue(forKey: .offHand)
                playerData?.inventory.append(offHandId)
            }
            if let mainHandId = playerData?.equippedItems[.mainHand] {
                playerData?.equippedItems.removeValue(forKey: .mainHand)
                playerData?.inventory.append(mainHandId)
            }
        }

        // If equipping mainHand or offHand, clear twoHand
        if (slot == .mainHand || slot == .offHand),
           let twoHandId = playerData?.equippedItems[.twoHand] {
            playerData?.equippedItems.removeValue(forKey: .twoHand)
            playerData?.inventory.append(twoHandId)
        }

        playerData?.equippedItems[slot] = itemId
        playerData?.inventory.removeAll { $0 == itemId }

        if let prevId = previousItemId {
            playerData?.inventory.append(prevId)
        }

        playerData?.powerScore = powerScore
        save()
        return previousItemId
    }

    // MARK: - Food
    func useFood(_ foodType: FoodType) -> Food? {
        guard let player = playerData,
              let count = player.foodInventory[foodType],
              count > 0,
              let food = FoodDatabase.shared.food(for: foodType) else { return nil }

        playerData?.foodInventory[foodType] = (playerData?.foodInventory[foodType] ?? 1) - 1
        if playerData?.foodInventory[foodType] == 0 {
            playerData?.foodInventory.removeValue(forKey: foodType)
        }
        return food
    }

    func buyFood(_ foodType: FoodType) -> Bool {
        guard let food = FoodDatabase.shared.food(for: foodType) else { return false }
        guard spendGold(food.price) else { return false }
        playerData?.foodInventory[foodType, default: 0] += 1
        save()
        return true
    }

    // MARK: - Characters
    func buyCharacter(_ character: PlayableCharacter) -> Bool {
        guard let player = playerData else { return false }
        guard !player.unlockedCharacters.contains(character) else { return false }
        guard player.highestMapCompleted >= character.requiredMap else { return false }
        guard spendGold(character.price) else { return false }

        playerData?.unlockedCharacters.append(character)
        save()
        return true
    }

    func selectCharacter(_ character: PlayableCharacter) -> Bool {
        guard let player = playerData,
              player.unlockedCharacters.contains(character) else { return false }
        playerData?.activeCharacter = character
        save()
        return true
    }

    // MARK: - Battle Results
    func completeBattle(mapId: Int, battleId: Int, stars: Int, goldEarned: Int, xpEarned: Int, enemiesKilled: Int) {
        playerData?.setStars(mapId: mapId, battleId: battleId, stars: stars)
        addGold(goldEarned)
        playerData?.totalEnemiesKilled += enemiesKilled

        if let leveledUp = playerData?.addExperience(xpEarned), leveledUp {
            // Could notify UI of level up
        }

        // Check if map is completed (all 4 battles done)
        if let map = EnemyDatabase.shared.map(withId: mapId) {
            let allCompleted = map.battles.allSatisfy { battle in
                (playerData?.starsForBattle(mapId: mapId, battleId: battle.battleId) ?? 0) > 0
            }
            if allCompleted && mapId > (playerData?.highestMapCompleted ?? 0) {
                playerData?.highestMapCompleted = mapId
            }
        }

        playerData?.powerScore = powerScore
        save()
    }

    // MARK: - Save
    func save() {
        playerData?.lastSaved = Date()
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
            playerData = PlayerData.newPlayer(userId: userId, displayName: displayName, language: language)
            // Give starter weapon
            playerData?.inventory.append("weapon_01")
            _ = equipItem("weapon_01")
        }
        save()
    }
}
