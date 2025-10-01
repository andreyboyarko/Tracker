import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Один экземпляр CoreDataStack на всё приложение
    let core = CoreDataStack(modelName: "TrackerModel")

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        // Собираем корневой контроллер таббара и передаём зависимости
        let root = TabBarController(coreDataStack: core)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = root
        self.window = window
        window.makeKeyAndVisible()
    }
}
