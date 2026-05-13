import SpriteKit

class InventoryScene: SKScene {

    private let loc = LocalizationManager.shared
    private var selectedItemId: String?
    
    // UI Containers
    private var leftPanel: SKNode!
    private var rightPanel: SKNode!
    private var detailsPanel: SKNode!
    
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
        let safeL = max(40, safeArea.left)
        let safeR = max(40, safeArea.right)

        // Painel Esquerdo (Personagem e Stats)
        leftPanel = SKNode()
        leftPanel.position = CGPoint(x: safeL, y: 0)
        addChild(leftPanel)
        
        // Painel Direito (Grid de Itens)
        rightPanel = SKNode()
        rightPanel.position = CGPoint(x: size.width * 0.48, y: 0) // Ajustado levemente para a esquerda
        addChild(rightPanel)
        
        // Painel de Detalhes (Popup)
        detailsPanel = SKNode()
        detailsPanel.isHidden = true
        detailsPanel.zPosition = 100
        addChild(detailsPanel)
        
        // Fundos dos painéis com bordas douradas
        let leftBg = createPanel(size: CGSize(width: size.width * 0.42 - safeL, height: size.height - 100))
        leftBg.position = CGPoint(x: (size.width * 0.42 - safeL) / 2, y: size.height / 2 - 30)
        leftBg.name = "panel_bg"
        leftPanel.addChild(leftBg)
        
        let rightBg = createPanel(size: CGSize(width: size.width * 0.52 - safeR, height: size.height - 100))
        rightBg.position = CGPoint(x: (size.width * 0.52 - safeR) / 2, y: size.height / 2 - 30)
        rightBg.name = "panel_bg"
        rightPanel.addChild(rightBg)

        // Título Centralizado
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.inventory")
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
        let panelW = size.width * 0.42 - 40
        let centerX = panelW / 2
        
        // Avatar usando o novo sprite
        let charNode = SKSpriteNode(imageNamed: "davijovem")
        charNode.size = CGSize(width: 100, height: 120)
        charNode.position = CGPoint(x: centerX, y: size.height * 0.62)
        leftPanel.addChild(charNode)
        
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = loc.localize("character.\(player.activeCharacter.rawValue)")
        nameLabel.fontSize = 18
        nameLabel.position = CGPoint(x: centerX, y: size.height * 0.78)
        leftPanel.addChild(nameLabel)
        
        // Slots de Equipamento (posicionados de forma mais limpa)
        let slots: [(EquipmentSlot, CGPoint)] = [
            (.head, CGPoint(x: centerX, y: size.height * 0.73)),
            (.body, CGPoint(x: centerX - 70, y: size.height * 0.62)),
            (.mainHand, CGPoint(x: centerX - 70, y: size.height * 0.50)),
            (.offHand, CGPoint(x: centerX + 70, y: size.height * 0.62)),
            (.feet, CGPoint(x: centerX, y: size.height * 0.46)),
            (.necklace, CGPoint(x: centerX + 70, y: size.height * 0.50))
        ]
        
        for (slot, pos) in slots {
            let slotNode = createSlotNode(slot: slot, position: pos, equippedItemId: player.equippedItems[slot])
            leftPanel.addChild(slotNode)
        }
        
        // Painel de Stats
        let statsY = size.height * 0.35
        let statLines = [
            ("HP", "\(stats.currentHP)/\(stats.maxHP)", SKColor.green, "icon_heart"),
            (loc.localize("hud.damage"), "\(stats.damageMin)-\(stats.damageMax)", SKColor.red, "icon_staff"),
            (loc.localize("hud.max_armor"), "\(stats.armor)", SKColor.gray, "icon_shield"),
            (loc.localize("hud.crit_chance"), "\(Int(stats.critChance * 100))%", SKColor.yellow, "icon_sling")
        ]
        
