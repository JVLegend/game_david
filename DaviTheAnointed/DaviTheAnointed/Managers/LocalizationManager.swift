import Foundation

final class LocalizationManager {
    static let shared = LocalizationManager()

    private var currentLanguage: GameLanguage = .portuguese
    private var strings: [String: String] = [:]

    private init() {
        loadLanguage(.portuguese)
    }

    var language: GameLanguage {
        return currentLanguage
    }

    func setLanguage(_ language: GameLanguage) {
        currentLanguage = language
        loadLanguage(language)
        UserDefaults.standard.set(language.rawValue, forKey: "game_language")
    }

    func loadSavedLanguage() {
        if let saved = UserDefaults.standard.string(forKey: "game_language"),
           let lang = GameLanguage(rawValue: saved) {
            setLanguage(lang)
        }
    }

    var hasSelectedLanguage: Bool {
        return UserDefaults.standard.string(forKey: "game_language") != nil
    }

    func localize(_ key: String) -> String {
        return strings[key] ?? key
    }

    private func loadLanguage(_ language: GameLanguage) {
        switch language {
        case .portuguese:
            strings = Self.portugueseStrings
        case .english:
            strings = Self.englishStrings
        }
    }

    // MARK: - Portuguese Strings
    static var portugueseStrings: [String: String] = [
        // Menu
        "menu.continue": "Continuar Jornada",
        "menu.inventory": "Inventário",
        "menu.shop": "Loja",
        "menu.achievements": "Conquistas",
        "menu.ranking": "Ranking",
        "menu.pvp": "PvP Arena",
        "menu.clans": "Clãs",
        "menu.challenges": "Desafios Semanais",
        "menu.settings": "Configurações",
        "menu.characters": "Personagens",

        // Language Selection
        "lang.title": "Escolha seu idioma",
        "lang.select": "Selecionar",

        // Login
        "login.title": "Davi: O Ungido",
        "login.google": "Entrar com Google",
        "login.loading": "Carregando...",

        // Maps
        "map.bethlehem_fields": "Campos de Belém",
        "map.valley_of_elah": "Vale de Elá",

        // Battles Map 1
        "battle.wolf_pack": "Alcateia dos Campos",
        "battle.night_invaders": "Invasores Noturnos",
        "battle.mountain_trail": "Trilha da Montanha",
        "battle.lion_boss": "O Leão de Belém",

        // Battles Map 2
        "battle.mountain_bear": "O Urso das Montanhas",
        "battle.philistine_scouts": "Batedores Filisteus",
        "battle.advance_guard": "Guarda Avançada",
        "battle.goliath_boss": "Golias, o Gigante",

        // Enemies
        "enemy.grey_wolf": "Lobo Cinzento",
        "enemy.alpha_wolf": "Lobo Alfa",
        "enemy.rabid_fox": "Raposa Raivosa",
        "enemy.hungry_jackal": "Chacal Faminto",
        "enemy.wild_boar": "Javali Selvagem",
        "enemy.venomous_snake": "Serpente Venenosa",
        "enemy.hunting_eagle": "Águia Caçadora",
        "enemy.giant_scorpion": "Escorpião Gigante",
        "enemy.pack_hyena": "Hiena Matilheira",
        "enemy.hyena_pup": "Hiena Filhote",
        "enemy.lion_boss": "Leão de Belém",
        "enemy.bear_cub": "Filhote de Urso",
        "enemy.brown_bear": "Urso Pardo",
        "enemy.goliath": "Golias",
        "enemy.philistine_scout_spear": "Batedor Filisteu (Lança)",
        "enemy.philistine_scout_bow": "Batedor Filisteu (Arco)",
        "enemy.philistine_scout_shield": "Batedor Filisteu (Escudo)",
        "enemy.philistine_soldier": "Soldado Filisteu",
        "enemy.philistine_archer": "Arqueiro Filisteu",
        "enemy.philistine_elite": "Soldado Filisteu Elite",
        "enemy.philistine_healer": "Curandeiro Filisteu",

        // Food
        "food.barley_bread": "Pão de Cevada",
        "food.grapes": "Cacho de Uvas",
        "food.dried_figs": "Figos Secos",
        "food.olives": "Azeitonas em Azeite",
        "food.honey_bread": "Pão com Mel",
        "food.pomegranate": "Romã",
        "food.goat_cheese": "Queijo de Cabra",
        "food.dates": "Tâmaras",
        "food.cooked_lentils": "Lentilhas Cozidas",
        "food.roasted_fish": "Peixe Assado",
        "food.raisin_cake": "Bolo de Passas",
        "food.roasted_lamb": "Cordeiro Assado",
        "food.manna": "Pão dos Anjos (Maná)",
        "food.kings_feast": "Festa do Rei",
        "food.celestial_banquet": "Banquete Celestial",
        "food.dried_figs.buff": "Remove veneno",
        "food.olives.buff": "+5% Esquiva por 10s",
        "food.pomegranate.buff": "+10% Vel. Ataque por 8s",
        "food.goat_cheese.buff": "+5 Armadura por 10s",
        "food.dates.buff": "+8% Chance Crítica por 10s",
        "food.roasted_fish.buff": "+3% Roubo de Vida por 15s",
        "food.raisin_cake.buff": "Remove debuffs",
        "food.roasted_lamb.buff": "+10% Dano por 10s",
        "food.manna.buff": "+5% todos atributos por 10s",
        "food.kings_feast.buff": "+15% Dano, +10 Armadura por 12s",
        "food.celestial_banquet.buff": "Cura completa + todos buffs por 8s",

        // Characters
        "character.davi": "Davi",
        "character.bigJ": "BigJ",
        "character.sansao": "Sansão",
        "character.josue": "Josué",
        "character.debora": "Débora",
        "character.elias": "Elias",
        "character.gideao": "Gideão",

        // HUD
        "hud.attack": "ATAQUE",
        "hud.defense": "DEFESA",
        "hud.dodge": "ESQUIVA",
        "hud.damage": "Dano",
        "hud.crit_chance": "Chance Crítica",
        "hud.crit_damage": "Dano Crítico",
        "hud.hp_max": "HP Máx",
        "hud.max_armor": "Máx Armadura",
        "hud.melee": "Corpo a corpo",
        "hud.ranged": "À distância",
        "hud.victory": "VITÓRIA!",
        "hud.defeat": "DERROTA",
        "hud.level": "Nível",
        "hud.gold": "Ouro",
        "hud.rubies": "Rubis",

        // Abilities
        "ability.bite": "Mordida",
        "ability.bite.desc": "Dano + sangramento leve",
        "ability.howl": "Uivo",
        "ability.howl.desc": "Buff ataque aliados +20%",
        "ability.charge": "Investida",
        "ability.charge.desc": "Dano em área + stun 1s",
        "ability.venom": "Veneno",
        "ability.venom.desc": "Dano por tempo 3s",
        "ability.dive": "Mergulho",
        "ability.dive.desc": "Ataque aéreo, ignora armadura",
        "ability.sting": "Ferrão",
        "ability.sting.desc": "Veneno + slow",
        "ability.summon_pup": "Invocar Filhote",
        "ability.summon_pup.desc": "Invoca 1 Hiena Filhote",
        "ability.paw_swipe": "Patada",
        "ability.paw_swipe.desc": "Golpe de garra",
        "ability.roar": "Rugido",
        "ability.roar.desc": "Reduz ataque -15% por 5s",
        "ability.death_leap": "Salto Mortal",
        "ability.death_leap.desc": "Dano massivo + stun",
        "ability.bear_hug": "Abraço de Urso",
        "ability.bear_hug.desc": "Agarra e causa dano contínuo 3s",
        "ability.claw_strike": "Golpe de Garra",
        "ability.claw_strike.desc": "Dano + reduz armadura -5",
        "ability.block": "Bloqueio",
        "ability.block.desc": "+50% armadura temporária",
        "ability.fire_arrow": "Flecha Flamejante",
        "ability.fire_arrow.desc": "DoT 2s",
        "ability.counter": "Contra-Ataque",
        "ability.counter.desc": "Reflete 20% dano",
        "ability.heal_allies": "Curar Aliados",
        "ability.heal_allies.desc": "+15 HP aliados a cada 5s",
        "ability.spear_throw": "Lançamento de Lança",
        "ability.spear_throw.desc": "Dano alto à distância",
        "ability.giant_shield": "Escudo Gigante",
        "ability.giant_shield.desc": "Bloqueia próximo ataque",
        "ability.stomp": "Pisotão",
        "ability.stomp.desc": "AoE + stun 2s",
        "ability.giant_fury": "Fúria do Gigante",
        "ability.giant_fury.desc": "Dano +30% + investida",

        // Weapons
        "item.weapon.shepherd_staff": "Cajado de Pastor",
        "item.weapon.reinforced_staff": "Cajado Reforçado",
        "item.weapon.shearing_knife": "Faca de Tosquia",
        "item.weapon.wooden_club": "Porrete de Madeira",
        "item.weapon.bronze_dagger": "Adaga de Bronze",
        "item.weapon.short_bronze_sword": "Espada de Bronze Curta",
        "item.weapon.iron_mace": "Maça de Ferro",
        "item.weapon.philistine_sword": "Espada Filisteia",
        "item.weapon.desert_scimitar": "Cimitarra do Deserto",
        "item.weapon.iron_sword": "Espada de Ferro",
        "item.weapon.captain_blade": "Lâmina do Capitão",
        "item.weapon.royal_silver_sword": "Espada Real de Prata",
        "item.weapon.oath_sword": "Espada do Juramento",
        "item.weapon.seraph_blade": "Lâmina Serafim",
        "item.weapon.king_david_sword": "Espada do Rei Davi",

        // Head
        "item.head.pastor_band": "Faixa de Pastor",
        "item.head.simple_headband": "Faixa de Cabeça Simples",
        "item.head.leather_hood": "Capuz de Couro",
        "item.head.light_bronze_helm": "Elmo de Bronze Leve",
        "item.head.philistine_bronze_helm": "Elmo de Bronze Filisteu",
        "item.head.simple_iron_helmet": "Capacete de Ferro Simples",
        "item.head.desert_helm": "Elmo do Deserto",
        "item.head.bronze_crown": "Coroa de Bronze",
        "item.head.warrior_helm": "Elmo do Guerreiro",
        "item.head.royal_silver_helmet": "Capacete Real de Prata",
        "item.head.faith_helm": "Elmo da Fé",
        "item.head.anointed_iron_crown": "Coroa de Ferro Ungido",
        "item.head.goliath_helm_adapted": "Elmo de Golias (Adaptado)",
        "item.head.seraph_helmet": "Capacete Serafim",
        "item.head.crown_of_the_anointed": "Coroa do Ungido de Deus",

        // Body
        "item.body.shepherd_tunic": "Túnica de Pastor",
        "item.body.tanned_leather_vest": "Veste de Couro Curtido",
        "item.body.reinforced_leather": "Couraça de Couro Reforçado",
        "item.body.lion_skin": "Pele de Leão",
        "item.body.light_chainmail": "Cota de Malha Leve",
        "item.body.bronze_cuirass": "Couraça de Bronze",
        "item.body.scale_armor": "Armadura de Escamas",
        "item.body.philistine_chainmail": "Cota de Malha Filisteia",
        "item.body.desert_cuirass": "Couraça do Deserto",
        "item.body.royal_bronze_armor": "Armadura Real de Bronze",
        "item.body.forged_iron_cuirass": "Couraça de Ferro Forjado",
        "item.body.covenant_breastplate": "Peitoral da Aliança",
        "item.body.general_armor": "Armadura do General",
        "item.body.archangel_cuirass": "Couraça do Arcanjo",
        "item.body.sacred_king_mantle": "Manto Sagrado do Rei",

        // Shield
        "item.shield.wooden_shield": "Escudo de Madeira",
        "item.shield.leather_shield": "Escudo de Couro",
        "item.shield.bronze_round_shield": "Escudo Redondo de Bronze",
        "item.shield.plank_shield": "Escudo de Tábuas",
        "item.shield.iron_buckler": "Broquel de Ferro",
        "item.shield.philistine_bronze_shield": "Escudo de Bronze Filisteu",
        "item.shield.sentinel_shield": "Escudo do Sentinela",
        "item.shield.iron_shield": "Escudo de Ferro",
        "item.shield.desert_shield": "Escudo do Deserto",
        "item.shield.royal_bronze_shield": "Escudo Real de Bronze",
        "item.shield.general_shield": "Escudo do General",
        "item.shield.iron_tower_shield": "Escudo Torre de Ferro",
        "item.shield.covenant_shield": "Escudo do Pacto",
        "item.shield.seraphic_shield": "Escudo Seráfico",
        "item.shield.ark_sacred_shield": "Escudo da Arca Sagrada",

        // Two-hand
        "item.twohand.cedar_staff": "Cajado Grande de Cedro",
        "item.twohand.wooden_spear": "Lança de Madeira",
        "item.twohand.simple_bow": "Arco Simples",
        "item.twohand.bronze_spear": "Lança de Bronze",
        "item.twohand.lumber_axe": "Machado de Lenhador",
        "item.twohand.goliath_sword": "Espada de Golias",
        "item.twohand.composite_war_bow": "Arco Composto de Guerra",
        "item.twohand.iron_halberd": "Alabarda de Ferro",
        "item.twohand.desert_lance": "Lança do Deserto",
        "item.twohand.war_axe": "Machado de Guerra",
        "item.twohand.royal_longbow": "Arco Longo Real",
        "item.twohand.iron_bastard_sword": "Espada Bastarda de Ferro",
        "item.twohand.judgment_lance": "Lança do Juízo",
        "item.twohand.divine_axe": "Machado Divino",
        "item.twohand.moses_staff": "Cajado de Moisés",

        // Settings
        "settings.title": "Configurações",
        "settings.language": "Idioma",
        "settings.sound": "Som",
        "settings.music": "Música",
        "settings.notifications": "Notificações",
        "settings.account": "Conta",
        "settings.logout": "Sair",

        // General
        "general.buy": "Comprar",
        "general.sell": "Vender",
        "general.equip": "Equipar",
        "general.unequip": "Desequipar",
        "general.close": "Fechar",
        "general.confirm": "Confirmar",
        "general.cancel": "Cancelar",
        "general.back": "Voltar",
        "general.ok": "OK",
    ]

