import SpriteKit

class RankingScene: SKScene {
    
    private let loc = LocalizationManager.shared
    private var rankingData: [RankingEntry] = []
    private var loadingLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1)
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        removeAllChildren()
        
        let safeL: CGFloat = 60
        
        // Back button
        let backBtn = createButton(text: "← \(loc.localize("general.back"))", position: CGPoint(x: safeL + 50, y: size.height - 22), name: "btn_back")
        addChild(backBtn)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "RANKING"
        title.fontSize = 24
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 30)
        addChild(title)
        
        // Headers
        let headerY = size.height - 70
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
        scoreHeader.text = "POWER SCORE"
        scoreHeader.fontSize = 12
        scoreHeader.fontColor = .gray
        scoreHeader.horizontalAlignmentMode = .right
        scoreHeader.position = CGPoint(x: size.width * 0.8, y: headerY)
        addChild(scoreHeader)
        
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
        let startY = size.height - 100
        let spacing: CGFloat = 25
        
        for (index, entry) in rankingData.enumerated() {
            let y = startY - CGFloat(index) * spacing
            
            // Background row
            let rowBg = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 22), cornerRadius: 4)
            rowBg.position = CGPoint(x: size.width / 2, y: y + 4)
            rowBg.fillColor = index % 2 == 0 ? SKColor(white: 1, alpha: 0.05) : .clear
            rowBg.strokeColor = .clear
            addChild(rowBg)
            
            // Position
            let posLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            posLbl.text = "\(index + 1)"
            posLbl.fontSize = 13
            posLbl.fontColor = index < 3 ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) : .white
            posLbl.position = CGPoint(x: size.width * 0.2, y: y)
            addChild(posLbl)
            
            // Name (Level)
            let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Medium")
            nameLbl.text = "\(entry.displayName) (Lvl \(entry.level))"
            nameLbl.fontSize = 13
            nameLbl.fontColor = .white
            nameLbl.horizontalAlignmentMode = .left
            nameLbl.position = CGPoint(x: size.width * 0.3, y: y)
            addChild(nameLbl)
            
            // Score
            let scoreLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            scoreLbl.text = "\(entry.powerScore)"
            scoreLbl.fontSize = 13
            scoreLbl.fontColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
            scoreLbl.horizontalAlignmentMode = .right
            scoreLbl.position = CGPoint(x: size.width * 0.8, y: y)
            addChild(scoreLbl)
        }
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
        let node = atPoint(location)
        
        if node.name == "btn_back" || node.parent?.name == "btn_back" {
            let scene = MainMenuScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
        }
    }
}
