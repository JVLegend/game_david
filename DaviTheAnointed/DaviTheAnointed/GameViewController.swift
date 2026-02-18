import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create SKView programmatically to avoid storyboard SKView dependency
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let sceneSize = CGSize(width: 896, height: 414) // iPhone landscape proportions
        print("[APP] viewDidLoad - sceneSize: \(sceneSize)")

        // Check if language was already selected
        LocalizationManager.shared.loadSavedLanguage()
        print("[APP] hasSelectedLanguage: \(LocalizationManager.shared.hasSelectedLanguage)")

        let scene: SKScene
        if LocalizationManager.shared.hasSelectedLanguage {
            print("[APP] Loading LoginScene")
            scene = LoginScene(size: sceneSize)
        } else {
            print("[APP] Loading LanguageSelectionScene")
            scene = LanguageSelectionScene(size: sceneSize)
        }

        scene.scaleMode = .aspectFill
        print("[APP] Presenting scene: \(type(of: scene))")
        skView.presentScene(scene)
        print("[APP] Scene presented")
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
