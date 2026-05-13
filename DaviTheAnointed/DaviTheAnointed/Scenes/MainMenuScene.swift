import SpriteKit

class MainMenuScene: SKScene {

    private let loc = LocalizationManager.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        guard let player = GameManager.shared.playerData else { return }

        // Background
        let bg = SKSpriteNode(imageNamed: "background_menu")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)

        // Safe margins dinamicos baseados na view
        let safeArea = view?.safeAreaInsets ?? .zero
        // Converter safeArea para coordenadas da scene se necessário, mas aqui usaremos frações de size.
        let safeL: CGFloat = max(40, safeArea.left * (size.height / (view?.bounds.height ?? 1)))
        let safeR: CGFloat = max(40, safeArea.right * (size.height / (view?.bounds.height ?? 1)))

        // === COLUNA ESQUERDA: título + stats do player ===
        let leftCenterX: CGFloat = safeL + (size.width * 0.44 - safeL) / 2

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Davi: O Ungido"
        title.fontSize = 26
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: leftCenterX, y: size.height - 50)
        addChild(title)

        // Stats do jogador (nivel, gold, rubies) em linha horizontal
        let statsY = size.height - 80
        let statItems: [(String, SKColor, String)] = [
            ("\(loc.localize("hud.level")) \(player.level)", .white, ""),
            ("\(player.gold)", SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1), "icon_gold"),
            ("\(player.rubies)", SKColor(red: 1, green: 0.4, blue: 0.4, alpha: 1), "icon_ruby"),
        ]
        let statTotalW = size.width * 0.38
        let statSpacing = statTotalW / CGFloat(statItems.count)
        let statStartX = leftCenterX - statTotalW / 2 + statSpacing / 2
        for (i, stat) in statItems.enumerated() {
            let xPos = statStartX + CGFloat(i) * statSpacing
            
            if !stat.2.isEmpty {
                let icon = SKSpriteNode(imageNamed: stat.2)
                icon.size = CGSize(width: 16, height: 16)
                icon.position = CGPoint(x: xPos - 35, y: statsY + 5)
                addChild(icon)
            }

            let lbl = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            lbl.text = stat.0
            lbl.fontSize = 13
            lbl.fontColor = stat.1
            lbl.horizontalAlignmentMode = stat.2.isEmpty ? .center : .left
            lbl.position = CGPoint(x: stat.2.isEmpty ? xPos : xPos - 25, y: statsY)
            addChild(lbl)
        }

        // Divider vertical
        let div = SKShapeNode(rectOf: CGSize(width: 2, height: size.height - 40))
        div.position = CGPoint(x: size.width * 0.44, y: size.height / 2)
        div.fillColor = SKColor(white: 1, alpha: 0.2)
        div.strokeColor = .clear
        addChild(div)

        // === COLUNA DIREITA: botões do menu ===
        let rightX: CGFloat = (size.width * 0.44 + size.width - safeR) / 2

        // Botão principal (Iniciar/Continuar Jornada) com destaque
        let isNewPlayer = player.highestMapCompleted == 0 && player.mapStars.isEmpty
        let mainBtnKey = isNewPlayer ? "menu.start" : "menu.continue"
        let mainBtn = createMenuButton(
            text: loc.localize(mainBtnKey),
            position: CGPoint(x: rightX, y: size.height * 0.78),
            name: "btn_continue",
            highlight: true
        )
        addChild(mainBtn)

        // Outros botões
        let otherButtons: [(String, String)] = [
            ("menu.inventory", "btn_inventory"),
            ("menu.shop", "btn_shop"),
            ("RANKING", "btn_ranking"),
            ("menu.settings", "btn_settings"),
        ]
        let startY = size.height * 0.58
        let spacing: CGFloat = 50

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
    }

    private func createMenuButton(text: String, position: CGPoint, name: String, highlight: Bool) -> SKNode {
        let btnW: CGFloat = highlight ? 260 : 230
        let btnH: CGFloat = highlight ? 44 : 40

        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = CGSize(width: btnW, height: btnH)
        button.position = position
        button.name = name
        
        if highlight {
            button.color = .orange
            button.colorBlendFactor = 0.2
        }

        let label = SKLabelNode(fontNamed: highlight ? "AvenirNext-Bold" : "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = highlight ? 18 : 16
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
            case "btn_ranking":
                transitionToRanking()
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

    private func transitionToRanking() {
        // let scene = RankingScene(size: self.size)
        // scene.scaleMode = .aspectFill
        // self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
        print("Ranking temporariamente desativado")
    }

    private func transitionToSettings() {
        let scene = SettingsScene(size: self.size)
        scene.scaleMode = .aspectFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }
}
