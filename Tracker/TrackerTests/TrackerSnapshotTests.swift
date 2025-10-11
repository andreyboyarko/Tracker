import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {
    private var container: StoreContainer!
    private var sut: TrackersViewController!

    override func setUp() {
        super.setUp()

        // Берём контейнер из AppDelegate (поэтому Host Application обязателен)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.storeContainer

        // Создаём тестируемый экран как в приложении
        sut = TrackersViewController(
            categoryStore: container.categoryStore,
            trackerStore:  container.trackerStore,
            recordStore:   container.recordStore
        )
        sut.loadViewIfNeeded() // гарантируем построение вью
    }

    override func tearDown() {
        sut = nil
        container = nil
        super.tearDown()
    }

    // Первый простой снимок (как в уроке)
    func test_Trackers_light() {
        assertSnapshot(
            of: UINavigationController(rootViewController: sut),
            as: .image(traits: .init(userInterfaceStyle: .light)),
            testName: "TrackersVC_Light"
        )
    }

    // По желанию — тёмная тема
    func test_Trackers_dark() {
        assertSnapshot(
            of: UINavigationController(rootViewController: sut),
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            testName: "TrackersVC_Dark"
        )
    }
}
