import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[MOCK] Dev mode active ✓")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        GameManager.shared.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        GameManager.shared.save()
    }
}
