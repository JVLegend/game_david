import SpriteKit

class BattleScene: SKScene {

    var mapId: Int = 1
    var battleId: Int = 1

    // World width — calculado dinamicamente no setupBattle baseado na quantidade de inimigos
    private var worldWidth: CGFloat = 1792

    // Camera
    private var gameCamera: SKCameraNode!
    // HUD layer (fixo na câmera)
    private var hudLayer: SKNode!

    // State
    private var battleState: BattleState = .idle
    private var currentEnemyIndex = 0
    private var enemyQueue: [EnemyData] = []
    private var bossData: BossData?
    private var currentBattleDef: BattleDefinition?
    private var currentMapDef: MapDefinition?

    // Stats
    private var playerStats: CharacterStats!
    private var enemyCurrentHP: Int = 0
    private var enemyMaxHP: Int = 0
    private var currentEnemy: EnemyData?
    private var goldEarned: Int = 0
    private var xpEarned: Int = 0
    private var droppedItemNames: [String] = []
    private var missionCompletions: [MissionCompletion] = []
    private var enemiesKilled: Int = 0
    private var usedFood: Bool = false
    private var foodSlots: [(FoodType, Int)] = []
    private var didAwardDefeatRewards: Bool = false
    private var selectedFoodIndex: Int = 0

    // Timers
    private var playerAttackTimer: TimeInterval = 0
    private var enemyAttackTimer: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0

    // Nodes
    private var playerNode: SKSpriteNode!
    private var enemyNode: SKSpriteNode!
    private var playerHPBar: SKShapeNode!
    private var playerHPFill: SKShapeNode!
    private var enemyUIContainer: SKNode!
    private var enemyHPBar: SKShapeNode!
    private var enemyHPFill: SKShapeNode!
    private var enemyHPText: SKLabelNode!
    private var enemyNameLabel: SKLabelNode!
    private var goldLabel: SKLabelNode!
    private var damageLabels: [SKLabelNode] = []
    private var statsPanel: SKNode!
    private var progressBar: SKNode!
    private var foodButtons: [SKNode] = []

    // Skill state
    private var skillButtons: [SKNode] = []
    private var skillLastUsed: [String: TimeInterval] = [:]
    private var skillCooldowns: [String: TimeInterval] = [:]
    private var skillCooldownViews: [String: SkillCooldownView] = [:]
    private var lastCooldownVisualUpdate: TimeInterval = 0
    private var enemyStunnedTimer: TimeInterval = 0
    private var bossPhaseTriggers = Set<String>()
    private var enemyArmorBonus: Int = 0
    private var enemyArmorBonusTimer: TimeInterval = 0
    private var enemyDamageMultiplier: Double = 1.0
    private var enemyDamageMultiplierTimer: TimeInterval = 0

    private struct SkillVisuals {
        let rangedLabel: String
        let rangedIcon: String
        let rangedProjectile: String
        let rangedSize: CGSize
        let meleeLabel: String
        let meleeIcon: String
        let meleeEffect: String
        let meleeSize: CGSize
    }

    private struct SkillCooldownView {
        let overlay: SKShapeNode
        let label: SKLabelNode
        let ring: SKShapeNode
    }

    // Bonus Cards
    private var bonusCardEffects: [() -> Void] = []
    private var isShowingCards: Bool = false

    // MARK: - Sprite Animation
    private let playerHeight: CGFloat = 90
    private var playerBaseY: CGFloat = 0
    private var playerIdleFrames: [SKTexture] = []
    private var playerWalkFrames: [SKTexture] = []
    private var playerAttackFrames: [SKTexture] = []
    private var currentPlayerAnim: String = ""  // "idle", "walk", "attack"

    private var enemyWalkFrames: [String: [SKTexture]] = [:]
    private var currentEnemyAnim: String = ""
    private var enemyBaseY: CGFloat = 0

    private func loadPlayerTextures() {
        let character = GameManager.shared.playerData?.activeCharacter ?? .davi
        guard character == .davi else {
            loadRosterPlayerTexture(for: character)
            return
        }

        // Row 0 (00-05): idle
        let prefix = "davi_jovem"
        playerIdleFrames = (0...5).map { SKTexture(imageNamed: "\(prefix)_\(String(format: "%02d", $0))") }
        // Walk enhanced: longer cycle with stronger leg/hip movement. Falls back to the original row if needed.
        let enhancedWalk = (0...7).map { SKTexture(imageNamed: "\(prefix)_walk_enhanced_\(String(format: "%02d", $0))") }
        playerWalkFrames = enhancedWalk.allSatisfy { $0.size().width > 0 }
            ? enhancedWalk
            : (6...11).map { SKTexture(imageNamed: "\(prefix)_\(String(format: "%02d", $0))") }
        // Row 2 (12-17): attack
        playerAttackFrames = (12...17).map { SKTexture(imageNamed: "\(prefix)_\(String(format: "%02d", $0))") }

        // Configura texture inicial
        if let first = playerIdleFrames.first {
            playerNode.texture = first
            playerNode.size = CGSize(width: first.size().width / first.size().height * playerHeight,
                                     height: playerHeight)
        }
    }

    private func loadRosterPlayerTexture(for character: PlayableCharacter) {
        let requestedTexture = SKTexture(imageNamed: character.rosterTextureName)
        let texture = requestedTexture.size().width > 0
            ? requestedTexture
            : SKTexture(imageNamed: PlayableCharacter.davi.rosterTextureName)
        playerIdleFrames = [texture]
        playerWalkFrames = [texture]
        playerAttackFrames = [texture]

        playerNode.texture = texture
        // Roster portraits live on a square transparent canvas, so render them a bit taller in battle.
        let height = playerHeight + 18
        let aspect = texture.size().height > 0 ? texture.size().width / texture.size().height : 1
        playerNode.size = CGSize(width: height * aspect, height: height)
    }

    private func loadEnemyTextures() {
        let animatedTextureNames = Set(enemyQueue.map { enemy in
            enemy.textureName.isEmpty ? "lobocinzento" : enemy.textureName
        } + ["lobocinzento", "wolf"])

        enemyWalkFrames = Dictionary(uniqueKeysWithValues: animatedTextureNames.map { textureName in
            let prefix = (textureName == "lobocinzento" || textureName == "wolf") ? "wolf" : textureName
            let frames = (0...3).map { SKTexture(imageNamed: "\(prefix)_walk_\($0)") }
            return (textureName, frames.allSatisfy { $0.size().width > 0 } ? frames : [])
        })
    }

