import SpriteKit

class RankingScene: SKScene {
    private enum RankingMetric: String, CaseIterable {
        case power
        case stars
        case enemies
        case gold

        func title(language: GameLanguage) -> String {
            switch self {
            case .power:
                return language == .portuguese ? "Poder" : "Power"
            case .stars:
                return language == .portuguese ? "Estrelas" : "Stars"
            case .enemies:
                return language == .portuguese ? "Inimigos" : "Enemies"
            case .gold:
                return language == .portuguese ? "Ouro" : "Gold"
            }
        }

        func score(for entry: RankingEntry) -> Int {
            switch self {
            case .power:
                return entry.powerScore
            case .stars:
                return entry.totalStars
            case .enemies:
                return entry.totalEnemiesKilled
            case .gold:
                return entry.totalGoldEarned
            }
        }
    }
    
    private let loc = LocalizationManager.shared
    private var rankingData: [RankingEntry] = []
    private var loadingLabel: SKLabelNode?
    private var selectedMetric: RankingMetric = .power
    private var rankingRowsContainer = SKNode()
    private var scrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0
    private var lastTouchY: CGFloat?
    private var didDragRanking = false
    private let rowSpacing: CGFloat = 30
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        setupUI()
        loadData()
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
        
        // Back button
        let backBtn = createButton(text: "← \(loc.localize("general.back"))", position: CGPoint(x: safeL + 60, y: size.height - 40), name: "btn_back")
        addChild(backBtn)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "RANKING"
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 30)
        addChild(title)
        
        let tabY = size.height - 70
        let tabWidth: CGFloat = 86
        let totalWidth = tabWidth * CGFloat(RankingMetric.allCases.count) + 8 * CGFloat(RankingMetric.allCases.count - 1)
        for (index, metric) in RankingMetric.allCases.enumerated() {
            let x = size.width / 2 - totalWidth / 2 + tabWidth / 2 + CGFloat(index) * (tabWidth + 8)
            let tab = createMetricTab(metric: metric, position: CGPoint(x: x, y: tabY), width: tabWidth)
            addChild(tab)
        }

        // Headers
        let headerY = size.height - 110
        let posHeader = SKLabelNode(fontNamed: "AvenirNext-Bold")
        posHeader.text = "#"
        posHeader.fontSize = 12
        posHeader.fontColor = .gray
        posHeader.position = CGPoint(x: size.width * 0.2, y: headerY)
        addChild(posHeader)
        
        let nameHeader = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameHeader.text = "PLAYER"
        nameHeader.fontSize = 12
        nameHeader.fontColor = .gray
        nameHeader.horizontalAlignmentMode = .left
        nameHeader.position = CGPoint(x: size.width * 0.3, y: headerY)
        addChild(nameHeader)
        
        let scoreHeader = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreHeader.name = "score_header"
        scoreHeader.text = selectedMetric.title(language: loc.language).uppercased()
        scoreHeader.fontSize = 12
        scoreHeader.fontColor = .gray
        scoreHeader.horizontalAlignmentMode = .right
        scoreHeader.position = CGPoint(x: size.width * 0.8, y: headerY)
        addChild(scoreHeader)

        rankingRowsContainer = SKNode()
        rankingRowsContainer.name = "ranking_rows_container"
        rankingRowsContainer.zPosition = 2
        addChild(rankingRowsContainer)
        
        // Loading indicator
        let loading = SKLabelNode(fontNamed: "AvenirNext-Medium")
        loading.text = "Loading rankings..."
        loading.fontSize = 14
        loading.fontColor = .white
        loading.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(loading)
        self.loadingLabel = loading
    }
    
    private func loadData() {
        RankingManager.shared.fetchTopPlayers { [weak self] results in
            guard let self = self else { return }
            self.rankingData = results
            self.loadingLabel?.removeFromParent()
            self.displayRanking()
        }
    }
    
    private func displayRanking() {
        rankingRowsContainer.removeAllChildren()
        scrollOffset = 0
        maxScrollOffset = 0
        rankingRowsContainer.position.y = 0

        children.filter { $0.name == "empty_ranking" || $0.name == "score_header" || $0.name == "ranking_scroll_hint" }.forEach { node in
            if node.name == "score_header", let label = node as? SKLabelNode {
                label.text = selectedMetric.title(language: loc.language).uppercased()
            } else if node.name != "score_header" {
                node.removeFromParent()
            }
        }

        if rankingData.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            emptyLabel.name = "empty_ranking"
            emptyLabel.text = "Ranking indisponível. Entre com Google ou Apple para sincronizar sua pontuação."
            emptyLabel.fontSize = 13
            emptyLabel.fontColor = SKColor(white: 1, alpha: 0.85)
            emptyLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
            emptyLabel.preferredMaxLayoutWidth = size.width * 0.72
            emptyLabel.numberOfLines = 0
            addChild(emptyLabel)
            return
        }

        let sortedData = rankingData.sorted { selectedMetric.score(for: $0) > selectedMetric.score(for: $1) }
        let startY = size.height - 140
        let bottomY = max(34, (view?.safeAreaInsets.bottom ?? 0) + 26)
        let visibleHeight = max(80, startY - bottomY)
        let contentHeight = CGFloat(sortedData.count) * rowSpacing
        maxScrollOffset = max(0, contentHeight - visibleHeight + 8)
        
        for (index, entry) in sortedData.enumerated() {
            let y = startY - CGFloat(index) * rowSpacing
            let row = SKNode()
            row.name = "ranking_row"
            row.userData = ["baseY": y]
            rankingRowsContainer.addChild(row)
            
            // Background row
            let rowBg = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: 27), cornerRadius: 5)
            rowBg.position = CGPoint(x: size.width / 2, y: y + 4)
            rowBg.fillColor = index % 2 == 0 ? SKColor(white: 1, alpha: 0.05) : .clear
            rowBg.strokeColor = .clear
            row.addChild(rowBg)
            
            // Position
            let posLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            posLbl.text = "\(index + 1)"
            posLbl.fontSize = 13
            posLbl.fontColor = index < 3 ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .white
            posLbl.position = CGPoint(x: size.width * 0.2, y: y)
            row.addChild(posLbl)
            
            // Name (Level)
            let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Medium")
            nameLbl.text = "\(entry.displayName) (Lvl \(entry.level))"
            nameLbl.fontSize = 13
            nameLbl.fontColor = .white
            nameLbl.horizontalAlignmentMode = .left
            nameLbl.position = CGPoint(x: size.width * 0.3, y: y)
            row.addChild(nameLbl)
            
            // Score
            let scoreLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            scoreLbl.text = "\(selectedMetric.score(for: entry))"
            scoreLbl.fontSize = 13
            scoreLbl.fontColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
            scoreLbl.horizontalAlignmentMode = .right
            scoreLbl.position = CGPoint(x: size.width * 0.8, y: y)
            row.addChild(scoreLbl)

            let subLbl = SKLabelNode(fontNamed: "AvenirNext-Medium")
            subLbl.text = "Map \(entry.highestMapCompleted + 1) • ★ \(entry.totalStars)"
            subLbl.fontSize = 9
            subLbl.fontColor = SKColor(white: 1, alpha: 0.55)
            subLbl.horizontalAlignmentMode = .left
            subLbl.position = CGPoint(x: size.width * 0.3, y: y - 10)
            row.addChild(subLbl)
        }

        if maxScrollOffset > 0 {
            let hint = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            hint.name = "ranking_scroll_hint"
            hint.text = loc.language == .portuguese ? "Arraste para ver mais" : "Drag to see more"
            hint.fontSize = 10
            hint.fontColor = SKColor(white: 1, alpha: 0.55)
            hint.position = CGPoint(x: size.width / 2, y: bottomY - 12)
            addChild(hint)
        }

        updateRankingScroll()
    }

    private func updateRankingScroll() {
        scrollOffset = min(max(0, scrollOffset), maxScrollOffset)
        rankingRowsContainer.position.y = scrollOffset

        let topY = size.height - 124
        let bottomY = max(30, (view?.safeAreaInsets.bottom ?? 0) + 20)
        for row in rankingRowsContainer.children where row.name == "ranking_row" {
            let baseY = row.userData?["baseY"] as? CGFloat ?? row.position.y
            let visibleY = baseY + scrollOffset
            row.isHidden = visibleY > topY || visibleY < bottomY
        }
    }

    private func createMetricTab(metric: RankingMetric, position: CGPoint, width: CGFloat) -> SKNode {
        let node = SKNode()
        node.name = "tab_metric_\(metric.rawValue)"
        node.position = position

        let selected = metric == selectedMetric
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: 28), cornerRadius: 6)
        bg.name = node.name
        bg.fillColor = selected ? SKColor(red: 0.36, green: 0.24, blue: 0.08, alpha: 0.96) : SKColor(white: 0.04, alpha: 0.76)
        bg.strokeColor = selected ? SKColor(red: 1, green: 0.78, blue: 0.22, alpha: 1) : SKColor(red: 0.55, green: 0.42, blue: 0.20, alpha: 0.8)
        bg.lineWidth = 1.5
        node.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = node.name
        label.text = metric.title(language: loc.language)
        label.fontSize = 11
        label.fontColor = selected ? SKColor(red: 1, green: 0.86, blue: 0.34, alpha: 1) : .white
        label.verticalAlignmentMode = .center
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
        lastTouchY = location.y
        didDragRanking = false
        let node = atPoint(location)
        
        let name = node.name ?? node.parent?.name
        if name == "btn_back" {
            let scene = MainMenuScene(size: self.size)
            scene.scaleMode = .resizeFill
            self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
        } else if let name, name.hasPrefix("tab_metric_") {
            let raw = String(name.dropFirst("tab_metric_".count))
            if let metric = RankingMetric(rawValue: raw) {
                selectedMetric = metric
                setupUI()
                loadingLabel?.removeFromParent()
                displayRanking()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              maxScrollOffset > 0,
              let lastTouchY else { return }

        let location = touch.location(in: self)
        let deltaY = location.y - lastTouchY
        if abs(deltaY) > 1 {
            didDragRanking = true
        }
        scrollOffset -= deltaY
        self.lastTouchY = location.y
        updateRankingScroll()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchY = nil
        didDragRanking = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchY = nil
        didDragRanking = false
    }
}
