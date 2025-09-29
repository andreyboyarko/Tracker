import UIKit

final class TabBarController: UITabBarController {

    // хранить стек в таббаре (если нужно прокидывать дальше)
    private let coreDataStack: CoreDataStack

    // 🔹 DI через init
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // передаём стек в корневой контроллер «Трекеры»
        let trackersVC = TrackersViewController(coreDataStack: coreDataStack)

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

        let nav1 = UINavigationController(rootViewController: trackersVC)
        let nav2 = UINavigationController(rootViewController: statsVC)
        viewControllers = [nav1, nav2]

        // оформление таббара
        tabBar.tintColor = UIColor(named: "blue") ?? .systemBlue
        tabBar.unselectedItemTintColor = UIColor(named: "ybGray") ?? .systemGray

        let ap = UITabBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .systemBackground
        tabBar.standardAppearance = ap
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = ap }
    }
}
