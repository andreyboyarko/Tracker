import Foundation

protocol StatisticsViewDelegate: AnyObject {
    func didUpdateData()
}

final class StatisticsViewModel {
    // Публичное read-only состояние для VC
    private(set) var statistics: [StatisticsEnum: String] = [:]

    private let recordStore: TrackerRecordStore
    private let calendar = Calendar.current

    weak var delegate: StatisticsViewDelegate?

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore

        // 1) слушаем изменения стора
        self.recordStore.onChange = { [weak self] in
            self?.recalculate()                // всегда на main внутри recalculate()
        }
        self.recordStore.delegate = self

        // 2) сразу посчитать текущие значения
        recalculate()
    }

    /// Явный вызов из VC (если хочется)
    func loadStatistics() {
        recalculate()
    }

    // MARK: - Calc
    private func recalculate() {
        // гарантируем main для дальнейшего обновления UI
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in self?.recalculate() }
            return
        }

        let records = (try? recordStore.records()) ?? []

        guard !records.isEmpty else {
            statistics = [:]
            delegate?.didUpdateData()
            return
        }

        // уникальные календарные дни активности
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        let totalActiveDays = uniqueDays.count

        // группируем по дню, ищем лучший день
        let groupedByDay = Dictionary(grouping: records, by: { calendar.startOfDay(for: $0.date) })
        // если несколько лучших — выберем самый поздний
        let best = groupedByDay.max {
            if $0.value.count == $1.value.count { return $0.key < $1.key }
            return $0.value.count < $1.value.count
        }

        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        let bestDayFormatted = best.map { df.string(from: $0.key) } ?? "–"

        // среднее завершений в день, без дробей (как в макете)
        let avg = Double(records.count) / Double(max(totalActiveDays, 1))
        let averageFormatted = String(Int(round(avg)))

        statistics = [
            .totalCompleted: "\(records.count)",
            .totalActiveDays: "\(totalActiveDays)",
            .bestDay: bestDayFormatted,
            .average: averageFormatted
        ]

        delegate?.didUpdateData()
    }
}

extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        recalculate()
    }
}
