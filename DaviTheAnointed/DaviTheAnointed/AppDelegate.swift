import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO: Configure Firebase
        // FirebaseApp.configure()
        print("[APP] didFinishLaunchingWithOptions")
        return true
    }

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        GameManager.shared.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        GameManager.shared.save()
    }
}
