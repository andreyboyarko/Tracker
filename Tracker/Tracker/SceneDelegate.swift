
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // твой общий Core Data стек
    let core = CoreDataStack(modelName: "TrackerModel")

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let hasSeen = UserDefaults.standard.bool(forKey: Constants.hasSeenOnboardingKey)

        if hasSeen {
            window.rootViewController = TabBarController(coreDataStack: core)
        } else {
            window.rootViewController = OnboardingPageController()
        }

        self.window = window
        window.makeKeyAndVisible()
    }
}
