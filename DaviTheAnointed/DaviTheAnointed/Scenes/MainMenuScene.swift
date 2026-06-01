import SpriteKit

class MainMenuScene: SKScene {

    private let loc = LocalizationManager.shared
    private let goldColor = SKColor(red: 1.0, green: 0.78, blue: 0.18, alpha: 1)
    private let creamColor = SKColor(red: 1.0, green: 0.93, blue: 0.76, alpha: 1)
    private let inkColor = SKColor(red: 0.17, green: 0.08, blue: 0.02, alpha: 1)
    private let panelColor = SKColor(red: 0.20, green: 0.10, blue: 0.035, alpha: 0.88)

    override func didMove(to view: SKView) {
        loc.loadSavedLanguage()
        AudioManager.shared.playMenuMusic()
        backgroundColor = SKColor(red: 0.06, green: 0.035, blue: 0.018, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        removeAllChildren()
        guard let player = GameManager.shared.playerData else { return }

        let safeArea = view?.safeAreaInsets ?? .zero
        let sceneScale = size.height / max(view?.bounds.height ?? size.height, 1)
        let safeL: CGFloat = max(18, safeArea.left * sceneScale + 10)
        let safeR: CGFloat = max(18, safeArea.right * sceneScale + 10)
        let safeT: CGFloat = max(14, safeArea.top * sceneScale + 8)
        let safeB: CGFloat = max(14, safeArea.bottom * sceneScale + 8)
        let contentMinX = safeL
        let contentMaxX = size.width - safeR
        let contentWidth = contentMaxX - contentMinX

        let bg = SKSpriteNode(imageNamed: "background_menu")
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)

        addBackgroundDepth()

        let topBarHeight = min(56, max(46, size.height * 0.12))
        let topCenterY = size.height - safeT - topBarHeight / 2
        let mainTop = size.height - safeT - topBarHeight - 28
        let mainBottom = safeB + 16
        let mainHeight = max(268, mainTop - mainBottom)
        let mainCenterY = mainBottom + mainHeight / 2

        let columnGap = min(22, max(14, contentWidth * 0.025))
        var actionsWidth = min(440, max(360, contentWidth * 0.57))
        var journeyWidth = contentWidth - actionsWidth - columnGap
        if journeyWidth < 230 {
            journeyWidth = max(210, min(250, contentWidth * 0.30))
            actionsWidth = contentWidth - journeyWidth - columnGap
        }
        actionsWidth = max(330, actionsWidth)
        journeyWidth = contentWidth - actionsWidth - columnGap

        let leftX = contentMinX + journeyWidth / 2
        let rightX = contentMaxX - actionsWidth / 2

        let languageSwitcher = createLanguageSwitcher()
        languageSwitcher.position = CGPoint(x: contentMaxX - 52, y: topCenterY)
        languageSwitcher.zPosition = 18
        addChild(languageSwitcher)

        let statsWidth = min(276, max(238, contentWidth * 0.32))
        let statsNode = createStatsPanel(player: player, width: statsWidth)
        statsNode.position = CGPoint(x: contentMinX + statsWidth / 2, y: topCenterY)
        statsNode.zPosition = 18
        addChild(statsNode)

        let heroCard = createHeroCard(player: player, width: journeyWidth, height: mainHeight)
        heroCard.position = CGPoint(x: leftX, y: mainCenterY)
        heroCard.zPosition = 2
        addChild(heroCard)

        let menuPanelWidth = actionsWidth
        let menuPanel = createMenuPanel(width: menuPanelWidth, height: mainHeight)
        menuPanel.position = CGPoint(x: rightX, y: mainCenterY)
        menuPanel.zPosition = 4
        addChild(menuPanel)

        let isNewPlayer = player.highestMapCompleted == 0 && player.mapStars.isEmpty
        let mainBtnKey = isNewPlayer ? "menu.start" : "menu.continue"
        let buttonWidth = menuPanelWidth - 56
        let panelTopY = menuPanel.position.y + mainHeight / 2
        let mainBtn = createMenuButton(
            text: loc.localize(mainBtnKey),
            position: CGPoint(x: menuPanel.position.x, y: panelTopY - 106),
            name: "btn_continue",
            width: buttonWidth,
            height: 68,
            style: .primary,
            iconName: "menu_icon_journey"
        )
        addChild(mainBtn)

        let missionTicker = createMissionTicker(player: player, width: buttonWidth)
        missionTicker.position = CGPoint(x: menuPanel.position.x, y: panelTopY - 52)
        missionTicker.zPosition = 7
        addChild(missionTicker)

        let otherButtons: [(String, String, String?)] = [
            ("menu.inventory", "btn_inventory", "menu_icon_inventory"),
            ("menu.shop", "btn_shop", "menu_icon_shop"),
            ("menu.ranking", "btn_ranking", "menu_icon_ranking"),
            ("menu.settings", "btn_settings", "menu_icon_settings"),
        ]
        let tileGap: CGFloat = 10
        let tileWidth = (buttonWidth - tileGap) / 2
        let tileHeight = min(58, max(50, (mainHeight - 190) / 2))
        let tileStartY = mainBtn.position.y - 78
        let tileStartX = menuPanel.position.x - buttonWidth / 2 + tileWidth / 2

        for (index, button) in otherButtons.enumerated() {
            let col = index % 2
            let row = index / 2
            let btn = createMenuTileButton(
                text: loc.localize(button.0),
                position: CGPoint(
                    x: tileStartX + CGFloat(col) * (tileWidth + tileGap),
                    y: tileStartY - CGFloat(row) * (tileHeight + tileGap)
                ),
                name: button.1,
                width: tileWidth,
                height: tileHeight,
                iconName: button.2
            )
            addChild(btn)
        }
    }

