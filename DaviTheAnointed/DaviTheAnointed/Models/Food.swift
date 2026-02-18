import Foundation

struct Food: Codable {
    let type: FoodType
    let nameKey: String
    let healAmount: Int
    let buffEffect: BuffEffect?
    let price: Int
    let minLevel: Int
    let textureName: String

    var localizedName: String {
        return LocalizationManager.shared.localize(nameKey)
    }
}

struct BuffEffect: Codable {
    let stat: String // e.g. "dodgeMelee", "attackSpeed", "critChance"
    let value: Double
    let duration: TimeInterval
    let descriptionKey: String

    var localizedDescription: String {
        return LocalizationManager.shared.localize(descriptionKey)
    }
}

struct FoodDatabase {
    static let shared = FoodDatabase()

    let allFoods: [Food]

    private init() {
        allFoods = [
            Food(type: .barleyBread, nameKey: "food.barley_bread", healAmount: 15,
                 buffEffect: nil, price: 20, minLevel: 1, textureName: "food_barley_bread"),

            Food(type: .grapes, nameKey: "food.grapes", healAmount: 25,
                 buffEffect: nil, price: 40, minLevel: 1, textureName: "food_grapes"),

            Food(type: .driedFigs, nameKey: "food.dried_figs", healAmount: 20,
                 buffEffect: BuffEffect(stat: "cleanse", value: 1, duration: 0, descriptionKey: "food.dried_figs.buff"),
                 price: 50, minLevel: 3, textureName: "food_dried_figs"),

            Food(type: .olives, nameKey: "food.olives", healAmount: 10,
                 buffEffect: BuffEffect(stat: "dodgeMelee", value: 0.05, duration: 10, descriptionKey: "food.olives.buff"),
                 price: 60, minLevel: 4, textureName: "food_olives"),

            Food(type: .honeyBread, nameKey: "food.honey_bread", healAmount: 35,
                 buffEffect: nil, price: 80, minLevel: 5, textureName: "food_honey_bread"),

            Food(type: .pomegranate, nameKey: "food.pomegranate", healAmount: 30,
                 buffEffect: BuffEffect(stat: "attackSpeed", value: 0.10, duration: 8, descriptionKey: "food.pomegranate.buff"),
                 price: 100, minLevel: 7, textureName: "food_pomegranate"),

            Food(type: .goatCheese, nameKey: "food.goat_cheese", healAmount: 40,
                 buffEffect: BuffEffect(stat: "armor", value: 5, duration: 10, descriptionKey: "food.goat_cheese.buff"),
                 price: 130, minLevel: 9, textureName: "food_goat_cheese"),

            Food(type: .dates, nameKey: "food.dates", healAmount: 25,
                 buffEffect: BuffEffect(stat: "critChance", value: 0.08, duration: 10, descriptionKey: "food.dates.buff"),
                 price: 110, minLevel: 8, textureName: "food_dates"),

            Food(type: .cookedLentils, nameKey: "food.cooked_lentils", healAmount: 50,
                 buffEffect: nil, price: 160, minLevel: 11, textureName: "food_lentils"),

            Food(type: .roastedFish, nameKey: "food.roasted_fish", healAmount: 45,
                 buffEffect: BuffEffect(stat: "lifeSteal", value: 0.03, duration: 15, descriptionKey: "food.roasted_fish.buff"),
                 price: 180, minLevel: 13, textureName: "food_roasted_fish"),

            Food(type: .raisinCake, nameKey: "food.raisin_cake", healAmount: 60,
                 buffEffect: BuffEffect(stat: "cleanse", value: 1, duration: 0, descriptionKey: "food.raisin_cake.buff"),
                 price: 220, minLevel: 15, textureName: "food_raisin_cake"),

            Food(type: .roastedLamb, nameKey: "food.roasted_lamb", healAmount: 80,
                 buffEffect: BuffEffect(stat: "damageMultiplier", value: 0.10, duration: 10, descriptionKey: "food.roasted_lamb.buff"),
                 price: 300, minLevel: 18, textureName: "food_roasted_lamb"),

            Food(type: .manna, nameKey: "food.manna", healAmount: 100,
                 buffEffect: BuffEffect(stat: "allStats", value: 0.05, duration: 10, descriptionKey: "food.manna.buff"),
                 price: 500, minLevel: 22, textureName: "food_manna"),

            Food(type: .kingsFeast, nameKey: "food.kings_feast", healAmount: 120,
                 buffEffect: BuffEffect(stat: "damageAndArmor", value: 0.15, duration: 12, descriptionKey: "food.kings_feast.buff"),
                 price: 750, minLevel: 26, textureName: "food_kings_feast"),

            Food(type: .celestialBanquet, nameKey: "food.celestial_banquet", healAmount: 150,
                 buffEffect: BuffEffect(stat: "fullHealAllBuffs", value: 1.0, duration: 8, descriptionKey: "food.celestial_banquet.buff"),
                 price: 1000, minLevel: 30, textureName: "food_celestial_banquet"),
        ]
    }

    func food(for type: FoodType) -> Food? {
        return allFoods.first { $0.type == type }
    }

    func availableFoods(forLevel level: Int) -> [Food] {
        return allFoods.filter { $0.minLevel <= level }
    }
}
