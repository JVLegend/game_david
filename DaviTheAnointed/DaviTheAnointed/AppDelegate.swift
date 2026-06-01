import UIKit

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #else
        print("[AUTH] Firebase SDK not installed; using local persistence.")
        #endif
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        AuthManager.shared.handleOpenURL(url)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        GameManager.shared.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        GameManager.shared.save()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .landscape
    }
}
