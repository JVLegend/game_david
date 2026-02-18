import SpriteKit

class MainMenuScene: SKScene {

    private let loc = LocalizationManager.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.10, blue: 0.08, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        guard let player = GameManager.shared.playerData else { return }

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("login.title")
        title.fontSize = 32
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(title)

        // Player info bar
        let infoBar = SKNode()
        infoBar.position = CGPoint(x: size.width / 2, y: size.height - 85)

        let levelLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        levelLabel.text = "\(loc.localize("hud.level")) \(player.level)"
        levelLabel.fontSize = 14
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: -300, y: 0)
        infoBar.addChild(levelLabel)

        let goldLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        goldLabel.text = "\(loc.localize("hud.gold")): \(player.gold)"
        goldLabel.fontSize = 14
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: -100, y: 0)
        infoBar.addChild(goldLabel)

        let rubyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        rubyLabel.text = "\(loc.localize("hud.rubies")): \(player.rubies)"
        rubyLabel.fontSize = 14
        rubyLabel.fontColor = SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        rubyLabel.horizontalAlignmentMode = .left
        rubyLabel.position = CGPoint(x: 100, y: 0)
        infoBar.addChild(rubyLabel)

        addChild(infoBar)

        // Menu buttons
        let buttons: [(String, String)] = [
            ("menu.continue", "btn_continue"),
            ("menu.inventory", "btn_inventory"),
            ("menu.shop", "btn_shop"),
            ("menu.ranking", "btn_ranking"),
            ("menu.challenges", "btn_challenges"),
            ("menu.settings", "btn_settings"),
        ]

        let startY = size.height * 0.65
        let spacing: CGFloat = 55

        for (index, button) in buttons.enumerated() {
            let y = startY - CGFloat(index) * spacing
            let btn = createMenuButton(
                text: loc.localize(button.0),
                position: CGPoint(x: size.width / 2, y: y),
                name: button.1
            )
            addChild(btn)
        }

        // Locked buttons (PvP, Clans - need Map 3)
        if player.highestMapCompleted >= 3 {
            let pvpBtn = createMenuButton(
                text: loc.localize("menu.pvp"),
                position: CGPoint(x: size.width / 2 - 200, y: size.height * 0.12),
                name: "btn_pvp"
            )
            addChild(pvpBtn)

            let clanBtn = createMenuButton(
                text: loc.localize("menu.clans"),
                position: CGPoint(x: size.width / 2 + 200, y: size.height * 0.12),
                name: "btn_clans"
            )
            addChild(clanBtn)
        }
    }

    private func createMenuButton(text: String, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 44), cornerRadius: 10)
        bg.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1)
        bg.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.25, alpha: 1)
        bg.lineWidth = 2
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 18
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
            switch node.name {
            case "btn_continue":
                transitionToOverworld()
            case "btn_inventory":
                transitionToInventory()
            case "btn_shop":
                transitionToShop()
            case "btn_settings":
                transitionToSettings()
            case "btn_ranking":
                // TODO: Ranking scene
                break
            case "btn_challenges":
                // TODO: Challenges scene
                break
            case "btn_pvp":
                // TODO: PvP scene
                break
            case "btn_clans":
                // TODO: Clans scene
                break
            default:
                break
            }
        }
    }

    private func transitionToOverworld() {
        let scene = OverworldScene(size: self.size)
        scene.scaleMode = .aspectFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToInventory() {
        let scene = InventoryScene(size: self.size)
        scene.scaleMode = .aspectFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToShop() {
        let scene = ShopScene(size: self.size)
        scene.scaleMode = .aspectFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToSettings() {
        let scene = SettingsScene(size: self.size)
        scene.scaleMode = .aspectFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }
}
