import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var hasLoadedInitialScene = false

    override func loadView() {
        view = SKView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !hasLoadedInitialScene {
            setupInitialScene()
            hasLoadedInitialScene = true
        } else if let skView = view as? SKView, let scene = skView.scene {
            let sceneSize = normalizedLandscapeSize(from: skView.bounds.size)
            if scene.size != sceneSize {
                scene.size = sceneSize
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enforceLandscapeGeometry()
    }

    private func setupInitialScene() {
        guard let skView = view as? SKView else {
            // Se não for SKView, cria uma (caso tenha sido adicionada manualmente)
            if let existingSkView = view.subviews.first(where: { $0 is SKView }) as? SKView {
                presentIn(existingSkView)
            }
            return
        }
        presentIn(skView)
    }

    private func presentIn(_ skView: SKView) {
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = .black
        let launchArgs = ProcessInfo.processInfo.arguments

        let sceneSize = normalizedLandscapeSize(from: skView.bounds.size)

        LocalizationManager.shared.loadSavedLanguage()

        let scene: SKScene
        #if DEBUG
        if launchArgs.contains("--debug-menu") {
            prepareDebugPlayer(language: .english)
            scene = MainMenuScene(size: sceneSize)
        } else if launchArgs.contains("--debug-inventory") {
            prepareDebugPlayer(language: .english)
            scene = InventoryScene(size: sceneSize)
        } else if launchArgs.contains("--debug-shop") {
            prepareDebugPlayer(language: .english)
            scene = ShopScene(size: sceneSize)
        } else if launchArgs.contains("--debug-settings") {
            prepareDebugPlayer(language: .english)
            scene = SettingsScene(size: sceneSize)
        } else if launchArgs.contains("--debug-battle") {
            prepareDebugPlayer(language: .english)
            let battleScene = BattleScene(size: sceneSize)
            battleScene.mapId = debugArgumentInt(named: "--debug-map", in: launchArgs) ?? 1
            battleScene.battleId = debugArgumentInt(named: "--debug-battle-id", in: launchArgs) ?? 1
            scene = battleScene
        } else {
            scene = makeInitialScene(size: sceneSize, skView: skView)
        }
        #else
        scene = makeInitialScene(size: sceneSize, skView: skView)
        #endif

        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    private func normalizedLandscapeSize(from viewSize: CGSize) -> CGSize {
        let width = max(viewSize.width, viewSize.height, 1)
        let height = max(min(viewSize.width, viewSize.height), 1)
        return CGSize(width: width, height: height)
    }

    private func makeInitialScene(size sceneSize: CGSize, skView: SKView) -> SKScene {
        if let cloudUser = AuthManager.shared.currentUser {
            GameManager.shared.initializePlayerFromAuth(
                userId: cloudUser.userId,
                displayName: cloudUser.displayName,
                language: LocalizationManager.shared.language
            ) { [weak skView] in
                let menuScene = MainMenuScene(size: sceneSize)
                menuScene.scaleMode = .resizeFill
                skView?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.3))
            }
            return makeLoadingScene(size: sceneSize, message: "Carregando conta...")
        } else {
            return LoginScene(size: sceneSize)
        }
    }

        #if DEBUG
    private func prepareDebugPlayer(language: GameLanguage) {
        let launchArgs = ProcessInfo.processInfo.arguments
        let debugLanguage = debugArgumentString(named: "--debug-language", in: launchArgs)
            .flatMap(GameLanguage.init(rawValue:))
        let selectedLanguage = debugLanguage ?? (LocalizationManager.shared.hasSelectedLanguage ? LocalizationManager.shared.language : language)
        LocalizationManager.shared.setLanguage(selectedLanguage)
        GameManager.shared.initializePlayer(userId: "dev_player_123", displayName: "Davi", language: selectedLanguage)
        GameManager.shared.playerData?.language = selectedLanguage
        if let debugCharacter = debugArgumentString(named: "--debug-character", in: launchArgs)
            .flatMap(PlayableCharacter.init(rawValue:)) {
            if GameManager.shared.playerData?.unlockedCharacters.contains(debugCharacter) == false {
                GameManager.shared.playerData?.unlockedCharacters.append(debugCharacter)
            }
            GameManager.shared.playerData?.activeCharacter = debugCharacter
        }
        GameManager.shared.save()
    }

    private func debugArgumentString(named name: String, in args: [String]) -> String? {
        guard let index = args.firstIndex(of: name), args.indices.contains(index + 1) else { return nil }
        return args[index + 1]
    }

    private func debugArgumentInt(named name: String, in args: [String]) -> Int? {
        guard let index = args.firstIndex(of: name), args.indices.contains(index + 1) else { return nil }
        return Int(args[index + 1])
    }
        #endif

    private func makeLoadingScene(size: CGSize, message: String) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = SKColor(red: 0.05, green: 0.04, blue: 0.03, alpha: 1)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = message
        label.fontSize = 18
        label.fontColor = SKColor(red: 1, green: 0.86, blue: 0.45, alpha: 1)
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.verticalAlignmentMode = .center
        scene.addChild(label)

        return scene
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func enforceLandscapeGeometry() {
        setNeedsUpdateOfSupportedInterfaceOrientations()
        guard #available(iOS 16.0, *),
              let windowScene = view.window?.windowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
            #if DEBUG
            print("[UI] Unable to force landscape geometry: \(error.localizedDescription)")
            #endif
        }
    }
}
