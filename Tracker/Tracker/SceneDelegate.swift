import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Один-единственный контейнер на всё приложение
    let core = CoreDataStack(modelName: "TrackerModel")

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Передаём стек внутрь корневого контроллера (Constructor Injection)
        let root = TabBarController(coreDataStack: core)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = root
        self.window = window
        window.makeKeyAndVisible()
    }
}

//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    var window: UIWindow?
//    
//    let core = CoreDataStack(modelName: "TrackerModel")
//
//    func scene(_ scene: UIScene,
//               willConnectTo session: UISceneSession,
//               options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = scene as? UIWindowScene else { return }
//
//        let window = UIWindow(windowScene: windowScene)
//        window.rootViewController = TabBarController()   // <- ВАЖНО
//        self.window = window
//        window.makeKeyAndVisible()
//    }
//}

