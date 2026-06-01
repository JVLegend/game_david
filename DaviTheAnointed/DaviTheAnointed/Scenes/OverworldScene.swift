import SpriteKit

class OverworldScene: SKScene {

    private let loc = LocalizationManager.shared
    private var availableBattleNames = Set<String>()
    private var selectedMapId: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        removeAllChildren()
        availableBattleNames.removeAll()
        guard let player = GameManager.shared.playerData else { return }
        let highestAccessibleMap = highestAccessibleMapId(for: player)
        if selectedMapId == 0 || selectedMapId > highestAccessibleMap {
            selectedMapId = highestAccessibleMap
        }
        selectedMapId = max(1, selectedMapId)
        AudioManager.shared.playMapMusic(mapId: selectedMapId)
        let mapDef = EnemyDatabase.shared.map(withId: selectedMapId)

        // Background
        let bg = SKSpriteNode(imageNamed: mapDef?.backgroundTexture ?? "background_forest")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.alpha = 0.6
        addChild(bg)

        let safeArea = view?.safeAreaInsets ?? .zero
        let safeL: CGFloat = max(40, safeArea.left)
        let safeR: CGFloat = max(40, safeArea.right)

        // Map Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = mapDef?.localizedName ?? "Map \(selectedMapId)"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height - 50)

        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleShadow.text = title.text
        titleShadow.fontSize = title.fontSize
        titleShadow.fontColor = .black
        titleShadow.position = CGPoint(x: 2, y: -2)
        titleShadow.zPosition = -1
        titleShadow.alpha = 0.7
        title.addChild(titleShadow)
        addChild(title)

        let mapNavY = size.height - 88
        if selectedMapId > 1 {
            let prevBtn = createButton(
                text: "← \(loc.localize("map.stage")) \(selectedMapId - 1)",
                position: CGPoint(x: size.width / 2 - 155, y: mapNavY),
                name: "btn_map_prev",
                size: CGSize(width: 142, height: 36)
            )
            addChild(prevBtn)
        }

        let mapIndexLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        mapIndexLabel.text = "\(loc.localize("map.stage")) \(selectedMapId)"
        mapIndexLabel.fontSize = 14
        mapIndexLabel.fontColor = SKColor(red: 1, green: 0.86, blue: 0.42, alpha: 1)
        mapIndexLabel.verticalAlignmentMode = .center
        mapIndexLabel.position = CGPoint(x: size.width / 2, y: mapNavY)
        addChild(mapIndexLabel)

        if selectedMapId < highestAccessibleMap {
            let nextBtn = createButton(
                text: "\(loc.localize("map.stage")) \(selectedMapId + 1) →",
                position: CGPoint(x: size.width / 2 + 155, y: mapNavY),
                name: "btn_map_next",
                size: CGSize(width: 142, height: 36)
            )
            addChild(nextBtn)
        }

