
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

extension TrackerCoreData {
    func toDomain() -> Tracker {
        let color = UIColor(hex6: colorHex ?? "#999999") ?? .black

        // в БД хранится битовая маска (Set<WeekdaysEnum>), а в модели — массив
        let daysSet: Set<WeekdaysEnum> = WeekdayMask.toSet(UInt16(scheduleMask))
        let days: [WeekdaysEnum] = Array(daysSet)  // можно отсортировать, если нужно

        return Tracker(
            id: id ?? UUID(),
            title: name ?? "",
            color: color,
            emoji: emoji ?? "🙂",
            weekdays: days
        )
    }
}
