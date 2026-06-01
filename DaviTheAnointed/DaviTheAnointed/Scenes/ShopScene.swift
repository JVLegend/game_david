import SpriteKit

class ShopScene: SKScene {

    private let loc = LocalizationManager.shared
    private var currentTab: ShopTab = .buy
    private var selectedSlotFilter: EquipmentSlot? = nil
    private var buyFirstVisibleIndex = 0
    private var foodFirstVisibleIndex = 0

    enum ShopTab {
        case buy, food, sell, chests, characters
    }

    override func didMove(to view: SKView) {
        loc.loadSavedLanguage()
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        applyDebugTabArgumentIfNeeded()
        setupUI()
    }

    private func applyDebugTabArgumentIfNeeded() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--debug-shop-sell") {
            currentTab = .sell
        } else if args.contains("--debug-shop-food") {
            currentTab = .food
        } else if args.contains("--debug-shop-chests") {
            currentTab = .chests
        } else if args.contains("--debug-shop-characters") {
            currentTab = .characters
        } else if args.contains("--debug-shop-buy") {
            currentTab = .buy
        }
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
        let sceneScale = size.height / max(view?.bounds.height ?? size.height, 1)
        let safeL = max(40, safeArea.left * sceneScale + 18)
        let safeR = max(40, safeArea.right * sceneScale + 18)
        let safeT = max(18, safeArea.top * sceneScale + 10)

        // Title Centralizado
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.shop")
        title.fontSize = 28
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - safeT - 26)

        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleShadow.text = title.text
        titleShadow.fontSize = title.fontSize
        titleShadow.fontColor = .black
        titleShadow.position = CGPoint(x: 2, y: -2)
        titleShadow.zPosition = -1
        titleShadow.alpha = 0.7
        title.addChild(titleShadow)
        addChild(title)

        // Botão Voltar (Top Esquerdo)
        let backBtn = createButton(text: "← \(loc.localize("general.back"))",
                                 position: CGPoint(x: safeL + 60, y: size.height - safeT - 22),
                                 name: "btn_back",
                                 size: CGSize(width: 120, height: 40))
        addChild(backBtn)

        let goldDisplay = createGoldDisplay(amount: player.gold, position: CGPoint(x: size.width - safeR - 72, y: size.height - safeT - 22))
        addChild(goldDisplay)

        // Abas (Tabs) - Abaixo do título
        let tabs: [(String, ShopTab, String)] = [
            (loc.localize("general.buy"), .buy, "tab_buy"),
            (loc.localize("shop.food"), .food, "tab_food"),
            (loc.localize("general.sell"), .sell, "tab_sell"),
            (loc.localize("shop.rewards"), .chests, "tab_chests"),
            (loc.localize("menu.characters"), .characters, "tab_characters"),
        ]

        let tabW: CGFloat = 104
        let tabTotalW = tabW * CGFloat(tabs.count)
        let tabStartX = (size.width - tabTotalW) / 2 + tabW / 2
        let tabY = size.height - safeT - 72

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
        case .food:
            setupFoodTab(player: player, area: contentSize, center: contentPos)
        case .sell:
            setupSellTab(player: player, area: contentSize, center: contentPos)
        case .chests:
            setupRewardsTab(area: contentSize, center: contentPos)
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

        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.text = text
        shadow.fontSize = label.fontSize
        shadow.fontColor = .black
        shadow.verticalAlignmentMode = .center
        shadow.position = CGPoint(x: 1, y: -1)
        shadow.zPosition = -1
        shadow.alpha = 0.6
        label.addChild(shadow)

        btn.addChild(label)

        return btn
    }

    private func createGoldDisplay(amount: Int, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 60

        let width: CGFloat = 144
        let height: CGFloat = 40
        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
        shadow.position = CGPoint(x: 3, y: -4)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.32
        container.addChild(shadow)

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.18, green: 0.10, blue: 0.035, alpha: 0.88)
        bg.strokeColor = SKColor(red: 0.92, green: 0.68, blue: 0.17, alpha: 0.95)
        bg.lineWidth = 2
        container.addChild(bg)

        let icon = SKSpriteNode(imageNamed: "menu_icon_gold")
        icon.size = CGSize(width: 26, height: 26)
        icon.position = CGPoint(x: -width / 2 + 24, y: 0)
        icon.zPosition = 1
        container.addChild(icon)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "\(amount)"
        label.fontSize = 16
        label.fontColor = SKColor(red: 1, green: 0.84, blue: 0.18, alpha: 1)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -width / 2 + 44, y: 0)
        label.zPosition = 2
        fit(label: label, maxWidth: width - 56, minimumSize: 10)

        let shadowLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadowLabel.text = label.text
        shadowLabel.fontSize = label.fontSize
        shadowLabel.fontColor = .black
        shadowLabel.horizontalAlignmentMode = .left
        shadowLabel.verticalAlignmentMode = .center
        shadowLabel.position = CGPoint(x: 1.5, y: -1.5)
        shadowLabel.zPosition = -1
        shadowLabel.alpha = 0.55
        label.addChild(shadowLabel)

        container.addChild(label)
        return container
    }

    private func setupBuyTab(player: PlayerData, area: CGSize, center: CGPoint) {
        let items = EquipmentDatabase.shared.availableItems(forLevel: player.level, slot: selectedSlotFilter)
            .filter { $0.price > 0 }
            .sorted { $0.price < $1.price }

        // Filtros de Slot
        let slots: [(String, EquipmentSlot?)] = [
            (loc.localize("shop.filter.all"), nil),
            (loc.localize("item.slot.head"), .head),
            (loc.localize("item.slot.body"), .body),
            (loc.localize("shop.filter.weapon"), .mainHand),
            (loc.localize("item.slot.twoHand"), .twoHand),
            (loc.localize("shop.filter.shield"), .offHand),
            (loc.localize("item.slot.feet"), .feet),
            (loc.localize("item.slot.waist"), .waist),
            (loc.localize("item.slot.gloves"), .gloves),
        ]

        let filterRows = [
            Array(slots.prefix(4)),
            Array(slots.dropFirst(4)),
        ]
        let filterGap: CGFloat = 8
        let maxFiltersInRow = CGFloat(filterRows.map(\.count).max() ?? 1)
        let filterW = min(82, max(68, (area.width - 64 - filterGap * (maxFiltersInRow - 1)) / maxFiltersInRow))
        let filterH: CGFloat = 25
        let firstFilterY = center.y + area.height / 2 - 28

        for (rowIndex, row) in filterRows.enumerated() {
            let rowWidth = CGFloat(row.count) * filterW + CGFloat(max(0, row.count - 1)) * filterGap
            let startX = center.x - rowWidth / 2 + filterW / 2
            let y = firstFilterY - CGFloat(rowIndex) * 31
            for (i, slot) in row.enumerated() {
                let x = startX + CGFloat(i) * (filterW + filterGap)
                let isActive = selectedSlotFilter == slot.1
                let btn = createSmallFilterButton(
                    text: slot.0,
                    position: CGPoint(x: x, y: y),
                    name: "filter_\(slot.1?.rawValue ?? "all")",
                    isActive: isActive,
                    size: CGSize(width: filterW, height: filterH)
                )
                addChild(btn)
            }
        }

        let panelTop = center.y + area.height / 2
        let panelBottom = center.y - area.height / 2
        let cardSize = CGSize(width: 76, height: 88)
        let gapX: CGFloat = 10
        let gapY: CGFloat = 10
        let availableWidth = area.width - 48
        let gridTop = min(firstFilterY - 76, panelTop - 104)
        let gridBottom = panelBottom + 26
        let gridHeight = max(cardSize.height, gridTop - gridBottom)
        let cols = max(1, min(5, Int((availableWidth + gapX) / (cardSize.width + gapX))))
        let rows = max(1, Int((gridHeight + gapY) / (cardSize.height + gapY)))
        let visibleCapacity = cols * rows
        let gridWidth = CGFloat(cols) * cardSize.width + CGFloat(cols - 1) * gapX
        let gridStartX = center.x - gridWidth / 2 + cardSize.width / 2
        let startY = gridTop - cardSize.height / 2

        if buyFirstVisibleIndex >= items.count {
            buyFirstVisibleIndex = max(0, items.count - visibleCapacity)
        }

        let visibleItems = Array(items.dropFirst(buyFirstVisibleIndex).prefix(visibleCapacity))
        for (i, item) in visibleItems.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gridStartX + CGFloat(col) * (cardSize.width + gapX)
            let y = startY - CGFloat(row) * (cardSize.height + gapY)
            let isOwned = GameManager.shared.ownsItem(item.id)

            let itemNode = createItemCard(
                item: item,
                position: CGPoint(x: x, y: y),
                canAfford: player.gold >= item.price && !isOwned,
                isOwned: isOwned,
                cardSize: cardSize
            )
            addChild(itemNode)
        }

        if items.count > visibleCapacity {
            addPagerControls(
                prefix: "buy",
                currentStart: buyFirstVisibleIndex,
                visibleCapacity: visibleCapacity,
                total: items.count,
                centerX: center.x,
                y: gridBottom + 6
            )
        }
    }

    private func setupFoodTab(player: PlayerData, area: CGSize, center: CGPoint) {
        let foods = FoodDatabase.shared.availableFoods(forLevel: player.level)
            .filter { hasBundledTexture(named: $0.textureName) }
            .sorted { $0.price < $1.price }

        let panelTop = center.y + area.height / 2
        let panelBottom = center.y - area.height / 2
        let cardSize = CGSize(width: 122, height: 138)
        let gapX: CGFloat = 14
        let gapY: CGFloat = 14
        let availableWidth = area.width - 52
        let gridTop = panelTop - 42
        let gridBottom = panelBottom + 28
        let gridHeight = max(cardSize.height, gridTop - gridBottom)
        let cols = max(1, min(4, Int((availableWidth + gapX) / (cardSize.width + gapX))))
        let rows = max(1, Int((gridHeight + gapY) / (cardSize.height + gapY)))
        let visibleCapacity = cols * rows
        let gridWidth = CGFloat(cols) * cardSize.width + CGFloat(cols - 1) * gapX
        let gridStartX = center.x - gridWidth / 2 + cardSize.width / 2
        let startY = gridTop - cardSize.height / 2

        if foodFirstVisibleIndex >= foods.count {
            foodFirstVisibleIndex = max(0, foods.count - visibleCapacity)
        }

        let visibleFoods = Array(foods.dropFirst(foodFirstVisibleIndex).prefix(visibleCapacity))
        for (i, food) in visibleFoods.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gridStartX + CGFloat(col) * (cardSize.width + gapX)
            let y = startY - CGFloat(row) * (cardSize.height + gapY)
            let count = player.foodInventory[food.type] ?? 0
            let node = createFoodCard(
                food: food,
                ownedCount: count,
                position: CGPoint(x: x, y: y),
                canAfford: player.gold >= food.price,
                cardSize: cardSize
            )
            addChild(node)
        }

        if foods.count > visibleCapacity {
            addPagerControls(
                prefix: "food",
                currentStart: foodFirstVisibleIndex,
                visibleCapacity: visibleCapacity,
                total: foods.count,
                centerX: center.x,
                y: gridBottom + 6
            )
        }
    }

    private func addPagerControls(prefix: String, currentStart: Int, visibleCapacity: Int, total: Int, centerX: CGFloat, y: CGFloat) {
        let end = min(total, currentStart + visibleCapacity)
        let canGoBack = currentStart > 0
        let canGoForward = end < total

        let back = createSmallFilterButton(
            text: "<",
            position: CGPoint(x: centerX - 70, y: y),
            name: "btn_\(prefix)_prev",
            isActive: canGoBack,
            size: CGSize(width: 36, height: 24)
        )
        addChild(back)

        let rangeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        rangeLabel.text = "\(currentStart + 1)-\(end)/\(total)"
        rangeLabel.fontSize = 12
        rangeLabel.fontColor = SKColor(red: 1, green: 0.82, blue: 0.30, alpha: 1)
        rangeLabel.verticalAlignmentMode = .center
        rangeLabel.horizontalAlignmentMode = .center
        rangeLabel.position = CGPoint(x: centerX, y: y)
        addChild(rangeLabel)

        let next = createSmallFilterButton(
            text: ">",
            position: CGPoint(x: centerX + 70, y: y),
            name: "btn_\(prefix)_next",
            isActive: canGoForward,
            size: CGSize(width: 36, height: 24)
        )
        addChild(next)
    }

    private func createFoodCard(food: Food, ownedCount: Int, position: CGPoint, canAfford: Bool, cardSize: CGSize) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "food_\(food.type.rawValue)"

        let bg = SKShapeNode(rectOf: cardSize, cornerRadius: 10)
        bg.fillColor = SKColor(red: 0.07, green: 0.08, blue: 0.065, alpha: 0.92)
        bg.strokeColor = SKColor(red: 0.92, green: 0.68, blue: 0.17, alpha: 0.95)
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let icon = SKSpriteNode(imageNamed: food.textureName)
        icon.size = CGSize(width: 50, height: 50)
        icon.position = CGPoint(x: 0, y: 36)
        icon.name = node.name
        icon.zPosition = 1
        node.addChild(icon)

        let countBadge = SKShapeNode(rectOf: CGSize(width: 34, height: 20), cornerRadius: 7)
        countBadge.position = CGPoint(x: cardSize.width / 2 - 24, y: cardSize.height / 2 - 18)
        countBadge.fillColor = SKColor(red: 0.04, green: 0.13, blue: 0.09, alpha: 0.90)
        countBadge.strokeColor = SKColor(red: 0.72, green: 1, blue: 0.52, alpha: 0.75)
        countBadge.lineWidth = 1
        countBadge.name = node.name
        node.addChild(countBadge)

        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.text = "x\(ownedCount)"
        countLabel.fontSize = 10
        countLabel.fontColor = SKColor(red: 0.72, green: 1, blue: 0.52, alpha: 1)
        countLabel.verticalAlignmentMode = .center
        countLabel.horizontalAlignmentMode = .center
        countLabel.position = countBadge.position
        countLabel.name = node.name
        node.addChild(countLabel)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = food.localizedName
        nameLabel.fontSize = 10.5
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -10)
        nameLabel.name = node.name
        fit(label: nameLabel, maxWidth: cardSize.width - 18, minimumSize: 7.5)
        node.addChild(nameLabel)

        let healLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        healLabel.text = "+\(food.healAmount) HP"
        healLabel.fontSize = 10
        healLabel.fontColor = SKColor(red: 0.55, green: 1, blue: 0.56, alpha: 1)
        healLabel.position = CGPoint(x: 0, y: -29)
        healLabel.name = node.name
        node.addChild(healLabel)

        let coin = SKSpriteNode(imageNamed: "menu_icon_gold")
        coin.size = CGSize(width: 14, height: 14)
        coin.position = CGPoint(x: -18, y: -50)
        coin.name = node.name
        node.addChild(coin)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        priceLabel.text = "\(food.price)"
        priceLabel.fontSize = 13
        priceLabel.fontColor = canAfford ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .red
        priceLabel.horizontalAlignmentMode = .left
        priceLabel.verticalAlignmentMode = .center
        priceLabel.position = CGPoint(x: -4, y: -50)
        priceLabel.name = node.name
        node.addChild(priceLabel)

        if !canAfford { node.alpha = 0.62 }
        return node
    }

    private func createSmallFilterButton(
        text: String,
        position: CGPoint,
        name: String,
        isActive: Bool,
        size: CGSize = CGSize(width: 80, height: 25)
    ) -> SKNode {
        let btn = SKSpriteNode(imageNamed: "button_texture")
        btn.size = size
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
        fit(label: label, maxWidth: size.width - 12, minimumSize: 7)
        btn.addChild(label)

        return btn
    }

    private func createItemCard(item: Equipment, position: CGPoint, canAfford: Bool, isOwned: Bool = false, cardSize: CGSize = CGSize(width: 76, height: 88)) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "buy_\(item.id)"

        let bg = SKShapeNode(rectOf: cardSize, cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.07, green: 0.08, blue: 0.065, alpha: 0.92)
        bg.strokeColor = item.rarity.color
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let itemSprite = SKSpriteNode(imageNamed: item.textureName)
        itemSprite.size = CGSize(width: 32, height: 32)
        itemSprite.position = CGPoint(x: 0, y: cardSize.height * 0.22)
        itemSprite.name = node.name
        itemSprite.zPosition = 1
        node.addChild(itemSprite)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = item.localizedName
        nameLabel.fontSize = 7.5
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -8)
        nameLabel.name = node.name
        fit(label: nameLabel, maxWidth: cardSize.width - 16, minimumSize: 6)
        node.addChild(nameLabel)

        let coin = SKSpriteNode(imageNamed: "menu_icon_gold")
        coin.size = CGSize(width: 11, height: 11)
        coin.position = CGPoint(x: -15, y: -25)
        coin.name = node.name
        node.addChild(coin)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        priceLabel.text = isOwned ? loc.localize("shop.owned") : "\(item.price)"
        priceLabel.fontSize = 9.5
        priceLabel.fontColor = canAfford ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .red
        priceLabel.horizontalAlignmentMode = .left
        priceLabel.verticalAlignmentMode = .center
        priceLabel.position = CGPoint(x: -5, y: -25)
        priceLabel.name = node.name
        fit(label: priceLabel, maxWidth: cardSize.width / 2 + 12, minimumSize: 7)
        node.addChild(priceLabel)

        let slotLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        slotLabel.text = slotShortName(item.slot)
        slotLabel.fontSize = 6
        slotLabel.fontColor = .lightGray
        slotLabel.position = CGPoint(x: 0, y: -36)
        slotLabel.name = node.name
        node.addChild(slotLabel)

        if !canAfford { node.alpha = isOwned ? 0.72 : 0.6 }

        return node
    }

    private func setupSellTab(player: PlayerData, area: CGSize, center: CGPoint) {
        if player.inventory.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            emptyLabel.text = "Inventário Vazio"
            emptyLabel.position = center
            addChild(emptyLabel)
            return
        }

        let panelTop = center.y + area.height / 2
        let panelBottom = center.y - area.height / 2
        let cardSize = CGSize(width: 76, height: 88)
        let gapX: CGFloat = 10
        let gapY: CGFloat = 10
        let availableWidth = area.width - 48
        let gridTop = panelTop - 38
        let gridBottom = panelBottom + 26
        let gridHeight = max(cardSize.height, gridTop - gridBottom)
        let cols = max(1, min(5, Int((availableWidth + gapX) / (cardSize.width + gapX))))
        let rows = max(1, Int((gridHeight + gapY) / (cardSize.height + gapY)))
        let visibleCapacity = cols * rows
        let gridWidth = CGFloat(cols) * cardSize.width + CGFloat(cols - 1) * gapX
        let gridStartX = center.x - gridWidth / 2 + cardSize.width / 2
        let startY = gridTop - cardSize.height / 2

        for (i, itemId) in player.inventory.prefix(visibleCapacity).enumerated() {
            guard let item = EquipmentDatabase.shared.item(withId: itemId) else { continue }
            let col = i % cols
            let row = i / cols
            let x = gridStartX + CGFloat(col) * (cardSize.width + gapX)
            let y = startY - CGFloat(row) * (cardSize.height + gapY)

            let sellNode = createSellCard(item: item, position: CGPoint(x: x, y: y), cardSize: cardSize)
            addChild(sellNode)
        }
    }

    private func createSellCard(item: Equipment, position: CGPoint, cardSize: CGSize) -> SKNode {
        let node = createItemCard(item: item, position: position, canAfford: true, cardSize: cardSize)
        let sellName = "sell_\(item.id)"
        node.name = "sell_\(item.id)"
        node.children.forEach { $0.name = sellName }
        // Ajustar preço para venda (metade)
        if let priceLbl = node.children.first(where: { ($0 as? SKLabelNode)?.horizontalAlignmentMode == .left }) as? SKLabelNode {
            priceLbl.text = "\(item.price / 2)"
            priceLbl.fontColor = .green
        }
        return node
    }

    private func setupRewardsTab(area: CGSize, center: CGPoint) {
        let cards: [(title: String, subtitle: String, icon: String, color: SKColor)] = [
            (
                loc.localize("shop.reward.battle.title"),
                loc.localize("shop.reward.battle.desc"),
                "menu_icon_journey",
                SKColor(red: 0.95, green: 0.66, blue: 0.20, alpha: 1)
            ),
            (
                loc.localize("shop.reward.items.title"),
                loc.localize("shop.reward.items.desc"),
                "menu_icon_inventory",
                SKColor(red: 0.26, green: 0.58, blue: 0.95, alpha: 1)
            ),
            (
                loc.localize("shop.reward.shop.title"),
                loc.localize("shop.reward.shop.desc"),
                "menu_icon_shop",
                SKColor(red: 0.32, green: 0.78, blue: 0.46, alpha: 1)
            ),
        ]

        let spacing: CGFloat = min(170, max(142, area.width / 3.3))
        let startX = center.x - (CGFloat(cards.count - 1) * spacing) / 2

        for (i, card) in cards.enumerated() {
            let x = startX + CGFloat(i) * spacing
            addChild(createRewardInfoCard(
                title: card.title,
                subtitle: card.subtitle,
                iconName: card.icon,
                color: card.color,
                position: CGPoint(x: x, y: center.y + 4)
            ))
        }

        let footer = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        footer.text = loc.localize("shop.reward.footer")
        footer.fontSize = 12
        footer.fontColor = SKColor(white: 0.86, alpha: 0.94)
        footer.numberOfLines = 0
        footer.preferredMaxLayoutWidth = min(area.width - 48, 520)
        footer.horizontalAlignmentMode = .center
        footer.verticalAlignmentMode = .center
        footer.position = CGPoint(x: center.x, y: center.y - area.height / 2 + 30)
        addChild(footer)
    }

    private func createRewardInfoCard(title: String, subtitle: String, iconName: String, color: SKColor, position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position

        let bg = SKShapeNode(rectOf: CGSize(width: 140, height: 180), cornerRadius: 12)
        bg.fillColor = SKColor(white: 0.1, alpha: 0.9)
        bg.strokeColor = color
        bg.lineWidth = 3
        node.addChild(bg)

        let iconPlate = SKShapeNode(circleOfRadius: 40)
        iconPlate.fillColor = color.withAlphaComponent(0.20)
        iconPlate.strokeColor = color
        iconPlate.lineWidth = 2
        iconPlate.position = CGPoint(x: 0, y: 44)
        node.addChild(iconPlate)

        let icon = SKSpriteNode(imageNamed: iconName)
        icon.size = CGSize(width: 64, height: 64)
        icon.position = CGPoint(x: 0, y: 44)
        node.addChild(icon)

        let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLbl.text = title
        nameLbl.fontSize = 14
        nameLbl.fontColor = SKColor(red: 1, green: 0.87, blue: 0.44, alpha: 1)
        nameLbl.position = CGPoint(x: 0, y: -18)
        fit(label: nameLbl, maxWidth: 118, minimumSize: 10)
        node.addChild(nameLbl)

        let subtitleLbl = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        subtitleLbl.text = subtitle
        subtitleLbl.fontSize = 10
        subtitleLbl.fontColor = SKColor(white: 0.82, alpha: 0.9)
        subtitleLbl.numberOfLines = 0
        subtitleLbl.preferredMaxLayoutWidth = 112
        subtitleLbl.horizontalAlignmentMode = .center
        subtitleLbl.verticalAlignmentMode = .center
        subtitleLbl.position = CGPoint(x: 0, y: -58)
        node.addChild(subtitleLbl)
        return node
    }

    private func setupCharactersTab(player: PlayerData, area: CGSize, center: CGPoint) {
        let characters = PlayableCharacter.allCases
        let cardSize = CGSize(width: 88, height: 118)
        let horizontalGap: CGFloat = 10
        let verticalGap: CGFloat = 8
        let cols = max(1, min(4, Int((area.width + horizontalGap) / (cardSize.width + horizontalGap))))
        let totalWidth = CGFloat(cols) * cardSize.width + CGFloat(cols - 1) * horizontalGap
        let gridStartX = center.x - totalWidth / 2 + cardSize.width / 2
        let startY = center.y + area.height / 2 - cardSize.height / 2 - 12

        for (i, char) in characters.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gridStartX + CGFloat(col) * (cardSize.width + horizontalGap)
            let y = startY - CGFloat(row) * (cardSize.height + verticalGap)

            let charNode = createCharacterCard(character: char, player: player, position: CGPoint(x: x, y: y), size: cardSize)
            addChild(charNode)
        }
    }

    private func createCharacterCard(character: PlayableCharacter, player: PlayerData, position: CGPoint, size cardSize: CGSize) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "char_\(character.rawValue)"

        let isUnlocked = player.unlockedCharacters.contains(character)
        let isActive = player.activeCharacter == character
        let bg = SKShapeNode(rectOf: cardSize, cornerRadius: 10)
        bg.fillColor = isUnlocked ? SKColor(red: 0.08, green: 0.22, blue: 0.11, alpha: 0.86) : SKColor(white: 0.08, alpha: 0.86)
        bg.strokeColor = isActive ? SKColor(red: 1, green: 0.84, blue: 0.22, alpha: 1) : (isUnlocked ? .green : .gray)
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let icon = SKSpriteNode(imageNamed: character.rosterTextureName)
        icon.size = CGSize(width: 36, height: 48)
        icon.position = CGPoint(x: 0, y: 25)
        icon.name = node.name
        node.addChild(icon)

        let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLbl.text = loc.localize("character.\(character.rawValue)")
        nameLbl.fontSize = 9.5
        nameLbl.position = CGPoint(x: 0, y: -12)
        nameLbl.name = node.name
        fit(label: nameLbl, maxWidth: cardSize.width - 18, minimumSize: 8)
        node.addChild(nameLbl)

        let statPreview = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        statPreview.text = primaryCharacterBonusText(character)
        statPreview.fontSize = 7.5
        statPreview.fontColor = SKColor(red: 1, green: 0.85, blue: 0.35, alpha: 1)
        statPreview.position = CGPoint(x: 0, y: -28)
        statPreview.name = node.name
        fit(label: statPreview, maxWidth: cardSize.width - 16, minimumSize: 6)
        node.addChild(statPreview)

        if isUnlocked {
            let status = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            status.text = isActive ? loc.localize("character.active") : loc.localize("character.unlocked")
            status.fontSize = 9
            status.fontColor = isActive ? SKColor(red: 1, green: 0.84, blue: 0.22, alpha: 1) : .green
            status.position = CGPoint(x: 0, y: -45)
            status.name = node.name
            node.addChild(status)
        } else {
            let canAfford = player.gold >= character.price
            let coin = SKSpriteNode(imageNamed: "menu_icon_gold")
            coin.size = CGSize(width: 13, height: 13)
            coin.position = CGPoint(x: -18, y: -45)
            coin.name = node.name
            node.addChild(coin)

            let price = SKLabelNode(fontNamed: "AvenirNext-Bold")
            price.text = "\(character.price)"
            price.fontSize = 10
            price.fontColor = canAfford ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .red
            price.horizontalAlignmentMode = .left
            price.verticalAlignmentMode = .center
            price.position = CGPoint(x: -5, y: -45)
            price.name = node.name
            node.addChild(price)
        }

        return node
    }

    private func primaryCharacterBonusText(_ character: PlayableCharacter) -> String {
        characterBonusLines(for: character).first ?? loc.localize("character.balanced")
    }

    private func characterBonusLines(for character: PlayableCharacter) -> [String] {
        let stats = character.passiveBonus
        var lines: [String] = []

        if stats.maxHP != 0 { lines.append("+\(stats.maxHP) \(loc.localize("stat.hp"))") }
        if stats.damageMin != 0 || stats.damageMax != 0 { lines.append("+\(stats.damageMin)-\(stats.damageMax) \(loc.localize("stat.damage"))") }
        if stats.damageMultiplier != 0 { lines.append("+\(percent(stats.damageMultiplier)) \(loc.localize("stat.damage_bonus"))") }
        if stats.armor != 0 { lines.append("+\(stats.armor) \(loc.localize("stat.armor"))") }
        if stats.critChance != 0 { lines.append("+\(percent(stats.critChance)) \(loc.localize("stat.crit_chance"))") }
        if stats.critDamage != 0 { lines.append("+\(percent(stats.critDamage)) \(loc.localize("stat.crit_damage"))") }
        if stats.attackSpeedBonus != 0 { lines.append("+\(percent(stats.attackSpeedBonus)) \(loc.localize("stat.attack_speed"))") }
        if stats.lifeSteal != 0 { lines.append("+\(percent(stats.lifeSteal)) \(loc.localize("stat.life_steal"))") }
        if stats.dodgeMelee != 0 { lines.append("+\(percent(stats.dodgeMelee)) \(loc.localize("stat.dodge_melee"))") }
        if stats.dodgeRanged != 0 { lines.append("+\(percent(stats.dodgeRanged)) \(loc.localize("stat.dodge_ranged"))") }
        if stats.runSpeed != 0 { lines.append("+\(Int(stats.runSpeed)) \(loc.localize("stat.run_speed"))") }

        return lines.isEmpty ? [loc.localize("character.balanced")] : lines
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
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

    private func fit(label: SKLabelNode, maxWidth: CGFloat, minimumSize: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > minimumSize {
            label.fontSize -= 1
        }
    }

    private func hasBundledTexture(named textureName: String) -> Bool {
        Bundle.main.path(forResource: textureName, ofType: "png") != nil
    }

    private func slotShortName(_ slot: EquipmentSlot) -> String {
        loc.localize("item.slot.short.\(slot.rawValue)")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        if childNode(withName: "reward_overlay") != nil {
            for node in nodes {
                guard let name = node.name else { continue }
                if name.hasPrefix("btn_confirm_sell_") {
                    confirmSellItem(String(name.dropFirst("btn_confirm_sell_".count)))
                    return
                } else if name.hasPrefix("btn_buy_char_") {
                    confirmCharacterPurchase(String(name.dropFirst("btn_buy_char_".count)))
                    return
                } else if name.hasPrefix("btn_select_char_") {
                    selectCharacter(String(name.dropFirst("btn_select_char_".count)))
                    return
                }
            }
            for node in nodes {
                if node.name == "btn_close_overlay" {
                    childNode(withName: "reward_overlay")?.removeFromParent()
                    return
                }
            }
            return
        }

        for node in nodes {
            guard let name = node.name else { continue }

            if name == "btn_close_overlay" {
                childNode(withName: "reward_overlay")?.removeFromParent()
                return
            }

            switch name {
            case "btn_back":
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
                return
            case "tab_buy":
                currentTab = .buy
                setupUI()
                return
            case "tab_food":
                currentTab = .food
                setupUI()
                return
            case "tab_sell":
                currentTab = .sell
                setupUI()
                return
            case "tab_chests":
                currentTab = .chests
                setupUI()
                return
            case "tab_characters":
                currentTab = .characters
                setupUI()
                return
            default:
                if name == "btn_buy_prev" {
                    buyFirstVisibleIndex = max(0, buyFirstVisibleIndex - 5)
                    setupUI()
                    return
                } else if name == "btn_buy_next" {
                    buyFirstVisibleIndex += 5
                    setupUI()
                    return
                } else if name == "btn_food_prev" {
                    foodFirstVisibleIndex = max(0, foodFirstVisibleIndex - 4)
                    setupUI()
                    return
                } else if name == "btn_food_next" {
                    foodFirstVisibleIndex += 4
                    setupUI()
                    return
                } else if name.hasPrefix("buy_") {
                    buyItem(String(name.dropFirst(4)))
                    return
                } else if name.hasPrefix("food_") {
                    buyFood(String(name.dropFirst(5)))
                    return
                } else if name.hasPrefix("sell_") {
                    showSellConfirmation(String(name.dropFirst(5)))
                    return
                } else if name.hasPrefix("btn_confirm_sell_") {
                    confirmSellItem(String(name.dropFirst("btn_confirm_sell_".count)))
                    return
                } else if name.hasPrefix("char_") {
                    handleCharacterTap(String(name.dropFirst(5)))
                    return
                } else if name.hasPrefix("filter_") {
                    let filterRaw = String(name.dropFirst(7))
                    selectedSlotFilter = filterRaw == "all" ? nil : EquipmentSlot(rawValue: filterRaw)
                    buyFirstVisibleIndex = 0
                    setupUI()
                    return
                }
            }
        }
    }

    private func showSellConfirmation(_ itemId: String) {
        guard let item = EquipmentDatabase.shared.item(withId: itemId),
              GameManager.shared.playerData?.inventory.contains(itemId) == true else {
            setupUI()
            return
        }

        let sellValue = max(1, item.price / 2)
        let overlay = SKNode()
        overlay.name = "reward_overlay"
        overlay.zPosition = 200
        addChild(overlay)

        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = .black.withAlphaComponent(0.55)
        dim.strokeColor = .clear
        dim.name = "btn_close_overlay"
        overlay.addChild(dim)

        let panelSize = CGSize(width: 330, height: 230)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 14)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.12, green: 0.07, blue: 0.035, alpha: 0.97)
        panel.strokeColor = item.rarity.color
        panel.lineWidth = 3
        overlay.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = loc.localize("shop.sell.title")
        title.fontSize = 20
        title.fontColor = SKColor(red: 1, green: 0.86, blue: 0.42, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 82)
        overlay.addChild(title)

        let iconPlate = SKShapeNode(rectOf: CGSize(width: 68, height: 68), cornerRadius: 10)
        iconPlate.position = CGPoint(x: size.width / 2 - 96, y: size.height / 2 + 24)
        iconPlate.fillColor = SKColor(white: 0.05, alpha: 0.85)
        iconPlate.strokeColor = item.rarity.color
        iconPlate.lineWidth = 2
        overlay.addChild(iconPlate)

        let icon = SKSpriteNode(imageNamed: item.textureName)
        icon.size = CGSize(width: 50, height: 50)
        icon.position = iconPlate.position
        overlay.addChild(icon)

        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.text = item.localizedName
        name.fontSize = 17
        name.fontColor = .white
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode = .center
        name.position = CGPoint(x: size.width / 2 - 48, y: size.height / 2 + 40)
        fit(label: name, maxWidth: 190, minimumSize: 11)
        overlay.addChild(name)

        let valueText = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        valueText.text = "\(loc.localize("shop.sell.confirm")) \(sellValue)"
        valueText.fontSize = 14
        valueText.fontColor = SKColor(red: 1, green: 0.84, blue: 0.18, alpha: 1)
        valueText.horizontalAlignmentMode = .left
        valueText.verticalAlignmentMode = .center
        valueText.position = CGPoint(x: size.width / 2 - 48, y: size.height / 2 + 12)
        overlay.addChild(valueText)

        let coin = SKSpriteNode(imageNamed: "menu_icon_gold")
        coin.size = CGSize(width: 18, height: 18)
        coin.position = CGPoint(x: valueText.position.x + valueText.frame.width + 14, y: valueText.position.y)
        overlay.addChild(coin)

        let cancel = createButton(
            text: loc.localize("general.cancel"),
            position: CGPoint(x: size.width / 2 - 82, y: size.height / 2 - 72),
            name: "btn_close_overlay",
            size: CGSize(width: 130, height: 40)
        )
        overlay.addChild(cancel)

        let confirm = createButton(
            text: loc.localize("general.sell"),
            position: CGPoint(x: size.width / 2 + 82, y: size.height / 2 - 72),
            name: "btn_confirm_sell_\(item.id)",
            size: CGSize(width: 130, height: 40)
        )
        overlay.addChild(confirm)
    }

    private func confirmSellItem(_ itemId: String) {
        guard let item = EquipmentDatabase.shared.item(withId: itemId),
              let gained = GameManager.shared.sellInventoryItem(itemId) else {
            setupUI()
            return
        }

        setupUI()
        let message = String(format: loc.localize("shop.sell.done.desc"), item.localizedName, gained)
        showMessageOverlay(title: loc.localize("shop.sell.done"), message: message)
    }

    private func showChestReward(_ item: Equipment) {
        let overlay = createOverlayBase()
        let panelSize = CGSize(width: 320, height: 230)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 14)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.12, green: 0.07, blue: 0.035, alpha: 0.97)
        panel.strokeColor = item.rarity.color
        panel.lineWidth = 3
        overlay.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = loc.localize("shop.chest.reward")
        title.fontSize = 20
        title.fontColor = SKColor(red: 1, green: 0.86, blue: 0.42, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 82)
        overlay.addChild(title)

        let iconPlate = SKShapeNode(rectOf: CGSize(width: 72, height: 72), cornerRadius: 10)
        iconPlate.position = CGPoint(x: size.width / 2 - 96, y: size.height / 2 + 20)
        iconPlate.fillColor = SKColor(white: 0.05, alpha: 0.85)
        iconPlate.strokeColor = item.rarity.color
        iconPlate.lineWidth = 2
        overlay.addChild(iconPlate)

        let icon = SKSpriteNode(imageNamed: item.textureName)
        icon.size = CGSize(width: 54, height: 54)
        icon.position = iconPlate.position
        overlay.addChild(icon)

        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.text = item.localizedName
        name.fontSize = 18
        name.fontColor = .white
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode = .center
        name.position = CGPoint(x: size.width / 2 - 48, y: size.height / 2 + 34)
        fit(label: name, maxWidth: 190, minimumSize: 12)
        overlay.addChild(name)

        let rarity = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        rarity.text = rarityDisplayName(item.rarity)
        rarity.fontSize = 13
        rarity.fontColor = item.rarity.color
        rarity.horizontalAlignmentMode = .left
        rarity.verticalAlignmentMode = .center
        rarity.position = CGPoint(x: size.width / 2 - 48, y: size.height / 2 + 8)
        overlay.addChild(rarity)

        let ok = createButton(text: loc.localize("general.ok"), position: CGPoint(x: size.width / 2, y: size.height / 2 - 74), name: "btn_close_overlay", size: CGSize(width: 150, height: 42))
        overlay.addChild(ok)
    }

    private func showMessageOverlay(title: String, message: String) {
        let overlay = createOverlayBase()
        let panelSize = CGSize(width: 300, height: 170)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 14)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.12, green: 0.07, blue: 0.035, alpha: 0.97)
        panel.strokeColor = SKColor(red: 0.92, green: 0.68, blue: 0.17, alpha: 0.95)
        panel.lineWidth = 2
        overlay.addChild(panel)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = title
        titleLabel.fontSize = 18
        titleLabel.fontColor = SKColor(red: 1, green: 0.86, blue: 0.42, alpha: 1)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 42)
        fit(label: titleLabel, maxWidth: 260, minimumSize: 12)
        overlay.addChild(titleLabel)

        let messageLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        messageLabel.text = message
        messageLabel.fontSize = 12
        messageLabel.fontColor = SKColor(white: 0.9, alpha: 0.9)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 10)
        fit(label: messageLabel, maxWidth: 260, minimumSize: 9)
        overlay.addChild(messageLabel)

        let ok = createButton(text: loc.localize("general.ok"), position: CGPoint(x: size.width / 2, y: size.height / 2 - 52), name: "btn_close_overlay", size: CGSize(width: 140, height: 38))
        overlay.addChild(ok)
    }

    private func createOverlayBase() -> SKNode {
        let overlay = SKNode()
        overlay.name = "reward_overlay"
        overlay.zPosition = 200
        addChild(overlay)

        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = .black.withAlphaComponent(0.55)
        dim.strokeColor = .clear
        dim.name = "btn_close_overlay"
        overlay.addChild(dim)

        return overlay
    }

    private func rarityDisplayName(_ rarity: ItemRarity) -> String {
        switch rarity {
        case .common: return loc.localize("item.rarity.common")
        case .uncommon: return loc.localize("item.rarity.uncommon")
        case .rare: return loc.localize("item.rarity.rare")
        case .epic: return loc.localize("item.rarity.epic")
        case .legendary: return loc.localize("item.rarity.legendary")
        }
    }

    private func buyItem(_ itemId: String) {
        guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return }
        guard !GameManager.shared.ownsItem(itemId) else { return }
        if GameManager.shared.spendGold(item.price) {
            GameManager.shared.addItemToInventory(itemId)
            setupUI()
        }
    }

    private func buyFood(_ rawValue: String) {
        guard let foodType = FoodType(rawValue: rawValue) else { return }
        if GameManager.shared.buyFood(foodType) {
            setupUI()
        } else {
            showMessageOverlay(title: loc.localize("shop.not_enough_gold"), message: loc.localize("shop.not_enough_gold.desc"))
        }
    }

    private func handleCharacterTap(_ rawValue: String) {
        guard let character = PlayableCharacter(rawValue: rawValue) else { return }
        showCharacterDetails(character)
    }

    private func showCharacterDetails(_ character: PlayableCharacter) {
        guard let player = GameManager.shared.playerData else { return }

        let overlay = createOverlayBase()
        let panelSize = CGSize(width: 330, height: 292)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 14)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.11, green: 0.07, blue: 0.035, alpha: 0.97)
        panel.strokeColor = player.activeCharacter == character ? SKColor(red: 1, green: 0.84, blue: 0.22, alpha: 1) : SKColor(red: 0.82, green: 0.58, blue: 0.16, alpha: 0.95)
        panel.lineWidth = 3
        overlay.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = loc.localize("character.stats_title")
        title.fontSize = 18
        title.fontColor = SKColor(red: 1, green: 0.86, blue: 0.42, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 114)
        overlay.addChild(title)

        let iconPlate = SKShapeNode(rectOf: CGSize(width: 72, height: 82), cornerRadius: 10)
        iconPlate.position = CGPoint(x: size.width / 2 - 106, y: size.height / 2 + 48)
        iconPlate.fillColor = SKColor(white: 0.05, alpha: 0.85)
        iconPlate.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 0.9)
        iconPlate.lineWidth = 2
        overlay.addChild(iconPlate)

        let icon = SKSpriteNode(imageNamed: character.rosterTextureName)
        icon.size = CGSize(width: 58, height: 72)
        icon.position = iconPlate.position
        overlay.addChild(icon)

        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.text = loc.localize("character.\(character.rawValue)")
        name.fontSize = 18
        name.fontColor = .white
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode = .center
        name.position = CGPoint(x: size.width / 2 - 54, y: size.height / 2 + 72)
        fit(label: name, maxWidth: 190, minimumSize: 12)
        overlay.addChild(name)

        let status = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        let isUnlocked = player.unlockedCharacters.contains(character)
        status.text = player.activeCharacter == character ? loc.localize("character.active") : (isUnlocked ? loc.localize("character.unlocked") : loc.localize("character.locked"))
        status.fontSize = 12
        status.fontColor = isUnlocked ? SKColor(red: 0.55, green: 1, blue: 0.52, alpha: 1) : SKColor(red: 1, green: 0.62, blue: 0.36, alpha: 1)
        status.horizontalAlignmentMode = .left
        status.verticalAlignmentMode = .center
        status.position = CGPoint(x: size.width / 2 - 54, y: size.height / 2 + 48)
        overlay.addChild(status)

        if !isUnlocked {
            let price = SKLabelNode(fontNamed: "AvenirNext-Bold")
            price.text = "\(character.price)"
            price.fontSize = 14
            price.fontColor = player.gold >= character.price ? SKColor(red: 1, green: 0.84, blue: 0.18, alpha: 1) : .red
            price.horizontalAlignmentMode = .left
            price.verticalAlignmentMode = .center
            price.position = CGPoint(x: size.width / 2 - 54, y: size.height / 2 + 26)
            overlay.addChild(price)

            let coin = SKSpriteNode(imageNamed: "menu_icon_gold")
            coin.size = CGSize(width: 17, height: 17)
            coin.position = CGPoint(x: size.width / 2 - 68, y: price.position.y)
            overlay.addChild(coin)
        }

        let statTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statTitle.text = loc.localize("character.passive_bonus")
        statTitle.fontSize = 13
        statTitle.fontColor = SKColor(red: 1, green: 0.84, blue: 0.24, alpha: 1)
        statTitle.horizontalAlignmentMode = .left
        statTitle.position = CGPoint(x: size.width / 2 - 140, y: size.height / 2 - 18)
        overlay.addChild(statTitle)

        for (index, line) in characterBonusLines(for: character).prefix(6).enumerated() {
            let statLine = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            statLine.text = line
            statLine.fontSize = 12
            statLine.fontColor = SKColor(white: 0.92, alpha: 0.96)
            statLine.horizontalAlignmentMode = .left
            statLine.verticalAlignmentMode = .center
            statLine.position = CGPoint(x: size.width / 2 - 140 + CGFloat(index % 2) * 150, y: size.height / 2 - 44 - CGFloat(index / 2) * 24)
            fit(label: statLine, maxWidth: 136, minimumSize: 9)
            overlay.addChild(statLine)
        }

        let close = createButton(
            text: loc.localize("general.close"),
            position: CGPoint(x: size.width / 2 - 82, y: size.height / 2 - 114),
            name: "btn_close_overlay",
            size: CGSize(width: 128, height: 38)
        )
        overlay.addChild(close)

        let actionName: String?
        let actionText: String
        if player.activeCharacter == character {
            actionName = nil
            actionText = loc.localize("character.active")
        } else if isUnlocked {
            actionName = "btn_select_char_\(character.rawValue)"
            actionText = loc.localize("character.select")
        } else if player.highestMapCompleted < character.requiredMap {
            actionName = nil
            actionText = "\(loc.localize("character.required_map")) \(character.requiredMap)"
        } else if player.gold < character.price {
            actionName = nil
            actionText = loc.localize("shop.not_enough_gold")
        } else {
            actionName = "btn_buy_char_\(character.rawValue)"
            actionText = loc.localize("general.buy")
        }

        let action = createButton(
            text: actionText,
            position: CGPoint(x: size.width / 2 + 82, y: size.height / 2 - 114),
            name: actionName ?? "btn_close_overlay",
            size: CGSize(width: 128, height: 38)
        )
        if actionName == nil {
            action.alpha = 0.72
        }
        overlay.addChild(action)
    }

    private func confirmCharacterPurchase(_ rawValue: String) {
        guard let character = PlayableCharacter(rawValue: rawValue) else { return }
        childNode(withName: "reward_overlay")?.removeFromParent()
        if GameManager.shared.buyCharacter(character) {
            setupUI()
            showMessageOverlay(title: loc.localize("character.unlocked"), message: loc.localize("character.unlocked_message"))
        } else {
            showMessageOverlay(title: loc.localize("shop.not_enough_gold"), message: loc.localize("shop.not_enough_gold.desc"))
        }
    }

    private func selectCharacter(_ rawValue: String) {
        guard let character = PlayableCharacter(rawValue: rawValue) else { return }
        childNode(withName: "reward_overlay")?.removeFromParent()
        if GameManager.shared.selectCharacter(character) {
            setupUI()
            showMessageOverlay(title: loc.localize("character.active"), message: loc.localize("character.selected_message"))
        }
    }
}