        // Gold display
        let goldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goldLabel.text = "\(player.gold)"
        goldLabel.fontSize = 18
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: safeL + 30, y: size.height - 50)

        let goldShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goldShadow.text = goldLabel.text
        goldShadow.fontSize = goldLabel.fontSize
        goldShadow.fontColor = .black
        goldShadow.horizontalAlignmentMode = .left
        goldShadow.position = CGPoint(x: 1.5, y: -1.5)
        goldShadow.zPosition = -1
        goldShadow.alpha = 0.6
        goldLabel.addChild(goldShadow)
        addChild(goldLabel)

        let goldIcon = SKSpriteNode(imageNamed: "menu_icon_gold")
        goldIcon.size = CGSize(width: 26, height: 26)
        goldIcon.position = CGPoint(x: safeL + 15, y: size.height - 44)
        addChild(goldIcon)

        // Battle nodes
        guard let map = mapDef else { return }
        let nodeSpacing = (size.width - safeL - safeR) / CGFloat(map.battles.count + 1)

        for (index, battle) in map.battles.enumerated() {
            let x = safeL + nodeSpacing * CGFloat(index + 1)
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
                let nextX = safeL + nodeSpacing * CGFloat(index + 2)
                let nextY = size.height * 0.45 + ((index + 1) % 2 == 0 ? 30 : -30)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: nextX, y: nextY))
                let pathNode = SKShapeNode(path: path)
                pathNode.strokeColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 0.6)
                pathNode.lineWidth = 3
                pathNode.zPosition = -1
                addChild(pathNode)
            }
        }

        // Back button
        let backBtn = createButton(text: loc.localize("general.back"), position: CGPoint(x: safeL + 60, y: 40), name: "btn_back")
        addChild(backBtn)

        // Quick access buttons at bottom
        let bottomButtons: [(String, String)] = [
            ("menu.shop", "btn_shop"),
            ("menu.inventory", "btn_inventory"),
        ]
        for (i, btn) in bottomButtons.enumerated() {
            let x = size.width - safeR - 60 - CGFloat(i) * 140
            let button = createButton(text: loc.localize(btn.0), position: CGPoint(x: x, y: 40), name: btn.1)
            addChild(button)
        }
    }

    private func highestAccessibleMapId(for player: PlayerData) -> Int {
        var candidate = max(1, player.highestMapCompleted + 1)
        while candidate > 1 && EnemyDatabase.shared.map(withId: candidate) == nil {
            candidate -= 1
        }
        return max(1, candidate)
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

        // Node sprite instead of circle
        let marker = SKSpriteNode(imageNamed: "map_marker")
        let sizeVal: CGFloat = battle.isBossBattle ? 80 : 64
        marker.size = CGSize(width: sizeVal, height: sizeVal)
        if !isAvailable {
            marker.color = .black
            marker.colorBlendFactor = 0.6
            marker.alpha = 0.65
        } else if let name = container.name {
            availableBattleNames.insert(name)
        }
        marker.name = container.name
        container.addChild(marker)

        // Battle number
        let numLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        numLabel.text = battle.isBossBattle ? "BOSS" : "\(battle.battleId)"
        numLabel.fontSize = battle.isBossBattle ? 14 : 18
        numLabel.fontColor = isAvailable ? .white : SKColor(white: 0.75, alpha: 1)
        numLabel.verticalAlignmentMode = .center
        numLabel.name = container.name
        container.addChild(numLabel)

        // Battle name below
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        nameLabel.text = battle.localizedName
        nameLabel.fontSize = 12
        nameLabel.fontColor = isAvailable ? .white : SKColor(white: 0.65, alpha: 1)
        nameLabel.position = CGPoint(x: 0, y: -sizeVal / 2 - 18)
        container.addChild(nameLabel)

        if !isAvailable {
            let lock = SKLabelNode(fontNamed: "AvenirNext-Bold")
            lock.text = "LOCK"
            lock.fontSize = 10
            lock.fontColor = SKColor(red: 1, green: 0.75, blue: 0.3, alpha: 1)
            lock.position = CGPoint(x: 0, y: -sizeVal / 2 - 4)
            container.addChild(lock)
        }

        // Stars
        if stars > 0 {
            for i in 0..<3 {
                let starLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                starLabel.text = i < stars ? "★" : "☆"
                starLabel.fontSize = 14
                starLabel.fontColor = i < stars ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(white: 0.5, alpha: 1)
                starLabel.position = CGPoint(x: CGFloat(i - 1) * 16, y: sizeVal / 2 + 10)
                container.addChild(starLabel)
            }
        }

        return container
    }

    private func createButton(text: String, position: CGPoint, name: String, size: CGSize = CGSize(width: 120, height: 40)) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = size
        button.position = position
        button.name = name

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = min(14, size.height * 0.38)
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = name
        fit(label: label, maxWidth: size.width - 16, minimumSize: 10)
        button.addChild(label)

        return button
    }

    private func fit(label: SKLabelNode, maxWidth: CGFloat, minimumSize: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > minimumSize {
            label.fontSize -= 1
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            guard let name = node.name else { continue }

            if name.hasPrefix("battle_") {
                guard availableBattleNames.contains(name) else {
                    showLockedBattleHint()
                    return
                }

                let parts = name.split(separator: "_")
                if parts.count == 3, let mapId = Int(parts[1]), let battleId = Int(parts[2]) {
                    startBattle(mapId: mapId, battleId: battleId)
                    return
                }
            }

            switch name {
            case "btn_map_prev":
                selectedMapId = max(1, selectedMapId - 1)
                setupUI()
                return
            case "btn_map_next":
                if let player = GameManager.shared.playerData {
                    selectedMapId = min(highestAccessibleMapId(for: player), selectedMapId + 1)
                    setupUI()
                }
                return
            case "btn_back":
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
            case "btn_shop":
                let scene = ShopScene(size: self.size)
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
            case "btn_inventory":
                let scene = InventoryScene(size: self.size)
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
            default:
                break
            }
        }
    }

    private func showLockedBattleHint() {
        childNode(withName: "locked_battle_hint")?.removeFromParent()

        let hint = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hint.name = "locked_battle_hint"
        hint.text = "Complete a batalha anterior"
        hint.fontSize = 16
        hint.fontColor = SKColor(red: 1, green: 0.8, blue: 0.3, alpha: 1)
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        hint.zPosition = 50
        addChild(hint)

        hint.setScale(0.9)
        hint.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.08),
            SKAction.wait(forDuration: 0.85),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }

    private func startBattle(mapId: Int, battleId: Int) {
        guard let player = GameManager.shared.playerData,
              let map = EnemyDatabase.shared.map(withId: mapId) else { return }

        let battle = map.battles.first { $0.battleId == battleId }
        guard let battleDef = battle else { return }
        guard isBattleAvailable(battleDef, in: map, player: player) else { return }

        let battleScene = BattleScene(size: self.size)
        battleScene.scaleMode = .resizeFill
        battleScene.mapId = mapId
        battleScene.battleId = battleId
        self.view?.presentScene(battleScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
