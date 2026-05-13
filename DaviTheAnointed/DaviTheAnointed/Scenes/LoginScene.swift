import SpriteKit

class LoginScene: SKScene {

    private let loc = LocalizationManager.shared
    private var loadingNode: SKLabelNode?

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

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Davi: O Ungido"
        title.fontSize = 48
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = "A Jornada do Rei"
        subtitle.fontSize = 18
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        addChild(subtitle)

        // Dev Login Button
        let loginBtn = createButton(text: "ENTRAR (MODO DEV)", position: CGPoint(x: size.width / 2, y: size.height * 0.35), name: "btn_dev_login")
        addChild(loginBtn)
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = CGSize(width: 280, height: 60)
        button.position = position
        button.name = name

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = name // Mesmo nome para propagar o clique
        button.addChild(label)

        return button
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            if node.name == "btn_dev_login" {
                performDevLogin()
                return
            }
        }
    }

    private func performDevLogin() {
        print("[AUTH] Performing Mocked Dev Login...")
        GameManager.shared.initializePlayer(userId: "dev_player_123", displayName: "Davi Dev", language: .portuguese)
        
        let scene = MainMenuScene(size: self.size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 0.5))
    }
}
