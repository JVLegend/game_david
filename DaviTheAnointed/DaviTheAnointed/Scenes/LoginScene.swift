import SpriteKit
import FirebaseAuth

class LoginScene: SKScene {

    private var isLoggingIn = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1)
        setupUI()
        checkExistingSession()
    }

    // MARK: - Auto-login if already signed in to Firebase
    private func checkExistingSession() {
        if let user = Auth.auth().currentUser {
            print("[AUTH] Existing Firebase session: \(user.uid)")
            let language = LocalizationManager.shared.language
            GameManager.shared.initializePlayer(
                userId: user.uid,
                displayName: user.displayName ?? user.email ?? "Player",
                language: language
            )
            transitionToMainMenu()
        }
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

        // Anonymous / Guest button
        let guestBtn = SKNode()
        guestBtn.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
        guestBtn.name = "btn_guest"

        let guestBg = SKShapeNode(rectOf: CGSize(width: 230, height: 42), cornerRadius: 6)
        guestBg.fillColor = SKColor(white: 0.2, alpha: 0.7)
        guestBg.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        guestBg.name = "btn_guest"
        guestBtn.addChild(guestBg)

        let guestLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        guestLabel.text = "Jogar como Convidado"
        guestLabel.fontSize = 14
        guestLabel.fontColor = SKColor(white: 0.75, alpha: 1)
        guestLabel.verticalAlignmentMode = .center
        guestLabel.name = "btn_guest"
        guestBtn.addChild(guestLabel)

        addChild(guestBtn)

        // Dev skip button
        let devBtn = SKNode()
        devBtn.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        devBtn.name = "btn_dev"

        let devBg = SKShapeNode(rectOf: CGSize(width: 200, height: 34), cornerRadius: 6)
        devBg.fillColor = SKColor(white: 0.3, alpha: 0.4)
        devBg.strokeColor = SKColor(white: 0.4, alpha: 0.4)
        devBg.name = "btn_dev"
        devBtn.addChild(devBg)

        let devLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        devLabel.text = "Dev Mode (Skip Login)"
        devLabel.fontSize = 12
        devLabel.fontColor = SKColor(white: 0.5, alpha: 1)
        devLabel.verticalAlignmentMode = .center
        devLabel.name = "btn_dev"
        devBtn.addChild(devLabel)

        addChild(devBtn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isLoggingIn else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            switch node.name {
            case "btn_google":
                // TODO: Implement Google Sign-In (requires GoogleSignIn SDK + URL scheme)
                // For now, fall through to anonymous auth
                loginAnonymously()
                return
            case "btn_guest":
                loginAnonymously()
                return
            case "btn_dev":
                loginWithDevMode()
                return
            default:
                break
            }
        }
    }

    // MARK: - Anonymous Firebase Auth (Guest)
    private func loginAnonymously() {
        isLoggingIn = true
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("[AUTH] Anonymous sign-in error: \(error.localizedDescription)")
                    // Fallback to local dev mode
                    self.loginWithDevMode()
                    return
                }
                guard let user = result?.user else {
                    self.loginWithDevMode()
                    return
                }
                print("[AUTH] Anonymous sign-in: \(user.uid)")
                let language = LocalizationManager.shared.language
                GameManager.shared.initializePlayer(
                    userId: user.uid,
                    displayName: "Guerreiro",
                    language: language
                )
                self.transitionToMainMenu()
            }
        }
    }

    // MARK: - Dev Mode (local only)
    private func loginWithDevMode() {
        isLoggingIn = false
        let language = LocalizationManager.shared.language
        GameManager.shared.initializePlayer(
            userId: "dev_player_001",
            displayName: "Dev Player",
            language: language
        )
        transitionToMainMenu()
    }

    private func transitionToMainMenu() {
        let menuScene = MainMenuScene(size: self.size)
        menuScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(menuScene, transition: transition)
    }
}
