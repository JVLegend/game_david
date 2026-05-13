import SpriteKit

class LanguageSelectionScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        // Background
        let bg = SKSpriteNode(imageNamed: "background_menu")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Choose your language"
        title.fontSize = 28
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = "Escolha seu idioma"
        subtitle.fontSize = 20
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        addChild(subtitle)

        // Portuguese Button
        let ptButton = createButton(
            text: "Português",
            position: CGPoint(x: size.width / 2, y: size.height * 0.45),
            name: "btn_portuguese"
        )
        addChild(ptButton)

        // English Button
        let enButton = createButton(
            text: "English",
            position: CGPoint(x: size.width / 2, y: size.height * 0.28),
            name: "btn_english"
        )
        addChild(enButton)
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = CGSize(width: 260, height: 60)
        button.position = position
        button.name = name

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 20
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
