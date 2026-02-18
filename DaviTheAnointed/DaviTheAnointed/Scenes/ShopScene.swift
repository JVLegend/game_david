import SpriteKit

class ShopScene: SKScene {

    private let loc = LocalizationManager.shared
    private var currentTab: ShopTab = .buy
    private var selectedSlotFilter: EquipmentSlot? = nil
    private var scrollOffset: Int = 0

    enum ShopTab {
        case buy, sell, chests, characters
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        removeAllChildren()

        guard let player = GameManager.shared.playerData else { return }

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.shop")
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 30)
        addChild(title)

        // Gold display
        let goldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goldLabel.text = "\(player.gold)"
        goldLabel.fontSize = 14
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: 15, y: size.height - 30)
        addChild(goldLabel)

        // Tabs
        let tabs: [(String, ShopTab, String)] = [
            (loc.localize("general.buy"), .buy, "tab_buy"),
            (loc.localize("general.sell"), .sell, "tab_sell"),
            ("Baus", .chests, "tab_chests"),
            (loc.localize("menu.characters"), .characters, "tab_characters"),
        ]

        for (i, tab) in tabs.enumerated() {
            let x = CGFloat(i) * 120 + size.width * 0.25
            let btn = createTabButton(text: tab.0, position: CGPoint(x: x, y: size.height - 65), name: tab.2, isActive: currentTab == tab.1)
            addChild(btn)
        }

        // Content area
        switch currentTab {
        case .buy:
            setupBuyTab(player: player)
        case .sell:
            setupSellTab(player: player)
        case .chests:
            setupChestsTab()
        case .characters:
            setupCharactersTab(player: player)
        }

        // Back button
        let backBtn = createButton(text: loc.localize("general.back"), position: CGPoint(x: 60, y: 25), name: "btn_back")
        addChild(backBtn)
    }

    private func setupBuyTab(player: PlayerData) {
        let items = EquipmentDatabase.shared.availableItems(forLevel: player.level, slot: selectedSlotFilter)
            .filter { $0.price > 0 }
            .sorted { $0.price < $1.price }

        // Slot filter buttons
        let slots: [(String, EquipmentSlot?)] = [
            ("All", nil), ("Head", .head), ("Body", .body), ("Wpn", .mainHand),
            ("Shield", .offHand), ("2H", .twoHand), ("Feet", .feet), ("Gloves", .gloves),
        ]

        for (i, slot) in slots.enumerated() {
            let x = CGFloat(i) * 65 + 50
            let isActive = selectedSlotFilter == slot.1
            let btn = createSmallButton(text: slot.0, position: CGPoint(x: x, y: size.height - 95), name: "filter_\(slot.1?.rawValue ?? "all")", isActive: isActive)
            addChild(btn)
        }

        // Item grid
        let columns = 4
        let itemSize: CGFloat = 70
        let startX: CGFloat = size.width * 0.3
        let startY: CGFloat = size.height - 130

        for (i, item) in items.prefix(12).enumerated() {
            let col = i % columns
            let row = i / columns
            let x = startX + CGFloat(col) * (itemSize + 10)
            let y = startY - CGFloat(row) * (itemSize + 10)

            let itemNode = createItemNode(item: item, position: CGPoint(x: x, y: y), canAfford: player.gold >= item.price)
            addChild(itemNode)
        }
    }

    private func setupSellTab(player: PlayerData) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Inventory: \(player.inventory.count) items"
        label.fontSize = 14
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)

        for (i, itemId) in player.inventory.prefix(12).enumerated() {
            guard let item = EquipmentDatabase.shared.item(withId: itemId) else { continue }
            let col = i % 4
            let row = i / 4
            let x = size.width * 0.3 + CGFloat(col) * 80
            let y = size.height * 0.55 - CGFloat(row) * 80

            let sellNode = createSellItemNode(item: item, position: CGPoint(x: x, y: y))
            addChild(sellNode)
        }
    }

    private func setupChestsTab() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "Coming soon..."
        label.fontSize = 14
        label.fontColor = SKColor(white: 0.5, alpha: 1)
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }

    private func setupCharactersTab(player: PlayerData) {
        let characters = PlayableCharacter.allCases

        for (i, character) in characters.enumerated() {
            let x = CGFloat(i % 4) * 130 + size.width * 0.2
            let y = size.height * 0.55 - CGFloat(i / 4) * 120

            let charNode = createCharacterNode(character: character, player: player, position: CGPoint(x: x, y: y))
            addChild(charNode)
        }
    }

    private func createItemNode(item: Equipment, position: CGPoint, canAfford: Bool) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "buy_\(item.id)"

        let bg = SKShapeNode(rectOf: CGSize(width: 65, height: 65), cornerRadius: 4)
        bg.fillColor = SKColor(white: 0.15, alpha: 0.9)
        bg.strokeColor = rarityColor(item.rarity)
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = String(item.localizedName.prefix(6))
        nameLabel.fontSize = 8
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 5)
        nameLabel.name = node.name
        node.addChild(nameLabel)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        priceLabel.text = "\(item.price)"
        priceLabel.fontSize = 9
        priceLabel.fontColor = canAfford ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 1)
        priceLabel.position = CGPoint(x: 0, y: -12)
        priceLabel.name = node.name
        node.addChild(priceLabel)

        if !canAfford { node.alpha = 0.5 }

        return node
    }

    private func createSellItemNode(item: Equipment, position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "sell_\(item.id)"

        let bg = SKShapeNode(rectOf: CGSize(width: 65, height: 65), cornerRadius: 4)
        bg.fillColor = SKColor(white: 0.15, alpha: 0.9)
        bg.strokeColor = rarityColor(item.rarity)
        bg.lineWidth = 1
        bg.name = node.name
        node.addChild(bg)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = String(item.localizedName.prefix(6))
        nameLabel.fontSize = 8
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 5)
        nameLabel.name = node.name
        node.addChild(nameLabel)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        priceLabel.text = "\(item.price / 2)"
        priceLabel.fontSize = 9
        priceLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        priceLabel.position = CGPoint(x: 0, y: -12)
        priceLabel.name = node.name
        node.addChild(priceLabel)

        return node
    }

    private func createCharacterNode(character: PlayableCharacter, player: PlayerData, position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "char_\(character.rawValue)"

        let isUnlocked = player.unlockedCharacters.contains(character)
        let canBuy = !isUnlocked && player.highestMapCompleted >= character.requiredMap && player.gold >= character.price

        let bg = SKShapeNode(rectOf: CGSize(width: 110, height: 100), cornerRadius: 6)
        bg.fillColor = isUnlocked ?
            SKColor(red: 0.2, green: 0.35, blue: 0.2, alpha: 0.9) :
            SKColor(white: 0.15, alpha: 0.9)
        bg.strokeColor = isUnlocked ?
            SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1) :
            SKColor(white: 0.3, alpha: 0.5)
        bg.lineWidth = isUnlocked ? 2 : 1
        bg.name = node.name
        node.addChild(bg)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = loc.localize("character.\(character.rawValue)")
        nameLabel.fontSize = 12
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 25)
        nameLabel.name = node.name
        node.addChild(nameLabel)

        if isUnlocked {
            let ownedLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            ownedLabel.text = player.activeCharacter == character ? "ACTIVE" : "OWNED"
            ownedLabel.fontSize = 10
            ownedLabel.fontColor = SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1)
            ownedLabel.position = CGPoint(x: 0, y: -20)
            ownedLabel.name = node.name
            node.addChild(ownedLabel)
        } else {
            let priceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            priceLabel.text = "\(character.price)"
            priceLabel.fontSize = 11
            priceLabel.fontColor = canBuy ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(white: 0.4, alpha: 1)
            priceLabel.position = CGPoint(x: 0, y: -10)
            priceLabel.name = node.name
            node.addChild(priceLabel)

            if player.highestMapCompleted < character.requiredMap {
                let lockLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
                lockLabel.text = "Map \(character.requiredMap) req."
                lockLabel.fontSize = 8
                lockLabel.fontColor = SKColor(white: 0.4, alpha: 1)
                lockLabel.position = CGPoint(x: 0, y: -28)
                node.addChild(lockLabel)
                node.alpha = 0.4
            }
        }

        return node
    }

    private func rarityColor(_ rarity: ItemRarity) -> SKColor {
        switch rarity {
        case .common: return SKColor(white: 0.5, alpha: 1)
        case .uncommon: return SKColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1)
        case .rare: return SKColor(red: 0.3, green: 0.5, blue: 1, alpha: 1)
        case .epic: return SKColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1)
        case .legendary: return SKColor(red: 1, green: 0.75, blue: 0.2, alpha: 1)
        }
    }

    private func createTabButton(text: String, position: CGPoint, name: String, isActive: Bool) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 28), cornerRadius: 4)
        bg.fillColor = isActive ?
            SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1) :
            SKColor(white: 0.2, alpha: 0.8)
        bg.strokeColor = isActive ?
            SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1) :
            SKColor(white: 0.3, alpha: 0.5)
        bg.name = name
        node.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 12
        label.fontColor = isActive ? .white : SKColor(white: 0.6, alpha: 1)
        label.verticalAlignmentMode = .center
        label.name = name
        node.addChild(label)

        return node
    }

    private func createSmallButton(text: String, position: CGPoint, name: String, isActive: Bool) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 55, height: 20), cornerRadius: 3)
        bg.fillColor = isActive ? SKColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1) : SKColor(white: 0.15, alpha: 0.8)
        bg.strokeColor = isActive ? SKColor(red: 0.7, green: 0.5, blue: 0.25, alpha: 1) : .clear
        bg.name = name
        node.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = text
        label.fontSize = 9
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        node.addChild(label)

        return node
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 90, height: 30), cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.15, alpha: 0.9)
        bg.strokeColor = SKColor(red: 0.6, green: 0.45, blue: 0.2, alpha: 1)
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        container.addChild(label)

        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            guard let name = node.name else { continue }

            switch name {
            case "btn_back":
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
                return
            case "tab_buy":
                currentTab = .buy; setupUI()
            case "tab_sell":
                currentTab = .sell; setupUI()
            case "tab_chests":
                currentTab = .chests; setupUI()
            case "tab_characters":
                currentTab = .characters; setupUI()
            default:
                if name.hasPrefix("buy_") {
                    let itemId = String(name.dropFirst(4))
                    buyItem(itemId)
                } else if name.hasPrefix("char_") {
                    let charRaw = String(name.dropFirst(5))
                    if let character = PlayableCharacter(rawValue: charRaw) {
                        handleCharacterTap(character)
                    }
                } else if name.hasPrefix("filter_") {
                    let filterRaw = String(name.dropFirst(7))
                    selectedSlotFilter = filterRaw == "all" ? nil : EquipmentSlot(rawValue: filterRaw)
                    setupUI()
                }
            }
        }
    }

    private func buyItem(_ itemId: String) {
        guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return }
        guard GameManager.shared.spendGold(item.price) else { return }
        GameManager.shared.playerData?.inventory.append(itemId)
        GameManager.shared.save()
        setupUI()
    }

    private func handleCharacterTap(_ character: PlayableCharacter) {
        guard let player = GameManager.shared.playerData else { return }

        if player.unlockedCharacters.contains(character) {
            _ = GameManager.shared.selectCharacter(character)
        } else {
            _ = GameManager.shared.buyCharacter(character)
        }
        setupUI()
    }
}