    private enum MenuButtonStyle {
        case primary
        case secondary
    }

    private func addBackgroundDepth() {
        let shade = SKShapeNode(rectOf: size)
        shade.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shade.fillColor = SKColor(red: 0.02, green: 0.025, blue: 0.022, alpha: 0.20)
        shade.strokeColor = .clear
        shade.zPosition = -8
        addChild(shade)

        let leftReadability = SKShapeNode(rectOf: CGSize(width: size.width * 0.55, height: size.height))
        leftReadability.position = CGPoint(x: size.width * 0.25, y: size.height / 2)
        leftReadability.fillColor = SKColor(red: 0.02, green: 0.045, blue: 0.035, alpha: 0.36)
        leftReadability.strokeColor = .clear
        leftReadability.zPosition = -7
        addChild(leftReadability)

        let rightReadability = SKShapeNode(rectOf: CGSize(width: size.width * 0.43, height: size.height))
        rightReadability.position = CGPoint(x: size.width * 0.79, y: size.height / 2)
        rightReadability.fillColor = SKColor(red: 0.11, green: 0.055, blue: 0.025, alpha: 0.44)
        rightReadability.strokeColor = .clear
        rightReadability.zPosition = -7
        addChild(rightReadability)

        let bottomBand = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.28))
        bottomBand.position = CGPoint(x: size.width / 2, y: size.height * 0.14)
        bottomBand.fillColor = SKColor(red: 0.05, green: 0.055, blue: 0.028, alpha: 0.56)
        bottomBand.strokeColor = .clear
        bottomBand.zPosition = -6
        addChild(bottomBand)
    }

    private func addGoldenTopRule(y: CGFloat, minX: CGFloat, maxX: CGFloat) {
        let rule = SKShapeNode(rectOf: CGSize(width: maxX - minX, height: 2))
        rule.position = CGPoint(x: (minX + maxX) / 2, y: y)
        rule.fillColor = goldColor.withAlphaComponent(0.55)
        rule.strokeColor = .clear
        rule.zPosition = 3
        addChild(rule)

        let crown = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        crown.text = "D"
        crown.fontSize = 13
        crown.fontColor = inkColor
        crown.verticalAlignmentMode = .center
        crown.horizontalAlignmentMode = .center
        crown.position = CGPoint(x: minX + 14, y: y + 10)
        crown.zPosition = 5

        let seal = SKShapeNode(circleOfRadius: 14)
        seal.fillColor = goldColor
        seal.strokeColor = SKColor(red: 0.46, green: 0.24, blue: 0.04, alpha: 1)
        seal.lineWidth = 2
        seal.position = CGPoint(x: minX + 14, y: y + 10)
        seal.zPosition = 4
        addChild(seal)
        addChild(crown)
    }

    private func createStatsPanel(player: PlayerData, width: CGFloat) -> SKNode {
        let container = SKNode()
        let height: CGFloat = 46
        let panel = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
        panel.fillColor = SKColor(red: 0.10, green: 0.055, blue: 0.025, alpha: 0.86)
        panel.strokeColor = goldColor.withAlphaComponent(0.42)
        panel.lineWidth = 1.5
        container.addChild(panel)

        let items: [(title: String, value: String, icon: String?, color: SKColor)] = [
            (loc.localize("hud.level"), "\(player.level)", nil, creamColor),
            (loc.localize("hud.gold"), "\(player.gold)", "menu_icon_gold", goldColor),
            (loc.localize("hud.rubies"), "\(player.rubies)", "menu_icon_ruby", SKColor(red: 1, green: 0.44, blue: 0.46, alpha: 1)),
        ]
        let itemWidth = width / CGFloat(items.count)
        for (index, item) in items.enumerated() {
            let baseX = -width / 2 + itemWidth * CGFloat(index) + itemWidth / 2

            if index > 0 {
                let divider = SKShapeNode(rectOf: CGSize(width: 1, height: height - 18))
                divider.position = CGPoint(x: -width / 2 + itemWidth * CGFloat(index), y: 0)
                divider.fillColor = goldColor.withAlphaComponent(0.18)
                divider.strokeColor = .clear
                container.addChild(divider)
            }

            let titleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            titleLabel.text = item.title
            titleLabel.fontSize = 8
            titleLabel.fontColor = creamColor.withAlphaComponent(0.78)
            titleLabel.verticalAlignmentMode = .center
            titleLabel.horizontalAlignmentMode = .center
            titleLabel.position = CGPoint(x: baseX, y: 12)
            titleLabel.zPosition = 2
            fit(label: titleLabel, maxWidth: itemWidth - 14, minimumSize: 7)
            container.addChild(titleLabel)

            var valueX = baseX
            if let iconName = item.icon {
                let icon = SKSpriteNode(imageNamed: iconName)
                icon.size = CGSize(width: 16, height: 16)
                icon.position = CGPoint(x: baseX - 16, y: -9)
                icon.zPosition = 2
                container.addChild(icon)
                valueX = baseX - 1
            }

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = item.value
            label.fontSize = 13
            label.fontColor = item.color
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = item.icon == nil ? .center : .left
            label.position = CGPoint(x: item.icon == nil ? valueX : valueX, y: -9)
            label.zPosition = 2
            fit(label: label, maxWidth: itemWidth - (item.icon == nil ? 16 : 42), minimumSize: 10)
            addShadowedLabel(label, shadowOffset: CGPoint(x: 1, y: -1), alpha: 0.55)
            container.addChild(label)
        }
        return container
    }

    private func createLanguageSwitcher() -> SKNode {
        let container = SKNode()
        let width: CGFloat = 104
        let height: CGFloat = 42

        let plate = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 9)
        plate.fillColor = SKColor(red: 0.08, green: 0.045, blue: 0.025, alpha: 0.86)
        plate.strokeColor = goldColor.withAlphaComponent(0.36)
        plate.lineWidth = 1.2
        plate.zPosition = 0
        container.addChild(plate)

        let english = createFlagButton(language: .english, isActive: loc.language == .english)
        english.position = CGPoint(x: -26, y: 0)
        english.zPosition = 1
        container.addChild(english)

        let portuguese = createFlagButton(language: .portuguese, isActive: loc.language == .portuguese)
        portuguese.position = CGPoint(x: 26, y: 0)
        portuguese.zPosition = 1
        container.addChild(portuguese)

        return container
    }

    private func createFlagButton(language: GameLanguage, isActive: Bool) -> SKNode {
        let button = SKNode()
        let nodeName = "lang_\(language.rawValue)"
        button.name = nodeName

        let bg = SKShapeNode(rectOf: CGSize(width: 44, height: 30), cornerRadius: 6)
        bg.fillColor = isActive ? goldColor.withAlphaComponent(0.28) : SKColor.black.withAlphaComponent(0.18)
        bg.strokeColor = isActive ? goldColor : creamColor.withAlphaComponent(0.28)
        bg.lineWidth = isActive ? 2 : 1
        bg.name = nodeName
        button.addChild(bg)

        let flagFrame = SKShapeNode(rectOf: CGSize(width: 34, height: 22), cornerRadius: 3)
        flagFrame.fillColor = .clear
        flagFrame.strokeColor = SKColor.black.withAlphaComponent(0.38)
        flagFrame.lineWidth = 1
        flagFrame.name = nodeName
        flagFrame.zPosition = 5
        button.addChild(flagFrame)

        switch language {
        case .english:
            addUSFlag(to: button, name: nodeName)
        case .portuguese:
            addBrazilFlag(to: button, name: nodeName)
        }

        return button
    }

    private func addUSFlag(to button: SKNode, name: String) {
        let flagWidth: CGFloat = 34
        let flagHeight: CGFloat = 22
        let stripeHeight = flagHeight / 7

        let base = SKShapeNode(rectOf: CGSize(width: flagWidth, height: flagHeight), cornerRadius: 3)
        base.fillColor = .white
        base.strokeColor = .clear
        base.name = name
        base.zPosition = 1
        button.addChild(base)

        for index in 0..<4 {
            let stripe = SKShapeNode(rectOf: CGSize(width: flagWidth, height: stripeHeight), cornerRadius: 0)
            stripe.fillColor = SKColor(red: 0.74, green: 0.06, blue: 0.10, alpha: 1)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: 0, y: flagHeight / 2 - stripeHeight / 2 - CGFloat(index * 2) * stripeHeight)
            stripe.name = name
            stripe.zPosition = 2
            button.addChild(stripe)
        }

        let canton = SKShapeNode(rectOf: CGSize(width: flagWidth * 0.45, height: flagHeight * 0.50), cornerRadius: 1)
        canton.fillColor = SKColor(red: 0.04, green: 0.16, blue: 0.43, alpha: 1)
        canton.strokeColor = .clear
        canton.position = CGPoint(x: -flagWidth * 0.275, y: flagHeight * 0.25)
        canton.name = name
        canton.zPosition = 3
        button.addChild(canton)

        let star = SKShapeNode(circleOfRadius: 1.6)
        star.fillColor = .white
        star.strokeColor = .clear
        star.position = canton.position
        star.name = name
        star.zPosition = 4
        button.addChild(star)
    }

    private func addBrazilFlag(to button: SKNode, name: String) {
        let flagWidth: CGFloat = 34
        let flagHeight: CGFloat = 22

        let base = SKShapeNode(rectOf: CGSize(width: flagWidth, height: flagHeight), cornerRadius: 3)
        base.fillColor = SKColor(red: 0.02, green: 0.48, blue: 0.20, alpha: 1)
        base.strokeColor = .clear
        base.name = name
        base.zPosition = 1
        button.addChild(base)

        let diamondPath = CGMutablePath()
        diamondPath.move(to: CGPoint(x: 0, y: flagHeight * 0.42))
        diamondPath.addLine(to: CGPoint(x: flagWidth * 0.40, y: 0))
        diamondPath.addLine(to: CGPoint(x: 0, y: -flagHeight * 0.42))
        diamondPath.addLine(to: CGPoint(x: -flagWidth * 0.40, y: 0))
        diamondPath.closeSubpath()

        let diamond = SKShapeNode(path: diamondPath)
        diamond.fillColor = SKColor(red: 0.98, green: 0.84, blue: 0.12, alpha: 1)
        diamond.strokeColor = .clear
        diamond.name = name
        diamond.zPosition = 2
        button.addChild(diamond)

        let globe = SKShapeNode(circleOfRadius: 5.3)
        globe.fillColor = SKColor(red: 0.04, green: 0.16, blue: 0.58, alpha: 1)
        globe.strokeColor = .clear
        globe.name = name
        globe.zPosition = 3
        button.addChild(globe)

        let band = SKShapeNode(rectOf: CGSize(width: 12, height: 2), cornerRadius: 1)
        band.fillColor = .white
        band.strokeColor = .clear
        band.zRotation = -0.18
        band.name = name
        band.zPosition = 4
        button.addChild(band)
    }

    private func createHeroCard(player: PlayerData, width: CGFloat, height: CGFloat) -> SKNode {
        let container = SKNode()
        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        shadow.position = CGPoint(x: 4, y: -5)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.28
        container.addChild(shadow)

        let panel = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        panel.fillColor = SKColor(red: 0.12, green: 0.06, blue: 0.025, alpha: 0.78)
        panel.strokeColor = goldColor.withAlphaComponent(0.32)
        panel.lineWidth = 1.5
        container.addChild(panel)

        let inner = SKShapeNode(rectOf: CGSize(width: width - 14, height: height - 14), cornerRadius: 8)
        inner.fillColor = .clear
        inner.strokeColor = goldColor.withAlphaComponent(0.18)
        inner.lineWidth = 1
        inner.zPosition = 1
        container.addChild(inner)

        let heroGlow = SKShapeNode(ellipseOf: CGSize(width: width * 0.74, height: height * 0.44))
        heroGlow.fillColor = SKColor(red: 0.95, green: 0.68, blue: 0.22, alpha: 0.12)
        heroGlow.strokeColor = .clear
        heroGlow.position = CGPoint(x: 0, y: -height * 0.04)
        heroGlow.zPosition = 1
        container.addChild(heroGlow)

        let topPlateHeight = min(78, max(66, height * 0.30))
        let textPlate = SKShapeNode(rectOf: CGSize(width: width - 28, height: topPlateHeight), cornerRadius: 8)
        textPlate.fillColor = SKColor(red: 0.035, green: 0.032, blue: 0.022, alpha: 0.88)
        textPlate.strokeColor = goldColor.withAlphaComponent(0.34)
        textPlate.lineWidth = 1
        textPlate.position = CGPoint(x: 0, y: height / 2 - 18 - topPlateHeight / 2)
        textPlate.zPosition = 5
        container.addChild(textPlate)

        let badgeWidth = min(width - 44, 106)
        let badge = SKShapeNode(rectOf: CGSize(width: badgeWidth, height: 24), cornerRadius: 7)
        badge.fillColor = SKColor(red: 0.04, green: 0.18, blue: 0.13, alpha: 0.85)
        badge.strokeColor = goldColor.withAlphaComponent(0.45)
        badge.lineWidth = 1
        badge.position = CGPoint(x: 0, y: height / 2 - 34)
        badge.zPosition = 6
        container.addChild(badge)

        let badgeText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        badgeText.text = loc.localize("menu.journey_badge")
        badgeText.fontSize = 10
        badgeText.fontColor = SKColor(red: 0.77, green: 1.0, blue: 0.78, alpha: 1)
        badgeText.verticalAlignmentMode = .center
        badgeText.horizontalAlignmentMode = .center
        badgeText.position = badge.position
        badgeText.zPosition = 7
        fit(label: badgeText, maxWidth: badgeWidth - 14, minimumSize: 8)
        container.addChild(badgeText)

        let chapter = SKLabelNode(fontNamed: "AvenirNext-Bold")
        chapter.text = loc.localize("menu.chapter1")
        chapter.fontSize = 12.5
        chapter.fontColor = goldColor
        chapter.horizontalAlignmentMode = .center
        chapter.verticalAlignmentMode = .center
        chapter.position = CGPoint(x: 0, y: height / 2 - 68)
        chapter.zPosition = 7
        addShadowedLabel(chapter, shadowOffset: CGPoint(x: 1, y: -1), alpha: 0.6)
        fit(label: chapter, maxWidth: width - 42, minimumSize: 8.5)
        container.addChild(chapter)

        let heroTextureName = player.activeCharacter.rosterTextureName
        let hero = SKSpriteNode(imageNamed: heroTextureName)
        let heroTopLimit = height / 2 - topPlateHeight - 30
        let heroBottomLimit = -height / 2 + 68
        let heroAvailableHeight = max(76, heroTopLimit - heroBottomLimit)
        let heroHeight = min(height * 0.66, heroAvailableHeight * 1.24)
        let heroAspect = (hero.texture?.size().width ?? 1) / max(hero.texture?.size().height ?? 1, 1)
        hero.size = CGSize(width: heroHeight * heroAspect, height: heroHeight)
        hero.position = CGPoint(x: 0, y: (heroTopLimit + heroBottomLimit) / 2)
        hero.zPosition = 4

        let groundShadow = SKShapeNode(ellipseOf: CGSize(width: min(width * 0.56, heroHeight * 0.58), height: 12))
        groundShadow.fillColor = SKColor.black.withAlphaComponent(0.30)
        groundShadow.strokeColor = .clear
        groundShadow.position = CGPoint(x: 0, y: heroBottomLimit + 3)
        groundShadow.zPosition = 3
        container.addChild(groundShadow)
        container.addChild(hero)

        let battleCount = player.mapStars.count

        let progressAreaWidth = max(80, width - 56)
        let progressLeftX = -progressAreaWidth / 2
        let progressCenterX: CGFloat = 0

        let progressTitle = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        progressTitle.text = loc.localize("menu.progress")
        progressTitle.fontSize = 11
        progressTitle.fontColor = creamColor.withAlphaComponent(0.74)
        progressTitle.horizontalAlignmentMode = .center
        progressTitle.verticalAlignmentMode = .center
        progressTitle.position = CGPoint(x: 0, y: -height / 2 + 48)
        progressTitle.zPosition = 6
        fit(label: progressTitle, maxWidth: progressAreaWidth, minimumSize: 8)
        container.addChild(progressTitle)

        let progressTrack = SKShapeNode(rectOf: CGSize(width: progressAreaWidth, height: 9), cornerRadius: 4.5)
        progressTrack.position = CGPoint(x: progressCenterX, y: -height / 2 + 32)
        progressTrack.fillColor = SKColor.black.withAlphaComponent(0.34)
        progressTrack.strokeColor = .clear
        progressTrack.zPosition = 6
        container.addChild(progressTrack)

        let totalBattlesHint: CGFloat = 12
        let progress = min(1, max(0.12, CGFloat(battleCount) / totalBattlesHint))
        let progressWidth = max(32, progressAreaWidth * progress)
        let progressFill = SKShapeNode(rectOf: CGSize(width: progressWidth, height: 9), cornerRadius: 4.5)
        progressFill.position = CGPoint(x: progressLeftX + progressWidth / 2, y: -height / 2 + 32)
        progressFill.fillColor = goldColor
        progressFill.strokeColor = .clear
        progressFill.zPosition = 7
        container.addChild(progressFill)

        return container
    }

    private func createMenuPanel(width: CGFloat, height: CGFloat) -> SKNode {
        let container = SKNode()
        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 12)
        shadow.position = CGPoint(x: 5, y: -6)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.35
        container.addChild(shadow)

        let panel = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 12)
        panel.fillColor = SKColor(red: 0.08, green: 0.055, blue: 0.032, alpha: 0.90)
        panel.strokeColor = goldColor.withAlphaComponent(0.64)
        panel.lineWidth = 2
        container.addChild(panel)

        let inner = SKShapeNode(rectOf: CGSize(width: width - 14, height: height - 14), cornerRadius: 9)
        inner.fillColor = .clear
        inner.strokeColor = SKColor(red: 0.60, green: 0.95, blue: 0.62, alpha: 0.12)
        inner.lineWidth = 1
        inner.zPosition = 1
        container.addChild(inner)

        let rule = SKShapeNode(rectOf: CGSize(width: width - 44, height: 1))
        rule.position = CGPoint(x: 0, y: height / 2 - 28)
        rule.fillColor = goldColor.withAlphaComponent(0.16)
        rule.strokeColor = .clear
        rule.zPosition = 2
        container.addChild(rule)

        return container
    }

    private func createMissionTicker(player: PlayerData, width: CGFloat) -> SKNode {
        let container = SKNode()
        let height: CGFloat = 34
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.04, green: 0.105, blue: 0.075, alpha: 0.86)
        bg.strokeColor = goldColor.withAlphaComponent(0.34)
        bg.lineWidth = 1
        container.addChild(bg)

        let missions = GameMissionManager.visibleMissions(for: player, limit: 1)
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.fontSize = 9
        title.fontColor = goldColor
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: -width / 2 + 12, y: 7)
        title.zPosition = 2
        title.text = loc.language == .portuguese ? "MISSÃO" : "MISSION"
        container.addChild(title)

        let detail = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        detail.fontSize = 10.5
        detail.fontColor = creamColor
        detail.horizontalAlignmentMode = .left
        detail.verticalAlignmentMode = .center
        detail.position = CGPoint(x: -width / 2 + 70, y: 7)
        detail.zPosition = 2

        let progress = SKLabelNode(fontNamed: "AvenirNext-Bold")
        progress.fontSize = 10.5
        progress.fontColor = SKColor(red: 0.70, green: 1.0, blue: 0.64, alpha: 1)
        progress.horizontalAlignmentMode = .right
        progress.verticalAlignmentMode = .center
        progress.position = CGPoint(x: width / 2 - 12, y: 7)
        progress.zPosition = 2

        let desc = SKLabelNode(fontNamed: "AvenirNext-Medium")
        desc.fontSize = 8.5
        desc.fontColor = creamColor.withAlphaComponent(0.72)
        desc.horizontalAlignmentMode = .left
        desc.verticalAlignmentMode = .center
        desc.position = CGPoint(x: -width / 2 + 12, y: -9)
        desc.zPosition = 2

        if let daily = DailyMissionManager.nextVisibleMission(for: player) {
            title.text = loc.language == .portuguese ? "DIÁRIA" : "DAILY"
            detail.text = daily.title(language: loc.language)
            progress.text = DailyMissionManager.progressText(for: daily, userId: player.userId)
            desc.text = loc.language == .portuguese ? "Reinicia todos os dias e ajuda no grind." : "Resets daily and helps your grind."
        } else if let mission = missions.first {
            detail.text = mission.title(language: loc.language)
            progress.text = mission.progressText(for: player)
            desc.text = mission.description(language: loc.language)
        } else {
            detail.text = loc.language == .portuguese ? "Tudo completo" : "All complete"
            progress.text = "✓"
            desc.text = loc.language == .portuguese ? "Novas metas chegam com seu avanço." : "More goals unlock as you progress."
        }

        fit(label: detail, maxWidth: width - 146, minimumSize: 8)
        fit(label: desc, maxWidth: width - 28, minimumSize: 7)
        container.addChild(detail)
        container.addChild(progress)
        container.addChild(desc)

        return container
    }

    private func createMenuTileButton(
        text: String,
        position: CGPoint,
        name: String,
        width: CGFloat,
        height: CGFloat,
        iconName: String? = nil
    ) -> SKNode {
        let button = SKNode()
        button.position = position
        button.name = name
        button.zPosition = 8

        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.26
        shadow.name = name
        shadow.zPosition = -2
        button.addChild(shadow)

        let body = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        body.fillColor = SKColor(red: 0.10, green: 0.16, blue: 0.105, alpha: 0.95)
        body.strokeColor = SKColor(red: 0.70, green: 0.52, blue: 0.25, alpha: 0.86)
        body.lineWidth = 1.4
        body.name = name
        body.zPosition = -1
        button.addChild(body)

        let highlight = SKShapeNode(rectOf: CGSize(width: width - 8, height: height * 0.38), cornerRadius: 7)
        highlight.position = CGPoint(x: 0, y: height * 0.16)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.055)
        highlight.strokeColor = .clear
        highlight.name = name
        button.addChild(highlight)

        let iconCenterX = -width / 2 + 27
        if let iconName {
            let badge = SKShapeNode(circleOfRadius: 18)
            badge.position = CGPoint(x: iconCenterX, y: 0)
            badge.fillColor = SKColor(red: 0.04, green: 0.09, blue: 0.065, alpha: 0.68)
            badge.strokeColor = goldColor.withAlphaComponent(0.34)
            badge.lineWidth = 1
            badge.name = name
            badge.zPosition = 1
            button.addChild(badge)

            let icon = SKSpriteNode(imageNamed: iconName)
            icon.size = CGSize(width: 28, height: 28)
            icon.position = badge.position
            icon.name = name
            icon.zPosition = 2
            button.addChild(icon)
        }

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: iconName == nil ? -width / 2 + 14 : -width / 2 + 52, y: 1)
        label.zPosition = 3
        label.name = name
        fit(label: label, maxWidth: width - (iconName == nil ? 28 : 62), minimumSize: 8)
        addShadowedLabel(label, shadowOffset: CGPoint(x: 1.3, y: -1.7), alpha: 0.62)
        button.addChild(label)

        return button
    }

    private func createMenuButton(
        text: String,
        position: CGPoint,
        name: String,
        width: CGFloat,
        height: CGFloat,
        style: MenuButtonStyle,
        iconName: String? = nil
    ) -> SKNode {
        let button = SKNode()
        button.position = position
        button.name = name
        button.zPosition = 8

        let corner = min(12, height * 0.24)
        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: corner)
        shadow.position = CGPoint(x: 3, y: -4)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = style == .primary ? 0.42 : 0.28
        shadow.name = name
        shadow.zPosition = -2
        button.addChild(shadow)

        let body = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: corner)
        body.name = name
        body.zPosition = -1
        if style == .primary {
            body.fillColor = SKColor(red: 0.70, green: 0.42, blue: 0.12, alpha: 0.98)
            body.strokeColor = SKColor(red: 1.0, green: 0.78, blue: 0.24, alpha: 1)
        } else {
            body.fillColor = SKColor(red: 0.10, green: 0.16, blue: 0.105, alpha: 0.95)
            body.strokeColor = SKColor(red: 0.70, green: 0.52, blue: 0.25, alpha: 0.86)
        }
        body.lineWidth = style == .primary ? 2.5 : 1.5
        button.addChild(body)

        let highlight = SKShapeNode(rectOf: CGSize(width: width - 10, height: max(1, height * 0.42)), cornerRadius: max(2, corner - 3))
        highlight.position = CGPoint(x: 0, y: height * 0.16)
        highlight.fillColor = SKColor.white.withAlphaComponent(style == .primary ? 0.10 : 0.055)
        highlight.strokeColor = .clear
        highlight.name = name
        highlight.zPosition = 0
        button.addChild(highlight)

        if let iconName {
            let badge = SKShapeNode(circleOfRadius: height * 0.33)
            badge.fillColor = style == .primary ?
                SKColor(red: 0.10, green: 0.08, blue: 0.04, alpha: 0.35) :
                SKColor(red: 0.04, green: 0.09, blue: 0.065, alpha: 0.65)
            badge.strokeColor = goldColor.withAlphaComponent(0.35)
            badge.lineWidth = 1
            badge.position = CGPoint(x: -width / 2 + height * 0.62, y: 0)
            badge.name = name
            badge.zPosition = 1
            button.addChild(badge)

            let icon = SKSpriteNode(imageNamed: iconName)
            let iconSize = height * 0.58
            icon.size = CGSize(width: iconSize, height: iconSize)
            icon.position = badge.position
            icon.name = name
            icon.zPosition = 2
            button.addChild(icon)
        }

        let hasChevron = false
        let chevronX = width / 2 - max(18, height * 0.32)
        let textStartX = iconName == nil ? -width / 2 + 24 : -width / 2 + height + 18
        let textEndX = hasChevron ? chevronX - 44 : width / 2 - 20
        let textMaxWidth = max(48, textEndX - textStartX)

        if style == .primary {
            let words = text.split(separator: " ").map(String.init)
            let lines = words.count >= 2 ? [words[0], words.dropFirst().joined(separator: " ")] : [text]
            let baseX = iconName == nil ? (textStartX + textEndX) / 2 : textStartX
            let lineY: [CGFloat] = lines.count == 1 ? [1] : [9, -9]

            for (index, line) in lines.enumerated() {
                let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
                label.text = line
                label.fontSize = 14
                label.fontColor = .white
                label.verticalAlignmentMode = .center
                label.horizontalAlignmentMode = iconName == nil ? .center : .left
                label.position = CGPoint(x: baseX, y: lineY[index])
                label.zPosition = 3
                label.name = name
                fit(label: label, maxWidth: textMaxWidth, minimumSize: 9)
                addShadowedLabel(label, shadowOffset: CGPoint(x: 1.5, y: -2), alpha: 0.65)
                button.addChild(label)
            }
        } else {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = text
            label.fontSize = 14
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = iconName == nil ? .center : .left
            label.position = CGPoint(x: iconName == nil ? (textStartX + textEndX) / 2 : textStartX, y: 1)
            label.zPosition = 3
            label.name = name
            fit(label: label, maxWidth: textMaxWidth, minimumSize: 10)
            addShadowedLabel(label, shadowOffset: CGPoint(x: 1.5, y: -2), alpha: 0.65)
            button.addChild(label)
        }

        if hasChevron {
            let chevronBadge = SKShapeNode(circleOfRadius: height * 0.22)
            chevronBadge.position = CGPoint(x: chevronX, y: 0)
            chevronBadge.fillColor = SKColor(red: 0.10, green: 0.08, blue: 0.04, alpha: 0.28)
            chevronBadge.strokeColor = creamColor.withAlphaComponent(0.28)
            chevronBadge.lineWidth = 1
            chevronBadge.name = name
            chevronBadge.zPosition = 2
            button.addChild(chevronBadge)

            let chevron = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            chevron.text = ">"
            chevron.fontSize = 18
            chevron.fontColor = creamColor
            chevron.verticalAlignmentMode = .center
            chevron.horizontalAlignmentMode = .center
            chevron.position = CGPoint(x: chevronX + 1, y: 0)
            chevron.name = name
            chevron.zPosition = 3
            button.addChild(chevron)
        }

        return button
    }

    private func addShadowedLabel(_ label: SKLabelNode, shadowOffset: CGPoint, alpha: CGFloat) {
        let shadow = SKLabelNode(fontNamed: label.fontName)
        shadow.text = label.text
        shadow.fontSize = label.fontSize
        shadow.fontColor = .black
        shadow.horizontalAlignmentMode = label.horizontalAlignmentMode
        shadow.verticalAlignmentMode = label.verticalAlignmentMode
        shadow.position = shadowOffset
        shadow.zPosition = -1
        shadow.alpha = alpha
        label.addChild(shadow)
    }

    private func fit(label: SKLabelNode, maxWidth: CGFloat, minimumSize: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > minimumSize {
            label.fontSize -= 1
            for child in label.children {
                if let childLabel = child as? SKLabelNode {
                    childLabel.fontSize = label.fontSize
                }
            }
        }
    }

    private func aspectFillSize(for sprite: SKSpriteNode, in targetSize: CGSize) -> CGSize {
        let textureSize = sprite.texture?.size() ?? targetSize
        let scale = max(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        return CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            if let name = node.name, name.hasPrefix("lang_") {
                switchLanguage(rawValue: String(name.dropFirst(5)))
                return
            }

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

    private func switchLanguage(rawValue: String) {
        guard let language = GameLanguage(rawValue: rawValue), language != loc.language else { return }
        loc.setLanguage(language)
        GameManager.shared.playerData?.language = language
        GameManager.shared.save()
        setupUI()
    }

    private func transitionToOverworld() {
        let scene = OverworldScene(size: self.size)
        scene.scaleMode = .resizeFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToInventory() {
        let scene = InventoryScene(size: self.size)
        scene.scaleMode = .resizeFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToShop() {
        let scene = ShopScene(size: self.size)
        scene.scaleMode = .resizeFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToRanking() {
        let scene = RankingScene(size: self.size)
        scene.scaleMode = .resizeFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func transitionToSettings() {
        let scene = SettingsScene(size: self.size)
        scene.scaleMode = .resizeFill
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }
}
