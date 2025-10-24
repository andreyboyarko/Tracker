
import Foundation
#if canImport(AppMetricaCore)
import AppMetricaCore
#endif

protocol AnalyticsServiceProtocol {
    func activate(apiKey: String)
    func sendEvent(_ event: Analytics.Event, screen: Analytics.Screen, item: Analytics.Item?)
    func sendOpen(screen: Analytics.Screen)
    func sendClose(screen: Analytics.Screen)
    func sendClick(screen: Analytics.Screen, item: Analytics.Item)
}

final class AppMetricaService: AnalyticsServiceProtocol {
    static let shared = AppMetricaService()
    private init() {}

    // MARK: Activate
    func activate(apiKey: String) {
        #if canImport(AppMetricaCore)
        if let cfg = AppMetricaConfiguration(apiKey: apiKey) {
            AppMetrica.activate(with: cfg)
            debugPrint("[AM] activated")
        } else {
            debugPrint("[AM][WARN] configuration failed")
        }
        #else
        debugPrint("[AM][SKIP] SDK not linked for this build")
        #endif
    }

    // MARK: Send
    func sendEvent(_ event: Analytics.Event, screen: Analytics.Screen, item: Analytics.Item? = nil) {
        var params: [String: Any] = ["event": event.rawValue,
                                     "screen": screen.rawValue]
        if event == .click, let item { params["item"] = item.rawValue }

        // лог в консоль для тестов
        print("[AM]", params)

        #if canImport(AppMetricaCore)
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            // колбэк вызывается при ошибке
            print("[AM][ERROR]", error.localizedDescription)
        }
        #endif
    }

    // MARK: Shortcuts
    func sendOpen(screen: Analytics.Screen)  { sendEvent(.open,  screen: screen, item: nil) }
    func sendClose(screen: Analytics.Screen) { sendEvent(.close, screen: screen, item: nil) }
    func sendClick(screen: Analytics.Screen, item: Analytics.Item) {
        sendEvent(.click, screen: screen, item: item)
    }
}
