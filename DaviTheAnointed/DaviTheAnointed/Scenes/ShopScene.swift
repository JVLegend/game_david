import SpriteKit

class ShopScene: SKScene {

    private let loc = LocalizationManager.shared
    private var currentTab: ShopTab = .buy
    private var selectedSlotFilter: EquipmentSlot? = nil

    enum ShopTab {
        case buy, sell, chests, characters
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        removeAllChildren()

        guard let player = GameManager.shared.playerData else { return }

        // Background
        let bg = SKSpriteNode(imageNamed: "background_menu")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.alpha = 0.4
        addChild(bg)

        let safeArea = view?.safeAreaInsets ?? .zero
        let safeL = max(40, safeArea.left)
        let safeR = max(40, safeArea.right)

        // Title Centralizado
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.shop")
        title.fontSize = 28
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 45)
        addChild(title)

        // Botão Voltar (Top Esquerdo)
        let backBtn = createButton(text: "← \(loc.localize("general.back"))", 
                                 position: CGPoint(x: safeL + 60, y: size.height - 40), 
                                 name: "btn_back", 
                                 size: CGSize(width: 120, height: 40))
        addChild(backBtn)

        // Gold Display (Top Direito)
        let goldContainer = SKSpriteNode(imageNamed: "button_texture")
        goldContainer.size = CGSize(width: 140, height: 40)
        goldContainer.position = CGPoint(x: size.width - safeR - 70, y: size.height - 40)
        goldContainer.color = .black
        goldContainer.colorBlendFactor = 0.3
        addChild(goldContainer)

        let goldIcon = SKSpriteNode(imageNamed: "icon_gold")
        goldIcon.size = CGSize(width: 22, height: 22)
        goldIcon.position = CGPoint(x: -50, y: 0)
        goldContainer.addChild(goldIcon)

