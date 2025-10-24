import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // DI контейнер стораджей (как и было)
    let storeContainer = StoreContainer()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // Активируем AppMetrica через сервис (без форс-unwrap)
        AppMetricaService.shared.activate(apiKey: "916ebf43-8fc8-4bee-afde-a6bbda67159e")

        // тут можно добавить UIAppearance/логирование и т.п.
        return true
    }

    // MARK: - UIScene configuration
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let cfg = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        cfg.delegateClass = SceneDelegate.self
        return cfg
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // no-op
    }
}
