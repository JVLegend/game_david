import SpriteKit

class OverworldScene: SKScene {

    private let loc = LocalizationManager.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.2, green: 0.35, blue: 0.15, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        guard let player = GameManager.shared.playerData else { return }
        let currentMap = player.highestMapCompleted + 1
        let mapDef = EnemyDatabase.shared.map(withId: min(currentMap, 2))

        // Map Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = mapDef?.localizedName ?? "Map \(currentMap)"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(title)

        // Gold display
        let goldLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        goldLabel.text = "\(player.gold)"
        goldLabel.fontSize = 16
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: 20, y: size.height - 40)
        addChild(goldLabel)

        // Battle nodes
        guard let map = mapDef else { return }
        let nodeSpacing = size.width / CGFloat(map.battles.count + 1)

        for (index, battle) in map.battles.enumerated() {
            let x = nodeSpacing * CGFloat(index + 1)
            let y = size.height * 0.45 + (index % 2 == 0 ? 30 : -30)

            let battleNode = createBattleNode(
                battle: battle,
                position: CGPoint(x: x, y: y),
                stars: player.starsForBattle(mapId: map.id, battleId: battle.battleId),
                isAvailable: isBattleAvailable(battle, in: map, player: player)
            )
            addChild(battleNode)

            // Draw path to next node
            if index < map.battles.count - 1 {
                let nextX = nodeSpacing * CGFloat(index + 2)
                let nextY = size.height * 0.45 + ((index + 1) % 2 == 0 ? 30 : -30)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: nextX, y: nextY))
                let pathNode = SKShapeNode(path: path)
                pathNode.strokeColor = SKColor(white: 0.6, alpha: 0.5)
                pathNode.lineWidth = 2
                pathNode.zPosition = -1
                addChild(pathNode)
            }
        }

        // Back button
        let backBtn = createButton(text: loc.localize("general.back"), position: CGPoint(x: 80, y: 30), name: "btn_back")
        addChild(backBtn)

        // Quick access buttons at bottom
        let bottomButtons: [(String, String)] = [
            ("menu.shop", "btn_shop"),
            ("menu.inventory", "btn_inventory"),
        ]
        for (i, btn) in bottomButtons.enumerated() {
            let x = size.width - 120 - CGFloat(i) * 130
            let button = createButton(text: loc.localize(btn.0), position: CGPoint(x: x, y: 30), name: btn.1)
            addChild(button)
        }
    }

    private func isBattleAvailable(_ battle: BattleDefinition, in map: MapDefinition, player: PlayerData) -> Bool {
        if battle.battleId == 1 { return true }
        let prevBattle = battle.battleId - 1
        return player.starsForBattle(mapId: map.id, battleId: prevBattle) > 0
    }

    private func createBattleNode(battle: BattleDefinition, position: CGPoint, stars: Int, isAvailable: Bool) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = "battle_\(battle.mapId)_\(battle.battleId)"

        // Node circle
        let radius: CGFloat = battle.isBossBattle ? 35 : 28
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = isAvailable ?
            (battle.isBossBattle ? SKColor(red: 0.8, green: 0.2, blue: 0.1, alpha: 1) : SKColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1)) :
            SKColor(white: 0.3, alpha: 0.7)
        circle.strokeColor = stars > 0 ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(white: 0.5, alpha: 1)
        circle.lineWidth = stars > 0 ? 3 : 1
        circle.name = container.name
        container.addChild(circle)

        // Battle number
        let numLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        numLabel.text = battle.isBossBattle ? "BOSS" : "\(battle.battleId)"
        numLabel.fontSize = battle.isBossBattle ? 12 : 16
        numLabel.fontColor = .white
        numLabel.verticalAlignmentMode = .center
        numLabel.name = container.name
        container.addChild(numLabel)

        // Battle name below
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        nameLabel.text = battle.localizedName
        nameLabel.fontSize = 10
        nameLabel.fontColor = SKColor(white: 0.9, alpha: 1)
        nameLabel.position = CGPoint(x: 0, y: -radius - 15)
        container.addChild(nameLabel)

        // Stars
        if stars > 0 {
            for i in 0..<3 {
                let starLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                starLabel.text = i < stars ? "★" : "☆"
                starLabel.fontSize = 12
                starLabel.fontColor = i < stars ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(white: 0.4, alpha: 1)
                starLabel.position = CGPoint(x: CGFloat(i - 1) * 14, y: radius + 8)
                container.addChild(starLabel)
            }
        }

        return container
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 110, height: 32), cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.15, alpha: 0.9)
        bg.strokeColor = SKColor(red: 0.6, green: 0.45, blue: 0.2, alpha: 1)
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 13
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

            if name.hasPrefix("battle_") {
                let parts = name.split(separator: "_")
                if parts.count == 3, let mapId = Int(parts[1]), let battleId = Int(parts[2]) {
                    startBattle(mapId: mapId, battleId: battleId)
                    return
                }
            }

            switch name {
            case "btn_back":
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
            case "btn_shop":
                let scene = ShopScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
            case "btn_inventory":
                let scene = InventoryScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
            default:
                break
            }
        }
    }

    private func startBattle(mapId: Int, battleId: Int) {
        guard let player = GameManager.shared.playerData,
              let map = EnemyDatabase.shared.map(withId: mapId) else { return }

        let battle = map.battles.first { $0.battleId == battleId }
        guard let battleDef = battle else { return }
        guard isBattleAvailable(battleDef, in: map, player: player) else { return }

        let battleScene = BattleScene(size: self.size)
        battleScene.scaleMode = .aspectFill
        battleScene.mapId = mapId
        battleScene.battleId = battleId
        self.view?.presentScene(battleScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
