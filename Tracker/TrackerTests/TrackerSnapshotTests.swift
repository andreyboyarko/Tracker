import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {
    private var container: StoreContainer!
    private var sut: TrackersViewController!

    override func setUp() {
        super.setUp()

        // ⚠️ включить один раз, чтобы перезаписать снимки
        isRecording = false  // ← поставить true на один прогон, потом вернуть false

        // Делаем снапшоты детерминированными
        UIView.setAnimationsEnabled(false)
        UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")   // фиксируем язык
        UserDefaults.standard.set("ru_RU", forKey: "AppleLocale")
        UserDefaults.standard.synchronize()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.storeContainer

        sut = TrackersViewController(
            categoryStore: container.categoryStore,
            trackerStore:  container.trackerStore,
            recordStore:   container.recordStore
        )
        sut.loadViewIfNeeded()

        // Фиксируем дату/тему и делаем финальный layout
        sut.overrideUserInterfaceStyle = .light
        sut.view.layoutIfNeeded()
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        sut = nil
        container = nil
        super.tearDown()
    }
    
    func test_Trackers_light() {
        let nav = UINavigationController(rootViewController: sut)
        assertSnapshot(
            of: nav,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            testName: "TrackersVC_Light"
        )
    }
    func test_Trackers_dark() {
        let nav = UINavigationController(rootViewController: sut)
        assertSnapshot(
            of: nav,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            testName: "TrackersVC_Dark"
        )
    }
}
