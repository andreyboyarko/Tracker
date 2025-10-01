import UIKit

final class TabBarController: UITabBarController {
    private let core: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.core = coreDataStack
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Сервисы
        let categoryStore = TrackerCategoryStore(stack: core)
        let trackerStore  = TrackerStore(stack: core, categoryStore: categoryStore)
        let recordStore = TrackerRecordStore(stack: core)

        // VC с DI
        let trackersVC = TrackersViewController(
            categoryStore: categoryStore,
            trackerStore: trackerStore,
            recordStore: recordStore
        )
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры",
                                             image: UIImage(named:"trackers")?.withRenderingMode(.alwaysTemplate),
                                             selectedImage: nil)

        let statsVC = UIViewController()
        statsVC.view.backgroundColor = .systemBackground
        statsVC.tabBarItem = UITabBarItem(title: "Статистика",
                                          image: UIImage(named:"stats")?.withRenderingMode(.alwaysTemplate),
                                          selectedImage: nil)

        viewControllers = [UINavigationController(rootViewController: trackersVC),
                           UINavigationController(rootViewController: statsVC)]

        tabBar.tintColor = UIColor(named: "blue")
        tabBar.unselectedItemTintColor = UIColor(named: "ybGray")

        let ap = UITabBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = .systemBackground
        tabBar.standardAppearance = ap
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = ap }
    }
}
