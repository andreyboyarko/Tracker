import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let trackersVC = TrackersViewController()
        let trackersImg = UIImage(named: "trackers")?.withRenderingMode(.alwaysTemplate)
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: trackersImg,
            selectedImage: trackersImg
        )

        let statsVC = UIViewController()
        statsVC.view.backgroundColor = .systemBackground
        let statsImg = UIImage(named: "stats")?.withRenderingMode(.alwaysTemplate)
        statsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: statsImg,
            selectedImage: statsImg
        )

        // Цвета таббара
        tabBar.tintColor = UIColor(named: "blue") ?? .systemBlue          // активная
        tabBar.unselectedItemTintColor = UIColor(named: "ybGray") ?? .systemGray // неактивная

        let nav1 = UINavigationController(rootViewController: trackersVC)
        let nav2 = UINavigationController(rootViewController: statsVC)

        viewControllers = [nav1, nav2]

        // Цвета таббара: активный — blue из Assets, неактивный — ybGray
        tabBar.tintColor = UIColor(named: "blue") ?? .systemBlue
        tabBar.unselectedItemTintColor = UIColor(named: "ybGray") ?? .systemGray

        let ap = UITabBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .systemBackground
        tabBar.standardAppearance = ap
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = ap }
    }
}