        let goldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goldLabel.text = "\(player.gold)"
        goldLabel.fontSize = 16
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.verticalAlignmentMode = .center
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: -35, y: 0)
        goldContainer.addChild(goldLabel)

        // Abas (Tabs) - Abaixo do título
        let tabs: [(String, ShopTab, String)] = [
            (loc.localize("general.buy"), .buy, "tab_buy"),
            (loc.localize("general.sell"), .sell, "tab_sell"),
            ("Baús", .chests, "tab_chests"),
            (loc.localize("menu.characters"), .characters, "tab_characters"),
        ]
        
        let tabW: CGFloat = 120
        let tabTotalW = tabW * CGFloat(tabs.count)
        let tabStartX = (size.width - tabTotalW) / 2 + tabW / 2
        let tabY = size.height - 90

        for (i, tab) in tabs.enumerated() {
            let x = tabStartX + CGFloat(i) * tabW
            let isActive = currentTab == tab.1
            let btn = createTabButton(text: tab.0, position: CGPoint(x: x, y: tabY), name: tab.2, isActive: isActive)
            addChild(btn)
        }

        // Área de Conteúdo
        let contentSize = CGSize(width: size.width - safeL - safeR, height: size.height - 140)
        let contentPos = CGPoint(x: size.width / 2, y: (size.height - 110) / 2)
        
        // Fundo da área de conteúdo
        let contentBg = SKShapeNode(rectOf: contentSize, cornerRadius: 12)
        contentBg.fillColor = SKColor(white: 0, alpha: 0.5)
        contentBg.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 0.8)
        contentBg.position = contentPos
        contentBg.zPosition = -1
        addChild(contentBg)

        switch currentTab {
        case .buy:
            setupBuyTab(player: player, area: contentSize, center: contentPos)
        case .sell:
            setupSellTab(player: player, area: contentSize, center: contentPos)
        case .chests:
            setupChestsTab(area: contentSize, center: contentPos)
        case .characters:
            setupCharactersTab(player: player, area: contentSize, center: contentPos)
        }
    }

    private func createTabButton(text: String, position: CGPoint, name: String, isActive: Bool) -> SKNode {
        let btn = SKSpriteNode(imageNamed: "button_texture")
        btn.size = CGSize(width: 115, height: 35)
        btn.position = position
        btn.name = name
        
        if !isActive {
            btn.color = .black
            btn.colorBlendFactor = 0.5
            btn.alpha = 0.7
        } else {
            btn.color = .orange
            btn.colorBlendFactor = 0.2
        }

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 13
        label.fontColor = isActive ? .white : .lightGray
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = name
        btn.addChild(label)
        
        return btn
    }

    private func setupBuyTab(player: PlayerData, area: CGSize, center: CGPoint) {
        let items = EquipmentDatabase.shared.availableItems(forLevel: player.level, slot: selectedSlotFilter)
            .filter { $0.price > 0 }
            .sorted { $0.price < $1.price }

        // Filtros de Slot
        let slots: [(String, EquipmentSlot?)] = [
            ("Todos", nil), ("Cabeça", .head), ("Corpo", .body), ("Arma", .mainHand),
            ("Escudo", .offHand), ("Pés", .feet), ("Luvas", .gloves),
        ]
        
        let filterW: CGFloat = 85
        let filterStartX = center.x - (CGFloat(slots.count - 1) * filterW) / 2
        let filterY = center.y + area.height / 2 - 30

        for (i, slot) in slots.enumerated() {
            let x = filterStartX + CGFloat(i) * filterW
            let isActive = selectedSlotFilter == slot.1
            let btn = createSmallFilterButton(text: slot.0, position: CGPoint(x: x, y: filterY), name: "filter_\(slot.1?.rawValue ?? "all")", isActive: isActive)
            addChild(btn)
        }

        // Grid de Itens
        let cols = 5
        let itemSize: CGFloat = 90
        let spacing: CGFloat = 20
        let gridStartX = center.x - (CGFloat(cols - 1) * (itemSize + spacing)) / 2
        let startY = filterY - 70

        for (i, item) in items.prefix(10).enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gridStartX + CGFloat(col) * (itemSize + spacing)
            let y = startY - CGFloat(row) * (itemSize + spacing)

            let itemNode = createItemCard(item: item, position: CGPoint(x: x, y: y), canAfford: player.gold >= item.price)
            addChild(itemNode)
        }
    }

    private func createSmallFilterButton(text: String, position: CGPoint, name: String, isActive: Bool) -> SKNode {
        let btn = SKSpriteNode(imageNamed: "button_texture")
        btn.size = CGSize(width: 80, height: 25)
        btn.position = position
        btn.name = name
        
        if !isActive {
            btn.color = .black
            btn.colorBlendFactor = 0.6
        }

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 10
        label.fontColor = isActive ? .white : .gray
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = name
        btn.addChild(label)
        
        return btn
    }

    private func createItemCard(item: Equipment, position: CGPoint, canAfford: Bool) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "buy_\(item.id)"

        let bg = SKShapeNode(rectOf: CGSize(width: 85, height: 85), cornerRadius: 8)
        bg.fillColor = SKColor(white: 0.1, alpha: 0.9)
        bg.strokeColor = item.rarity.color
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = item.localizedName
        nameLabel.fontSize = 10
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: 15)
        nameLabel.name = node.name
        node.addChild(nameLabel)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        priceLabel.text = "🪙 \(item.price)"
        priceLabel.fontSize = 12
        priceLabel.fontColor = canAfford ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .red
        priceLabel.position = CGPoint(x: 0, y: -15)
        priceLabel.name = node.name
        node.addChild(priceLabel)

        let slotLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        slotLabel.text = item.slot.rawValue.uppercased()
        slotLabel.fontSize = 8
        slotLabel.fontColor = .lightGray
        slotLabel.position = CGPoint(x: 0, y: -30)
        slotLabel.name = node.name
        node.addChild(slotLabel)

        if !canAfford { node.alpha = 0.6 }

        return node
    }

    private func setupSellTab(player: PlayerData, area: CGSize, center: CGPoint) {
        // Implementação similar ao Buy mas com itens do inventário
        let gridStartX = center.x - (4 * 100) / 2
        let startY = center.y + area.height / 2 - 60

        if player.inventory.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            emptyLabel.text = "Inventário Vazio"
            emptyLabel.position = center
            addChild(emptyLabel)
            return
        }

        for (i, itemId) in player.inventory.prefix(12).enumerated() {
            guard let item = EquipmentDatabase.shared.item(withId: itemId) else { continue }
            let col = i % 5
            let row = i / 5
            let x = gridStartX + CGFloat(col) * 105
            let y = startY - CGFloat(row) * 105

            let sellNode = createSellCard(item: item, position: CGPoint(x: x, y: y))
            addChild(sellNode)
        }
    }

    private func createSellCard(item: Equipment, position: CGPoint) -> SKNode {
        let node = createItemCard(item: item, position: position, canAfford: true)
        node.name = "sell_\(item.id)"
        // Ajustar preço para venda (metade)
        if let priceLbl = node.children.first(where: { ($0 as? SKLabelNode)?.text?.contains("🪙") ?? false }) as? SKLabelNode {
            priceLbl.text = "💰 \(item.price / 2)"
            priceLbl.fontColor = .green
        }
        return node
    }

    private func setupChestsTab(area: CGSize, center: CGPoint) {
        let chests: [(String, Int, SKColor)] = [
            ("Baú Comum", 100, SKColor.gray),
            ("Baú Raro", 500, SKColor.blue),
            ("Baú Lendário", 2000, SKColor.orange)
        ]
        
        let spacing: CGFloat = 160
        let startX = center.x - (CGFloat(chests.count - 1) * spacing) / 2
        
        for (i, chest) in chests.enumerated() {
            let x = startX + CGFloat(i) * spacing
            let node = createChestCard(name: chest.0, price: chest.1, color: chest.2, position: CGPoint(x: x, y: center.y))
            addChild(node)
        }
    }

    private func createChestCard(name: String, price: Int, color: SKColor, position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "chest_\(name.replacingOccurrences(of: " ", with: "_").lowercased())"
        
        let bg = SKShapeNode(rectOf: CGSize(width: 140, height: 180), cornerRadius: 12)
        bg.fillColor = SKColor(white: 0.1, alpha: 0.9)
        bg.strokeColor = color
        bg.lineWidth = 3
        bg.name = node.name
        node.addChild(bg)
        
        let icon = SKLabelNode(text: "📦")
        icon.fontSize = 50
        icon.position = CGPoint(x: 0, y: 20)
        icon.name = node.name
        node.addChild(icon)
        
        let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLbl.text = name
        nameLbl.fontSize = 14
        nameLbl.position = CGPoint(x: 0, y: -30)
        nameLbl.name = node.name
        node.addChild(nameLbl)
        
        let priceLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        priceLbl.text = "🪙 \(price)"
        priceLbl.fontSize = 16
        priceLbl.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        priceLbl.position = CGPoint(x: 0, y: -60)
        priceLbl.name = node.name
        node.addChild(priceLbl)
        
        return node
    }

    private func setupCharactersTab(player: PlayerData, area: CGSize, center: CGPoint) {
        let characters = PlayableCharacter.allCases
        let spacing: CGFloat = 130
        let cols = 4
        let gridStartX = center.x - (CGFloat(cols - 1) * spacing) / 2
        let startY = center.y + area.height / 2 - 80

        for (i, char) in characters.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gridStartX + CGFloat(col) * spacing
            let y = startY - CGFloat(row) * 140
            
            let charNode = createCharacterCard(character: char, player: player, position: CGPoint(x: x, y: y))
            addChild(charNode)
        }
    }

    private func createCharacterCard(character: PlayableCharacter, player: PlayerData, position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "char_\(character.rawValue)"

        let isUnlocked = player.unlockedCharacters.contains(character)
        let bg = SKShapeNode(rectOf: CGSize(width: 110, height: 130), cornerRadius: 10)
        bg.fillColor = isUnlocked ? SKColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 0.8) : SKColor(white: 0.1, alpha: 0.8)
        bg.strokeColor = isUnlocked ? .green : .gray
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let texName = character == .davi ? "davijovem" : "davirei"
        let icon = SKSpriteNode(imageNamed: texName)
        icon.size = CGSize(width: 60, height: 70)
        icon.position = CGPoint(x: 0, y: 15)
        icon.name = node.name
        node.addChild(icon)

        let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLbl.text = loc.localize("character.\(character.rawValue)")
        nameLbl.fontSize = 11
        nameLbl.position = CGPoint(x: 0, y: -35)
        nameLbl.name = node.name
        node.addChild(nameLbl)

        if isUnlocked {
            let status = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            status.text = player.activeCharacter == character ? "ATIVO" : "LIBERADO"
            status.fontSize = 10
            status.fontColor = .green
            status.position = CGPoint(x: 0, y: -50)
            node.addChild(status)
        } else {
            let price = SKLabelNode(fontNamed: "AvenirNext-Bold")
            price.text = "🪙 \(character.price)"
            price.fontSize = 12
            price.fontColor = .yellow
            price.position = CGPoint(x: 0, y: -50)
            node.addChild(price)
        }

        return node
    }

    private func createButton(text: String, position: CGPoint, name: String, size: CGSize) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = size
        button.position = position
        button.name = name

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = size.height * 0.4
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = name
        button.addChild(label)

        return button
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
            case "tab_buy": currentTab = .buy; setupUI()
            case "tab_sell": currentTab = .sell; setupUI()
            case "tab_chests": currentTab = .chests; setupUI()
            case "tab_characters": currentTab = .characters; setupUI()
            default:
                if name.hasPrefix("buy_") {
                    buyItem(String(name.dropFirst(4)))
                } else if name.hasPrefix("char_") {
                    handleCharacterTap(PlayableCharacter(rawValue: String(name.dropFirst(5)))!)
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
        if GameManager.shared.spendGold(item.price) {
            GameManager.shared.addItemToInventory(itemId)
            setupUI()
        }
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
