

import UIKit

enum TrackerFilter: String, CaseIterable {
    case all
    case forToday
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all: return L10n.filterAll
        case .forToday: return L10n.filterForToday
        case .completed: return L10n.filterCompleted
        case .uncompleted: return L10n.filterUncompleted
        }
    }
}