    // MARK: - English Strings
    static var englishStrings: [String: String] = [
        // Menu
        "menu.continue": "Continue Journey",
        "menu.inventory": "Inventory",
        "menu.shop": "Shop",
        "menu.achievements": "Achievements",
        "menu.ranking": "Ranking",
        "menu.pvp": "PvP Arena",
        "menu.clans": "Clans",
        "menu.challenges": "Weekly Challenges",
        "menu.settings": "Settings",
        "menu.characters": "Characters",

        // Language Selection
        "lang.title": "Choose your language",
        "lang.select": "Select",

        // Login
        "login.title": "David: The Anointed",
        "login.google": "Sign in with Google",
        "login.loading": "Loading...",

        // Maps
        "map.bethlehem_fields": "Fields of Bethlehem",
        "map.valley_of_elah": "Valley of Elah",

        // Battles Map 1
        "battle.wolf_pack": "Wolf Pack",
        "battle.night_invaders": "Night Invaders",
        "battle.mountain_trail": "Mountain Trail",
        "battle.lion_boss": "The Lion of Bethlehem",

        // Battles Map 2
        "battle.mountain_bear": "The Mountain Bear",
        "battle.philistine_scouts": "Philistine Scouts",
        "battle.advance_guard": "Advance Guard",
        "battle.goliath_boss": "Goliath the Giant",

        // Enemies
        "enemy.grey_wolf": "Grey Wolf",
        "enemy.alpha_wolf": "Alpha Wolf",
        "enemy.rabid_fox": "Rabid Fox",
        "enemy.hungry_jackal": "Hungry Jackal",
        "enemy.wild_boar": "Wild Boar",
        "enemy.venomous_snake": "Venomous Snake",
        "enemy.hunting_eagle": "Hunting Eagle",
        "enemy.giant_scorpion": "Giant Scorpion",
        "enemy.pack_hyena": "Pack Hyena",
        "enemy.hyena_pup": "Hyena Pup",
        "enemy.lion_boss": "Lion of Bethlehem",
        "enemy.bear_cub": "Bear Cub",
        "enemy.brown_bear": "Brown Bear",
        "enemy.goliath": "Goliath",
        "enemy.philistine_scout_spear": "Philistine Scout (Spear)",
        "enemy.philistine_scout_bow": "Philistine Scout (Bow)",
        "enemy.philistine_scout_shield": "Philistine Scout (Shield)",
        "enemy.philistine_soldier": "Philistine Soldier",
        "enemy.philistine_archer": "Philistine Archer",
        "enemy.philistine_elite": "Elite Philistine Soldier",
        "enemy.philistine_healer": "Philistine Healer",

        // Food
        "food.barley_bread": "Barley Bread",
        "food.grapes": "Grape Bunch",
        "food.dried_figs": "Dried Figs",
        "food.olives": "Olives in Oil",
        "food.honey_bread": "Honey Bread",
        "food.pomegranate": "Pomegranate",
        "food.goat_cheese": "Goat Cheese",
        "food.dates": "Dates",
        "food.cooked_lentils": "Cooked Lentils",
        "food.roasted_fish": "Roasted Fish",
        "food.raisin_cake": "Raisin Cake",
        "food.roasted_lamb": "Roasted Lamb",
        "food.manna": "Angel's Bread (Manna)",
        "food.kings_feast": "King's Feast",
        "food.celestial_banquet": "Celestial Banquet",
        "food.dried_figs.buff": "Removes poison",
        "food.olives.buff": "+5% Dodge for 10s",
        "food.pomegranate.buff": "+10% Attack Speed for 8s",
        "food.goat_cheese.buff": "+5 Armor for 10s",
        "food.dates.buff": "+8% Crit Chance for 10s",
        "food.roasted_fish.buff": "+3% Life Steal for 15s",
        "food.raisin_cake.buff": "Removes debuffs",
        "food.roasted_lamb.buff": "+10% Damage for 10s",
        "food.manna.buff": "+5% all stats for 10s",
        "food.kings_feast.buff": "+15% Damage, +10 Armor for 12s",
        "food.celestial_banquet.buff": "Full heal + all buffs for 8s",

        // Characters
        "character.davi": "David",
        "character.bigJ": "BigJ",
        "character.sansao": "Samson",
        "character.josue": "Joshua",
        "character.debora": "Deborah",
        "character.elias": "Elijah",
        "character.gideao": "Gideon",

        // HUD
        "hud.attack": "ATTACK",
        "hud.defense": "DEFENSE",
        "hud.dodge": "DODGE",
        "hud.damage": "Damage",
        "hud.crit_chance": "Crit Chance",
        "hud.crit_damage": "Crit Damage",
        "hud.hp_max": "Max HP",
        "hud.max_armor": "Max Armor",
        "hud.melee": "Melee",
        "hud.ranged": "Ranged",
        "hud.victory": "VICTORY!",
        "hud.defeat": "DEFEAT",
        "hud.level": "Level",
        "hud.gold": "Gold",
        "hud.rubies": "Rubies",

        // Abilities
        "ability.bite": "Bite",
        "ability.bite.desc": "Damage + light bleed",
        "ability.howl": "Howl",
        "ability.howl.desc": "Buff allies attack +20%",
        "ability.charge": "Charge",
        "ability.charge.desc": "AoE damage + stun 1s",
        "ability.venom": "Venom",
        "ability.venom.desc": "DoT for 3s",
        "ability.dive": "Dive",
        "ability.dive.desc": "Aerial attack, ignores armor",
        "ability.sting": "Sting",
        "ability.sting.desc": "Poison + slow",
        "ability.summon_pup": "Summon Pup",
        "ability.summon_pup.desc": "Summons 1 Hyena Pup",
        "ability.paw_swipe": "Paw Swipe",
        "ability.paw_swipe.desc": "Claw strike",
        "ability.roar": "Roar",
        "ability.roar.desc": "Reduces attack -15% for 5s",
        "ability.death_leap": "Death Leap",
        "ability.death_leap.desc": "Massive damage + stun",
        "ability.bear_hug": "Bear Hug",
        "ability.bear_hug.desc": "Grabs and deals continuous damage 3s",
        "ability.claw_strike": "Claw Strike",
        "ability.claw_strike.desc": "Damage + reduces armor -5",
        "ability.block": "Block",
        "ability.block.desc": "+50% temporary armor",
        "ability.fire_arrow": "Flaming Arrow",
        "ability.fire_arrow.desc": "DoT 2s",
        "ability.counter": "Counter-Attack",
        "ability.counter.desc": "Reflects 20% damage",
        "ability.heal_allies": "Heal Allies",
        "ability.heal_allies.desc": "+15 HP allies every 5s",
        "ability.spear_throw": "Spear Throw",
        "ability.spear_throw.desc": "High ranged damage",
        "ability.giant_shield": "Giant Shield",
        "ability.giant_shield.desc": "Blocks next attack",
        "ability.stomp": "Stomp",
        "ability.stomp.desc": "AoE + stun 2s",
        "ability.giant_fury": "Giant's Fury",
        "ability.giant_fury.desc": "+30% damage + charge",

        // Weapons
        "item.weapon.shepherd_staff": "Shepherd's Staff",
        "item.weapon.reinforced_staff": "Reinforced Staff",
        "item.weapon.shearing_knife": "Shearing Knife",
        "item.weapon.wooden_club": "Wooden Club",
        "item.weapon.bronze_dagger": "Bronze Dagger",
        "item.weapon.short_bronze_sword": "Short Bronze Sword",
        "item.weapon.iron_mace": "Iron Mace",
        "item.weapon.philistine_sword": "Philistine Sword",
        "item.weapon.desert_scimitar": "Desert Scimitar",
        "item.weapon.iron_sword": "Iron Sword",
        "item.weapon.captain_blade": "Captain's Blade",
        "item.weapon.royal_silver_sword": "Royal Silver Sword",
        "item.weapon.oath_sword": "Oath Sword",
        "item.weapon.seraph_blade": "Seraph Blade",
        "item.weapon.king_david_sword": "King David's Sword",

        // Head
        "item.head.pastor_band": "Shepherd's Band",
        "item.head.simple_headband": "Simple Headband",
        "item.head.leather_hood": "Leather Hood",
        "item.head.light_bronze_helm": "Light Bronze Helm",
        "item.head.philistine_bronze_helm": "Philistine Bronze Helm",
        "item.head.simple_iron_helmet": "Simple Iron Helmet",
        "item.head.desert_helm": "Desert Helm",
        "item.head.bronze_crown": "Bronze Crown",
        "item.head.warrior_helm": "Warrior Helm",
        "item.head.royal_silver_helmet": "Royal Silver Helmet",
        "item.head.faith_helm": "Helm of Faith",
        "item.head.anointed_iron_crown": "Anointed Iron Crown",
        "item.head.goliath_helm_adapted": "Goliath's Helm (Adapted)",
        "item.head.seraph_helmet": "Seraph Helmet",
        "item.head.crown_of_the_anointed": "Crown of the Anointed",

        // Body
        "item.body.shepherd_tunic": "Shepherd's Tunic",
        "item.body.tanned_leather_vest": "Tanned Leather Vest",
        "item.body.reinforced_leather": "Reinforced Leather",
        "item.body.lion_skin": "Lion Skin",
        "item.body.light_chainmail": "Light Chainmail",
        "item.body.bronze_cuirass": "Bronze Cuirass",
        "item.body.scale_armor": "Scale Armor",
        "item.body.philistine_chainmail": "Philistine Chainmail",
        "item.body.desert_cuirass": "Desert Cuirass",
        "item.body.royal_bronze_armor": "Royal Bronze Armor",
        "item.body.forged_iron_cuirass": "Forged Iron Cuirass",
        "item.body.covenant_breastplate": "Covenant Breastplate",
        "item.body.general_armor": "General's Armor",
        "item.body.archangel_cuirass": "Archangel Cuirass",
        "item.body.sacred_king_mantle": "Sacred King's Mantle",

        // Shield
        "item.shield.wooden_shield": "Wooden Shield",
        "item.shield.leather_shield": "Leather Shield",
        "item.shield.bronze_round_shield": "Bronze Round Shield",
        "item.shield.plank_shield": "Plank Shield",
        "item.shield.iron_buckler": "Iron Buckler",
        "item.shield.philistine_bronze_shield": "Philistine Bronze Shield",
        "item.shield.sentinel_shield": "Sentinel Shield",
        "item.shield.iron_shield": "Iron Shield",
        "item.shield.desert_shield": "Desert Shield",
        "item.shield.royal_bronze_shield": "Royal Bronze Shield",
        "item.shield.general_shield": "General's Shield",
        "item.shield.iron_tower_shield": "Iron Tower Shield",
        "item.shield.covenant_shield": "Covenant Shield",
        "item.shield.seraphic_shield": "Seraphic Shield",
        "item.shield.ark_sacred_shield": "Ark Sacred Shield",

        // Two-hand
        "item.twohand.cedar_staff": "Cedar Grand Staff",
        "item.twohand.wooden_spear": "Wooden Spear",
        "item.twohand.simple_bow": "Simple Bow",
        "item.twohand.bronze_spear": "Bronze Spear",
        "item.twohand.lumber_axe": "Lumber Axe",
        "item.twohand.goliath_sword": "Goliath's Sword",
        "item.twohand.composite_war_bow": "Composite War Bow",
        "item.twohand.iron_halberd": "Iron Halberd",
        "item.twohand.desert_lance": "Desert Lance",
        "item.twohand.war_axe": "War Axe",
        "item.twohand.royal_longbow": "Royal Longbow",
        "item.twohand.iron_bastard_sword": "Iron Bastard Sword",
        "item.twohand.judgment_lance": "Judgment Lance",
        "item.twohand.divine_axe": "Divine Axe",
        "item.twohand.moses_staff": "Moses' Staff",

        // Settings
        "settings.title": "Settings",
        "settings.language": "Language",
        "settings.sound": "Sound",
        "settings.music": "Music",
        "settings.notifications": "Notifications",
        "settings.account": "Account",
        "settings.logout": "Sign Out",

        // General
        "general.buy": "Buy",
        "general.sell": "Sell",
        "general.equip": "Equip",
        "general.unequip": "Unequip",
        "general.close": "Close",
        "general.confirm": "Confirm",
        "general.cancel": "Cancel",
        "general.back": "Back",
        "general.ok": "OK",
    ]
}
