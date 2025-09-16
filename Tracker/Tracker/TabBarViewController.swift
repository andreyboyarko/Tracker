import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1) Экран «Трекеры»
        let trackersVC = TrackersViewController() // или TrackerViewController, как у тебя называется реально
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers"), // или UIImage(resource: .trackers) если генерируешь ресурсы
            tag: 0
        )

        // 2) Экран «Статистика»
        let statsVC = UIViewController()
        statsVC.view.backgroundColor = .systemBackground
        statsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "stats"),
            tag: 1
        )

        // Оборачиваем в навигацию
        let nav1 = UINavigationController(rootViewController: trackersVC)
        let nav2 = UINavigationController(rootViewController: statsVC)

        viewControllers = [nav1, nav2]

        configureTabBarAppearance()
    }

    private func configureTabBarAppearance() {
        let ap = UITabBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .systemBackground
        ap.shadowColor = UIColor(white: 0, alpha: 0.1) // верхняя тонкая полоска

        // Цвета айтемов
        ap.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        ap.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        ap.stackedLayoutAppearance.selected.iconColor = .systemBlue
        ap.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]

        tabBar.standardAppearance = ap
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = ap }

        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
    }
}
