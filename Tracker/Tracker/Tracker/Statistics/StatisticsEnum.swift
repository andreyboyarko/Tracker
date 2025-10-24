
enum StatisticsEnum: String, CaseIterable {
    case totalActiveDays
    case totalCompleted
    case bestDay
    case average
    
    var title: String {
        switch self {
        case .totalCompleted:
            return L10n.totalCompleted
        case .totalActiveDays:
            return L10n.totalActiveDays
        case .bestDay:
            return L10n.bestDay
        case .average:
            return L10n.average
        }
    }
}
