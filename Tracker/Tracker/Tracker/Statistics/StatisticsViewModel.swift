import Foundation

protocol StatisticsViewDelegate: AnyObject {
    func didUpdateData()
}

final class StatisticsViewModel {
    private(set) var statistics: [StatisticsEnum: String] = [:]

    private let recordStore: TrackerRecordStore
    private let calendar = Calendar.current

    weak var delegate: StatisticsViewDelegate?

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore

        // у стора — замыкание onChange, а не delegate
        self.recordStore.onChange = { [weak self] in
            self?.loadStatistics()
        }
    }

    func loadStatistics() {
        // records() — предположительно throws -> [TrackerRecord]
        let records = (try? recordStore.records()) ?? []

        guard !records.isEmpty else {
            statistics = [:]
            delegate?.didUpdateData()
            return
        }

        // активные дни
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        let totalActiveDays = uniqueDays.count

        // лучший день
        let groupedByDay = Dictionary(grouping: records, by: { calendar.startOfDay(for: $0.date) })
        let best = groupedByDay.max(by: { $0.value.count < $1.value.count })

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let bestDayFormatted = best.map { dateFormatter.string(from: $0.key) } ?? "–"

        // среднее
        let avg = Double(records.count) / Double(max(totalActiveDays, 1))
        let nf = NumberFormatter()
        nf.locale = Locale.current
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 0
        let averageFormatted = nf.string(from: NSNumber(value: avg)) ?? "0"

        // всего завершено
        let totalCompleted = records.count

        statistics = [
            .totalCompleted: "\(totalCompleted)",
            .totalActiveDays: "\(totalActiveDays)",
            .bestDay: bestDayFormatted,
            .average: averageFormatted
        ]

        delegate?.didUpdateData()
    }
}
