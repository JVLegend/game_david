import SpriteKit

class LanguageSelectionScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.10, blue: 0.08, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Choose your language / Escolha seu idioma"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(title)

        // Portuguese Button
        let ptButton = createButton(
            text: "Portugues (BR)",
            position: CGPoint(x: size.width / 2 - 150, y: size.height * 0.4),
            name: "btn_portuguese"
        )
        addChild(ptButton)

        // English Button
        let enButton = createButton(
            text: "English",
            position: CGPoint(x: size.width / 2 + 150, y: size.height * 0.4),
            name: "btn_english"
        )
        addChild(enButton)
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 240, height: 60), cornerRadius: 12)
        bg.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
        bg.strokeColor = SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1)
        bg.lineWidth = 2
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 20
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
            if node.name == "btn_portuguese" {
                selectLanguage(.portuguese)
                return
            } else if node.name == "btn_english" {
                selectLanguage(.english)
                return
            }
        }
    }

    private func selectLanguage(_ language: GameLanguage) {
        LocalizationManager.shared.setLanguage(language)
        transitionToLogin()
    }

    private func transitionToLogin() {
        let loginScene = LoginScene(size: self.size)
        loginScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(loginScene, transition: transition)
    }
}
