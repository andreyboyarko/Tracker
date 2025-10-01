
import UIKit

struct Tracker: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let weekdays: [WeekdaysEnum]

    init(
        id: UUID = UUID(),
        title: String,
        color: UIColor,
        emoji: String,
        weekdays: [WeekdaysEnum]
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.weekdays = weekdays
    }
}

