import SpriteKit

class SettingsScene: SKScene {

    private let loc = LocalizationManager.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("settings.title")
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(title)

        // Language setting
        let currentLang = loc.language
        let langLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        langLabel.text = "\(loc.localize("settings.language")): \(currentLang.displayName)"
        langLabel.fontSize = 16
        langLabel.fontColor = .white
        langLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        addChild(langLabel)

        // Language toggle buttons
        for (i, language) in GameLanguage.allCases.enumerated() {
            let x = size.width / 2 + CGFloat(i == 0 ? -80 : 80)
            let isActive = language == currentLang
            let btn = createLanguageButton(
                language: language,
                position: CGPoint(x: x, y: size.height * 0.55),
                isActive: isActive
            )
            addChild(btn)
        }

        // Sound toggle
        let soundLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        soundLabel.text = "\(loc.localize("settings.sound")): ON"
        soundLabel.fontSize = 16
        soundLabel.fontColor = .white
        soundLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.42)
        soundLabel.name = "btn_sound"
        addChild(soundLabel)

        // Music toggle
        let musicLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        musicLabel.text = "\(loc.localize("settings.music")): ON"
        musicLabel.fontSize = 16
        musicLabel.fontColor = .white
        musicLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.34)
        musicLabel.name = "btn_music"
        addChild(musicLabel)

        // Account info
        if let player = GameManager.shared.playerData {
            let accountLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            accountLabel.text = "\(loc.localize("settings.account")): \(player.displayName)"
            accountLabel.fontSize = 12
            accountLabel.fontColor = SKColor(white: 0.5, alpha: 1)
            accountLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
            addChild(accountLabel)
        }

        // Back button — topo esquerdo
        let backBtn = createButton(text: "← \(loc.localize("general.back"))", position: CGPoint(x: 60, y: size.height - 22), name: "btn_back")
        addChild(backBtn)
    }

    private func createLanguageButton(language: GameLanguage, position: CGPoint, isActive: Bool) -> SKNode {
        let node = SKNode()
        node.position = position
        node.name = "lang_\(language.rawValue)"

        let bg = SKShapeNode(rectOf: CGSize(width: 140, height: 36), cornerRadius: 6)
        bg.fillColor = isActive ?
            SKColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1) :
            SKColor(white: 0.2, alpha: 0.8)
        bg.strokeColor = isActive ?
            SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1) :
            SKColor(white: 0.3, alpha: 0.5)
        bg.lineWidth = isActive ? 2 : 1
        bg.name = node.name
        node.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = language.displayName
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = node.name
        node.addChild(label)

        return node
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 90, height: 30), cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.15, alpha: 0.9)
        bg.strokeColor = SKColor(red: 0.6, green: 0.45, blue: 0.2, alpha: 1)
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 12
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
            guard let name = node.name else { continue }

            if name == "btn_back" {
                let scene = MainMenuScene(size: self.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
                return
            }

            if name.hasPrefix("lang_") {
                let langRaw = String(name.dropFirst(5))
                if let language = GameLanguage(rawValue: langRaw) {
                    LocalizationManager.shared.setLanguage(language)
                    GameManager.shared.playerData?.language = language
                    GameManager.shared.save()
                    // Rebuild UI
                    removeAllChildren()
                    setupUI()
                }
                return
            }
        }
    }
}
