import SpriteKit

class MainMenuScene: SKScene {

    private let loc = LocalizationManager.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.10, blue: 0.08, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        guard let player = GameManager.shared.playerData else { return }

        // Safe margins para evitar corte em notch/bordas
        let safeL: CGFloat = 60
        let safeR: CGFloat = 60

        // Background decorativo
        let bgRect = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bgRect.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgRect.fillColor = SKColor(red: 0.15, green: 0.10, blue: 0.08, alpha: 1)
        bgRect.strokeColor = .clear
        bgRect.zPosition = -10
        addChild(bgRect)

        // === COLUNA ESQUERDA: título + stats do player ===
        let leftCenterX: CGFloat = safeL + (size.width * 0.44 - safeL) / 2

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("login.title")
        title.fontSize = 22
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: leftCenterX, y: size.height - 38)
        addChild(title)

        // Stats do jogador (nivel, gold, rubies) em linha horizontal
        let statsY = size.height - 60
        let statItems: [(String, SKColor)] = [
            ("\(loc.localize("hud.level")) \(player.level)", .white),
            ("🪙 \(player.gold)", SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)),
            ("💎 \(player.rubies)", SKColor(red: 1, green: 0.4, blue: 0.4, alpha: 1)),
        ]
        let statTotalW = size.width * 0.34
        let statSpacing = statTotalW / CGFloat(statItems.count)
        let statStartX = leftCenterX - statTotalW / 2 + statSpacing / 2
        for (i, stat) in statItems.enumerated() {
            let lbl = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            lbl.text = stat.0
            lbl.fontSize = 12
            lbl.fontColor = stat.1
            lbl.horizontalAlignmentMode = .center
            lbl.position = CGPoint(x: statStartX + CGFloat(i) * statSpacing, y: statsY)
            addChild(lbl)
        }

        // Power Score
        let psLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        psLabel.text = "PS: \(player.powerScore)"
        psLabel.fontSize = 11
        psLabel.fontColor = SKColor(white: 0.6, alpha: 1)
        psLabel.horizontalAlignmentMode = .center
        psLabel.position = CGPoint(x: leftCenterX, y: statsY - 20)
        addChild(psLabel)

        // Divider vertical
        let divPath = CGMutablePath()
        divPath.move(to: CGPoint(x: size.width * 0.44, y: 10))
        divPath.addLine(to: CGPoint(x: size.width * 0.44, y: size.height - 10))
        let div = SKShapeNode(path: divPath)
        div.strokeColor = SKColor(white: 0.3, alpha: 0.6)
        div.lineWidth = 1
        addChild(div)

        // === COLUNA DIREITA: botões do menu ===
        let rightX: CGFloat = (size.width * 0.44 + size.width - safeR) / 2

        // Botão principal (Iniciar/Continuar Jornada) com destaque
        let isNewPlayer = player.highestMapCompleted == 0 &&
            player.mapStars.isEmpty
        let mainBtnKey = isNewPlayer ? "menu.start" : "menu.continue"
        let mainBtn = createMenuButton(
            text: loc.localize(mainBtnKey),
            position: CGPoint(x: rightX, y: size.height * 0.75),
            name: "btn_continue",
            highlight: true
        )
        addChild(mainBtn)

        // Outros botões
        let otherButtons: [(String, String)] = [
            ("menu.inventory", "btn_inventory"),
            ("menu.shop", "btn_shop"),
            ("menu.settings", "btn_settings"),
        ]
        let startY = size.height * 0.55
        let spacing: CGFloat = 46

        for (index, button) in otherButtons.enumerated() {
            let y = startY - CGFloat(index) * spacing
            let btn = createMenuButton(
                text: loc.localize(button.0),
                position: CGPoint(x: rightX, y: y),
                name: button.1,
                highlight: false
            )
            addChild(btn)
        }

        // PvP e Clans (desbloqueiam no mapa 3)
        if player.highestMapCompleted >= 3 {
            let pvpBtn = createMenuButton(
                text: loc.localize("menu.pvp"),
                position: CGPoint(x: rightX - 80, y: size.height * 0.12),
                name: "btn_pvp",
                highlight: false
            )
            addChild(pvpBtn)

            let clanBtn = createMenuButton(
                text: loc.localize("menu.clans"),
                position: CGPoint(x: rightX + 80, y: size.height * 0.12),
                name: "btn_clans",
                highlight: false
            )
            addChild(clanBtn)
        }
    }

    private func createMenuButton(text: String, position: CGPoint, name: String, highlight: Bool) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let btnW: CGFloat = highlight ? 240 : 220
        let btnH: CGFloat = highlight ? 40 : 36

        let bg = SKShapeNode(rectOf: CGSize(width: btnW, height: btnH), cornerRadius: 10)
        bg.fillColor = highlight ?
            SKColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1) :
            SKColor(red: 0.4, green: 0.28, blue: 0.12, alpha: 1)
        bg.strokeColor = highlight ?
            SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1) :
            SKColor(red: 0.6, green: 0.45, blue: 0.2, alpha: 0.8)
        bg.lineWidth = highlight ? 2 : 1
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: highlight ? "AvenirNext-Bold" : "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = highlight ? 17 : 15
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
                return
            case "btn_inventory":
                transitionToInventory()
                return
            case "btn_shop":
                transitionToShop()
                return
            case "btn_settings":
                transitionToSettings()
                return
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
