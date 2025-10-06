import UIKit

extension TrackerCoreData {
    func toDomain() -> Tracker {
        let hex = colorHex ?? "34C759FF" // зелёный дефолт, если пусто
        let color = UIColor(hexAny: hex) ?? .systemGreen

        let days = Array(WeekdayMask.toSet(UInt16(scheduleMask)))
        return Tracker(
            id: id ?? UUID(),
            title: name ?? "",
            color: color,
            emoji: emoji ?? "🙂",
            weekdays: days
        )
    }
}

extension TrackerCategoryCoreData {
    func toDomain() -> TrackerCategory {
        let list: [Tracker] = (trackers as? Set<TrackerCoreData> ?? [])
            .map { $0.toDomain() }
            .sorted { $0.title < $1.title }
        return TrackerCategory(title: title ?? "", trackers: list)
    }
}

extension TrackerRecordCoreData {
    func toDomain() -> TrackerRecord {
        TrackerRecord(trackerId: tracker?.id ?? UUID(), // ← тоже id
                      date: date ?? Date())
    }
}
