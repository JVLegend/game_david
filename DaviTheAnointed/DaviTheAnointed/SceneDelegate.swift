import UIKit
import SpriteKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let gameVC = GameViewController()
        
        window.rootViewController = gameVC
        window.makeKeyAndVisible()
        self.window = window

        if #available(iOS 16.0, *) {
            gameVC.setNeedsUpdateOfSupportedInterfaceOrientations()
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
                #if DEBUG
                print("[UI] Unable to force landscape geometry: \(error.localizedDescription)")
                #endif
            }
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = AuthManager.shared.handleOpenURL(url)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        GameManager.shared.save()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        GameManager.shared.save()
    }
}
