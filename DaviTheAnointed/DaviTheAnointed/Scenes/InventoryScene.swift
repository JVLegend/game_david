import SpriteKit

class InventoryScene: SKScene {

    private let loc = LocalizationManager.shared
    private var selectedItemId: String?

    // UI Containers
    private var leftPanel: SKNode!
    private var rightPanel: SKNode!
    private var detailsPanel: SKNode!
    private var leftPanelSize: CGSize = .zero
    private var rightPanelSize: CGSize = .zero
    private var panelBottom: CGFloat = 0
    private var inventoryFirstVisibleRow: Int = 0

    private enum InventoryDisplayLine {
        case header(slot: EquipmentSlot, count: Int, equippedItemId: String?)
        case items([(id: String, item: Equipment)])
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        setupLayout()
        refreshUI()
    }

    private func setupLayout() {
        removeAllChildren()

        // Background principal
        let bg = SKSpriteNode(imageNamed: "background_menu")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.alpha = 0.5
        addChild(bg)

        let safeArea = view?.safeAreaInsets ?? .zero
        let sceneScale = size.height / max(view?.bounds.height ?? size.height, 1)
        let safeL = max(34, safeArea.left * sceneScale + 18)
        let safeR = max(34, safeArea.right * sceneScale + 18)
        let safeT = max(18, safeArea.top * sceneScale + 12)
        let safeB = max(18, safeArea.bottom * sceneScale + 12)
        let contentMinX = safeL
        let contentMaxX = size.width - safeR
        let contentWidth = contentMaxX - contentMinX
        let gap: CGFloat = 20
        let leftWidth = min(292, max(260, contentWidth * 0.32))
        let rightWidth = contentWidth - leftWidth - gap
        panelBottom = safeB + 14
        let panelTop = size.height - safeT - 66
        let panelHeight = panelTop - panelBottom
        leftPanelSize = CGSize(width: leftWidth, height: panelHeight)
        rightPanelSize = CGSize(width: rightWidth, height: panelHeight)

        // Painel Esquerdo (Personagem e Stats)
        leftPanel = SKNode()
        leftPanel.position = CGPoint(x: contentMinX, y: 0)
        addChild(leftPanel)

        // Painel Direito (Grid de Itens)
        rightPanel = SKNode()
        rightPanel.position = CGPoint(x: contentMinX + leftWidth + gap, y: 0)
        addChild(rightPanel)

        // Painel de Detalhes (Popup)
        detailsPanel = SKNode()
        detailsPanel.isHidden = true
        detailsPanel.zPosition = 100
        addChild(detailsPanel)

        // Fundos dos painéis com bordas douradas
        let leftBg = createPanel(size: leftPanelSize)
        leftBg.position = CGPoint(x: leftPanelSize.width / 2, y: panelBottom + leftPanelSize.height / 2)
        leftBg.name = "panel_bg"
        leftPanel.addChild(leftBg)

        let rightBg = createPanel(size: rightPanelSize)
        rightBg.position = CGPoint(x: rightPanelSize.width / 2, y: panelBottom + rightPanelSize.height / 2)
        rightBg.name = "panel_bg"
        rightPanel.addChild(rightBg)

        // Título Centralizado
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.inventory")
        title.fontSize = 26
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - safeT - 24)
        addChild(title)

