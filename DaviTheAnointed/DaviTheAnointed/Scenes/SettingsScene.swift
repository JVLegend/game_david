import SpriteKit

class SettingsScene: SKScene {

    private let loc = LocalizationManager.shared
    private var awaitingDeleteConfirmation = false
    private var statusMessage: String?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        removeAllChildren()

        // Background
        let bg = SKSpriteNode(imageNamed: "background_menu")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        bg.alpha = 0.5
        addChild(bg)

        let safeArea = view?.safeAreaInsets ?? .zero
        let safeL = max(40, safeArea.left)
        let isPortrait = size.height > size.width

        let panelWidth = min(size.width * 0.70, 420)
        let rowWidth = min(panelWidth, 340)

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("settings.title")
        title.fontSize = 28
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - (isPortrait ? 58 : 45))
        addChild(title)

        // Back button
        let backPosition = isPortrait
            ? CGPoint(x: safeL + 58, y: title.position.y - 52)
            : CGPoint(x: safeL + 60, y: size.height - 40)
        let backBtn = createButton(text: "← \(loc.localize("general.back"))", position: backPosition, name: "btn_back")
        addChild(backBtn)

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

        let soundToggle = createToggleRow(
            title: loc.localize("settings.sound"),
            isOn: AudioManager.shared.isSoundEnabled,
            position: CGPoint(x: size.width / 2, y: size.height * 0.44),
            name: "btn_sound"
        )
        addChild(soundToggle)

        let musicToggle = createToggleRow(
            title: loc.localize("settings.music"),
            isOn: AudioManager.shared.isMusicEnabled,
            position: CGPoint(x: size.width / 2, y: size.height * 0.325),
            name: "btn_music"
        )
        addChild(musicToggle)

        let accountPanel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: 122), cornerRadius: 10)
        accountPanel.position = CGPoint(x: size.width / 2, y: size.height * 0.19)
        accountPanel.fillColor = SKColor(red: 0.08, green: 0.045, blue: 0.025, alpha: 0.86)
        accountPanel.strokeColor = SKColor(red: 0.75, green: 0.52, blue: 0.16, alpha: 0.65)
        accountPanel.lineWidth = 1.5
        addChild(accountPanel)

        if let player = GameManager.shared.playerData {
            let accountLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            accountLabel.text = "\(loc.localize("settings.account")): \(player.displayName)"
            accountLabel.fontSize = 13
            accountLabel.fontColor = SKColor(white: 0.86, alpha: 1)
            accountLabel.position = CGPoint(x: size.width / 2, y: accountPanel.position.y + 42)
            fit(label: accountLabel, maxWidth: rowWidth, minimumSize: 10)
            addChild(accountLabel)
        }

        if let statusMessage {
            let statusLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            statusLabel.text = statusMessage
            statusLabel.fontSize = 11
            statusLabel.fontColor = SKColor(red: 1.0, green: 0.56, blue: 0.42, alpha: 1)
            statusLabel.position = CGPoint(x: size.width / 2, y: accountPanel.position.y + 16)
            fit(label: statusLabel, maxWidth: rowWidth, minimumSize: 8)
            addChild(statusLabel)
        }

        let logoutBtn = createAccountButton(
            text: loc.localize("settings.logout"),
            position: CGPoint(x: size.width / 2, y: accountPanel.position.y - 10),
            name: "btn_logout_account",
            isDestructive: false
        )
        addChild(logoutBtn)

        let deleteTitle = awaitingDeleteConfirmation
            ? loc.localize("settings.confirm_delete_account")
            : loc.localize("settings.delete_account")
        let deleteBtn = createAccountButton(
            text: deleteTitle,
            position: CGPoint(x: size.width / 2, y: accountPanel.position.y - 48),
            name: "btn_delete_account",
            isDestructive: true
        )
        addChild(deleteBtn)

        let footer = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        footer.text = "By JV."
        footer.fontSize = 11
        footer.fontColor = SKColor(white: 0.82, alpha: 0.78)
        footer.horizontalAlignmentMode = .center
        footer.verticalAlignmentMode = .center
        footer.position = CGPoint(x: size.width / 2, y: max(18, safeArea.bottom + 14))
        footer.zPosition = 2
        addChild(footer)
    }

    private func createLanguageButton(language: GameLanguage, position: CGPoint, isActive: Bool) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = CGSize(width: 140, height: 40)
        button.position = position
        button.name = "lang_\(language.rawValue)"

        if !isActive {
            button.color = .black
            button.colorBlendFactor = 0.5
            button.alpha = 0.7
        } else {
            button.color = .orange
            button.colorBlendFactor = 0.2
        }

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = language.displayName
        label.fontSize = 14
        label.fontColor = isActive ? .white : .lightGray
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = button.name
        button.addChild(label)

        return button
    }

    private func createToggleRow(title: String, isOn: Bool, position: CGPoint, name: String) -> SKNode {
        let row = SKNode()
        row.position = position
        row.name = name

        let rowSize = CGSize(width: 270, height: 48)
        let shadow = SKShapeNode(rectOf: rowSize, cornerRadius: 8)
        shadow.position = CGPoint(x: 3, y: -4)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.28
        row.addChild(shadow)

        let bg = SKShapeNode(rectOf: rowSize, cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.10, green: 0.055, blue: 0.025, alpha: 0.88)
        bg.strokeColor = SKColor(red: 0.80, green: 0.56, blue: 0.18, alpha: 0.70)
        bg.lineWidth = 1.5
        bg.name = name
        row.addChild(bg)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        titleLabel.text = title
        titleLabel.fontSize = 16
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -112, y: 0)
        titleLabel.zPosition = 2
        titleLabel.name = name
        row.addChild(titleLabel)

        let trackSize = CGSize(width: 82, height: 30)
        let track = SKShapeNode(rectOf: trackSize, cornerRadius: 15)
        track.position = CGPoint(x: 70, y: 0)
        track.fillColor = isOn ? SKColor(red: 0.93, green: 0.63, blue: 0.16, alpha: 1) : SKColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        track.strokeColor = isOn ? SKColor(red: 1.0, green: 0.82, blue: 0.32, alpha: 1) : SKColor(white: 0.40, alpha: 1)
        track.lineWidth = 2
        track.zPosition = 2
        track.name = name
        row.addChild(track)

        let thumb = SKShapeNode(circleOfRadius: 12)
        thumb.position = CGPoint(x: track.position.x + (isOn ? 24 : -24), y: 0)
        thumb.fillColor = .white
        thumb.strokeColor = SKColor(white: 0, alpha: 0.25)
        thumb.lineWidth = 1
        thumb.zPosition = 3
        thumb.name = name
        row.addChild(thumb)

        let stateLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        stateLabel.text = isOn ? "ON" : "OFF"
        stateLabel.fontSize = 11
        stateLabel.fontColor = isOn ? SKColor(red: 0.20, green: 0.10, blue: 0.02, alpha: 1) : .lightGray
        stateLabel.verticalAlignmentMode = .center
        stateLabel.position = CGPoint(x: 70 + (isOn ? -16 : 16), y: 0)
        stateLabel.zPosition = 4
        stateLabel.name = name
        row.addChild(stateLabel)

        return row
    }

    private func createButton(text: String, position: CGPoint, name: String) -> SKNode {
        let button = SKSpriteNode(imageNamed: "button_texture")
        button.size = CGSize(width: 120, height: 40)
        button.position = position
        button.name = name

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        label.name = name
        button.addChild(label)

        return button
    }

    private func createAccountButton(text: String, position: CGPoint, name: String, isDestructive: Bool) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        let buttonSize = CGSize(width: isDestructive ? 178 : 220, height: isDestructive ? 30 : 38)
        let bg = SKShapeNode(rectOf: buttonSize, cornerRadius: 8)
        if isDestructive {
            bg.fillColor = awaitingDeleteConfirmation
                ? SKColor(red: 0.52, green: 0.08, blue: 0.06, alpha: 0.90)
                : SKColor(red: 0.16, green: 0.06, blue: 0.045, alpha: 0.78)
            bg.strokeColor = SKColor(red: 0.95, green: 0.30, blue: 0.22, alpha: 0.85)
        } else {
            bg.fillColor = SKColor(red: 0.12, green: 0.24, blue: 0.13, alpha: 0.90)
            bg.strokeColor = SKColor(red: 0.38, green: 0.82, blue: 0.45, alpha: 0.88)
        }
        bg.lineWidth = 1.5
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = isDestructive ? 11 : 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        fit(label: label, maxWidth: buttonSize.width - 24, minimumSize: 9)
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
                scene.scaleMode = .resizeFill
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

            if name == "btn_sound" {
                statusMessage = nil
                AudioManager.shared.isSoundEnabled.toggle()
                setupUI()
                return
            }

            if name == "btn_music" {
                statusMessage = nil
                AudioManager.shared.isMusicEnabled.toggle()
                setupUI()
                return
            }

            if name == "btn_logout_account" {
                handleLogoutTap()
                return
            }

            if name == "btn_delete_account" {
                handleDeleteAccountTap()
                return
            }
        }
    }

    private func handleLogoutTap() {
        awaitingDeleteConfirmation = false
        statusMessage = nil
        AuthManager.shared.signOut()

        let scene = LoginScene(size: self.size)
        scene.scaleMode = .resizeFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func handleDeleteAccountTap() {
        if !awaitingDeleteConfirmation {
            awaitingDeleteConfirmation = true
            statusMessage = loc.localize("settings.delete_hint")
            setupUI()
            return
        }

        statusMessage = loc.localize("settings.deleting_account")
        setupUI()

        AuthManager.shared.deleteCurrentAccount { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    let scene = LoginScene(size: self.size)
                    scene.scaleMode = .resizeFill
                    self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
                case .failure(let error):
                    self.awaitingDeleteConfirmation = false
                    self.statusMessage = error.localizedDescription
                    self.setupUI()
                }
            }
        }
    }

    private func fit(label: SKLabelNode, maxWidth: CGFloat, minimumSize: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > minimumSize {
            label.fontSize -= 1
        }
    }
}
