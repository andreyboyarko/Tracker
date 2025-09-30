import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // один экземпляр CoreDataStack на всё приложение
    let core = CoreDataStack(modelName: "TrackerModel")

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let tab = TabBarController(coreDataStack: core)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tab
        self.window = window
        window.makeKeyAndVisible()
    }
}
