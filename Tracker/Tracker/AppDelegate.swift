import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Контейнер хранилищ
    let storeContainer = StoreContainer()
    // Если DI/хранилища не нужны — ничего лишнего здесь не держим.
    // Если будешь прокидывать контейнер хранения — добавишь здесь поле.

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Точка для ранней конфигурации (например, UIAppearance, логирование, аналитика)
        return true
    }

    // MARK: - UIScene configuration

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Сообщаем системе, что корневую сцену обслуживает наш SceneDelegate
        let cfg = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        cfg.delegateClass = SceneDelegate.self
        return cfg
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Можно освободить ресурсы, связанные с отброшенными сценами (если было нужно)
    }
}
