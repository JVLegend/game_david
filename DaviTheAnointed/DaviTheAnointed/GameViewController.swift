import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let sceneSize = CGSize(width: 896, height: 414) // iPhone landscape proportions

        // Check if language was already selected
        LocalizationManager.shared.loadSavedLanguage()

        let scene: SKScene
        if LocalizationManager.shared.hasSelectedLanguage {
            // If already has language, go to login
            scene = LoginScene(size: sceneSize)
        } else {
            // First time: show language selection
            scene = LanguageSelectionScene(size: sceneSize)
        }

        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