        // Botão Voltar (Top Esquerdo)
        let backBtn = createButton(text: "← \(loc.localize("general.back"))",
                                 position: CGPoint(x: contentMinX + 60, y: size.height - safeT - 22),
                                 name: "btn_back",
                                 size: CGSize(width: 120, height: 40))
        addChild(backBtn)
    }

    private func createPanel(size: CGSize) -> SKNode {
        let node = SKNode()
        let bg = SKShapeNode(rectOf: size, cornerRadius: 12)
        bg.fillColor = SKColor(white: 0, alpha: 0.6)
        bg.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 1)
        bg.lineWidth = 2
        node.addChild(bg)
        return node
    }

    private func refreshUI() {
        // Limpa apenas o conteúdo dinâmico
        leftPanel.children.filter { $0.name != "panel_bg" }.forEach { $0.removeFromParent() }
        rightPanel.children.filter { $0.name != "panel_bg" }.forEach { $0.removeFromParent() }

        guard let player = GameManager.shared.playerData else { return }
        let stats = GameManager.shared.computedStats()

        setupLeftContent(player: player, stats: stats)
        setupRightContent(player: player)

        if let itemId = selectedItemId {
            showItemDetails(itemId: itemId)
        } else {
            detailsPanel.isHidden = true
        }
    }

    private func setupLeftContent(player: PlayerData, stats: CharacterStats) {
        let panelW = leftPanelSize.width
        let panelTop = panelBottom + leftPanelSize.height
        let centerX = panelW / 2

        // Avatar usando o sprite do personagem ativo
        let charNode = SKSpriteNode(imageNamed: player.activeCharacter.rosterTextureName)
        charNode.size = CGSize(width: 76, height: 96)
        charNode.position = CGPoint(x: centerX - 52, y: panelTop - 98)
        leftPanel.addChild(charNode)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = loc.localize("character.\(player.activeCharacter.rawValue)")
        nameLabel.fontSize = 18
        nameLabel.fontColor = SKColor(red: 1, green: 0.88, blue: 0.55, alpha: 1)
        nameLabel.position = CGPoint(x: centerX, y: panelTop - 34)
        leftPanel.addChild(nameLabel)

        let orderedSlots: [EquipmentSlot] = [
            .head, .body, .waist, .feet,
            .mainHand, .offHand, .twoHand, .gloves,
            .necklace, .ring1, .ring2
        ]

        let equipmentWidth = panelW - 34
        let equipmentTop = panelTop - 154
        let equipmentBottom = panelBottom + 18
        let equipmentHeight = min(188, max(166, equipmentTop - equipmentBottom))
        let equipmentCenterY = equipmentBottom + equipmentHeight / 2
        let equipmentCard = SKShapeNode(rectOf: CGSize(width: equipmentWidth, height: equipmentHeight), cornerRadius: 9)
        equipmentCard.position = CGPoint(x: centerX, y: equipmentCenterY)
        equipmentCard.fillColor = SKColor(red: 0.035, green: 0.045, blue: 0.038, alpha: 0.50)
        equipmentCard.strokeColor = SKColor(red: 0.55, green: 0.40, blue: 0.18, alpha: 0.72)
        equipmentCard.lineWidth = 1
        leftPanel.addChild(equipmentCard)

        let slotTitle = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        slotTitle.text = loc.localize("inventory.equipped")
        slotTitle.fontSize = 14
        slotTitle.fontColor = SKColor(white: 0.9, alpha: 0.84)
        slotTitle.horizontalAlignmentMode = .left
        slotTitle.verticalAlignmentMode = .center
        slotTitle.position = CGPoint(x: centerX - equipmentWidth / 2 + 14, y: equipmentCenterY + equipmentHeight / 2 - 20)
        leftPanel.addChild(slotTitle)

        let cols = 4
        let usableWidth = equipmentWidth - 24
        let gapX: CGFloat = 8
        let slotCardSize = CGSize(width: (usableWidth - gapX * CGFloat(cols - 1)) / CGFloat(cols), height: 46)
        let gridWidth = CGFloat(cols) * slotCardSize.width + gapX * CGFloat(cols - 1)
        let startX = centerX - gridWidth / 2 + slotCardSize.width / 2
        let firstSlotY = equipmentCenterY + equipmentHeight / 2 - 54
        let rowGap: CGFloat = 48

        for (index, slot) in orderedSlots.enumerated() {
            let col = index % cols
            let row = index / cols
            let pos = CGPoint(x: startX + CGFloat(col) * (slotCardSize.width + gapX), y: firstSlotY - CGFloat(row) * rowGap)
            let slotNode = createCompactSlotNode(slot: slot, position: pos, size: slotCardSize, equippedItemId: player.equippedItems[slot])
            leftPanel.addChild(slotNode)
        }

        // Painel de Stats
        let statsX = centerX + 12
        let statsY = panelTop - 74
        let statLines = [
            ("HP", "\(stats.currentHP)/\(stats.maxHP)", SKColor.green, "icon_heart"),
            (loc.localize("hud.damage"), "\(stats.damageMin)-\(stats.damageMax)", SKColor.red, "icon_staff"),
            (loc.localize("hud.max_armor"), "\(stats.armor)", SKColor.gray, "icon_shield"),
            (loc.localize("hud.crit_chance"), "\(Int(stats.critChance * 100))%", SKColor.yellow, "icon_sling")
        ]

        for (i, stat) in statLines.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.text = "\(stat.0): \(stat.1)"
            label.fontSize = 12.5
            label.fontColor = stat.2
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: statsX, y: statsY - CGFloat(i) * 24)

            let shadow = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            shadow.text = label.text
            shadow.fontSize = label.fontSize
            shadow.fontColor = .black
            shadow.horizontalAlignmentMode = .left
            shadow.position = CGPoint(x: 1, y: -1)
            shadow.zPosition = -1
            shadow.alpha = 0.5
            label.addChild(shadow)

            leftPanel.addChild(label)

        }

        let activeSets = EquipmentSetDatabase.shared.activeSets(forEquippedItemIds: Set(player.equippedItems.values))
            .filter { !$0.activeBonuses.isEmpty }
        if let strongestSet = activeSets.sorted(by: { $0.activeBonuses.count > $1.activeBonuses.count }).first {
            let setLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            setLabel.text = "\(strongestSet.definition.name(language: loc.language)): \(strongestSet.equippedPieces)p"
            setLabel.fontSize = 10.5
            setLabel.fontColor = SKColor(red: 0.70, green: 0.94, blue: 1, alpha: 1)
            setLabel.horizontalAlignmentMode = .left
            setLabel.position = CGPoint(x: statsX, y: statsY - 98)
            fit(label: setLabel, maxWidth: panelW - statsX - 14, minimumSize: 8)
            leftPanel.addChild(setLabel)
        }
    }

    private func setupRightContent(player: PlayerData) {
        let panelW = rightPanelSize.width
        let panelTop = panelBottom + rightPanelSize.height
        let panelInset: CGFloat = 24

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.inventory_list")
        title.fontSize = 22
        title.fontColor = SKColor(red: 1, green: 0.88, blue: 0.55, alpha: 1)
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: panelInset, y: panelTop - 40)
        rightPanel.addChild(title)

        let contentTop = title.position.y - 36
        let contentBottom = panelBottom + 22
        let contentHeight = max(74, contentTop - contentBottom)
        let contentWidth = panelW - panelInset * 2
        let contentCard = SKShapeNode(rectOf: CGSize(width: contentWidth, height: contentHeight), cornerRadius: 8)
        contentCard.position = CGPoint(x: panelW / 2, y: contentBottom + contentHeight / 2)
        contentCard.fillColor = SKColor(red: 0.03, green: 0.04, blue: 0.035, alpha: 0.44)
        contentCard.strokeColor = SKColor(red: 0.55, green: 0.4, blue: 0.18, alpha: 0.72)
        contentCard.lineWidth = 1
        rightPanel.addChild(contentCard)

        if player.inventory.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            emptyLabel.text = loc.localize("inventory.empty")
            emptyLabel.fontSize = 13
            emptyLabel.fontColor = SKColor(white: 0.86, alpha: 0.78)
            emptyLabel.position = CGPoint(x: panelW / 2, y: contentBottom + contentHeight / 2 - 6)
            rightPanel.addChild(emptyLabel)
            return
        }

        let availableWidth = contentWidth - 30
        let itemCols = availableWidth >= 360 ? 2 : 1
        let itemGap: CGFloat = 14
        let itemWidth = (availableWidth - CGFloat(itemCols - 1) * itemGap) / CGFloat(itemCols)
        let itemHeight: CGFloat = itemCols == 1 && itemWidth < 230 ? 112 : 58
        let headerHeight: CGFloat = 28
        let lineGap: CGFloat = 11
        let topY = contentTop - 16
        let bottomLimit = contentBottom + 40
        let lines = groupedInventoryLines(player: player, columns: itemCols)
        inventoryFirstVisibleRow = min(max(0, inventoryFirstVisibleRow), max(0, lines.count - 1))

        func displayHeight(for line: InventoryDisplayLine) -> CGFloat {
            switch line {
            case .header:
                return headerHeight
            case .items:
                return itemHeight
            }
        }

        var visibleLineEntries: [(index: Int, line: InventoryDisplayLine, y: CGFloat)] = []
        var cursorTop = topY
        for index in inventoryFirstVisibleRow..<lines.count {
            let line = lines[index]
            let lineHeight = displayHeight(for: line)
            var requiredHeight = lineHeight

            if case .header = line, index + 1 < lines.count {
                requiredHeight += lineGap + displayHeight(for: lines[index + 1])
            }

            if !visibleLineEntries.isEmpty && cursorTop - requiredHeight < bottomLimit {
                break
            }

            let y = cursorTop - lineHeight / 2
            visibleLineEntries.append((index: index, line: line, y: y))
            cursorTop -= lineHeight + lineGap
        }

        let visibleLines = visibleLineEntries.map { $0.line }
        let lastVisibleIndex = visibleLineEntries.last?.index ?? inventoryFirstVisibleRow

        for entry in visibleLineEntries {
            let y = entry.y

            switch entry.line {
            case let .header(slot, count, equippedItemId):
                let headerNode = createInventoryGroupHeader(
                    slot: slot,
                    count: count,
                    equippedItemId: equippedItemId,
                    position: CGPoint(x: panelW / 2, y: y),
                    size: CGSize(width: availableWidth, height: headerHeight)
                )
                rightPanel.addChild(headerNode)

            case let .items(items):
                let rowWidth = CGFloat(items.count) * itemWidth + CGFloat(max(0, items.count - 1)) * itemGap
                let startX = panelW / 2 - rowWidth / 2 + itemWidth / 2

                for (col, entry) in items.enumerated() {
                    let pos = CGPoint(x: startX + CGFloat(col) * (itemWidth + itemGap), y: y)
                    let isEquipped = player.equippedItems[entry.item.slot] == entry.id
                    let itemNode = createItemIcon(item: entry.item, position: pos, size: CGSize(width: itemWidth, height: itemHeight), isEquipped: isEquipped)
                    itemNode.name = "inv_\(entry.id)"
                    itemNode.children.forEach { $0.name = itemNode.name }
                    rightPanel.addChild(itemNode)

                    if selectedItemId == entry.id {
                        let highlight = SKShapeNode(rectOf: CGSize(width: itemWidth + 4, height: itemHeight + 4), cornerRadius: 8)
                        highlight.strokeColor = .yellow
                        highlight.lineWidth = 2
                        highlight.zPosition = 5
                        itemNode.addChild(highlight)
                    }
                }
            }
        }

        if inventoryFirstVisibleRow > 0 || lastVisibleIndex < lines.count - 1 {
            let visibleItemCount = visibleLines.reduce(0) { total, line in
                if case let .items(items) = line {
                    return total + items.count
                }
                return total
            }

            let rangeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            rangeLabel.text = "\(visibleItemCount)/\(itemCountText(player.inventory.count))"
            rangeLabel.fontSize = 13
            rangeLabel.fontColor = SKColor(white: 0.86, alpha: 0.82)
            rangeLabel.horizontalAlignmentMode = .center
            rangeLabel.verticalAlignmentMode = .center
            rangeLabel.position = CGPoint(x: panelW / 2, y: contentBottom + 11)
            rightPanel.addChild(rangeLabel)

            let upBtn = createMiniPagerButton(text: "▲", position: CGPoint(x: panelInset + 16, y: contentBottom + 11), name: "btn_inv_page_up", isEnabled: inventoryFirstVisibleRow > 0)
            let downBtn = createMiniPagerButton(text: "▼", position: CGPoint(x: panelW - panelInset - 16, y: contentBottom + 11), name: "btn_inv_page_down", isEnabled: lastVisibleIndex < lines.count - 1)
            rightPanel.addChild(upBtn)
            rightPanel.addChild(downBtn)
        }
    }

    private func groupedInventoryLines(player: PlayerData, columns: Int) -> [InventoryDisplayLine] {
        let inventoryItems = player.inventory.compactMap { itemId -> (id: String, item: Equipment)? in
            guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return nil }
            return (itemId, item)
        }

        let slotOrder: [EquipmentSlot] = [
            .head, .body, .mainHand, .offHand, .twoHand,
            .necklace, .ring1, .ring2, .gloves, .feet
        ]

        var lines: [InventoryDisplayLine] = []
        for slot in slotOrder {
            let slotItems = inventoryItems
                .filter { $0.item.slot == slot }
                .sorted { lhs, rhs in
                    if lhs.item.minLevel != rhs.item.minLevel {
                        return lhs.item.minLevel < rhs.item.minLevel
                    }
                    if lhs.item.price != rhs.item.price {
                        return lhs.item.price < rhs.item.price
                    }
                    return lhs.item.localizedName < rhs.item.localizedName
                }

            guard !slotItems.isEmpty else { continue }

            var currentRow: [(id: String, item: Equipment)] = []
            for entry in slotItems {
                currentRow.append(entry)
                if currentRow.count == columns {
                    lines.append(.items(currentRow))
                    currentRow.removeAll()
                }
            }

            if !currentRow.isEmpty {
                lines.append(.items(currentRow))
            }
        }

        return lines
    }

    private func createInventoryGroupHeader(slot: EquipmentSlot, count: Int, equippedItemId: String?, position: CGPoint, size: CGSize) -> SKNode {
        let node = SKNode()
        node.position = position

        let bg = SKShapeNode(rectOf: size, cornerRadius: 7)
        bg.fillColor = SKColor(red: 0.13, green: 0.08, blue: 0.035, alpha: 0.86)
        bg.strokeColor = SKColor(red: 0.86, green: 0.62, blue: 0.24, alpha: 0.9)
        bg.lineWidth = 1
        node.addChild(bg)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "\(slotDisplayName(slot))  •  \(count)"
        title.fontSize = 11
        title.fontColor = SKColor(red: 1, green: 0.86, blue: 0.46, alpha: 1)
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: -size.width / 2 + 12, y: 0)
        fit(label: title, maxWidth: size.width * 0.42, minimumSize: 8.5)
        node.addChild(title)

        if let equippedItemId,
           let equipped = EquipmentDatabase.shared.item(withId: equippedItemId) {
            let equippedLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            equippedLabel.text = "\(loc.localize("inventory.equipped_short")) \(equipped.localizedName)"
            equippedLabel.fontSize = 9.2
            equippedLabel.fontColor = SKColor(white: 0.92, alpha: 0.9)
            equippedLabel.horizontalAlignmentMode = .right
            equippedLabel.verticalAlignmentMode = .center
            equippedLabel.position = CGPoint(x: size.width / 2 - 12, y: 0)
            fit(label: equippedLabel, maxWidth: size.width * 0.48, minimumSize: 7.5)
            node.addChild(equippedLabel)
        }

        return node
    }

    private func itemCountText(_ count: Int) -> String {
        let key = count == 1 ? "inventory.item_count.one" : "inventory.item_count.many"
        return String(format: loc.localize(key), count)
    }

    private func createMiniPagerButton(text: String, position: CGPoint, name: String, isEnabled: Bool) -> SKNode {
        let button = SKShapeNode(rectOf: CGSize(width: 34, height: 26), cornerRadius: 7)
        button.position = position
        button.name = name
        button.fillColor = isEnabled
            ? SKColor(red: 0.25, green: 0.15, blue: 0.055, alpha: 0.92)
            : SKColor(red: 0.08, green: 0.08, blue: 0.07, alpha: 0.72)
        button.strokeColor = isEnabled
            ? SKColor(red: 0.95, green: 0.68, blue: 0.18, alpha: 0.95)
            : SKColor(white: 0.30, alpha: 0.8)
        button.lineWidth = 1.2

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 13
        label.fontColor = isEnabled ? .white : SKColor(white: 0.45, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = name
        label.zPosition = 1
        button.addChild(label)

        return button
    }

    private func createCompactSlotNode(slot: EquipmentSlot, position: CGPoint, size: CGSize, equippedItemId: String?) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "equipped_\(slot.rawValue)"

        let bg = SKShapeNode(rectOf: size, cornerRadius: 7)
        bg.fillColor = equippedItemId == nil
            ? SKColor(red: 0.055, green: 0.075, blue: 0.065, alpha: 0.86)
            : SKColor(red: 0.10, green: 0.13, blue: 0.08, alpha: 0.92)
        bg.strokeColor = equippedItemId != nil ? SKColor.orange : SKColor(white: 0.34, alpha: 0.95)
        bg.lineWidth = equippedItemId != nil ? 1.8 : 1.1
        bg.name = node.name
        node.addChild(bg)

        if let id = equippedItemId, let item = EquipmentDatabase.shared.item(withId: id) {
            let icon = SKSpriteNode(imageNamed: item.textureName)
            icon.size = CGSize(width: min(31, size.width * 0.62), height: min(31, size.width * 0.62))
            icon.position = CGPoint(x: 0, y: 7)
            icon.zPosition = 1
            icon.name = node.name
            node.addChild(icon)
        } else {
            let empty = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            empty.text = slotShortName(slot)
            empty.fontSize = 11
            empty.fontColor = SKColor(white: 0.58, alpha: 0.92)
            empty.verticalAlignmentMode = .center
            empty.horizontalAlignmentMode = .center
            empty.position = CGPoint(x: 0, y: 7)
            empty.name = node.name
            node.addChild(empty)
        }

        let slotLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        slotLabel.text = slotShortName(slot)
        slotLabel.fontSize = 7.8
        slotLabel.fontColor = SKColor(white: 0.88, alpha: 0.86)
        slotLabel.verticalAlignmentMode = .center
        slotLabel.horizontalAlignmentMode = .center
        slotLabel.position = CGPoint(x: 0, y: -14)
        slotLabel.name = node.name
        fit(label: slotLabel, maxWidth: size.width - 5, minimumSize: 5)
        node.addChild(slotLabel)

        return node
    }

    private func createSlotNode(slot: EquipmentSlot, position: CGPoint, size: CGSize, equippedItemId: String?) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "equipped_\(slot.rawValue)"

        let bg = SKShapeNode(rectOf: size, cornerRadius: 7)
        bg.fillColor = SKColor(red: 0.08, green: 0.12, blue: 0.09, alpha: 0.88)
        bg.strokeColor = equippedItemId != nil ? SKColor.orange : SKColor(white: 0.3, alpha: 1)
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)

        let iconPlate = SKShapeNode(rectOf: CGSize(width: 22, height: 22), cornerRadius: 5)
        iconPlate.fillColor = SKColor(red: 0.03, green: 0.04, blue: 0.035, alpha: 0.75)
        iconPlate.strokeColor = SKColor(white: 1, alpha: 0.14)
        iconPlate.lineWidth = 1
        iconPlate.position = CGPoint(x: -size.width / 2 + 15, y: 0)
        iconPlate.name = node.name
        node.addChild(iconPlate)

        if let id = equippedItemId, let item = EquipmentDatabase.shared.item(withId: id) {
            let icon = SKSpriteNode(imageNamed: item.textureName)
            icon.size = CGSize(width: 18, height: 18)
            icon.position = iconPlate.position
            icon.zPosition = 1
            icon.name = node.name
            node.addChild(icon)

            let itemLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            itemLabel.text = item.localizedName
            itemLabel.fontSize = 6.4
            itemLabel.fontColor = item.rarity.color
            itemLabel.horizontalAlignmentMode = .left
            itemLabel.verticalAlignmentMode = .center
            itemLabel.position = CGPoint(x: -size.width / 2 + 30, y: -5.5)
            itemLabel.name = node.name
            fit(label: itemLabel, maxWidth: size.width - 35, minimumSize: 5)
            node.addChild(itemLabel)
        } else {
            let iconLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            iconLabel.text = slotShortName(slot)
            iconLabel.fontSize = 7
            iconLabel.fontColor = SKColor(white: 0.55, alpha: 1)
            iconLabel.verticalAlignmentMode = .center
            iconLabel.position = iconPlate.position
            iconLabel.name = node.name
            node.addChild(iconLabel)

            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            emptyLabel.text = loc.localize("inventory.empty_slot")
            emptyLabel.fontSize = 6.2
            emptyLabel.fontColor = SKColor(white: 0.58, alpha: 0.82)
            emptyLabel.horizontalAlignmentMode = .left
            emptyLabel.verticalAlignmentMode = .center
            emptyLabel.position = CGPoint(x: -size.width / 2 + 30, y: -5.5)
            emptyLabel.name = node.name
            node.addChild(emptyLabel)
        }

        let slotLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        slotLabel.text = slotDisplayName(slot)
        slotLabel.fontSize = 6.4
        slotLabel.fontColor = SKColor(white: 0.82, alpha: 0.82)
        slotLabel.verticalAlignmentMode = .center
        slotLabel.horizontalAlignmentMode = .left
        slotLabel.position = CGPoint(x: -size.width / 2 + 30, y: 6)
        slotLabel.name = node.name
        fit(label: slotLabel, maxWidth: size.width - 35, minimumSize: 5)
        node.addChild(slotLabel)

        return node
    }

    private func createItemIcon(item: Equipment, position: CGPoint, size: CGSize, isEquipped: Bool = false) -> SKNode {
        let container = SKNode()
        container.position = position

        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = isEquipped
            ? SKColor(red: 0.12, green: 0.17, blue: 0.08, alpha: 0.93)
            : SKColor(white: 0.15, alpha: 0.9)
        bg.strokeColor = isEquipped ? SKColor(red: 0.62, green: 0.95, blue: 0.36, alpha: 1) : item.rarity.color
        bg.lineWidth = isEquipped ? 2.4 : 1.6
        container.addChild(bg)

        if size.height > 80 {
            let iconSide = min(50, size.width * 0.42)
            let icon = SKSpriteNode(imageNamed: item.textureName)
            icon.size = CGSize(width: iconSide, height: iconSide)
            icon.position = CGPoint(x: 0, y: 22)
            icon.zPosition = 1
            container.addChild(icon)

            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nameLabel.text = item.localizedName
            nameLabel.fontSize = 12
            nameLabel.fontColor = .white
            nameLabel.horizontalAlignmentMode = .center
            nameLabel.verticalAlignmentMode = .center
            nameLabel.position = CGPoint(x: 0, y: -18)
            nameLabel.zPosition = 1
            fit(label: nameLabel, maxWidth: size.width - 18, minimumSize: 8.5)
            container.addChild(nameLabel)

            let slotLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            slotLabel.text = isEquipped
                ? "\(loc.localize("inventory.equipped")) • \(slotDisplayName(item.slot))"
                : slotDisplayName(item.slot)
            slotLabel.fontSize = 9
            slotLabel.fontColor = isEquipped ? SKColor(red: 0.72, green: 1, blue: 0.52, alpha: 1) : item.rarity.color
            slotLabel.verticalAlignmentMode = .center
            slotLabel.horizontalAlignmentMode = .center
            slotLabel.position = CGPoint(x: 0, y: -39)
            slotLabel.zPosition = 1
            fit(label: slotLabel, maxWidth: size.width - 18, minimumSize: 7)
            container.addChild(slotLabel)

            return container
        }

        let iconSide = min(42, size.height * 0.72)
        let icon = SKSpriteNode(imageNamed: item.textureName)
        icon.size = CGSize(width: iconSide, height: iconSide)
        icon.position = CGPoint(x: -size.width / 2 + 30, y: 0)
        icon.zPosition = 1
        container.addChild(icon)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = item.localizedName
        nameLabel.fontSize = 12.5
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -size.width / 2 + 56, y: 12)
        nameLabel.zPosition = 1
        fit(label: nameLabel, maxWidth: size.width - 66, minimumSize: 9)
        container.addChild(nameLabel)

        let slotLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        slotLabel.text = isEquipped
            ? "\(loc.localize("inventory.equipped")) • \(slotDisplayName(item.slot))"
            : slotDisplayName(item.slot)
        slotLabel.fontSize = 9.6
        slotLabel.fontColor = isEquipped ? SKColor(red: 0.72, green: 1, blue: 0.52, alpha: 1) : item.rarity.color
        slotLabel.verticalAlignmentMode = .center
        slotLabel.horizontalAlignmentMode = .left
        slotLabel.position = CGPoint(x: -size.width / 2 + 56, y: -13)
        slotLabel.zPosition = 1
        fit(label: slotLabel, maxWidth: size.width - 66, minimumSize: 7.5)
        container.addChild(slotLabel)

        return container
    }

    private func slotShortName(_ slot: EquipmentSlot) -> String {
        loc.localize("item.slot.short.\(slot.rawValue)")
    }

    private func slotDisplayName(_ slot: EquipmentSlot) -> String {
        loc.localize("item.slot.\(slot.rawValue)")
    }

    private func showItemDetails(itemId: String) {
        detailsPanel.removeAllChildren()
        detailsPanel.isHidden = false

        guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return }

        let dim = SKShapeNode(rectOf: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.fillColor = SKColor.black.withAlphaComponent(0.42)
        dim.strokeColor = .clear
        detailsPanel.addChild(dim)

        let panelSize = CGSize(width: 340, height: 250)
        let panel = SKNode()
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        detailsPanel.addChild(panel)

        let shadow = SKShapeNode(rectOf: panelSize, cornerRadius: 14)
        shadow.position = CGPoint(x: 5, y: -6)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.30
        panel.addChild(shadow)

        let bg = SKShapeNode(rectOf: panelSize, cornerRadius: 14)
        bg.fillColor = SKColor(red: 0.13, green: 0.075, blue: 0.035, alpha: 0.96)
        bg.strokeColor = item.rarity.color
        bg.lineWidth = 2.5
        panel.addChild(bg)

        let iconPlate = SKShapeNode(rectOf: CGSize(width: 76, height: 76), cornerRadius: 10)
        iconPlate.fillColor = SKColor(red: 0.04, green: 0.045, blue: 0.04, alpha: 0.90)
        iconPlate.strokeColor = SKColor(white: 1, alpha: 0.22)
        iconPlate.lineWidth = 1
        iconPlate.position = CGPoint(x: -112, y: 54)
        panel.addChild(iconPlate)

        let icon = SKSpriteNode(imageNamed: item.textureName)
        icon.size = CGSize(width: 54, height: 54)
        icon.position = iconPlate.position
        icon.zPosition = 1
        panel.addChild(icon)

        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.text = item.localizedName
        name.fontSize = 20
        name.fontColor = SKColor(red: 1, green: 0.88, blue: 0.56, alpha: 1)
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode = .center
        name.position = CGPoint(x: -62, y: 78)
        fit(label: name, maxWidth: 198, minimumSize: 13)
        panel.addChild(name)

        let rarityLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rarityLabel.text = rarityDisplayName(item.rarity)
        rarityLabel.fontSize = 12
        rarityLabel.fontColor = item.rarity.color
        rarityLabel.horizontalAlignmentMode = .left
        rarityLabel.verticalAlignmentMode = .center
        rarityLabel.position = CGPoint(x: -62, y: 54)
        panel.addChild(rarityLabel)

        let typeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        typeLabel.text = "\(loc.localize("item.type")): \(slotDisplayName(item.slot))"
        typeLabel.fontSize = 12
        typeLabel.fontColor = SKColor(white: 0.92, alpha: 0.88)
        typeLabel.horizontalAlignmentMode = .left
        typeLabel.verticalAlignmentMode = .center
        typeLabel.position = CGPoint(x: -62, y: 32)
        panel.addChild(typeLabel)

        let statLines = itemStatLines(item)
        for (index, line) in statLines.prefix(5).enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.text = line
            label.fontSize = 12
            label.fontColor = SKColor(white: 0.95, alpha: 0.92)
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: -136, y: 2 - CGFloat(index) * 20)
            panel.addChild(label)
        }

        let equipBtn = createButton(text: loc.localize("item.action.equip"),
                                   position: CGPoint(x: 0, y: -96),
                                   name: "btn_equip_\(itemId)",
                                   size: CGSize(width: 160, height: 45))
        panel.addChild(equipBtn)

        let closeBtn = createButton(text: "X",
                                   position: CGPoint(x: 146, y: 100),
                                   name: "btn_close_details",
                                   size: CGSize(width: 35, height: 35))
        panel.addChild(closeBtn)
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

    private func itemStatLines(_ item: Equipment) -> [String] {
        let stats = item.stats
        var lines: [String] = []
        if stats.maxHP != 0 { lines.append("+\(stats.maxHP) HP máximo") }
        if stats.armor != 0 { lines.append("+\(stats.armor) Armadura") }
        if stats.damageMin != 0 || stats.damageMax != 0 {
            lines.append("+\(stats.damageMin)-\(stats.damageMax) Dano")
        }
        if stats.critChance != 0 { lines.append("+\(Int(stats.critChance * 100))% Chance crítica") }
        if stats.critDamage != 0 { lines.append("+\(Int(stats.critDamage * 100))% Dano crítico") }
        if stats.dodgeMelee != 0 { lines.append("+\(Int(stats.dodgeMelee * 100))% Esquiva corpo a corpo") }
        if stats.dodgeRanged != 0 { lines.append("+\(Int(stats.dodgeRanged * 100))% Esquiva à distância") }
        if stats.attackSpeedBonus != 0 { lines.append("+\(Int(stats.attackSpeedBonus * 100))% Velocidade de ataque") }
        if stats.lifeSteal != 0 { lines.append("+\(Int(stats.lifeSteal * 100))% Roubo de vida") }
        if stats.runSpeed != 0 { lines.append("\(Int(stats.runSpeed)) Velocidade") }
        return lines.isEmpty ? ["Sem bônus de atributo"] : lines
    }

    private func fit(label: SKLabelNode, maxWidth: CGFloat, minimumSize: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > minimumSize {
            label.fontSize -= 1
            for child in label.children {
                if let childLabel = child as? SKLabelNode {
                    childLabel.fontSize = label.fontSize
                }
            }
        }
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

        // Sombra do botão
        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.text = text
        shadow.fontSize = label.fontSize
        shadow.fontColor = .black
        shadow.verticalAlignmentMode = .center
        shadow.position = CGPoint(x: 1.5, y: -1.5)
        shadow.zPosition = -1
        shadow.alpha = 0.6
        label.addChild(shadow)

        button.addChild(label)

        return button
    }

    private func itemId(forNodeName name: String) -> String? {
        if name.hasPrefix("inv_") {
            return String(name.dropFirst(4))
        }

        if name.hasPrefix("equipped_") {
            let rawSlot = String(name.dropFirst("equipped_".count))
            guard let slot = EquipmentSlot(rawValue: rawSlot) else { return nil }
            return GameManager.shared.playerData?.equippedItems[slot]
        }

        return nil
    }

    @discardableResult
    private func previewItemDetails(fromNodeName name: String) -> Bool {
        guard let itemId = itemId(forNodeName: name) else { return false }
        if selectedItemId != itemId {
            selectedItemId = itemId
            refreshUI()
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            guard let name = node.name else { continue }

            if name == "btn_back" {
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .resizeFill
                view?.presentScene(scene, transition: SKTransition.reveal(with: .right, duration: 0.3))
                return
            }

            if name == "btn_close_details" {
                selectedItemId = nil
                refreshUI()
                return
            }

            if name == "btn_inv_page_up" {
                inventoryFirstVisibleRow = max(0, inventoryFirstVisibleRow - 1)
                refreshUI()
                return
            }

            if name == "btn_inv_page_down" {
                inventoryFirstVisibleRow += 1
                refreshUI()
                return
            }

            if previewItemDetails(fromNodeName: name) {
                return
            }

            if name.hasPrefix("btn_equip_") {
                let itemId = String(name.dropFirst(10))
                GameManager.shared.equipItem(itemId)
                selectedItemId = nil
                refreshUI()
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            guard let name = node.name else { continue }
            if previewItemDetails(fromNodeName: name) {
                return
            }
        }
    }
}
