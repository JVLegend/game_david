import SpriteKit

class LoginScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        let loc = LocalizationManager.shared

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("login.title")
        title.fontSize = 40
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(title)

        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "Side-Scrolling AFK RPG"
        subtitle.fontSize = 16
        subtitle.fontColor = SKColor(white: 0.7, alpha: 1)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        addChild(subtitle)

        // Google Sign In Button
        let googleBtn = SKNode()
        googleBtn.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        googleBtn.name = "btn_google"

        let btnBg = SKShapeNode(rectOf: CGSize(width: 280, height: 56), cornerRadius: 8)
        btnBg.fillColor = .white
        btnBg.strokeColor = SKColor(white: 0.85, alpha: 1)
        btnBg.lineWidth = 1
        btnBg.name = "btn_google"
        googleBtn.addChild(btnBg)

        let btnLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        btnLabel.text = loc.localize("login.google")
        btnLabel.fontSize = 18
        btnLabel.fontColor = SKColor(white: 0.3, alpha: 1)
        btnLabel.verticalAlignmentMode = .center
        btnLabel.name = "btn_google"
        googleBtn.addChild(btnLabel)

        addChild(googleBtn)

        // Dev skip button (for testing without Google Auth)
        let devBtn = SKNode()
        devBtn.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        devBtn.name = "btn_dev"

        let devBg = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 6)
        devBg.fillColor = SKColor(white: 0.3, alpha: 0.5)
        devBg.strokeColor = SKColor(white: 0.5, alpha: 0.5)
        devBg.name = "btn_dev"
        devBtn.addChild(devBg)

        let devLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        devLabel.text = "Dev Mode (Skip Login)"
        devLabel.fontSize = 14
        devLabel.fontColor = SKColor(white: 0.6, alpha: 1)
        devLabel.verticalAlignmentMode = .center
        devLabel.name = "btn_dev"
        devBtn.addChild(devLabel)

        addChild(devBtn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            if node.name == "btn_google" {
                // TODO: Implement Google Sign-In via Firebase Auth
                // For now, use dev mode
                loginWithDevMode()
                return
            } else if node.name == "btn_dev" {
                loginWithDevMode()
                return
            }
        }
    }

    private func loginWithDevMode() {
        print("[DEV] loginWithDevMode started")
        let language = LocalizationManager.shared.language
        print("[DEV] language: \(language)")
        do {
            GameManager.shared.initializePlayer(
                userId: "dev_player_001",
                displayName: "Dev Player",
                language: language
            )
            print("[DEV] initializePlayer OK, playerData: \(String(describing: GameManager.shared.playerData))")
        }
        print("[DEV] transitioning to main menu")
        transitionToMainMenu()
    }

    private func transitionToMainMenu() {
        print("[DEV] creating MainMenuScene size=\(self.size)")
        let menuScene = MainMenuScene(size: self.size)
        menuScene.scaleMode = .aspectFill
        print("[DEV] presenting scene")
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(menuScene, transition: transition)
        print("[DEV] presentScene called")
    }
}