    private func playEnemyAnim(_ anim: String, for enemy: EnemyData, loop: Bool = true) {
        guard anim != currentEnemyAnim else { return }
        currentEnemyAnim = anim

        enemyNode.removeAction(forKey: "enemyAnim")
        resetEnemyVerticalPosition()

        let frames = enemyWalkFrames[enemy.textureName] ?? []
        if anim == "walk", !frames.isEmpty {
            let animAction = SKAction.animate(with: frames, timePerFrame: 0.15)
            let action = loop ? SKAction.repeatForever(animAction) : animAction
            enemyNode.run(action, withKey: "enemyAnim")
            return
        }

        // Animações genéricas (respiro/idle) para outros ou se não houver frames
        switch anim {
        case "idle":
            let breathUp = SKAction.moveTo(y: enemyBaseY + 4, duration: 1.1)
            breathUp.timingMode = .easeInEaseOut
            let breathDown = SKAction.moveTo(y: enemyBaseY, duration: 1.1)
            breathDown.timingMode = .easeInEaseOut
            let breathLoop = SKAction.repeatForever(SKAction.sequence([breathUp, breathDown]))

            if !frames.isEmpty {
                let frameLoop = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.24))
                enemyNode.run(SKAction.group([frameLoop, breathLoop]), withKey: "enemyAnim")
            } else {
                let leanRight = SKAction.rotate(toAngle: 0.035, duration: 1.0, shortestUnitArc: true)
                leanRight.timingMode = .easeInEaseOut
                let leanLeft = SKAction.rotate(toAngle: -0.025, duration: 1.0, shortestUnitArc: true)
                leanLeft.timingMode = .easeInEaseOut
                let swayLoop = SKAction.repeatForever(SKAction.sequence([leanRight, leanLeft]))
                enemyNode.run(SKAction.group([breathLoop, swayLoop]), withKey: "enemyAnim")
            }
        case "attack":
            // Salto de ataque
            let jump = SKAction.sequence([
                SKAction.moveBy(x: -30, y: 20, duration: 0.15),
                SKAction.moveBy(x: 30, y: -20, duration: 0.15),
                SKAction.run { [weak self] in
                    self?.resetEnemyVerticalPosition()
                }
            ])
            enemyNode.run(jump, withKey: "enemyAnim")
            currentEnemyAnim = "" // Reset para voltar ao idle depois
        default:
            break
        }
    }

    private func resetEnemyVerticalPosition() {
        guard enemyBaseY > 0 else { return }
        enemyNode.position.y = enemyBaseY
        enemyNode.zRotation = 0
    }

    private func playAnim(_ anim: String, loop: Bool = true) {
        guard !loop || anim != currentPlayerAnim else { return }
        currentPlayerAnim = anim

        playerNode.removeAction(forKey: "playerAnim")
        playerNode.removeAction(forKey: "playerIdleMotion")

        let frames: [SKTexture]
        let fps: TimeInterval
        switch anim {
        case "walk":
            frames = playerWalkFrames
            fps = 0.075
        case "attack":
            frames = playerAttackFrames
            fps = 0.08
        default:  // "idle"
            frames = playerIdleFrames
            fps = 0.12
        }
        guard !frames.isEmpty else { return }

        if frames.count == 1, anim == "idle", loop {
            startRosterIdleMotion()
        }

        let animAction = SKAction.animate(with: frames, timePerFrame: fps)
        let action: SKAction
        if loop {
            action = SKAction.repeatForever(animAction)
        } else {
            action = SKAction.sequence([
                animAction,
                SKAction.run { [weak self] in
                    self?.currentPlayerAnim = ""
                    self?.playAnim("idle")
                }
            ])
        }
        playerNode.run(action, withKey: "playerAnim")
    }

    private func startRosterIdleMotion() {
        let breatheUp = SKAction.group([
            SKAction.scaleX(to: 1.015, y: 0.992, duration: 0.95),
            SKAction.moveTo(y: playerBaseY + 2, duration: 0.95)
        ])
        breatheUp.timingMode = .easeInEaseOut
        let breatheDown = SKAction.group([
            SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.95),
            SKAction.moveTo(y: playerBaseY, duration: 0.95)
        ])
        breatheDown.timingMode = .easeInEaseOut
        playerNode.run(SKAction.repeatForever(SKAction.sequence([breatheUp, breatheDown])), withKey: "playerIdleMotion")
    }

    private func setSpriteTexture(_ node: SKSpriteNode, textureName: String, targetHeight: CGFloat) {
        let texture = SKTexture(imageNamed: textureName)
        node.texture = texture

        let textureSize = texture.size()
        let aspect = textureSize.height > 0 ? textureSize.width / textureSize.height : 1
        node.size = CGSize(width: targetHeight * aspect, height: targetHeight)
    }

    private func shouldMirrorEnemySprite(_ enemy: EnemyData) -> Bool {
        // Most enemy sheets face right in the source art, so the right-side enemy node
        // is mirrored to face Davi. These newer animal sheets already face left.
        switch enemy.textureName {
        case "enemy_rabid_fox", "enemy_wild_boar", "enemy_hunting_eagle", "enemy_giant_scorpion", "enemy_pack_hyena":
            return false
        default:
            return true
        }
    }

    private func addTiledLayer(textureName: String, tileHeight: CGFloat, y: CGFloat, zPosition: CGFloat, mirrorAlternatingTiles: Bool = false) {
        let texture = SKTexture(imageNamed: textureName)
        let textureSize = texture.size()
        let aspect = textureSize.height > 0 ? textureSize.width / textureSize.height : 1
        let tileWidth = max(size.width * 0.75, tileHeight * aspect)
        let tileCount = Int(ceil(worldWidth / tileWidth)) + 1

        for index in 0..<tileCount {
            let tile = SKSpriteNode(texture: texture, size: CGSize(width: tileWidth, height: tileHeight))
            tile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            tile.position = CGPoint(x: CGFloat(index) * tileWidth + tileWidth / 2, y: y)
            if mirrorAlternatingTiles, index % 2 == 1 {
                tile.xScale = -1
            }
            tile.zPosition = zPosition
            addChild(tile)
        }
    }

    private func addAtmosphere(groundHeight: CGFloat) {
        let sunWash = SKShapeNode(rectOf: CGSize(width: worldWidth, height: size.height * 0.36))
        sunWash.fillColor = SKColor(red: 1.0, green: 0.72, blue: 0.32, alpha: 0.12)
        sunWash.strokeColor = .clear
        sunWash.position = CGPoint(x: worldWidth / 2, y: size.height * 0.64)
        sunWash.zPosition = -8
        addChild(sunWash)

        let groundShade = SKShapeNode(rectOf: CGSize(width: worldWidth, height: groundHeight * 0.45))
        groundShade.fillColor = SKColor(red: 0.08, green: 0.12, blue: 0.06, alpha: 0.18)
        groundShade.strokeColor = .clear
        groundShade.position = CGPoint(x: worldWidth / 2, y: groundHeight * 0.24)
        groundShade.zPosition = -4
        addChild(groundShade)
    }

    private func addForegroundDetails(groundHeight: CGFloat) {
        for index in 0..<18 {
            let t = CGFloat(index)
            let x = (t / 17.0) * worldWidth
            let rockSize = CGSize(width: 16 + CGFloat(index % 4) * 5, height: 8 + CGFloat(index % 3) * 3)
            let rock = SKShapeNode(ellipseOf: rockSize)
            rock.fillColor = SKColor(red: 0.36, green: 0.33, blue: 0.27, alpha: 0.75)
            rock.strokeColor = SKColor(red: 0.18, green: 0.16, blue: 0.13, alpha: 0.5)
            rock.lineWidth = 1
            rock.position = CGPoint(x: x + sin(t * 1.7) * 28, y: groundHeight + 5 + CGFloat(index % 2) * 4)
            rock.zPosition = -2
            addChild(rock)
        }

        let tuftTextures = ["grass_tuft_01", "grass_tuft_02", "grass_tuft_03"]
        for index in 0..<32 {
            let x = CGFloat(index) / 31.0 * worldWidth + cos(CGFloat(index) * 1.7) * 20
            let y = groundHeight + 8 + CGFloat(index % 4) * 2
            let tuft = SKSpriteNode(imageNamed: tuftTextures[index % tuftTextures.count])
            tuft.size = CGSize(width: 42 + CGFloat(index % 3) * 8, height: 28 + CGFloat(index % 2) * 5)
            tuft.position = CGPoint(x: x, y: y)
            tuft.zPosition = 4.5
            tuft.alpha = 0.62 + CGFloat(index % 4) * 0.06
            if index % 2 == 0 {
                tuft.xScale *= -1
            }
            addChild(tuft)
        }
    }

    private func startPlayerWalkMotion() {
        playerNode.removeAction(forKey: "walkMotion")
        playerNode.removeAction(forKey: "playerIdleMotion")
        removeAction(forKey: "playerStepDust")

        let stepUp = SKAction.group([
            SKAction.moveTo(y: playerBaseY + 5, duration: 0.10),
            SKAction.scaleX(to: 1.035, y: 0.975, duration: 0.10),
            SKAction.rotate(toAngle: 0.025, duration: 0.10, shortestUnitArc: true)
        ])
        stepUp.timingMode = .easeInEaseOut
        let stepDown = SKAction.group([
            SKAction.moveTo(y: playerBaseY, duration: 0.10),
            SKAction.scaleX(to: 0.985, y: 1.015, duration: 0.10),
            SKAction.rotate(toAngle: -0.018, duration: 0.10, shortestUnitArc: true)
        ])
        stepDown.timingMode = .easeInEaseOut
        let settle = SKAction.group([
            SKAction.moveTo(y: playerBaseY + 1, duration: 0.08),
            SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.08),
            SKAction.rotate(toAngle: 0, duration: 0.08, shortestUnitArc: true)
        ])
        settle.timingMode = .easeInEaseOut
        playerNode.run(SKAction.repeatForever(SKAction.sequence([stepUp, stepDown, settle])), withKey: "walkMotion")

        let dustLoop = SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in self?.emitStepDust() },
            SKAction.wait(forDuration: 0.20)
        ]))
        run(dustLoop, withKey: "playerStepDust")
    }

    private func stopPlayerWalkMotion() {
        playerNode.removeAction(forKey: "walkMotion")
        removeAction(forKey: "playerStepDust")
        playerNode.run(SKAction.group([
            SKAction.moveTo(y: playerBaseY, duration: 0.08),
            SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.08),
            SKAction.rotate(toAngle: 0, duration: 0.08, shortestUnitArc: true)
        ]))
    }

    private func emitStepDust() {
        let dust = SKShapeNode(ellipseOf: CGSize(width: 18, height: 6))
        dust.fillColor = SKColor(red: 0.75, green: 0.66, blue: 0.48, alpha: 0.34)
        dust.strokeColor = .clear
        dust.position = CGPoint(x: playerNode.position.x - 18, y: size.height * 0.28 + 8)
        dust.zPosition = 4
        addChild(dust)
        dust.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: -18, y: 4, duration: 0.35),
                SKAction.scale(to: 1.8, duration: 0.35),
                SKAction.fadeOut(withDuration: 0.35)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    private let loc = LocalizationManager.shared

    private func activeSkillVisuals() -> SkillVisuals {
        let character = GameManager.shared.playerData?.activeCharacter ?? .davi

        switch character {
        case .josue:
            return SkillVisuals(
                rangedLabel: loc.language == .portuguese ? "BASQ." : "B-BALL",
                rangedIcon: "battle_skill_basketball",
                rangedProjectile: "battle_skill_basketball",
                rangedSize: CGSize(width: 28, height: 28),
                meleeLabel: "FTP",
                meleeIcon: "battle_skill_book_ftp",
                meleeEffect: "battle_skill_book_ftp",
                meleeSize: CGSize(width: 44, height: 44)
            )
        case .bigJ:
            return SkillVisuals(
                rangedLabel: loc.language == .portuguese ? "FUTEBOL" : "SOCCER",
                rangedIcon: "battle_skill_soccer_ball",
                rangedProjectile: "battle_skill_soccer_ball",
                rangedSize: CGSize(width: 28, height: 28),
                meleeLabel: loc.language == .portuguese ? "SOL" : "SHADE",
                meleeIcon: "battle_skill_beach_umbrella",
                meleeEffect: "battle_skill_beach_umbrella",
                meleeSize: CGSize(width: 54, height: 54)
            )
        default:
            return SkillVisuals(
                rangedLabel: loc.language == .portuguese ? "PEDRA" : "STONE",
                rangedIcon: "battle_skill_stone",
                rangedProjectile: "battle_skill_stone",
                rangedSize: CGSize(width: 24, height: 24),
                meleeLabel: loc.language == .portuguese ? "CAJADO" : "STAFF",
                meleeIcon: "battle_skill_staff",
                meleeEffect: "battle_skill_staff",
                meleeSize: CGSize(width: 46, height: 46)
            )
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        AudioManager.shared.playMapMusic(mapId: mapId)
        setupCamera()
        setupBattle()
        loadEnemyTextures()
        setupHUD()
        if shouldShowStoryIntro() {
            showStoryIntro()
        } else {
            startBattle()
        }
    }

    // MARK: - Camera
    private func setupCamera() {
        gameCamera = SKCameraNode()
        gameCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameCamera)
        camera = gameCamera

        // Câmera começa no início do mundo
        cameraTargetX = size.width / 2

        // HUD layer é filho da câmera — fica fixo na tela
        hudLayer = SKNode()
        hudLayer.zPosition = 200 // Ensure it's above everything
        gameCamera.addChild(hudLayer)
    }

    /// O Davi fica numa posição fixa na tela (levemente à esquerda do centro).
    /// A câmera se move pelo mundo e o player acompanha a câmera.
    private let playerScreenX: CGFloat = 0.38  // fração da tela (0 = esquerda, 1 = direita)

    private func updateCamera() {
        let halfW = size.width / 2
        let clampedTarget = max(halfW, min(worldWidth - halfW, cameraTargetX))
        // Lerp suave para acompanhar o alvo
        let lerpFactor: CGFloat = 0.12
        let newX = gameCamera.position.x + (clampedTarget - gameCamera.position.x) * lerpFactor
        gameCamera.position = CGPoint(x: newX, y: size.height / 2)

        // Player acompanha a câmera — fica fixo na posição de tela
        playerNode.position.x = newX - halfW + size.width * playerScreenX
    }

    /// X alvo da câmera no mundo — movemos isso para "andar"
    private var cameraTargetX: CGFloat = 0

    // MARK: - Setup
    private func setupBattle() {
        playerStats = GameManager.shared.computedStats()
        playerStats.currentHP = playerStats.maxHP

        // Load enemies
        guard let map = EnemyDatabase.shared.map(withId: mapId),
              let battleDef = map.battles.first(where: { $0.battleId == battleId }) else { return }
        currentMapDef = map
        currentBattleDef = battleDef

        for enemyId in battleDef.enemies {
            if let boss = EnemyDatabase.shared.boss(withId: enemyId) {
                enemyQueue.append(boss.enemy)
                bossData = boss
            } else if let enemy = EnemyDatabase.shared.enemy(withId: enemyId) {
                enemyQueue.append(enemy)
            }
        }

        goldEarned = 0
        xpEarned = 0
        droppedItemNames = []
        enemiesKilled = 0
        didAwardDefeatRewards = false

        // Calcula largura do mundo baseado na quantidade de inimigos
        let lastEnemyX = size.width * 1.5 + CGFloat(max(0, enemyQueue.count - 1)) * size.width * 1.0
        worldWidth = max(size.width * 3, lastEnemyX + size.width)

        // Load food from player inventory in the same order as the shop database.
        if let player = GameManager.shared.playerData {
            foodSlots = FoodDatabase.shared.allFoods.compactMap { food in
                let count = player.foodInventory[food.type] ?? 0
                return count > 0 ? (food.type, count) : nil
            }
            selectedFoodIndex = 0
        }
    }

    private func setupHUD() {
        // === MUNDO (rola com câmera) ===
        let groundHeight = size.height * 0.28

        // Background e chão em tiles para preservar a arte sem esticar no mundo inteiro.
        addTiledLayer(textureName: currentMapDef?.backgroundTexture ?? "background_forest", tileHeight: size.height, y: size.height / 2, zPosition: -10, mirrorAlternatingTiles: true)
        addTiledLayer(textureName: "ground_grass", tileHeight: groundHeight, y: groundHeight / 2, zPosition: -5)
        addAtmosphere(groundHeight: groundHeight)
        addForegroundDetails(groundHeight: groundHeight)

        // Player — posição X controlada pela câmera (fica fixo na tela)
        playerNode = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: playerHeight))
        let initialCamX = size.width / 2
        playerNode.position = CGPoint(x: initialCamX - size.width / 2 + size.width * playerScreenX,
                                       y: groundHeight + playerHeight / 2 - 10)
        playerBaseY = playerNode.position.y
        playerNode.zPosition = 5
        addChild(playerNode)

        // Carrega texturas e inicia animação idle
        loadPlayerTextures()
        playAnim("idle")

        // Enemy — está mais à frente no mundo
        enemyNode = SKSpriteNode(imageNamed: "lobocinzento")
        setSpriteTexture(enemyNode, textureName: "lobocinzento", targetHeight: 84)
        enemyNode.position = CGPoint(x: worldWidth * 0.6, y: groundHeight + enemyNode.size.height / 2 - 8)
        enemyNode.zPosition = 5
        enemyNode.isHidden = true
        addChild(enemyNode)

        enemyUIContainer = SKNode()
        enemyUIContainer.zPosition = 26
        enemyUIContainer.isHidden = true
        addChild(enemyUIContainer)

        enemyNameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        enemyNameLabel.fontSize = 14
        enemyNameLabel.fontColor = .white
        enemyNameLabel.horizontalAlignmentMode = .center
        enemyNameLabel.verticalAlignmentMode = .center
        enemyNameLabel.position = CGPoint(x: 0, y: 24)
        enemyNameLabel.zPosition = 25
        enemyUIContainer.addChild(enemyNameLabel)

        // HP bar do inimigo — fica no mundo, sobre o inimigo
        enemyHPBar = SKShapeNode(rectOf: CGSize(width: 108, height: 14), cornerRadius: 5)
        enemyHPBar.fillColor = SKColor(red: 0.08, green: 0.05, blue: 0.04, alpha: 0.88)
        enemyHPBar.strokeColor = SKColor(red: 0.9, green: 0.66, blue: 0.25, alpha: 0.95)
        enemyHPBar.lineWidth = 1.4
        enemyHPBar.position = CGPoint(x: 0, y: 0)
        enemyHPBar.zPosition = 20
        enemyUIContainer.addChild(enemyHPBar)

        enemyHPFill = SKShapeNode(rectOf: CGSize(width: 100, height: 8), cornerRadius: 3)
        enemyHPFill.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        enemyHPFill.strokeColor = .clear
        enemyHPFill.zPosition = 21
        enemyHPBar.addChild(enemyHPFill)

        enemyHPText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        enemyHPText.fontSize = 10
        enemyHPText.fontColor = .white
        enemyHPText.horizontalAlignmentMode = .center
        enemyHPText.verticalAlignmentMode = .center
        enemyHPText.position = CGPoint(x: 0, y: -18)
        enemyHPText.zPosition = 22
        enemyHPBar.addChild(enemyHPText)

        // === HUD FIXO (filho da câmera, não rola) ===

        // Player HP Bar — centralizado na parte inferior do HUD
        let hpBarWidth: CGFloat = min(size.width * 0.4, 250)
        let hpBarHeight: CGFloat = 16

        playerHPBar = SKShapeNode(rectOf: CGSize(width: hpBarWidth, height: hpBarHeight), cornerRadius: 4)
        playerHPBar.fillColor = SKColor(white: 0.1, alpha: 0.9)
        playerHPBar.strokeColor = SKColor(white: 0.6, alpha: 1)
        // posição relativa à câmera (centro = 0,0), então y negativo = parte de baixo
        playerHPBar.position = CGPoint(x: 0, y: -(size.height / 2) + 40)
        playerHPBar.zPosition = 20
        hudLayer.addChild(playerHPBar)

        playerHPFill = SKShapeNode(rectOf: CGSize(width: hpBarWidth - 4, height: hpBarHeight - 4), cornerRadius: 2)
        playerHPFill.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)
        playerHPFill.strokeColor = .clear
        playerHPFill.zPosition = 21
        playerHPBar.addChild(playerHPFill)

        let hpText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hpText.name = "hp_text"
        hpText.fontSize = 10
        hpText.fontColor = .white
        hpText.verticalAlignmentMode = .center
        hpText.zPosition = 22
        playerHPBar.addChild(hpText)
        updatePlayerHPBar()

        // Ouro coletado durante a batalha (topo esquerdo da HUD)
        let goldPanelSize = CGSize(width: 126, height: 38)
        let goldPanel = SKNode()
        goldPanel.position = CGPoint(x: -(size.width / 2) + 82, y: (size.height / 2) - 34)
        goldPanel.zPosition = 30

        let goldShadow = SKShapeNode(rectOf: goldPanelSize, cornerRadius: 9)
        goldShadow.position = CGPoint(x: 2, y: -3)
        goldShadow.fillColor = .black
        goldShadow.strokeColor = .clear
        goldShadow.alpha = 0.28
        goldPanel.addChild(goldShadow)

        let goldBg = SKShapeNode(rectOf: goldPanelSize, cornerRadius: 9)
        goldBg.fillColor = SKColor(red: 0.13, green: 0.08, blue: 0.03, alpha: 0.86)
        goldBg.strokeColor = SKColor(red: 0.95, green: 0.68, blue: 0.18, alpha: 0.95)
        goldBg.lineWidth = 1.8
        goldPanel.addChild(goldBg)

        let goldIcon = SKSpriteNode(imageNamed: "menu_icon_gold")
        goldIcon.size = CGSize(width: 26, height: 26)
        goldIcon.position = CGPoint(x: -45, y: 0)
        goldIcon.zPosition = 1
        goldPanel.addChild(goldIcon)

        goldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goldLabel.text = "\(loc.localize("hud.gold")) 0"
        goldLabel.fontSize = 13
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.verticalAlignmentMode = .center
        goldLabel.position = CGPoint(x: -26, y: 0)
        goldLabel.zPosition = 2
        goldPanel.addChild(goldLabel)
        hudLayer.addChild(goldPanel)

        // Stats panel e progress bar também no HUD
        setupStatsPanel()
        setupProgressBar()
        setupFoodButtons()
        setupSkillButtons()
    }

    private func setupStatsPanel() {
        statsPanel = SKNode()
        // posição relativa à câmera: canto inferior esquerdo com respiro da safe area
        statsPanel.position = CGPoint(x: -(size.width / 2) + 44, y: -(size.height / 2) + 12)
        statsPanel.zPosition = 30
        hudLayer.addChild(statsPanel)

        let panelSize = CGSize(width: 168, height: 134)
        let shadow = SKShapeNode(rectOf: panelSize, cornerRadius: 8)
        shadow.fillColor = SKColor(white: 0, alpha: 0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 88, y: 62)
        shadow.zPosition = -1
        statsPanel.addChild(shadow)

        let panelBg = SKShapeNode(rectOf: panelSize, cornerRadius: 8)
        panelBg.fillColor = SKColor(red: 0.08, green: 0.075, blue: 0.055, alpha: 0.94)
        panelBg.strokeColor = SKColor(red: 0.76, green: 0.55, blue: 0.24, alpha: 1)
        panelBg.lineWidth = 2
        panelBg.position = CGPoint(x: 84, y: 67)
        statsPanel.addChild(panelBg)

        let innerBorder = SKShapeNode(rectOf: CGSize(width: panelSize.width - 12, height: panelSize.height - 12), cornerRadius: 5)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(red: 0.95, green: 0.76, blue: 0.34, alpha: 0.25)
        innerBorder.lineWidth = 1
        innerBorder.position = panelBg.position
        statsPanel.addChild(innerBorder)

        let lines: [(String, String)] = [
            (loc.localize("hud.attack"), ""),
            (loc.localize("hud.damage"), "\(playerStats.damageMin)-\(playerStats.damageMax)"),
            (loc.localize("hud.crit_chance"), "\(Int(playerStats.critChance * 100))%"),
            (loc.localize("hud.crit_damage"), String(format: "%.1fx", playerStats.critDamage)),
            (loc.localize("hud.defense"), ""),
            (loc.localize("hud.hp_max"), "\(playerStats.maxHP)"),
            (loc.localize("hud.max_armor"), "\(playerStats.armor)"),
        ]

        for (i, line) in lines.enumerated() {
            let isHeader = line.1.isEmpty
            let label = SKLabelNode(fontNamed: isHeader ? "AvenirNext-Bold" : "AvenirNext-Medium")
            label.text = isHeader ? line.0.uppercased() : "\(line.0): \(line.1)"
            label.fontSize = isHeader ? 11 : 10
            label.fontColor = isHeader ? SKColor(red: 1, green: 0.75, blue: 0.3, alpha: 1) : .white
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: 14, y: 118 - CGFloat(i) * 16)
            statsPanel.addChild(label)
        }
    }

    private func setupProgressBar() {
        progressBar = SKNode()
        // topo centro da HUD
        progressBar.position = CGPoint(x: 0, y: (size.height / 2) - 25)
        progressBar.zPosition = 30
        hudLayer.addChild(progressBar)

        let totalEnemies = enemyQueue.count
        let spacing: CGFloat = 35

        for i in 0..<totalEnemies {
            let icon = SKShapeNode(circleOfRadius: 10)
            icon.fillColor = SKColor(white: 0.2, alpha: 0.9)
            icon.strokeColor = SKColor(white: 0.6, alpha: 1)
            icon.position = CGPoint(x: CGFloat(i) * spacing - CGFloat(totalEnemies - 1) * spacing / 2, y: 0)
            icon.name = "progress_\(i)"
            progressBar.addChild(icon)
        }
    }

    private func setupFoodButtons() {
        let selector = SKNode()
        selector.position = CGPoint(x: (size.width / 2) - 66, y: -(size.height / 2) + 52)
        selector.name = "food_selector"
        selector.zPosition = 30
        hudLayer.addChild(selector)
        foodButtons.append(selector)

        let bg = SKShapeNode(rectOf: CGSize(width: 108, height: 62), cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.08, green: 0.17, blue: 0.10, alpha: 0.94)
        bg.strokeColor = SKColor(red: 0.45, green: 0.78, blue: 0.34, alpha: 1)
        bg.lineWidth = 2
        bg.name = "food_use"
        selector.addChild(bg)

        let icon = SKSpriteNode()
        icon.name = "food_selected_icon"
        icon.position = CGPoint(x: -36, y: 2)
        icon.zPosition = 1
        selector.addChild(icon)

        let healLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healLabel.name = "food_selected_heal"
        healLabel.fontSize = 13
        healLabel.fontColor = SKColor(red: 0.55, green: 1, blue: 0.56, alpha: 1)
        healLabel.horizontalAlignmentMode = .left
        healLabel.verticalAlignmentMode = .center
        healLabel.position = CGPoint(x: -4, y: 13)
        selector.addChild(healLabel)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        nameLabel.name = "food_selected_name"
        nameLabel.fontSize = 9
        nameLabel.fontColor = SKColor(white: 0.92, alpha: 1)
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -4, y: -7)
        selector.addChild(nameLabel)

        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.name = "food_selected_count"
        countLabel.fontSize = 12
        countLabel.fontColor = .white
        countLabel.horizontalAlignmentMode = .left
        countLabel.verticalAlignmentMode = .center
        countLabel.position = CGPoint(x: 26, y: -24)
        selector.addChild(countLabel)

        let prev = createFoodCycleButton(text: "‹", name: "food_prev", position: CGPoint(x: -43, y: 24))
        let next = createFoodCycleButton(text: "›", name: "food_next", position: CGPoint(x: 43, y: 24))
        selector.addChild(prev)
        selector.addChild(next)

        refreshFoodSelector()
    }

    private func shouldShowStoryIntro() -> Bool {
        battleId == 1 || currentBattleDef?.isBossBattle == true
    }

    private func showStoryIntro() {
        let copy = storyCopy()
        let overlay = SKShapeNode(rectOf: CGSize(width: min(size.width * 0.72, 520), height: 158), cornerRadius: 14)
        overlay.name = "story_intro"
        overlay.fillColor = SKColor(red: 0.055, green: 0.04, blue: 0.026, alpha: 0.94)
        overlay.strokeColor = goldStrokeColor()
        overlay.lineWidth = 2
        overlay.zPosition = 220
        hudLayer.addChild(overlay)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = copy.title
        title.fontSize = 22
        title.fontColor = SKColor(red: 1, green: 0.83, blue: 0.24, alpha: 1)
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 48)
        overlay.addChild(title)

        let body = SKLabelNode(fontNamed: "AvenirNext-Medium")
        body.text = copy.body
        body.fontSize = 15
        body.fontColor = SKColor(red: 1.0, green: 0.93, blue: 0.76, alpha: 1)
        body.numberOfLines = 2
        body.preferredMaxLayoutWidth = min(size.width * 0.62, 460)
        body.lineBreakMode = .byWordWrapping
        body.verticalAlignmentMode = .center
        body.horizontalAlignmentMode = .center
        body.position = CGPoint(x: 0, y: 8)
        overlay.addChild(body)

        let btn = SKNode()
        btn.name = "btn_story_start"
        btn.position = CGPoint(x: 0, y: -51)
        overlay.addChild(btn)

        let btnBg = SKShapeNode(rectOf: CGSize(width: 154, height: 38), cornerRadius: 9)
        btnBg.name = "btn_story_start"
        btnBg.fillColor = SKColor(red: 0.48, green: 0.32, blue: 0.12, alpha: 1)
        btnBg.strokeColor = SKColor(red: 0.92, green: 0.68, blue: 0.25, alpha: 1)
        btnBg.lineWidth = 1.5
        btn.addChild(btnBg)

        let btnLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        btnLabel.name = "btn_story_start"
        btnLabel.text = loc.language == .portuguese ? "Começar" : "Start"
        btnLabel.fontSize = 14
        btnLabel.fontColor = .white
        btnLabel.verticalAlignmentMode = .center
        btn.addChild(btnLabel)
    }

    private func goldStrokeColor() -> SKColor {
        SKColor(red: 0.84, green: 0.61, blue: 0.24, alpha: 1)
    }

    private func storyCopy() -> (title: String, body: String) {
        let isPT = loc.language == .portuguese
        if currentBattleDef?.isBossBattle == true {
            switch mapId {
            case 1:
                return (isPT ? "O Leão de Belém" : "The Lion of Bethlehem",
                        isPT ? "O rebanho está ameaçado. Enfrente o leão e prove que Davi está pronto." : "The flock is threatened. Face the lion and prove David is ready.")
            case 2:
                return (isPT ? "Diante de Golias" : "Before Goliath",
                        isPT ? "O vale silencia diante do gigante. Uma pedra certa pode mudar tudo." : "The valley falls silent before the giant. One true stone can change everything.")
            case 3:
                return (isPT ? "A Corte de Saul" : "Saul's Court",
                        isPT ? "A inveja tomou o palácio. Sobreviva aos guardas e mantenha sua fé firme." : "Jealousy fills the palace. Survive the guards and keep your faith steady.")
            default:
                return (isPT ? "Batalha decisiva" : "Decisive Battle",
                        isPT ? "Um novo inimigo bloqueia a jornada. Use seus melhores itens." : "A new foe blocks the journey. Use your best gear.")
            }
        }

        switch mapId {
        case 1:
            return (isPT ? "Campos de Belém" : "Fields of Bethlehem",
                    isPT ? "Comece protegendo o rebanho. Vença batalhas rápidas, ganhe ouro e compre seus primeiros itens." : "Start by protecting the flock. Win quick battles, earn gold, and buy your first gear.")
        case 2:
            return (isPT ? "Vale de Elá" : "Valley of Elah",
                    isPT ? "O caminho fica mais duro. Rejogue fases, melhore equipamentos e prepare-se para Golias." : "The road gets harder. Replay stages, improve gear, and prepare for Goliath.")
        case 3:
            return (isPT ? "Corte de Saul" : "Saul's Court",
                    isPT ? "Os inimigos agora resistem mais. Escolha bênçãos e itens com cuidado." : "Enemies now endure more. Choose blessings and gear carefully.")
        default:
            return (currentMapDef?.localizedName ?? (isPT ? "Nova fase" : "New Stage"),
                    isPT ? "Avance, colete recompensas e adapte sua estratégia." : "Advance, collect rewards, and adapt your strategy.")
        }
    }

    private func createFoodCycleButton(text: String, name: String, position: CGPoint) -> SKNode {
        let node = SKNode()
        node.name = name
        node.position = position
        node.zPosition = 4

        let bg = SKShapeNode(circleOfRadius: 12)
        bg.name = name
        bg.fillColor = SKColor(red: 0.15, green: 0.30, blue: 0.17, alpha: 0.96)
        bg.strokeColor = SKColor(red: 0.60, green: 0.92, blue: 0.40, alpha: 1)
        bg.lineWidth = 1.4
        node.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.name = name
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        node.addChild(label)

        return node
    }

    private func refreshFoodSelector() {
        guard let selector = hudLayer.childNode(withName: "//food_selector") else { return }
        guard !foodSlots.isEmpty else {
            selector.alpha = 0.35
            (selector.childNode(withName: "food_selected_icon") as? SKSpriteNode)?.texture = nil
            (selector.childNode(withName: "food_selected_heal") as? SKLabelNode)?.text = "NO FOOD"
            (selector.childNode(withName: "food_selected_name") as? SKLabelNode)?.text = ""
            (selector.childNode(withName: "food_selected_count") as? SKLabelNode)?.text = ""
            selector.childNode(withName: "food_prev")?.isHidden = true
            selector.childNode(withName: "food_next")?.isHidden = true
            return
        }

        selectedFoodIndex = min(max(0, selectedFoodIndex), foodSlots.count - 1)
        let (foodType, count) = foodSlots[selectedFoodIndex]
        guard let food = FoodDatabase.shared.food(for: foodType) else { return }

        selector.alpha = count > 0 ? 1 : 0.35
        if let icon = selector.childNode(withName: "food_selected_icon") as? SKSpriteNode {
            icon.texture = SKTexture(imageNamed: food.textureName)
            icon.size = food.type == .barleyBread ? CGSize(width: 46, height: 46) : CGSize(width: 34, height: 34)
        }
        (selector.childNode(withName: "food_selected_heal") as? SKLabelNode)?.text = "+\(food.healAmount) HP"
        (selector.childNode(withName: "food_selected_name") as? SKLabelNode)?.text = shortFoodName(food)
        (selector.childNode(withName: "food_selected_count") as? SKLabelNode)?.text = "x\(count)"

        let hasChoices = foodSlots.count > 1
        selector.childNode(withName: "food_prev")?.isHidden = !hasChoices
        selector.childNode(withName: "food_next")?.isHidden = !hasChoices
    }

    private func shortFoodName(_ food: Food) -> String {
        let name = food.localizedName
        switch food.type {
        case .barleyBread:
            return loc.language == .portuguese ? "Pão" : "Bread"
        case .waterSkin:
            return loc.language == .portuguese ? "Água" : "Water"
        default:
            return name.components(separatedBy: " ").first ?? name
        }
    }

    private func setupSkillButtons() {
        // Mesma coluna das comidas, acima delas, para deixar Pedra/Cajado mais à direita.
        let startX: CGFloat = (size.width / 2) - 66
        let foodSpacing: CGFloat = 68
        let foodBottomY: CGFloat = -(size.height / 2) + 52
        let firstSkillY = foodBottomY + foodSpacing + 28
        let skillSpacing: CGFloat = 72
        let cardSize = CGSize(width: 98, height: 70)
        let visual = activeSkillVisuals()
        let character = GameManager.shared.playerData?.activeCharacter ?? .davi
        let rangedCooldown: TimeInterval = character == .josue ? 8.5 : (character == .bigJ ? 9.0 : 10.0)
        let meleeCooldown: TimeInterval = character == .bigJ ? 7.0 : 8.0

        let skills = [
            ("Pedrada", rangedCooldown, visual.rangedLabel, visual.rangedIcon, visual.rangedSize),
            ("Golpe do Cajado", meleeCooldown, visual.meleeLabel, visual.meleeIcon, visual.meleeSize)
        ]

        for (index, skill) in skills.enumerated() {
            let btn = SKNode()
            btn.position = CGPoint(x: startX, y: firstSkillY + CGFloat(index) * skillSpacing)
            btn.name = "skill_\(skill.0)"
            btn.zPosition = 30

            let bg = SKShapeNode(rectOf: cardSize, cornerRadius: 8)
            bg.fillColor = SKColor(red: 0.13, green: 0.10, blue: 0.075, alpha: 0.95)
            bg.strokeColor = SKColor(red: 0.82, green: 0.61, blue: 0.28, alpha: 1)
            bg.lineWidth = 2
            bg.name = btn.name
            btn.addChild(bg)

            let icon = SKSpriteNode(imageNamed: skill.3)
            icon.size = skill.4
            icon.position = CGPoint(x: 0, y: 11)
            icon.name = btn.name
            icon.zPosition = 1
            btn.addChild(icon)

            let cdRing = SKShapeNode()
            cdRing.name = "cd_ring_\(skill.0)"
            cdRing.strokeColor = SKColor(red: 1, green: 0.83, blue: 0.24, alpha: 0.95)
            cdRing.fillColor = .clear
            cdRing.lineWidth = 4
            cdRing.lineCap = .round
            cdRing.position = icon.position
            cdRing.zPosition = 33
            cdRing.isHidden = true
            btn.addChild(cdRing)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = skill.2
            label.fontSize = 13
            label.fontColor = SKColor(red: 1, green: 0.86, blue: 0.45, alpha: 1)
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: -23)
            label.name = btn.name
            btn.addChild(label)

            let cdOverlay = SKShapeNode(rectOf: cardSize, cornerRadius: 8)
            cdOverlay.fillColor = SKColor(white: 0, alpha: 0.7)
            cdOverlay.strokeColor = .clear
            cdOverlay.name = "cd_overlay_\(skill.0)"
            cdOverlay.isHidden = true
            cdOverlay.zPosition = 31
            btn.addChild(cdOverlay)

            let cdLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            cdLabel.fontSize = 16
            cdLabel.fontColor = .white
            cdLabel.verticalAlignmentMode = .center
            cdLabel.name = "cd_label_\(skill.0)"
            cdLabel.zPosition = 32
            btn.addChild(cdLabel)

            hudLayer.addChild(btn)
            skillButtons.append(btn)
            skillCooldowns[skill.0] = skill.1
            skillCooldownViews[skill.0] = SkillCooldownView(
                overlay: cdOverlay,
                label: cdLabel,
                ring: cdRing
            )
        }
    }

    // MARK: - Battle Flow
    private func startBattle() {
        walkToEnemy(index: 0)
    }

    /// Posiciona o inimigo no mundo e move a câmera até ele (cenário rola, Davi fica fixo)
    private func walkToEnemy(index: Int) {
        guard index < enemyQueue.count else {
            victory()
            return
        }
        battleState = .walking

        // Posiciona o inimigo no mundo antes de "andar"
        let enemy = enemyQueue[index]
        let isNewTarget = currentEnemy?.id != enemy.id || currentEnemyIndex != index
        currentEnemy = enemy
        currentEnemyIndex = index
        enemyMaxHP = enemy.hp
        if isNewTarget || enemyCurrentHP <= 0 {
            enemyCurrentHP = enemy.hp
        }

        // Primeiro inimigo aparece a ~1.5 telas de distância, os seguintes mais à frente
        let enemyX = size.width * 1.5 + CGFloat(index) * size.width * 1.0
        enemyNode.isHidden = false

        // Use textureName from enemy if possible, otherwise default lobocinzento
        let texName = enemy.textureName.isEmpty ? "lobocinzento" : (SKTexture(imageNamed: enemy.textureName).size().width > 0 ? enemy.textureName : "lobocinzento")
        let enemyHeight: CGFloat

        if enemy.id == "alpha_wolf" {
            enemyHeight = 100
            enemyNode.color = .darkGray
            enemyNode.colorBlendFactor = 0.3
        } else if enemy.id == "lion_boss" {
            enemyHeight = 160
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "wild_boar" {
            enemyHeight = 96
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "rabid_fox" || enemy.id == "hungry_jackal" {
            enemyHeight = 82
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "hunting_eagle" {
            enemyHeight = 92
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "giant_scorpion" {
            enemyHeight = 92
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "pack_hyena" {
            enemyHeight = 86
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "hyena_pup" {
            enemyHeight = 66
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "bear_cub" {
            enemyHeight = 96
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "brown_bear" {
            enemyHeight = 138
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "venomous_snake" {
            enemyHeight = 62
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "giant_spider" {
            enemyHeight = 78
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "philistine_giant" {
            enemyHeight = 132
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.id == "goliath" {
            enemyHeight = 176
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.textureName.hasPrefix("boss_") {
            enemyHeight = 146
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.textureName.hasPrefix("enemy_philistine_")
                    || enemy.textureName.hasPrefix("enemy_saul_")
                    || enemy.textureName.hasPrefix("enemy_desert_")
                    || enemy.textureName.hasPrefix("enemy_bandit_")
                    || enemy.textureName.hasPrefix("enemy_jebusite_")
                    || enemy.textureName.hasPrefix("enemy_absalom_") {
            enemyHeight = 104
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else if enemy.isBoss {
            enemyHeight = 120
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        } else {
            enemyHeight = 84
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
        }
        setSpriteTexture(enemyNode, textureName: texName, targetHeight: enemyHeight)
        let enemyYOffset: CGFloat
        if enemy.id == "hunting_eagle" {
            enemyYOffset = 42
        } else if enemy.id == "lion_boss" {
            enemyYOffset = -34
        } else {
            enemyYOffset = 0
        }
        enemyBaseY = size.height * 0.28 + enemyNode.size.height / 2 - 8 + enemyYOffset
        enemyNode.position = CGPoint(x: enemyX, y: enemyBaseY)

        // Garantir que o inimigo encare o player (esquerda)
        let mirrorEnemy = shouldMirrorEnemySprite(enemy)
        enemyNode.xScale = mirrorEnemy ? -abs(enemyNode.xScale) : abs(enemyNode.xScale)
        enemyUIContainer.xScale = 1
        enemyNameLabel.xScale = 1
        enemyHPBar.xScale = 1

        // Iniciar animação de andar
        playEnemyAnim("walk", for: enemy)

        setEnemyName(enemy.localizedName)
        enemyUIContainer.isHidden = false
        updateEnemyOverlayPosition()
        updateEnemyHPBar()

        // A câmera precisa mover até que o player (fixo na tela a 38%) fique a ~90px do inimigo
        let halfW = size.width / 2
        let targetCam = enemyX - 100 + halfW - size.width * playerScreenX

        let dist = abs(targetCam - cameraTargetX)
        let duration = TimeInterval(max(0.6, dist / 250))

        // Anima cameraTargetX suavemente usando SKAction no scene
        playAnim("walk")
        startPlayerWalkMotion()
        let startCam = cameraTargetX
        let scrollAction = SKAction.customAction(withDuration: duration) { [weak self] _, elapsed in
            guard let self = self else { return }
            let t = min(1.0, elapsed / CGFloat(duration))
            // Ease-in-out para movimento mais natural
            let eased = t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
            self.cameraTargetX = startCam + (targetCam - startCam) * eased
        }
        let beginFight = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.cameraTargetX = targetCam
            self.spawnEnemy(at: index)
        }
        run(SKAction.sequence([scrollAction, beginFight]), withKey: "walkToEnemy")
    }

    /// Configura o inimigo atual e começa o combate
    private func spawnEnemy(at index: Int) {
        guard index < enemyQueue.count else { victory(); return }

        let enemy = enemyQueue[index]
        if currentEnemy?.id != enemy.id || currentEnemyIndex != index {
            currentEnemy = enemy
            currentEnemyIndex = index
            enemyCurrentHP = enemy.hp
            enemyMaxHP = enemy.hp
        }

        // Atualiza visual
        enemyNode.isHidden = false
        enemyNode.alpha = 1
        enemyUIContainer.isHidden = false
        updateEnemyOverlayPosition()

        // Parar animação de andar e começar idle
        stopPlayerWalkMotion()
        playEnemyAnim("idle", for: enemy)

        // Progress bar — marca como ativo
        for i in 0..<enemyQueue.count {
            if let icon = progressBar.childNode(withName: "progress_\(i)") as? SKShapeNode {
                if i < index {
                    icon.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1) // mortos = verde
                } else if i == index {
                    icon.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1) // atual = laranja
                } else {
                    icon.fillColor = SKColor(white: 0.3, alpha: 0.8) // futuros = cinza
                }
            }
        }

        updateEnemyHPBar()
        // Zera timers para evitar ataque imediato
        playerAttackTimer = 0
        enemyAttackTimer = 0
        lastUpdateTime = 0
        resetEnemyTemporaryEffects()
        battleState = .fighting
        playAnim("idle")
    }

    private func resetEnemyTemporaryEffects() {
        bossPhaseTriggers.removeAll()
        enemyArmorBonus = 0
        enemyArmorBonusTimer = 0
        enemyDamageMultiplier = 1.0
        enemyDamageMultiplierTimer = 0
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        // Câmera sempre segue o player
        updateCamera()
        updateEnemyOverlayPosition()

        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update skill cooldown visuals
        updateSkillCooldowns(currentTime)
        updateEnemyTemporaryEffects(dt)

        guard battleState == .fighting else { return }
        guard let enemy = currentEnemy else { return }
        updateBossPhaseEvents(for: enemy)

        // Player attack (intervalo mínimo de 2s para combate mais pausado)
        playerAttackTimer += dt
        let playerInterval = max(2.0, playerStats.effectiveAttackInterval)
        if playerAttackTimer >= playerInterval {
            playerAttackTimer = 0
            performPlayerAttack(enemy: enemy)
        }

        // Enemy attack (intervalo mínimo de 2s)
        enemyAttackTimer += dt
        if enemyStunnedTimer > 0 {
            enemyStunnedTimer -= dt
        } else {
            let enemyInterval = max(2.0, 1.0 / enemy.attackSpeed)
            if enemyAttackTimer >= enemyInterval {
                enemyAttackTimer = 0
                performEnemyAttack(enemy: enemy)
            }
        }
    }

    private func updateEnemyTemporaryEffects(_ dt: TimeInterval) {
        if enemyArmorBonusTimer > 0 {
            enemyArmorBonusTimer -= dt
            if enemyArmorBonusTimer <= 0 {
                enemyArmorBonus = 0
                showCombatToast(loc.language == .portuguese ? "Defesa inimiga caiu" : "Enemy guard dropped")
            }
        }

        if enemyDamageMultiplierTimer > 0 {
            enemyDamageMultiplierTimer -= dt
            if enemyDamageMultiplierTimer <= 0 {
                enemyDamageMultiplier = 1.0
            }
        }
    }

    private func updateBossPhaseEvents(for enemy: EnemyData) {
        guard enemy.isBoss || enemy.isSubBoss, enemyMaxHP > 0 else { return }
        let hpRatio = Double(max(0, enemyCurrentHP)) / Double(enemyMaxHP)

        switch enemy.id {
        case "lion_boss":
            triggerBossPhase("lion_roar_70", when: hpRatio <= 0.70) {
                bossRoar(textPT: "Rugido do leão", textEN: "Lion roar", playerDelay: 1.2)
            }
            triggerBossPhase("lion_leap_40", when: hpRatio <= 0.40) {
                bossBurstDamage(multiplier: 1.35, textPT: "Salto feroz", textEN: "Fierce leap", stun: 0.8)
            }
        case "brown_bear":
            triggerBossPhase("bear_grab_50", when: hpRatio <= 0.50) {
                bossBurstDamage(multiplier: 1.20, textPT: "Abraço do urso", textEN: "Bear grab", stun: 0.7)
            }
        case "goliath":
            triggerBossPhase("goliath_shield_65", when: hpRatio <= 0.65) {
                enemyArmorBonus = 28
                enemyArmorBonusTimer = 5.0
                showBossPhaseToast(loc.language == .portuguese ? "Escudo de gigante" : "Giant shield")
                pulseEnemy(color: SKColor(red: 0.45, green: 0.75, blue: 1.0, alpha: 1))
            }
            triggerBossPhase("goliath_stomp_40", when: hpRatio <= 0.40) {
                bossBurstDamage(multiplier: 1.55, textPT: "Pisada sísmica", textEN: "Stomping shock", stun: 1.0)
            }
            triggerBossPhase("goliath_fury_25", when: hpRatio <= 0.25) {
                enemyDamageMultiplier = 1.35
                enemyDamageMultiplierTimer = 10.0
                showBossPhaseToast(loc.language == .portuguese ? "Fúria de Golias" : "Goliath's fury")
                pulseEnemy(color: SKColor(red: 1.0, green: 0.28, blue: 0.12, alpha: 1))
            }
        case "saul_mad":
            triggerBossPhase("saul_fury_50", when: hpRatio <= 0.50) {
                enemyDamageMultiplier = 1.30
                enemyDamageMultiplierTimer = 9.0
                bossRoar(textPT: "Fúria de Saul", textEN: "Saul's fury", playerDelay: 0.8)
            }
        default:
            triggerBossPhase("\(enemy.id)_resolve_50", when: hpRatio <= 0.50) {
                enemyDamageMultiplier = 1.18
                enemyDamageMultiplierTimer = 7.0
                showBossPhaseToast(loc.language == .portuguese ? "Chefe enfurecido" : "Boss enraged")
                pulseEnemy(color: SKColor(red: 1.0, green: 0.5, blue: 0.18, alpha: 1))
            }
        }
    }

    private func triggerBossPhase(_ id: String, when condition: Bool, action: () -> Void) {
        guard condition, !bossPhaseTriggers.contains(id) else { return }
        bossPhaseTriggers.insert(id)
        action()
    }

    private func bossRoar(textPT: String, textEN: String, playerDelay: TimeInterval) {
        playerAttackTimer = min(playerAttackTimer, -playerDelay)
        showBossPhaseToast(loc.language == .portuguese ? textPT : textEN)
        pulseEnemy(color: SKColor(red: 1.0, green: 0.78, blue: 0.22, alpha: 1))
        shakeCamera(strength: 10)
    }

    private func bossBurstDamage(multiplier: Double, textPT: String, textEN: String, stun: TimeInterval) {
        let enemy = currentEnemy
        let base = enemy.map { Int.random(in: $0.damageMin...$0.damageMax) } ?? 8
        let damage = playerStats.applyArmor(rawDamage: Int(Double(base) * multiplier))
        playerStats.currentHP -= damage
        playerAttackTimer = min(playerAttackTimer, -stun)
        showBossPhaseToast(loc.language == .portuguese ? textPT : textEN)
        showDamageNumber(damage, isCrit: false, at: playerNode.position, isEnemy: false)
        updatePlayerHPBar()
        pulseEnemy(color: SKColor(red: 1.0, green: 0.25, blue: 0.12, alpha: 1))
        shakeCamera(strength: 12)
        if playerStats.currentHP <= 0 {
            defeat()
        }
    }

    private func showBossPhaseToast(_ text: String) {
        showCombatToast("! \(text)")
    }

    private func pulseEnemy(color: SKColor) {
        enemyNode.run(SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 0.65, duration: 0.08),
            SKAction.scale(to: 1.08, duration: 0.08),
            SKAction.group([
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.18),
                SKAction.scale(to: 1.0, duration: 0.18)
            ])
        ]))
    }

    private func shakeCamera(strength: CGFloat) {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: strength, y: strength * 0.45, duration: 0.03),
            SKAction.moveBy(x: -strength * 2, y: -strength * 0.9, duration: 0.04),
            SKAction.moveBy(x: strength, y: strength * 0.45, duration: 0.03)
        ])
        gameCamera.run(shake)
    }

    private func updateSkillCooldowns(_ currentTime: TimeInterval) {
        guard currentTime - lastCooldownVisualUpdate >= 0.1 else { return }
        lastCooldownVisualUpdate = currentTime

        for (skillName, cooldown) in skillCooldowns {
            let lastUsed = skillLastUsed[skillName] ?? (currentTime - cooldown)
            let elapsed = currentTime - lastUsed
            let remaining = max(0, cooldown - elapsed)

            guard let view = skillCooldownViews[skillName] else { continue }
            if remaining > 0 {
                view.overlay.isHidden = false
                view.label.isHidden = false
                view.ring.isHidden = false
                view.label.text = String(format: "%.1f", remaining)
                view.ring.path = cooldownArcPath(radius: 25, progress: CGFloat(remaining / cooldown))
            } else {
                view.overlay.isHidden = true
                view.label.isHidden = true
                view.ring.isHidden = true
                view.ring.path = nil
            }
        }
    }

    private func cooldownArcPath(radius: CGFloat, progress: CGFloat) -> CGPath {
        let clamped = min(1, max(0, progress))
        let start = -CGFloat.pi / 2
        let end = start + clamped * CGFloat.pi * 2
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        return path
    }

    private func performPlayerAttack(enemy: EnemyData) {
        let rawDamage = playerStats.rollDamage()
        let armoredDamage = applyEnemyArmor(rawDamage, against: enemy)
        let (isCrit, finalDamage) = playerStats.rollCrit(baseDamage: armoredDamage)

        enemyCurrentHP -= finalDamage

        // Life steal
        if playerStats.lifeSteal > 0 {
            let healAmount = Int(Double(finalDamage) * playerStats.lifeSteal)
            playerStats.currentHP = min(playerStats.maxHP, playerStats.currentHP + healAmount)
            updatePlayerHPBar()
        }

        // Show damage number
        showDamageNumber(finalDamage, isCrit: isCrit, at: enemyNode.position, isEnemy: true)

        // Player attack animation
        playAnim("attack", loop: false)
        let attackAnim = SKAction.sequence([
            SKAction.moveBy(x: 15, y: 0, duration: 0.05),
            SKAction.moveBy(x: -15, y: 0, duration: 0.05),
        ])
        playerNode.run(attackAnim)

        // Enemy hit flash
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1),
        ])
        enemyNode.run(flash)

        updateEnemyHPBar()

        if enemyCurrentHP <= 0 {
            enemyDefeated()
        }
    }

    private func applyEnemyArmor(_ rawDamage: Int, against enemy: EnemyData) -> Int {
        let effectiveArmor = max(0, enemy.armor + enemyArmorBonus)
        guard effectiveArmor > 0 else { return rawDamage }
        let reduction = Double(effectiveArmor) / (Double(effectiveArmor) + 100.0)
        return max(1, Int(Double(rawDamage) * (1.0 - reduction)))
    }

    private func performEnemyAttack(enemy: EnemyData) {
        // Animação de ataque
        playEnemyAnim("attack", for: enemy)

        // Pequeno delay para o dano coincidir com o salto
        let wait = SKAction.wait(forDuration: 0.15)
        let dealDamage = SKAction.run { [weak self] in
            guard let self = self else { return }

            // Check dodge
            if self.playerStats.rollDodge(attackType: enemy.attackType) {
                self.showDodgeText(at: self.playerNode.position)
                return
            }

            let rawDamage = Int(Double(Int.random(in: enemy.damageMin...enemy.damageMax)) * self.enemyDamageMultiplier)
            let finalDamage = self.playerStats.applyArmor(rawDamage: rawDamage)

            self.playerStats.currentHP -= finalDamage

            self.showDamageNumber(finalDamage, isCrit: false, at: self.playerNode.position, isEnemy: false)

            // Player hit flash
            let flash = SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.05),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.15),
            ])
            self.playerNode.run(flash)

            self.updatePlayerHPBar()

            if self.playerStats.currentHP <= 0 {
                self.defeat()
            }
        }

        let backToIdle = SKAction.run { [weak self] in
            self?.playEnemyAnim("idle", for: enemy)
        }

        run(SKAction.sequence([wait, dealDamage, SKAction.wait(forDuration: 0.2), backToIdle]))
    }

    private func enemyDefeated() {
        guard let enemy = currentEnemy else { return }

        enemiesKilled += 1

        // Para o combate IMEDIATAMENTE
        removeAction(forKey: "walkToEnemy")
        stopPlayerWalkMotion()
        enemyNode.removeAction(forKey: "enemyAnim")
        currentEnemyAnim = ""
        battleState = .walking
        currentEnemy = nil
        playAnim("idle")  // volta ao idle enquanto morre o inimigo

        // Ouro e XP
        if let boss = bossData, boss.enemy.id == enemy.id {
            goldEarned += boss.goldReward
            xpEarned += boss.xpReward
        } else {
            goldEarned += 10 + enemy.hp / 5
            xpEarned += 5 + enemy.hp / 10
        }
        goldLabel.text = "\(loc.localize("hud.gold")) \(goldEarned)"

        let nextIndex = currentEnemyIndex + 1

        // Animação de morte + próximo inimigo
        let deathFade = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.5, duration: 0.3),
            ]),
            SKAction.run { [weak self] in
                self?.enemyNode.isHidden = true
                self?.enemyUIContainer.isHidden = true
                self?.enemyNode.alpha = 1.0
                self?.enemyNode.setScale(1.0)
            }
        ])
        enemyNode.run(deathFade)

        // Aguarda um momento e anda para o próximo
        let delay = SKAction.wait(forDuration: 0.8)
        let next = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.walkToEnemy(index: nextIndex)
        }
        run(SKAction.sequence([delay, next]))
    }

    // MARK: - Victory / Defeat
    private func victory() {
        battleState = .victory

        let stars: Int
        if !usedFood && Double(playerStats.currentHP) / Double(playerStats.maxHP) > 0.5 {
            stars = 3
        } else if !usedFood {
            stars = 2
        } else {
            stars = 1
        }

        if let battleDef = currentBattleDef, !battleDef.isBossBattle {
            goldEarned += battleDef.goldReward
            xpEarned += battleDef.xpReward
        }
        awardBattleDrops(stars: stars)

        GameManager.shared.completeBattle(
            mapId: mapId, battleId: battleId, stars: stars,
            goldEarned: goldEarned, xpEarned: xpEarned, enemiesKilled: enemiesKilled
        )
        missionCompletions = GameManager.shared.completeReadyMissions()

        // Se não for o boss do mapa, mostra as cartas de bônus antes do overlay final.
        if currentBattleDef?.isBossBattle == false {
            showBonusCards(stars: stars)
        } else {
            // Limpa bônus ao completar o mapa (matar boss)
            GameManager.shared.clearRunBonuses()
            showEndOverlay(victory: true, stars: stars)
        }
    }

    private func awardBattleDrops(stars: Int) {
        guard let battleDef = currentBattleDef else { return }

        var dropIds: [String] = []
        if battleDef.isBossBattle, let boss = bossData, !boss.guaranteedDropId.isEmpty {
            dropIds.append(boss.guaranteedDropId)
        }

        if !battleDef.possibleDropIds.isEmpty {
            let chance = battleDef.isBossBattle
                ? 1.0
                : min(0.65, 0.20 + Double(stars) * 0.10 + Double(battleDef.mapId) * 0.05)
            if Double.random(in: 0...1) <= chance, let itemId = battleDef.possibleDropIds.randomElement() {
                dropIds.append(itemId)
            }
        }

        var seen = Set<String>()
        for itemId in dropIds where seen.insert(itemId).inserted {
            guard let item = EquipmentDatabase.shared.item(withId: itemId) else { continue }
            GameManager.shared.addItemToInventory(itemId)
            droppedItemNames.append(item.localizedName)
        }
    }

    private func showBonusCards(stars: Int) {
        isShowingCards = true

        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height), cornerRadius: 0)
        overlay.fillColor = SKColor(white: 0, alpha: 0.8)
        overlay.strokeColor = .clear
        overlay.zPosition = 200
        overlay.name = "bonus_cards_overlay"
        hudLayer.addChild(overlay)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = loc.localize("battle.blessing.choose")
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        title.position = CGPoint(x: 0, y: 120)
        title.zPosition = 3
        overlay.addChild(title)

        struct BonusCardOption {
            let title: String
            let description: String
            let effect: () -> Void
        }

        let allOptions: [BonusCardOption] = [
            BonusCardOption(title: loc.localize("battle.blessing.strength"), description: loc.localize("battle.blessing.strength.desc"), effect: {
                GameManager.shared.addRunBonus(CharacterStats(damageMultiplier: 0.15))
            }),
            BonusCardOption(title: loc.localize("battle.blessing.faith_shield"), description: loc.localize("battle.blessing.faith_shield.desc"), effect: {
                GameManager.shared.addRunBonus(CharacterStats(armor: 10))
            }),
            BonusCardOption(title: loc.localize("battle.blessing.swift_hands"), description: loc.localize("battle.blessing.swift_hands.desc"), effect: {
                GameManager.shared.addRunBonus(CharacterStats(attackSpeedBonus: 0.15))
            }),
            BonusCardOption(title: loc.localize("battle.blessing.bronze_skin"), description: loc.localize("battle.blessing.bronze_skin.desc"), effect: {
                GameManager.shared.addRunBonus(CharacterStats(maxHP: 20))
            }),
            BonusCardOption(title: loc.localize("battle.blessing.eagle_eye"), description: loc.localize("battle.blessing.eagle_eye.desc"), effect: {
                GameManager.shared.addRunBonus(CharacterStats(critChance: 0.10))
            })
        ]

        let selected = Array(allOptions.shuffled().prefix(3))
        bonusCardEffects = []

        let cardW = min(172, max(146, (size.width - 118) / 3))
        let cardH = min(222, max(196, size.height * 0.56))
        let spacing = min(26, max(14, (size.width - cardW * 3) / 5))

        for (i, card) in selected.enumerated() {
            let cardNode = SKSpriteNode(imageNamed: "pergaminho")
            cardNode.size = CGSize(width: cardW, height: cardH)
            cardNode.position = CGPoint(x: CGFloat(i - 1) * (cardW + spacing), y: -20)
            cardNode.name = "card_\(i)"
            cardNode.zPosition = 1
            overlay.addChild(cardNode)

            let t = SKLabelNode(fontNamed: "AvenirNext-Bold")
            let rawTitle = card.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? loc.localize("battle.blessing.fallback") : card.title
            t.text = wrappedCardTitle(rawTitle)
            t.fontSize = 15
            t.fontColor = SKColor(red: 0.12, green: 0.06, blue: 0.015, alpha: 1)
            t.numberOfLines = 2
            t.lineBreakMode = .byWordWrapping
            t.preferredMaxLayoutWidth = cardW - 42
            t.horizontalAlignmentMode = .center
            t.verticalAlignmentMode = .center
            t.position = CGPoint(x: 0, y: cardH * 0.18)
            t.zPosition = 2
            t.name = cardNode.name
            cardNode.addChild(t)

            let d = SKLabelNode(fontNamed: "AvenirNext-Medium")
            d.text = card.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? loc.localize("battle.blessing.desc_fallback") : card.description
            d.fontSize = 14
            d.fontColor = SKColor(red: 0.24, green: 0.18, blue: 0.12, alpha: 1)
            d.numberOfLines = 2
            d.preferredMaxLayoutWidth = cardW - 44
            d.horizontalAlignmentMode = .center
            d.verticalAlignmentMode = .center
            d.position = CGPoint(x: 0, y: -cardH * 0.15)
            d.zPosition = 2
            d.name = cardNode.name
            cardNode.addChild(d)

            bonusCardEffects.append(card.effect)
        }

        overlay.userData = NSMutableDictionary()
        overlay.userData?["stars"] = stars
    }

    private func wrappedCardTitle(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 12 else { return trimmed }

        let words = trimmed.split(separator: " ").map(String.init)
        guard words.count > 1 else { return trimmed }

        var bestSplit = 1
        var bestScore = Int.max
        for split in 1..<words.count {
            let first = words[..<split].joined(separator: " ")
            let second = words[split...].joined(separator: " ")
            let score = max(first.count, second.count) + abs(first.count - second.count)
            if score < bestScore {
                bestScore = score
                bestSplit = split
            }
        }

        return words[..<bestSplit].joined(separator: " ") + "\n" + words[bestSplit...].joined(separator: " ")
    }

    private func applyBonusCard(index: Int) {
        guard index < bonusCardEffects.count else { return }
        bonusCardEffects[index]()

        if let overlay = hudLayer.childNode(withName: "bonus_cards_overlay") {
            let stars = (overlay.userData?["stars"] as? Int) ?? 1
            overlay.removeFromParent()
            isShowingCards = false
            showEndOverlay(victory: true, stars: stars)
        }
    }

    private func defeat() {
        guard battleState != .defeat && battleState != .victory else { return }
        battleState = .defeat
        awardDefeatRewards()
        showEndOverlay(victory: false, stars: 0)
    }

    private func awardDefeatRewards() {
        guard !didAwardDefeatRewards else { return }
        didAwardDefeatRewards = true

        let consolation = defeatConsolationRewards()
        goldEarned = max(goldEarned, consolation.gold)
        xpEarned = max(xpEarned, consolation.xp)
        goldLabel.text = "\(loc.localize("hud.gold")) \(goldEarned)"

        GameManager.shared.recordBattleDefeat(
            goldEarned: goldEarned,
            xpEarned: xpEarned,
            enemiesKilled: enemiesKilled
        )
        missionCompletions = GameManager.shared.completeReadyMissions()
    }

    private func defeatConsolationRewards() -> (gold: Int, xp: Int) {
        guard let battleDef = currentBattleDef else {
            return (gold: 20, xp: 10)
        }

        let progress = enemyQueue.isEmpty ? 0 : Double(enemiesKilled) / Double(enemyQueue.count)
        let multiplier = 0.22 + min(progress, 0.75) * 0.12
        let minimumGold = 15 + mapId * 5
        let minimumXP = 8 + mapId * 3

        return (
            gold: max(minimumGold, Int(Double(battleDef.goldReward) * multiplier)),
            xp: max(minimumXP, Int(Double(battleDef.xpReward) * multiplier))
        )
    }

    private func showEndOverlay(victory: Bool, stars: Int) {
        let overlaySize = CGSize(
            width: min(size.width * 0.72, 390),
            height: min(size.height * 0.72, max(226, size.height * 0.58))
        )
        let overlay = SKShapeNode(rectOf: overlaySize, cornerRadius: 14)
        overlay.fillColor = SKColor(red: 0.08, green: 0.07, blue: 0.055, alpha: 0.96)
        overlay.strokeColor = victory ?
            SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) :
            SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        overlay.lineWidth = 3
        overlay.position = CGPoint(x: 0, y: 0)   // centro da câmera
        overlay.zPosition = 100
        overlay.name = "overlay"
        hudLayer.addChild(overlay)

        let innerBorder = SKShapeNode(rectOf: CGSize(width: overlaySize.width - 16, height: overlaySize.height - 16), cornerRadius: 10)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = victory ?
            SKColor(red: 1, green: 0.84, blue: 0.32, alpha: 0.28) :
            SKColor(red: 1, green: 0.35, blue: 0.28, alpha: 0.28)
        innerBorder.lineWidth = 1
        overlay.addChild(innerBorder)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = victory ? loc.localize("hud.victory") : loc.localize("hud.defeat")
        titleLabel.fontSize = 30
        titleLabel.fontColor = victory ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        titleLabel.position = CGPoint(x: 0, y: overlaySize.height * 0.28)
        overlay.addChild(titleLabel)

        if victory {
            // Stars
            let starsText = (0..<3).map { $0 < stars ? "★" : "☆" }.joined()
            let starsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            starsLabel.text = starsText
            starsLabel.fontSize = 28
            starsLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
            starsLabel.position = CGPoint(x: 0, y: overlaySize.height * 0.12)
            overlay.addChild(starsLabel)

            // Rewards
            let rewardLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            rewardLabel.text = "+\(goldEarned) \(loc.localize("hud.gold"))  |  +\(xpEarned) XP"
            rewardLabel.fontSize = 16
            rewardLabel.fontColor = .white
            rewardLabel.position = CGPoint(x: 0, y: -overlaySize.height * 0.02)
            overlay.addChild(rewardLabel)

            if !droppedItemNames.isEmpty {
                let itemLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
                itemLabel.text = "Item: \(droppedItemNames.prefix(2).joined(separator: ", "))"
                itemLabel.fontSize = 12
                itemLabel.fontColor = SKColor(red: 0.75, green: 0.95, blue: 1.0, alpha: 1)
                itemLabel.numberOfLines = 2
                itemLabel.preferredMaxLayoutWidth = overlaySize.width - 56
                itemLabel.lineBreakMode = .byWordWrapping
                itemLabel.horizontalAlignmentMode = .center
                itemLabel.verticalAlignmentMode = .center
                itemLabel.position = CGPoint(x: 0, y: -overlaySize.height * 0.15)
                while itemLabel.frame.width > overlaySize.width - 56 && itemLabel.fontSize > 9 {
                    itemLabel.fontSize -= 0.5
                }
                overlay.addChild(itemLabel)
            }
            addMissionRewardLabel(to: overlay, overlaySize: overlaySize, y: -overlaySize.height * 0.25)
        } else {
            let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            hintLabel.text = loc.localize("battle.defeat_hint")
            hintLabel.fontSize = 15
            hintLabel.fontColor = SKColor(white: 0.9, alpha: 1)
            hintLabel.position = CGPoint(x: 0, y: overlaySize.height * 0.08)
            overlay.addChild(hintLabel)

            let rewardLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            rewardLabel.text = "\(loc.localize("battle.partial_reward")) +\(goldEarned) \(loc.localize("hud.gold"))  |  +\(xpEarned) XP"
            rewardLabel.fontSize = 14
            rewardLabel.fontColor = SKColor(red: 1, green: 0.84, blue: 0.32, alpha: 1)
            rewardLabel.position = CGPoint(x: 0, y: -overlaySize.height * 0.07)
            while rewardLabel.frame.width > overlaySize.width - 36 && rewardLabel.fontSize > 10 {
                rewardLabel.fontSize -= 1
            }
            overlay.addChild(rewardLabel)
            addMissionRewardLabel(to: overlay, overlaySize: overlaySize, y: -overlaySize.height * 0.20)
        }

        // Continue button
        let continueBtn = SKNode()
        continueBtn.position = CGPoint(x: 0, y: -overlaySize.height / 2 + 38)
        continueBtn.name = "btn_continue_overlay"

        let btnShadow = SKShapeNode(rectOf: CGSize(width: 172, height: 46), cornerRadius: 9)
        btnShadow.fillColor = SKColor(white: 0, alpha: 0.35)
        btnShadow.strokeColor = .clear
        btnShadow.position = CGPoint(x: 0, y: -3)
        btnShadow.name = "btn_continue_overlay"
        continueBtn.addChild(btnShadow)

        let btnBg = SKShapeNode(rectOf: CGSize(width: 172, height: 46), cornerRadius: 9)
        btnBg.fillColor = victory ?
            SKColor(red: 0.48, green: 0.33, blue: 0.14, alpha: 1) :
            SKColor(red: 0.42, green: 0.13, blue: 0.10, alpha: 1)
        btnBg.strokeColor = victory ?
            SKColor(red: 0.92, green: 0.68, blue: 0.25, alpha: 1) :
            SKColor(red: 1.0, green: 0.42, blue: 0.32, alpha: 1)
        btnBg.lineWidth = 2
        btnBg.name = "btn_continue_overlay"
        continueBtn.addChild(btnBg)

        let btnLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        btnLabel.text = victory ? loc.localize("general.ok") : loc.localize("general.continue")
        btnLabel.fontSize = 16
        btnLabel.fontColor = .white
        btnLabel.verticalAlignmentMode = .center
        btnLabel.name = "btn_continue_overlay"
        continueBtn.addChild(btnLabel)

        overlay.addChild(continueBtn)
    }

    private func addMissionRewardLabel(to overlay: SKNode, overlaySize: CGSize, y: CGFloat) {
        guard let mission = missionCompletions.first else { return }

        let prefix = loc.language == .portuguese ? "Missão" : "Mission"
        let suffix = missionCompletions.count > 1 ? " +\(missionCompletions.count - 1)" : ""

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = "\(prefix): \(mission.title)  \(mission.rewardText)\(suffix)"
        label.fontSize = 11.5
        label.fontColor = SKColor(red: 0.70, green: 1.0, blue: 0.64, alpha: 1)
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = overlaySize.width - 52
        label.lineBreakMode = .byWordWrapping
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: y)
        while label.frame.width > overlaySize.width - 52 && label.fontSize > 9 {
            label.fontSize -= 0.5
        }
        overlay.addChild(label)
    }

    // MARK: - UI Updates
    private func updatePlayerHPBar() {
        let ratio = max(0, CGFloat(playerStats.currentHP) / CGFloat(playerStats.maxHP))
        playerHPFill.xScale = ratio

        let color: SKColor
        if ratio > 0.6 { color = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1) }
        else if ratio > 0.3 { color = SKColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1) }
        else { color = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1) }
        playerHPFill.fillColor = color

        if let hpText = playerHPBar.childNode(withName: "hp_text") as? SKLabelNode {
            hpText.text = "\(max(0, playerStats.currentHP)) / \(playerStats.maxHP)"
        }
    }

    private func setEnemyName(_ name: String) {
        enemyNameLabel.text = name
        enemyNameLabel.fontSize = 14

        let maxWidth: CGFloat = 142
        while enemyNameLabel.frame.width > maxWidth && enemyNameLabel.fontSize > 9 {
            enemyNameLabel.fontSize -= 0.5
        }
    }

    private func updateEnemyOverlayPosition() {
        guard enemyUIContainer != nil,
              enemyNode != nil,
              !enemyNode.isHidden else { return }

        let enemyUIYOffset: CGFloat
        if currentEnemy?.id == "lion_boss" {
            enemyUIYOffset = -20
        } else if currentEnemy?.id == "hunting_eagle" {
            enemyUIYOffset = 8
        } else {
            enemyUIYOffset = 0
        }

        enemyUIContainer.position = CGPoint(
            x: enemyNode.position.x,
            y: enemyNode.position.y + enemyNode.size.height / 2 + 30 + enemyUIYOffset
        )
        enemyUIContainer.zRotation = 0
        enemyUIContainer.setScale(1)
    }

    private func updateEnemyHPBar() {
        guard enemyMaxHP > 0 else { return }
        let ratio = max(0, CGFloat(enemyCurrentHP) / CGFloat(enemyMaxHP))
        enemyHPFill.xScale = ratio

        let fillWidth: CGFloat = 100
        enemyHPFill.position.x = -(fillWidth * (1 - ratio)) / 2

        if ratio > 0.6 {
            enemyHPFill.fillColor = SKColor(red: 0.28, green: 0.78, blue: 0.26, alpha: 1)
        } else if ratio > 0.3 {
            enemyHPFill.fillColor = SKColor(red: 0.95, green: 0.72, blue: 0.16, alpha: 1)
        } else {
            enemyHPFill.fillColor = SKColor(red: 0.9, green: 0.18, blue: 0.16, alpha: 1)
        }

        enemyHPText.text = "\(max(0, enemyCurrentHP)) / \(enemyMaxHP) HP"
    }

    private func showDamageNumber(_ damage: Int, isCrit: Bool, at position: CGPoint, isEnemy: Bool) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy") // Fonte mais pesada
        label.text = isCrit ? "\(damage)!" : "\(damage)"
        label.fontSize = isCrit ? 28 : 18

        // Cores mais vibrantes e contornos
        if isEnemy {
            label.fontColor = isCrit ? SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1) : .white
        } else {
            label.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1)
        }

        let offsetX = CGFloat.random(in: -30...30)
        label.position = CGPoint(x: position.x + offsetX, y: position.y + 50)
        label.zPosition = 100

        // Adiciona contorno (stroke) usando um SKShapeNode ou sombra projetada
        let outline = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        outline.text = label.text
        outline.fontSize = label.fontSize
        outline.fontColor = .black
        outline.position = CGPoint(x: 2, y: -2) // Sombra projetada
        outline.zPosition = -1
        outline.alpha = 0.7
        label.addChild(outline)

        addChild(label)

        // Animação de impacto
        label.setScale(0.1)
        let pop = SKAction.scale(to: isCrit ? 1.4 : 1.1, duration: 0.08)
        let wait = SKAction.wait(forDuration: 0.05)
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.1)
        let rise = SKAction.moveBy(x: offsetX * 0.3, y: 60, duration: 0.7)
        let fade = SKAction.fadeOut(withDuration: 0.7)

        label.run(SKAction.sequence([
            pop, wait, scaleBack,
            SKAction.group([rise, fade]),
            SKAction.removeFromParent()
        ]))

        createHitParticles(at: position, isCrit: isCrit, isEnemy: isEnemy)

        // Screen Shake em críticos
        if isCrit {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 8, y: 5, duration: 0.03),
                SKAction.moveBy(x: -16, y: -10, duration: 0.03),
                SKAction.moveBy(x: 8, y: 5, duration: 0.03)
            ])
            gameCamera.run(shake)
        }
    }

    private func showHealNumber(_ amount: Int, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "+\(amount)"
        label.fontSize = 18
        label.fontColor = SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 1)

        let offsetX = CGFloat.random(in: -15...15)
        label.position = CGPoint(x: position.x + offsetX, y: position.y + 50)
        label.zPosition = 100

        addChild(label)

        label.setScale(0.1)
        let pop = SKAction.scale(to: 1.0, duration: 0.1)
        let rise = SKAction.moveBy(x: 0, y: 60, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([rise, fade])

        label.run(SKAction.sequence([pop, group, SKAction.removeFromParent()]))
    }

    private func createHitParticles(at position: CGPoint, isCrit: Bool, isEnemy: Bool) {
        let node = SKShapeNode(circleOfRadius: isCrit ? 6 : 3)
        node.fillColor = isEnemy ? (isCrit ? .yellow : .white) : .red
        node.strokeColor = .clear
        node.position = position
        node.zPosition = 90
        addChild(node)

        let duration: TimeInterval = 0.3
        let angle = CGFloat.random(in: 0...(.pi * 2))
        let distance = CGFloat.random(in: 20...50)
        let dx = cos(angle) * distance
        let dy = sin(angle) * distance

        let move = SKAction.moveBy(x: dx, y: dy, duration: duration)
        move.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: duration)
        let group = SKAction.group([move, fade])

        node.run(SKAction.sequence([group, SKAction.removeFromParent()]))

        if isCrit {
            // Cria mais algumas partículas se for crítico
            for _ in 0..<3 {
                let spark = SKShapeNode(circleOfRadius: 2)
                spark.fillColor = .orange
                spark.strokeColor = .clear
                spark.position = position
                spark.zPosition = 90
                addChild(spark)
                let a = CGFloat.random(in: 0...(.pi * 2))
                let d = CGFloat.random(in: 30...70)
                let m = SKAction.moveBy(x: cos(a)*d, y: sin(a)*d, duration: 0.4)
                m.timingMode = .easeOut
                spark.run(SKAction.sequence([SKAction.group([m, SKAction.fadeOut(withDuration: 0.4)]), SKAction.removeFromParent()]))
            }
        }
    }

    private func showDodgeText(at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "DODGE"
        label.fontSize = 12
        label.fontColor = SKColor(red: 0.5, green: 0.8, blue: 1, alpha: 1)
        label.position = CGPoint(x: position.x, y: position.y + 40)
        label.zPosition = 50
        addChild(label)

        let animation = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 30, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5),
            ]),
            SKAction.removeFromParent()
        ])
        label.run(animation)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            guard let name = node.name else { continue }

            if name == "btn_continue_overlay" {
                let overworldScene = OverworldScene(size: self.size)
                overworldScene.scaleMode = .resizeFill
                self.view?.presentScene(overworldScene, transition: SKTransition.fade(withDuration: 0.3))
                return
            }

            if name == "btn_story_start" {
                hudLayer.childNode(withName: "story_intro")?.removeFromParent()
                startBattle()
                return
            }

            if name == "food_prev" {
                cycleFoodSelection(direction: -1)
                return
            }

            if name == "food_next" {
                cycleFoodSelection(direction: 1)
                return
            }

            if name == "food_use" || name == "food_selector" || name.hasPrefix("food_selected") {
                useFood(at: selectedFoodIndex)
                return
            }

            if name.hasPrefix("skill_") {
                let skillName = name.replacingOccurrences(of: "skill_", with: "")
                useSkill(named: skillName)
                return
            }

            if name.hasPrefix("card_") {
                let parts = name.split(separator: "_")
                if let index = Int(parts.last ?? "") {
                    applyBonusCard(index: index)
                }
                return
            }
        }
    }

    private func useFood(at index: Int) {
        guard index < foodSlots.count else { return }
        guard battleState == .fighting else { return }

        let (foodType, count) = foodSlots[index]
        guard count > 0 else { return }

        guard let food = GameManager.shared.useFood(foodType) else { return }

        usedFood = true
        playerStats.currentHP = min(playerStats.maxHP, playerStats.currentHP + food.healAmount)
        updatePlayerHPBar()
        showHealNumber(food.healAmount, at: playerNode.position)

        let newCount = count - 1
        if newCount <= 0 {
            foodSlots.remove(at: index)
            if selectedFoodIndex >= foodSlots.count {
                selectedFoodIndex = max(0, foodSlots.count - 1)
            }
        } else {
            foodSlots[index] = (foodType, newCount)
        }
        refreshFoodSelector()
    }

    private func cycleFoodSelection(direction: Int) {
        guard foodSlots.count > 1 else { return }
        selectedFoodIndex = (selectedFoodIndex + direction + foodSlots.count) % foodSlots.count
        refreshFoodSelector()
    }

    private func useSkill(named name: String) {
        let canUseRangedStone = name == "Pedrada" && (battleState == .fighting || battleState == .walking)
        guard (battleState == .fighting || canUseRangedStone), let enemy = currentEnemy else { return }
        guard name == "Pedrada" || battleState == .fighting else { return }
        let visual = activeSkillVisuals()

        let now = lastUpdateTime
        let cooldown = skillCooldowns[name] ?? 0
        let lastUsed = skillLastUsed[name] ?? (now - cooldown)

        if now - lastUsed < cooldown {
            showCombatToast(String(format: "%.1fs", cooldown - (now - lastUsed)))
            return
        }

        skillLastUsed[name] = now

        if name == "Golpe do Cajado" {
            let damage = applyEnemyArmor(Int(Double(playerStats.rollDamage()) * meleeSkillMultiplier()), against: enemy)
            enemyCurrentHP -= damage
            enemyStunnedTimer = meleeStunDuration()
            showDamageNumber(damage, isCrit: false, at: enemyNode.position, isEnemy: true)
            showCombatToast("\(skillToast(for: name)) • \(loc.language == .portuguese ? "Atordoado" : "Stunned")")

            // Visual effect: simple lunge
            playAnim("attack", loop: false)
            playerNode.run(SKAction.sequence([
                SKAction.moveBy(x: 20, y: 0, duration: 0.1),
                SKAction.moveBy(x: -20, y: 0, duration: 0.1)
            ]))
            showMeleeSkillEffect(visual)

            // Stun effect on enemy
            enemyNode.run(SKAction.sequence([
                SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.1),
                SKAction.wait(forDuration: 0.8),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
            ]))
        } else if name == "Pedrada" {
            let damage = applyEnemyArmor(Int(Double(playerStats.rollDamage()) * rangedSkillMultiplier()), against: enemy)
            enemyCurrentHP -= damage
            var stunned = false
            if Double.random(in: 0...1) < rangedStunChance() {
                stunned = true
                enemyStunnedTimer = 1.0 + (hasEquippedItem(where: { $0.hasPrefix("gloves_") }) ? 0.25 : 0)
                enemyNode.run(SKAction.sequence([
                    SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.1),
                    SKAction.wait(forDuration: 0.8),
                    SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                ]))
            }
            showDamageNumber(damage, isCrit: false, at: enemyNode.position, isEnemy: true)
            showCombatToast(stunned
                ? "\(skillToast(for: name)) • \(loc.language == .portuguese ? "Atordoado" : "Stunned")"
                : skillToast(for: name))

            // Visual effect: projectile
            let projectile = SKSpriteNode(imageNamed: visual.rangedProjectile)
            projectile.size = visual.rangedSize
            projectile.position = CGPoint(x: playerNode.position.x + 18, y: playerNode.position.y + 22)
            projectile.zPosition = 12
            addChild(projectile)
            let target = CGPoint(x: enemyNode.position.x, y: enemyNode.position.y + enemyNode.size.height * 0.22)
            let distance = hypot(target.x - projectile.position.x, target.y - projectile.position.y)
            let duration = TimeInterval(min(0.65, max(0.22, distance / 900)))
            projectile.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: target, duration: duration),
                    SKAction.rotate(byAngle: CGFloat.pi * 2.2, duration: duration),
                    SKAction.sequence([
                        SKAction.scale(to: 1.35, duration: duration * 0.5),
                        SKAction.scale(to: 0.85, duration: duration * 0.5)
                    ])
                ]),
                SKAction.removeFromParent()
            ]))
        }

        updateEnemyHPBar()
        if enemyCurrentHP <= 0 {
            enemyDefeated()
        }
    }

    private func showMeleeSkillEffect(_ visual: SkillVisuals) {
        let effect = SKSpriteNode(imageNamed: visual.meleeEffect)
        effect.size = visual.meleeSize
        effect.position = CGPoint(x: playerNode.position.x + 28, y: playerNode.position.y + 34)
        effect.zPosition = 13
        addChild(effect)

        let target = CGPoint(
            x: min(enemyNode.position.x - enemyNode.size.width * 0.22, playerNode.position.x + 96),
            y: enemyNode.position.y + enemyNode.size.height * 0.16
        )

        effect.run(SKAction.sequence([
            SKAction.group([
                SKAction.move(to: target, duration: 0.18),
                SKAction.rotate(byAngle: -0.65, duration: 0.18),
                SKAction.scale(to: 1.12, duration: 0.18)
            ]),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.14),
                SKAction.scale(to: 0.85, duration: 0.14)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    private func equippedItemIds() -> Set<String> {
        guard let values = GameManager.shared.playerData?.equippedItems.values else { return [] }
        return Set(values)
    }

    private func hasEquippedItem(where matches: (String) -> Bool) -> Bool {
        equippedItemIds().contains(where: matches)
    }

    private func rangedSkillMultiplier() -> Double {
        var multiplier = 2.0
        if hasEquippedItem(where: { $0 == "weapon_sling_01" }) { multiplier += 0.25 }
        if hasEquippedItem(where: { $0 == "weapon_sling_02" }) { multiplier += 0.45 }
        if hasEquippedItem(where: { $0.hasPrefix("gloves_") }) { multiplier += 0.15 }

        let character = GameManager.shared.playerData?.activeCharacter ?? .davi
        if character == .josue { multiplier += 0.10 }
        if character == .bigJ { multiplier += 0.05 }
        return multiplier
    }

    private func rangedStunChance() -> Double {
        var chance = 0.20
        if hasEquippedItem(where: { $0 == "weapon_sling_01" }) { chance += 0.04 }
        if hasEquippedItem(where: { $0 == "weapon_sling_02" }) { chance += 0.08 }
        if hasEquippedItem(where: { $0 == "gloves_02" || $0 == "gloves_03" }) { chance += 0.06 }
        return min(0.42, chance)
    }

    private func meleeSkillMultiplier() -> Double {
        var multiplier = 1.5
        if hasEquippedItem(where: { $0 == "weapon_staff_01" || $0 == "twohand_staff_01" }) { multiplier += 0.18 }
        if hasEquippedItem(where: { $0 == "weapon_staff_02" || $0 == "twohand_staff_02" }) { multiplier += 0.32 }

        let character = GameManager.shared.playerData?.activeCharacter ?? .davi
        if character == .bigJ { multiplier += 0.12 }
        return multiplier
    }

    private func meleeStunDuration() -> TimeInterval {
        var duration: TimeInterval = 1.0
        if hasEquippedItem(where: { $0 == "weapon_staff_01" || $0 == "twohand_staff_01" }) { duration += 0.25 }
        if hasEquippedItem(where: { $0 == "weapon_staff_02" || $0 == "twohand_staff_02" }) { duration += 0.45 }
        return duration
    }

    private func skillToast(for name: String) -> String {
        let character = GameManager.shared.playerData?.activeCharacter ?? .davi
        if name == "Pedrada" {
            switch character {
            case .josue:
                return loc.language == .portuguese ? "Arremesso de basquete" : "Basketball throw"
            case .bigJ:
                return loc.language == .portuguese ? "Chute certeiro" : "Clean kick"
            default:
                return loc.language == .portuguese ? "Pedrada certeira" : "Clean stone hit"
            }
        }

        switch character {
        case .josue:
            return loc.language == .portuguese ? "Livro FTP" : "FTP book"
        case .bigJ:
            return loc.language == .portuguese ? "Guarda-sol" : "Beach umbrella"
        default:
            return loc.language == .portuguese ? "Golpe do cajado" : "Staff strike"
        }
    }

    private func showCombatToast(_ text: String) {
        hudLayer.childNode(withName: "combat_toast")?.removeFromParent()

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = "combat_toast"
        label.text = text
        label.fontSize = 14
        label.fontColor = SKColor(red: 1, green: 0.82, blue: 0.3, alpha: 1)
        label.position = CGPoint(x: 0, y: -(size.height / 2) + 92)
        label.zPosition = 80
        hudLayer.addChild(label)

        label.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 12, duration: 0.2),
            SKAction.wait(forDuration: 0.35),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
}
