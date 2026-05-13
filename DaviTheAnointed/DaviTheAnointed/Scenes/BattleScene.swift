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

    // Stats
    private var playerStats: CharacterStats!
    private var enemyCurrentHP: Int = 0
    private var enemyMaxHP: Int = 0
    private var currentEnemy: EnemyData?
    private var goldEarned: Int = 0
    private var xpEarned: Int = 0
    private var enemiesKilled: Int = 0
    private var usedFood: Bool = false
    private var foodSlots: [(FoodType, Int)] = []

    // Timers
    private var playerAttackTimer: TimeInterval = 0
    private var enemyAttackTimer: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0

    // Nodes
    private var playerNode: SKSpriteNode!
    private var enemyNode: SKSpriteNode!
    private var playerHPBar: SKShapeNode!
    private var playerHPFill: SKShapeNode!
    private var enemyHPBar: SKShapeNode!
    private var enemyHPFill: SKShapeNode!
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
    private var enemyStunnedTimer: TimeInterval = 0

    // Bonus Cards
    private var bonusCardEffects: [() -> Void] = []
    private var isShowingCards: Bool = false

    // MARK: - Sprite Animation
    private let playerHeight: CGFloat = 90
    private var playerIdleFrames: [SKTexture] = []
    private var playerWalkFrames: [SKTexture] = []
    private var playerAttackFrames: [SKTexture] = []
    private var currentPlayerAnim: String = ""  // "idle", "walk", "attack"

    private var wolfWalkFrames: [SKTexture] = []
    private var currentEnemyAnim: String = ""

    private func loadPlayerTextures() {
        let character = GameManager.shared.playerData?.activeCharacter ?? .davi
        // davi_jovem usa cajado; davi_funda usa funda — ambos têm mesma estrutura de frames
        let prefix: String
        switch character {
        case .davi:
            prefix = "davi_jovem"
        default:
            prefix = "davi_jovem"  // fallback até ter outros sprites
        }

        // Row 0 (00-05): idle
        playerIdleFrames = (0...5).map { SKTexture(imageNamed: "\(prefix)_\(String(format: "%02d", $0))") }
        // Row 1 (06-11): walk
        playerWalkFrames = (6...11).map { SKTexture(imageNamed: "\(prefix)_\(String(format: "%02d", $0))") }
        // Row 2 (12-17): attack
        playerAttackFrames = (12...17).map { SKTexture(imageNamed: "\(prefix)_\(String(format: "%02d", $0))") }

        // Configura texture inicial
        if let first = playerIdleFrames.first {
            playerNode.texture = first
            playerNode.size = CGSize(width: first.size().width / first.size().height * playerHeight,
                                    height: playerHeight)
        }
    }

    private func loadEnemyTextures() {
        wolfWalkFrames = (0...3).map { SKTexture(imageNamed: "wolf_walk_\($0)") }
    }

    private func playEnemyAnim(_ anim: String, for enemy: EnemyData, loop: Bool = true) {
        guard anim != currentEnemyAnim else { return }
        currentEnemyAnim = anim

        enemyNode.removeAction(forKey: "enemyAnim")

        // Somente o lobo tem frames por enquanto
        if enemy.textureName == "lobocinzento" || enemy.textureName == "wolf" {
            switch anim {
            case "walk":
                let animAction = SKAction.animate(with: wolfWalkFrames, timePerFrame: 0.15)
                let action = loop ? SKAction.repeatForever(animAction) : animAction
                enemyNode.run(action, withKey: "enemyAnim")
                return
            default: break
            }
        }

        // Animações genéricas (respiro/idle) para outros ou se não houver frames
        switch anim {
        case "idle":
            let breathUp = SKAction.moveBy(x: 0, y: 5, duration: 1.2)
            breathUp.timingMode = .easeInEaseOut
            let breathSequence = SKAction.sequence([breathUp, breathUp.reversed()])
            enemyNode.run(SKAction.repeatForever(breathSequence), withKey: "enemyAnim")
        case "attack":
            // Salto de ataque
            let jump = SKAction.sequence([
                SKAction.moveBy(x: -30, y: 20, duration: 0.15),
                SKAction.moveBy(x: 30, y: -20, duration: 0.15)
            ])
            enemyNode.run(jump, withKey: "enemyAnim")
            currentEnemyAnim = "" // Reset para voltar ao idle depois
        default:
            break
        }
    }

    private func playAnim(_ anim: String, loop: Bool = true) {
        guard anim != currentPlayerAnim else { return }
        currentPlayerAnim = anim

        playerNode.removeAction(forKey: "playerAnim")

        let frames: [SKTexture]
        let fps: TimeInterval
        switch anim {
        case "walk":
            frames = playerWalkFrames
            fps = 0.10
        case "attack":
            frames = playerAttackFrames
            fps = 0.08
        default:  // "idle"
            frames = playerIdleFrames
            fps = 0.12
        }
        guard !frames.isEmpty else { return }

        let animAction = SKAction.animate(with: frames, timePerFrame: fps)
        let action = loop ? SKAction.repeatForever(animAction) : animAction
        playerNode.run(action, withKey: "playerAnim")
    }

    private let loc = LocalizationManager.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        loadEnemyTextures()
        setupCamera()
        setupBattle()
        setupHUD()
        startBattle()
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

        // Calcula largura do mundo baseado na quantidade de inimigos
        let lastEnemyX = size.width * 1.5 + CGFloat(max(0, enemyQueue.count - 1)) * size.width * 1.0
        worldWidth = max(size.width * 3, lastEnemyX + size.width)

        // Load food from player inventory
        if let player = GameManager.shared.playerData {
            foodSlots = Array(player.foodInventory.prefix(3))
        }
    }

    private func setupHUD() {
        // === MUNDO (rola com câmera) ===

        // Background do mundo — mais largo que a tela, usando textura gerada
        let bgTexture = SKTexture(imageNamed: "background_forest")
        let bgNode = SKSpriteNode(texture: bgTexture, size: CGSize(width: worldWidth, height: size.height))
        bgNode.position = CGPoint(x: worldWidth / 2, y: size.height / 2)
        bgNode.zPosition = -10
        addChild(bgNode)

        // Chão que se estende pelo mundo inteiro, usando textura gerada
        let groundTexture = SKTexture(imageNamed: "ground_grass")
        let groundHeight = size.height * 0.28
        let ground = SKSpriteNode(texture: groundTexture, size: CGSize(width: worldWidth, height: groundHeight))
        ground.position = CGPoint(x: worldWidth / 2, y: groundHeight / 2)
        ground.zPosition = -5
        addChild(ground)

        // Player — posição X controlada pela câmera (fica fixo na tela)
        playerNode = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: playerHeight))
        let initialCamX = size.width / 2
        playerNode.position = CGPoint(x: initialCamX - size.width / 2 + size.width * playerScreenX,
                                       y: groundHeight + playerHeight / 2 - 10)
        playerNode.zPosition = 5
        addChild(playerNode)

        // Carrega texturas e inicia animação idle
        loadPlayerTextures()
        playAnim("idle")

        // Enemy — está mais à frente no mundo
        enemyNode = SKSpriteNode(imageNamed: "wolf")
        enemyNode.size = CGSize(width: 80, height: 80)
        enemyNode.position = CGPoint(x: worldWidth * 0.6, y: groundHeight + 30)
        enemyNode.zPosition = 5
        enemyNode.isHidden = true
        addChild(enemyNode)

        enemyNameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        enemyNameLabel.fontSize = 14
        enemyNameLabel.fontColor = .white
        enemyNameLabel.position = CGPoint(x: 0, y: 50)
        enemyNode.addChild(enemyNameLabel)

        // HP bar do inimigo — fica no mundo, sobre o inimigo
        enemyHPBar = SKShapeNode(rectOf: CGSize(width: 80, height: 8), cornerRadius: 2)
        enemyHPBar.fillColor = SKColor(white: 0.2, alpha: 0.8)
        enemyHPBar.strokeColor = SKColor(white: 0.5, alpha: 1)
        enemyHPBar.position = CGPoint(x: 0, y: 65)
        enemyHPBar.zPosition = 20
        enemyNode.addChild(enemyHPBar)

        enemyHPFill = SKShapeNode(rectOf: CGSize(width: 76, height: 4), cornerRadius: 1)
        enemyHPFill.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        enemyHPFill.strokeColor = .clear
        enemyHPFill.zPosition = 21
        enemyHPBar.addChild(enemyHPFill)

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

        // Gold (topo esquerdo da HUD)
        goldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goldLabel.text = "0"
        goldLabel.fontSize = 18
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: -(size.width / 2) + 50, y: (size.height / 2) - 40)
        goldLabel.zPosition = 30
        hudLayer.addChild(goldLabel)

        let goldIcon = SKSpriteNode(imageNamed: "icon_gold")
        goldIcon.size = CGSize(width: 24, height: 24)
        goldIcon.position = CGPoint(x: -(size.width / 2) + 30, y: (size.height / 2) - 34)
        goldIcon.zPosition = 30
        hudLayer.addChild(goldIcon)

        // Stats panel e progress bar também no HUD
        setupStatsPanel()
        setupProgressBar()
        setupFoodButtons()
        setupSkillButtons()
    }

    private func setupStatsPanel() {
        statsPanel = SKNode()
        // posição relativa à câmera: canto inferior esquerdo
        statsPanel.position = CGPoint(x: -(size.width / 2) + 10, y: -(size.height / 2) + 10)
        statsPanel.zPosition = 30
        hudLayer.addChild(statsPanel)

        let panelBg = SKShapeNode(rectOf: CGSize(width: 140, height: 120), cornerRadius: 6)
        panelBg.fillColor = SKColor(white: 0.05, alpha: 0.9)
        panelBg.strokeColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
        panelBg.position = CGPoint(x: 70, y: 60)
        statsPanel.addChild(panelBg)

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
            label.text = isHeader ? line.0 : "  \(line.0): \(line.1)"
            label.fontSize = isHeader ? 11 : 10
            label.fontColor = isHeader ? SKColor(red: 1, green: 0.75, blue: 0.3, alpha: 1) : .white
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: 10, y: 108 - CGFloat(i) * 15)
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
        // canto direito da HUD, posição relativa à câmera
        let startX: CGFloat = (size.width / 2) - 40
        let startY: CGFloat = 60 // Relative to center Y

        for (index, foodSlot) in foodSlots.enumerated() {
            guard let food = FoodDatabase.shared.food(for: foodSlot.0) else { continue }

            let btn = SKNode()
            btn.position = CGPoint(x: startX, y: startY - CGFloat(index) * 60)
            btn.name = "food_\(index)"
            btn.zPosition = 30

            let bg = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 8)
            bg.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.15, alpha: 0.95)
            bg.strokeColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1)
            bg.lineWidth = 2
            bg.name = btn.name
            btn.addChild(bg)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "+\(food.healAmount)"
            label.fontSize = 12
            label.fontColor = SKColor(red: 0.5, green: 1, blue: 0.5, alpha: 1)
            label.verticalAlignmentMode = .center
            label.name = btn.name
            btn.addChild(label)

            let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            countLabel.text = "x\(foodSlot.1)"
            countLabel.fontSize = 11
            countLabel.fontColor = .white
            countLabel.position = CGPoint(x: 18, y: -18)
            countLabel.name = "food_count_\(index)"
            btn.addChild(countLabel)

            hudLayer.addChild(btn)
            foodButtons.append(btn)
        }
    }

    private func setupSkillButtons() {
        // canto direito da HUD, posição relativa à câmera, à esquerda das comidas
        let startX: CGFloat = (size.width / 2) - 140
        let startY: CGFloat = -(size.height / 2) + 60

        let skills = [
            ("Golpe do Cajado", 8.0, "C"),
            ("Pedrada", 10.0, "P")
        ]

        for (index, skill) in skills.enumerated() {
            let btn = SKNode()
            btn.position = CGPoint(x: startX - CGFloat(index) * 75, y: startY)
            btn.name = "skill_\(skill.0)"
            btn.zPosition = 30

            let bg = SKSpriteNode(imageNamed: "botao_pedra")
            bg.size = CGSize(width: 60, height: 60)
            bg.name = btn.name
            btn.addChild(bg)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = skill.2
            label.fontSize = 24
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.name = btn.name
            btn.addChild(label)

            let cdOverlay = SKShapeNode(circleOfRadius: 26)
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
        // Primeiro inimigo aparece a ~1.5 telas de distância, os seguintes mais à frente
        let enemyX = size.width * 1.5 + CGFloat(index) * size.width * 1.0
        enemyNode.position = CGPoint(x: enemyX, y: size.height * 0.28 + 30)
        enemyNode.isHidden = false
        
        // Use textureName from enemy if possible, otherwise default lobocinzento
        let texName = enemy.textureName.isEmpty ? "lobocinzento" : (SKTexture(imageNamed: enemy.textureName).size().width > 0 ? enemy.textureName : "lobocinzento")
        enemyNode.texture = SKTexture(imageNamed: texName)
        
        if enemy.id == "alpha_wolf" {
            enemyNode.size = CGSize(width: 100, height: 100) // Maior que o comum
            enemyNode.color = .darkGray
            enemyNode.colorBlendFactor = 0.3
        } else if enemy.isBoss {
            enemyNode.color = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1)
            enemyNode.colorBlendFactor = 0.3
            enemyNode.size = CGSize(width: 120, height: 120)
        } else {
            enemyNode.color = .white
            enemyNode.colorBlendFactor = 0
            enemyNode.size = CGSize(width: 80, height: 80)
        }

        // Garantir que o inimigo encare o player (esquerda)
        enemyNode.xScale = -abs(enemyNode.xScale)
        
        // Iniciar animação de andar
        playEnemyAnim("walk", for: enemy)

        enemyNameLabel.text = enemy.localizedName
        enemyNameLabel.position = CGPoint(x: 0, y: enemyNode.size.height / 2 + 10)
        enemyHPBar.position = CGPoint(x: 0, y: enemyNode.size.height / 2 + 25)

        // A câmera precisa mover até que o player (fixo na tela a 38%) fique a ~90px do inimigo
        let halfW = size.width / 2
        let targetCam = enemyX - 100 + halfW - size.width * playerScreenX

        let dist = abs(targetCam - cameraTargetX)
        let duration = TimeInterval(max(0.6, dist / 250))

        // Anima cameraTargetX suavemente usando SKAction no scene
        playAnim("walk")
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
        currentEnemy = enemy
        currentEnemyIndex = index
        enemyCurrentHP = enemy.hp
        enemyMaxHP = enemy.hp

        // Atualiza visual
        enemyNode.isHidden = false
        enemyNode.alpha = 1
        
        // Parar animação de andar e começar idle
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
        battleState = .fighting
        playAnim("attack")
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        // Câmera sempre segue o player
        updateCamera()

        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update skill cooldown visuals
        updateSkillCooldowns(currentTime)

        guard battleState == .fighting else { return }
        guard let enemy = currentEnemy else { return }

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

    private func updateSkillCooldowns(_ currentTime: TimeInterval) {
        for (skillName, cooldown) in skillCooldowns {
            let lastUsed = skillLastUsed[skillName] ?? (currentTime - cooldown)
            let elapsed = currentTime - lastUsed
            let remaining = max(0, cooldown - elapsed)

            if let overlay = hudLayer.childNode(withName: "//cd_overlay_\(skillName)") as? SKShapeNode,
               let label = hudLayer.childNode(withName: "//cd_label_\(skillName)") as? SKLabelNode {
                if remaining > 0 {
                    overlay.isHidden = false
                    label.isHidden = false
                    label.text = String(format: "%.1f", remaining)
                } else {
                    overlay.isHidden = true
                    label.isHidden = true
                }
            }
        }
    }

    private func performPlayerAttack(enemy: EnemyData) {
        let rawDamage = playerStats.rollDamage()
        let (isCrit, finalDamage) = playerStats.rollCrit(baseDamage: rawDamage)

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

            let rawDamage = Int.random(in: enemy.damageMin...enemy.damageMax)
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
        goldLabel.text = "\(goldEarned) 🪙"

        let nextIndex = currentEnemyIndex + 1

        // Animação de morte + próximo inimigo
        let deathFade = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.5, duration: 0.3),
            ]),
            SKAction.run { [weak self] in
                self?.enemyNode.isHidden = true
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

        GameManager.shared.completeBattle(
            mapId: mapId, battleId: battleId, stars: stars,
            goldEarned: goldEarned, xpEarned: xpEarned, enemiesKilled: enemiesKilled
        )

        // Se não for boss, mostra as cartas de bônus antes do overlay final
        if bossData == nil {
            showBonusCards(stars: stars)
        } else {
            // Limpa bônus ao completar o mapa (matar boss)
            GameManager.shared.clearRunBonuses()
            showEndOverlay(victory: true, stars: stars)
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
        title.text = "ESCOLHA UMA BÊNÇÃO"
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        title.position = CGPoint(x: 0, y: 120)
        overlay.addChild(title)

        struct BonusCardOption {
            let title: String
            let description: String
            let effect: () -> Void
        }

        let allOptions: [BonusCardOption] = [
            BonusCardOption(title: "Benção de Força", description: "+15% Dano", effect: {
                GameManager.shared.addRunBonus(CharacterStats(damageMultiplier: 0.15))
            }),
            BonusCardOption(title: "Escudo da Fé", description: "+10 Armadura", effect: {
                GameManager.shared.addRunBonus(CharacterStats(armor: 10))
            }),
            BonusCardOption(title: "Mãos Ágeis", description: "+15% Vel. Ataque", effect: {
                GameManager.shared.addRunBonus(CharacterStats(attackSpeedBonus: 0.15))
            }),
            BonusCardOption(title: "Pele de Bronze", description: "+20 HP Máx", effect: {
                GameManager.shared.addRunBonus(CharacterStats(maxHP: 20))
            }),
            BonusCardOption(title: "Olho de Águia", description: "+10% Crítico", effect: {
                GameManager.shared.addRunBonus(CharacterStats(critChance: 0.10))
            })
        ]

        let selected = allOptions.shuffled().prefix(3)
        bonusCardEffects = []

        let cardW: CGFloat = 150
        let cardH: CGFloat = 200
        let spacing: CGFloat = 20

        for (i, card) in selected.enumerated() {
            let cardNode = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH), cornerRadius: 12)
            cardNode.fillColor = SKColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1)
            cardNode.strokeColor = .white
            cardNode.lineWidth = 2
            cardNode.position = CGPoint(x: CGFloat(i - 1) * (cardW + spacing), y: -20)
            cardNode.name = "card_\(i)"
            overlay.addChild(cardNode)

            let t = SKLabelNode(fontNamed: "AvenirNext-Bold")
            t.text = card.title
            t.fontSize = 14
            t.position = CGPoint(x: 0, y: 60)
            t.name = cardNode.name
            cardNode.addChild(t)

            let d = SKLabelNode(fontNamed: "AvenirNext-Regular")
            d.text = card.description
            d.fontSize = 12
            d.numberOfLines = 0
            d.position = CGPoint(x: 0, y: 0)
            d.name = cardNode.name
            cardNode.addChild(d)

            bonusCardEffects.append(card.effect)
        }
        
        overlay.userData = NSMutableDictionary()
        overlay.userData?["stars"] = stars
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
        battleState = .defeat
        showEndOverlay(victory: false, stars: 0)
    }

    private func showEndOverlay(victory: Bool, stars: Int) {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.6, height: size.height * 0.5), cornerRadius: 12)
        overlay.fillColor = SKColor(white: 0.1, alpha: 0.95)
        overlay.strokeColor = victory ?
            SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) :
            SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        overlay.lineWidth = 3
        overlay.position = CGPoint(x: 0, y: 0)   // centro da câmera
        overlay.zPosition = 100
        overlay.name = "overlay"
        hudLayer.addChild(overlay)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = victory ? loc.localize("hud.victory") : loc.localize("hud.defeat")
        titleLabel.fontSize = 32
        titleLabel.fontColor = victory ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        titleLabel.position = CGPoint(x: 0, y: 60)
        overlay.addChild(titleLabel)

        if victory {
            // Stars
            let starsText = (0..<3).map { $0 < stars ? "★" : "☆" }.joined()
            let starsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            starsLabel.text = starsText
            starsLabel.fontSize = 28
            starsLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
            starsLabel.position = CGPoint(x: 0, y: 20)
            overlay.addChild(starsLabel)

            // Rewards
            let rewardLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            rewardLabel.text = "+\(goldEarned) \(loc.localize("hud.gold"))  |  +\(xpEarned) XP"
            rewardLabel.fontSize = 16
            rewardLabel.fontColor = .white
            rewardLabel.position = CGPoint(x: 0, y: -15)
            overlay.addChild(rewardLabel)
        }

        // Continue button
        let continueBtn = SKNode()
        continueBtn.position = CGPoint(x: 0, y: -60)
        continueBtn.name = "btn_continue_overlay"

        let btnBg = SKShapeNode(rectOf: CGSize(width: 160, height: 40), cornerRadius: 8)
        btnBg.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1)
        btnBg.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.25, alpha: 1)
        btnBg.name = "btn_continue_overlay"
        continueBtn.addChild(btnBg)

        let btnLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        btnLabel.text = loc.localize("general.ok")
        btnLabel.fontSize = 16
        btnLabel.fontColor = .white
        btnLabel.verticalAlignmentMode = .center
        btnLabel.name = "btn_continue_overlay"
        continueBtn.addChild(btnLabel)

        overlay.addChild(continueBtn)
    }

    // MARK: - UI Updates
    private func updatePlayerHPBar() {
        let ratio = max(0, CGFloat(playerStats.currentHP) / CGFloat(playerStats.maxHP))
        let fullWidth: CGFloat = 196
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

    private func updateEnemyHPBar() {
        guard enemyMaxHP > 0 else { return }
        let ratio = max(0, CGFloat(enemyCurrentHP) / CGFloat(enemyMaxHP))
        enemyHPFill.xScale = ratio
    }

    private func showDamageNumber(_ damage: Int, isCrit: Bool, at position: CGPoint, isEnemy: Bool) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = isCrit ? "\(damage)!" : "\(damage)"
        label.fontSize = isCrit ? 20 : 14
        label.fontColor = isEnemy ?
            (isCrit ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .white) :
            SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        label.position = CGPoint(x: position.x + CGFloat.random(in: -20...20),
                                  y: position.y + 40)
        label.zPosition = 50

        addChild(label)

        let animation = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6),
            ]),
            SKAction.removeFromParent()
        ])
        label.run(animation)
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
                overworldScene.scaleMode = .aspectFill
                self.view?.presentScene(overworldScene, transition: SKTransition.fade(withDuration: 0.3))
                return
            }

            if name.hasPrefix("food_"), !name.contains("count") {
                let parts = name.split(separator: "_")
                if let index = Int(parts.last ?? "") {
                    useFood(at: index)
                }
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

        foodSlots[index] = (foodType, count - 1)
        if let countLabel = self.childNode(withName: "//food_count_\(index)") as? SKLabelNode {
            countLabel.text = "x\(count - 1)"
        }
        if count - 1 <= 0 {
            foodButtons[index].alpha = 0.3
        }

        // Heal visual
        let healLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healLabel.text = "+\(food.healAmount) HP"
        healLabel.fontSize = 14
        healLabel.fontColor = SKColor(red: 0.3, green: 1, blue: 0.3, alpha: 1)
        healLabel.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + 50)
        healLabel.zPosition = 50
        addChild(healLabel)

        let anim = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 30, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6),
            ]),
            SKAction.removeFromParent()
        ])
        healLabel.run(anim)
    }

    private func useSkill(named name: String) {
        guard battleState == .fighting, let enemy = currentEnemy else { return }

        let now = lastUpdateTime
        let cooldown = skillCooldowns[name] ?? 0
        let lastUsed = skillLastUsed[name] ?? (now - cooldown)

        if now - lastUsed < cooldown { return }

        skillLastUsed[name] = now

        if name == "Golpe do Cajado" {
            let damage = Int(Double(playerStats.rollDamage()) * 1.5)
            enemyCurrentHP -= damage
            enemyStunnedTimer = 1.0
            showDamageNumber(damage, isCrit: false, at: enemyNode.position, isEnemy: true)

            // Visual effect: simple lunge
            playerNode.run(SKAction.sequence([
                SKAction.moveBy(x: 20, y: 0, duration: 0.1),
                SKAction.moveBy(x: -20, y: 0, duration: 0.1)
            ]))

            // Stun effect on enemy
            enemyNode.run(SKAction.sequence([
                SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.1),
                SKAction.wait(forDuration: 0.8),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
            ]))
        } else if name == "Pedrada" {
            let damage = Int(Double(playerStats.rollDamage()) * 2.0)
            enemyCurrentHP -= damage
            if Double.random(in: 0...1) < 0.2 {
                enemyStunnedTimer = 1.0
                enemyNode.run(SKAction.sequence([
                    SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.1),
                    SKAction.wait(forDuration: 0.8),
                    SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                ]))
            }
            showDamageNumber(damage, isCrit: false, at: enemyNode.position, isEnemy: true)

            // Visual effect: projectile
            let stone = SKShapeNode(circleOfRadius: 4)
            stone.fillColor = .gray
            stone.strokeColor = .black
            stone.position = playerNode.position
            stone.zPosition = 10
            addChild(stone)
            stone.run(SKAction.sequence([
                SKAction.move(to: enemyNode.position, duration: 0.2),
                SKAction.removeFromParent()
            ]))
        }

        updateEnemyHPBar()
        if enemyCurrentHP <= 0 {
            enemyDefeated()
        }
    }
}
