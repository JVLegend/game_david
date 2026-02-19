import SpriteKit

class InventoryScene: SKScene {

    private let loc = LocalizationManager.shared
    private var selectedSlot: EquipmentSlot?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        guard let player = GameManager.shared.playerData else { return }
        let stats = GameManager.shared.computedStats()

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("menu.inventory")
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 30)
        addChild(title)

        // Character display (center)
        let charNode = SKSpriteNode(color: SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1), size: CGSize(width: 50, height: 90))
        charNode.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        addChild(charNode)

        let charLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        charLabel.text = loc.localize("character.\(player.activeCharacter.rawValue)")
        charLabel.fontSize = 14
        charLabel.fontColor = .white
        charLabel.position = CGPoint(x: 0, y: 55)
        charNode.addChild(charLabel)

        let levelLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        levelLabel.text = "\(loc.localize("hud.level")) \(player.level)"
        levelLabel.fontSize = 12
        levelLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        levelLabel.position = CGPoint(x: 0, y: -55)
        charNode.addChild(levelLabel)

        // Equipment slots around character
        let slotPositions: [(EquipmentSlot, CGPoint)] = [
            (.head, CGPoint(x: 0, y: 70)),
            (.body, CGPoint(x: -70, y: 20)),
            (.mainHand, CGPoint(x: -70, y: -30)),
            (.offHand, CGPoint(x: 70, y: -30)),
            (.feet, CGPoint(x: 0, y: -80)),
            (.gloves, CGPoint(x: 70, y: 20)),
            (.necklace, CGPoint(x: -70, y: 70)),
            (.ring1, CGPoint(x: 70, y: 70)),
            (.ring2, CGPoint(x: 100, y: 45)),
        ]

        for (slot, offset) in slotPositions {
            let pos = CGPoint(x: size.width / 2 + offset.x, y: size.height * 0.55 + offset.y)
            let slotNode = createSlotNode(slot: slot, position: pos, equippedItemId: player.equippedItems[slot])
            addChild(slotNode)
        }

        // Stats panel (left side)
        let statsLines: [(String, String)] = [
            (loc.localize("hud.attack"), ""),
            (loc.localize("hud.damage"), "\(stats.damageMin)-\(stats.damageMax)"),
            (loc.localize("hud.crit_chance"), "\(Int(stats.critChance * 100))%"),
            (loc.localize("hud.crit_damage"), String(format: "%.1fx", stats.critDamage)),
            ("", ""),
            (loc.localize("hud.defense"), ""),
            (loc.localize("hud.hp_max"), "\(stats.maxHP)"),
            (loc.localize("hud.max_armor"), "\(stats.armor)"),
            ("", ""),
            (loc.localize("hud.dodge"), ""),
            (loc.localize("hud.melee"), "\(Int(stats.dodgeMelee * 100))%"),
            (loc.localize("hud.ranged"), "\(Int(stats.dodgeRanged * 100))%"),
        ]

        for (i, line) in statsLines.enumerated() {
            if line.0.isEmpty { continue }
            let isHeader = line.1.isEmpty
            let label = SKLabelNode(fontNamed: isHeader ? "AvenirNext-Bold" : "AvenirNext-Regular")
            label.text = isHeader ? line.0 : "  \(line.0): \(line.1)"
            label.fontSize = isHeader ? 11 : 10
            label.fontColor = isHeader ? SKColor(red: 1, green: 0.7, blue: 0.3, alpha: 1) : .white
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: 15, y: size.height * 0.8 - CGFloat(i) * 14)
            addChild(label)
        }

        // Back button — canto inferior esquerdo, bem visível
        let backBtn = createButton(text: "← \(loc.localize("general.back"))", position: CGPoint(x: 60, y: size.height - 22), name: "btn_back")
        addChild(backBtn)
    }

    private func createSlotNode(slot: EquipmentSlot, position: CGPoint, equippedItemId: String?) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "slot_\(slot.rawValue)"

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 4)
        bg.fillColor = equippedItemId != nil ?
            SKColor(red: 0.4, green: 0.35, blue: 0.2, alpha: 0.9) :
            SKColor(white: 0.2, alpha: 0.7)
        bg.strokeColor = equippedItemId != nil ?
            SKColor(red: 0.7, green: 0.5, blue: 0.25, alpha: 1) :
            SKColor(white: 0.4, alpha: 0.5)
        bg.lineWidth = 1
        bg.name = node.name
        node.addChild(bg)

        if let itemId = equippedItemId, let item = EquipmentDatabase.shared.item(withId: itemId) {
            let itemLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            itemLabel.text = String(item.localizedName.prefix(3))
            itemLabel.fontSize = 8
            itemLabel.fontColor = .white
            itemLabel.verticalAlignmentMode = .center
            itemLabel.name = node.name
            node.addChild(itemLabel)
        } else {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            emptyLabel.text = slot.rawValue.prefix(3).uppercased()
            emptyLabel.fontSize = 7
            emptyLabel.fontColor = SKColor(white: 0.5, alpha: 0.6)
            emptyLabel.verticalAlignmentMode = .center
            emptyLabel.name = node.name
            node.addChild(emptyLabel)
        }

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
            if node.name == "btn_back" {
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
                return
            }
        }
    }
}
