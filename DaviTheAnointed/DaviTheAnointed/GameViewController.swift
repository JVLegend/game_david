import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var hasLoadedInitialScene = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !hasLoadedInitialScene {
            setupInitialScene()
            hasLoadedInitialScene = true
        }
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

        let baseHeight: CGFloat = 414
        let aspectRatio = skView.bounds.width / skView.bounds.height
        let sceneSize = CGSize(width: baseHeight * aspectRatio, height: baseHeight)

        LocalizationManager.shared.loadSavedLanguage()

        let scene: SKScene
        if LocalizationManager.shared.hasSelectedLanguage {
            scene = LoginScene(size: sceneSize)
        } else {
            scene = LanguageSelectionScene(size: sceneSize)
        }

        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create SKView programmatically to avoid storyboard SKView dependency
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
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

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
