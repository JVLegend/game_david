import SpriteKit

class LoginScene: SKScene {

    private let loc = LocalizationManager.shared
    private var loadingNode: SKLabelNode?
    private var statusMessageY: CGFloat = 24

    override func didMove(to view: SKView) {
        AudioManager.shared.playMenuMusic()
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        setupUI()

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--test-apple-login") {
            run(.sequence([
                .wait(forDuration: 1.0),
                .run { [weak self] in self?.performAppleLogin() }
            ]))
        }
        #endif
    }

    private func setupUI() {
        // 1. Background Épico
        let bg = SKSpriteNode(imageNamed: "background_epic_login")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)

        // 2. Efeito de Partículas (Estrelas/Brilho)
        setupParticles()

        let shortLayout = size.height < 480
        let logoWidth = min(shortLayout ? 240 : 300, size.width * 0.44)
        let logoHeight = logoWidth * 0.60
        let logoY = size.height * (shortLayout ? 0.75 : 0.70)
        let buttonWidth = min(shortLayout ? 300 : 320, size.width * 0.58)
        let buttonHeight = min(shortLayout ? 50 : 58, max(44, size.height * 0.12))
        let buttonGap = max(14, size.height * 0.035)
        let buttonStep = buttonHeight + buttonGap
        let logoBottom = logoY - logoHeight / 2
        let topButtonY = min(size.height * (shortLayout ? 0.43 : 0.40), logoBottom - buttonHeight / 2 - 26)

        // 4. Logo Gráfico Central
        let logoPlate = SKSpriteNode(imageNamed: "logo_graphic")
        logoPlate.size = CGSize(width: logoWidth, height: logoHeight)
        logoPlate.position = CGPoint(x: size.width / 2, y: logoY)
        logoPlate.zPosition = 5
        addChild(logoPlate)

        // Animação de flutuação no logo
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 2.0)
        moveUp.timingMode = .easeInEaseOut
        logoPlate.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveUp.reversed()])))

        // 5. Título Principal (Sobre o Logo)
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "DAVI"
        title.fontSize = shortLayout ? 46 : 56
        title.fontColor = SKColor(red: 1, green: 0.9, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: logoY + logoHeight * 0.20)
        title.zPosition = 10

        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleShadow.text = title.text
        titleShadow.fontSize = title.fontSize
        titleShadow.fontColor = .black
        titleShadow.position = CGPoint(x: 3, y: -3)
        titleShadow.zPosition = -1
        titleShadow.alpha = 0.8
        title.addChild(titleShadow)
        addChild(title)

        let subtitleText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleText.text = "O UNGIDO"
        subtitleText.fontSize = shortLayout ? 20 : 24
        subtitleText.fontColor = .white
        subtitleText.position = CGPoint(x: size.width / 2, y: logoY - logoHeight * 0.20)
        subtitleText.zPosition = 10

        let subShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subShadow.text = subtitleText.text
        subShadow.fontSize = subtitleText.fontSize
        subShadow.fontColor = .black
        subShadow.position = CGPoint(x: 2, y: -2)
        subShadow.zPosition = -1
        subtitleText.addChild(subShadow)
        addChild(subtitleText)

        let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        statusMessageY = topButtonY + buttonHeight / 2 + 14

        let googleBtn = createButton(
            text: loc.localize("login.google").uppercased(),
            iconText: "G",
            position: CGPoint(x: size.width / 2, y: topButtonY),
            name: "btn_google_login",
            size: buttonSize
        )
        googleBtn.zPosition = 20
        addChild(googleBtn)

        let appleBtn = createButton(
            text: loc.localize("login.apple").uppercased(),
            iconText: "A",
            position: CGPoint(x: size.width / 2, y: topButtonY - buttonStep),
            name: "btn_apple_login",
            size: buttonSize
        )
        appleBtn.zPosition = 20
        addChild(appleBtn)

        let scaleUp = SKAction.scale(to: 1.05, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut
        googleBtn.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleUp.reversed()])))
    }

    private func setupParticles() {
        for _ in 0...30 {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            p.fillColor = .white
            p.strokeColor = .clear
            p.alpha = CGFloat.random(in: 0.2...0.6)
            p.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
            p.zPosition = -5
            addChild(p)

            let fade = SKAction.sequence([
                SKAction.fadeOut(withDuration: Double.random(in: 1...3)),
                SKAction.fadeIn(withDuration: Double.random(in: 1...3))
            ])
            p.run(SKAction.repeatForever(fade))
        }
    }

    private func createButton(text: String, iconText: String, position: CGPoint, name: String, size: CGSize) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = size
        button.position = position
        button.name = name

        let iconBadge = SKShapeNode(circleOfRadius: size.height * 0.27)
        iconBadge.position = CGPoint(x: -size.width / 2 + size.height * 0.62, y: 0)
        iconBadge.fillColor = SKColor(red: 0.12, green: 0.07, blue: 0.025, alpha: 0.85)
        iconBadge.strokeColor = SKColor(red: 1, green: 0.82, blue: 0.28, alpha: 0.95)
        iconBadge.lineWidth = 1.5
        iconBadge.zPosition = 1
        iconBadge.name = name
        button.addChild(iconBadge)

        let iconLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        iconLabel.text = iconText
        iconLabel.fontSize = iconText.count > 1 ? size.height * 0.22 : size.height * 0.32
        iconLabel.fontColor = SKColor(red: 1, green: 0.88, blue: 0.42, alpha: 1)
        iconLabel.verticalAlignmentMode = .center
        iconLabel.horizontalAlignmentMode = .center
        iconLabel.zPosition = 2
        iconLabel.name = name
        iconBadge.addChild(iconLabel)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = size.height * 0.32
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.height * 0.20, y: 0)
        label.zPosition = 1
        label.name = name // Mesmo nome para propagar o clique
        fit(label: label, maxWidth: size.width - size.height * 1.55, minimumSize: 12)

        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.text = text
        shadow.fontSize = label.fontSize
        shadow.fontColor = .black
        shadow.verticalAlignmentMode = .center
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        shadow.alpha = 0.6
        label.addChild(shadow)

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
            if node.name == "btn_google_login" {
                performGoogleLogin()
                return
            }

            if node.name == "btn_apple_login" {
                performAppleLogin()
                return
            }
        }
    }

    private func performGoogleLogin() {
        setLoadingMessage(loc.localize("login.loading_google"))
        AuthManager.shared.signInWithGoogle(presenting: view?.window?.rootViewController) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let user):
                    GameManager.shared.initializePlayerFromAuth(
                        userId: user.userId,
                        displayName: user.displayName,
                        language: self.loc.language
                    ) {
                        self.presentMainMenu()
                    }
                case .failure(let error):
                    self.setLoadingMessage(error.localizedDescription)
                }
            }
        }
    }

    private func performAppleLogin() {
        setLoadingMessage(loc.localize("login.loading_apple"))
        AuthManager.shared.signInWithApple(presenting: view?.window?.rootViewController) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let user):
                    GameManager.shared.initializePlayerFromAuth(
                        userId: user.userId,
                        displayName: user.displayName,
                        language: self.loc.language
                    ) {
                        self.presentMainMenu()
                    }
                case .failure(let error):
                    self.setLoadingMessage(error.localizedDescription)
                }
            }
        }
    }

    private func presentMainMenu() {
        let scene = MainMenuScene(size: self.size)
        scene.scaleMode = .resizeFill
        view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 0.5))
    }

    private func setLoadingMessage(_ message: String) {
        loadingNode?.removeFromParent()

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = message
        label.fontSize = 12
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: statusMessageY)
        label.zPosition = 30
        fit(label: label, maxWidth: min(320, size.width * 0.72), minimumSize: 9)
        addChild(label)
        loadingNode = label
    }
}
