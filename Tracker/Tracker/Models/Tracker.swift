
import UIKit

struct Tracker: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let weekdays: [Weekday]

    init(
        id: UUID = UUID(),
        title: String,
        color: UIColor,
        emoji: String,
        weekdays: [Weekday]
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.weekdays = weekdays
    }
}

