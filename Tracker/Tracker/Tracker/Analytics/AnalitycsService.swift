
import AppMetricaCore

protocol AnalyticsServiceProtocol {
    func sendEvent(_ event: Analytics.Event, screen: Analytics.Screen, item: Analytics.Item?)
}

final class AppMetricaService: AnalyticsServiceProtocol {
    static let shared = AppMetricaService()
    private init() {}
    
    func activate(apiKey: String) {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    func sendEvent(_ event: Analytics.Event, screen: Analytics.Screen, item: Analytics.Item? = nil) {
        var parameters: [String: String] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item = item {
            parameters["item"] = item.rawValue
        }
        // Отправляем в AppMetrica (пример)
        AppMetrica.reportEvent(name: "ui_event", parameters: parameters)
    }
}