        for (i, stat) in statLines.enumerated() {
            let row = i / 2
            let col = i % 2
            let xPos = centerX + CGFloat(col - 1) * 95 + 40
            let yPos = statsY - CGFloat(row) * 30
            
            let icon = SKSpriteNode(imageNamed: stat.3)
            icon.size = CGSize(width: 18, height: 18)
            icon.position = CGPoint(x: xPos - 55, y: yPos)
            leftPanel.addChild(icon)

            let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            label.text = "\(stat.0): \(stat.1)"
            label.fontSize = 10
            label.fontColor = .white
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: xPos - 42, y: yPos - 4)
            leftPanel.addChild(label)
        }
    }
    
    private func setupRightContent(player: PlayerData) {
        let safeR = max(40, view?.safeAreaInsets.right ?? 0)
        let panelW = size.width * 0.52 - safeR
        
        let cols = 5
        let spacing: CGFloat = 65 // Mais espaçado
        let gridStartX = (panelW - CGFloat(cols - 1) * spacing) / 2
        let startY = size.height * 0.72
        
        for (i, itemId) in player.inventory.enumerated() {
            guard let item = EquipmentDatabase.shared.item(withId: itemId) else { continue }
            let col = i % cols
            let row = i / cols
            let pos = CGPoint(x: gridStartX + CGFloat(col) * spacing, y: startY - CGFloat(row) * spacing)
            
            let itemNode = createItemIcon(item: item, position: pos)
            itemNode.name = "inv_\(i)_\(itemId)" // Usando índice para evitar problemas com IDs repetidos
            rightPanel.addChild(itemNode)
            
            // Highlight se selecionado
            if selectedItemId == itemId {
                let highlight = SKShapeNode(rectOf: CGSize(width: 54, height: 54), cornerRadius: 8)
                highlight.strokeColor = .yellow
                highlight.lineWidth = 2
                highlight.zPosition = 5
                itemNode.addChild(highlight)
            }
        }
    }
    
    private func createSlotNode(slot: EquipmentSlot, position: CGPoint, equippedItemId: String?) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "equipped_\(slot.rawValue)"
        
        let bg = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 8)
        bg.fillColor = SKColor(white: 0.1, alpha: 0.8)
        bg.strokeColor = equippedItemId != nil ? SKColor.orange : SKColor(white: 0.3, alpha: 1)
        bg.lineWidth = 2
        bg.name = node.name
        node.addChild(bg)
        
        if let id = equippedItemId, let item = EquipmentDatabase.shared.item(withId: id) {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = String(item.localizedName.prefix(1)).uppercased()
            label.fontSize = 24
            label.fontColor = item.rarity.color
            label.verticalAlignmentMode = .center
            label.name = node.name
            node.addChild(label)
        } else {
            let iconLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            iconLabel.text = slot.rawValue.prefix(1).uppercased()
            iconLabel.fontSize = 14
            iconLabel.fontColor = SKColor(white: 0.2, alpha: 1)
            iconLabel.verticalAlignmentMode = .center
            iconLabel.name = node.name
            node.addChild(iconLabel)
        }
        
        return node
    }
    
    private func createItemIcon(item: Equipment, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        
        let bg = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 8)
        bg.fillColor = SKColor(white: 0.15, alpha: 0.9)
        bg.strokeColor = item.rarity.color
        bg.lineWidth = 2
        container.addChild(bg)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = String(item.localizedName.prefix(1)).uppercased()
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        return container
    }

    private func showItemDetails(itemId: String) {
        detailsPanel.removeAllChildren()
        detailsPanel.isHidden = false
        
        guard let item = EquipmentDatabase.shared.item(withId: itemId) else { return }
        
        // Fundo Pergaminho
        let bg = SKSpriteNode(imageNamed: "pergaminho")
        bg.size = CGSize(width: 320, height: 240)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        detailsPanel.addChild(bg)
        
        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.text = item.localizedName
        name.fontSize = 22
        name.fontColor = .black
        name.position = CGPoint(x: 0, y: 60)
        bg.addChild(name)
        
        let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        statsLabel.text = "Tipo: \(item.slot.rawValue.capitalized)"
        statsLabel.fontSize = 16
        statsLabel.fontColor = .darkGray
        statsLabel.position = CGPoint(x: 0, y: 30)
        bg.addChild(statsLabel)
        
        let rarityLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rarityLabel.text = item.rarity.rawValue.uppercased()
        rarityLabel.fontSize = 14
        rarityLabel.fontColor = item.rarity.color
        rarityLabel.position = CGPoint(x: 0, y: 10)
        bg.addChild(rarityLabel)
        
        let equipBtn = createButton(text: loc.localize("item.action.equip"), 
                                   position: CGPoint(x: 0, y: -45), 
                                   name: "btn_equip_\(itemId)", 
                                   size: CGSize(width: 160, height: 45))
        bg.addChild(equipBtn)
        
        let closeBtn = createButton(text: "X", 
                                   position: CGPoint(x: 120, y: 85), 
                                   name: "btn_close_details", 
                                   size: CGSize(width: 35, height: 35))
        bg.addChild(closeBtn)
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
            
            if name == "btn_back" {
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.reveal(with: .right, duration: 0.3))
                return
            }
            
            if name == "btn_close_details" {
                selectedItemId = nil
                refreshUI()
                return
            }
            
            // Prefix inv_ seguido de índice e itemId
            if name.hasPrefix("inv_") {
                let components = name.components(separatedBy: "_")
                if components.count >= 3 {
                    selectedItemId = components[2]
                    refreshUI()
                }
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
}
