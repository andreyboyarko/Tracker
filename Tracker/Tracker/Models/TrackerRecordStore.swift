
import CoreData

protocol TrackerRecordStoring: AnyObject {
    var onChange: (() -> Void)? { get set }
    func records() throws -> [TrackerRecord]
    func add(_ record: TrackerRecord) throws
    func remove(for trackerID: UUID, on date: Date) throws
    func count(for trackerID: UUID) throws -> Int
    func hasRecord(for trackerID: UUID, on date: Date) throws -> Bool
}

enum TrackerRecordStoreError: Error {
    case trackerNotFound(UUID)
    case dayBoundsFailed(Date)
}

final class TrackerRecordStore: NSObject, TrackerRecordStoring {
    private let stack: CoreDataStack
    var onChange: (() -> Void)?

    private lazy var frc: NSFetchedResultsController<TrackerRecordCoreData> = {
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: stack.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    init(stack: CoreDataStack) {
        self.stack = stack
        super.init()
        _ = frc
    }

    func records() throws -> [TrackerRecord] {
        (frc.fetchedObjects ?? []).map { $0.toDomain() }
    }

    func add(_ record: TrackerRecord) throws {
        let ctx = stack.viewContext

        // найдём связанный трекер
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)

        guard let trackerObj = try ctx.fetch(req).first else {
            throw TrackerRecordStoreError.trackerNotFound(record.trackerId)
        }

        let rec = TrackerRecordCoreData(context: ctx)
        rec.id = UUID() // id самой записи
        rec.date = Calendar.current.startOfDay(for: record.date)
        rec.tracker = trackerObj

        try ctx.save()
    }

    func remove(for trackerID: UUID, on date: Date) throws {
        let ctx = stack.viewContext
        guard let (start, end) = dayBounds(for: date) else {
            throw TrackerRecordStoreError.dayBoundsFailed(date)
        }

        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, start as CVarArg, end as CVarArg
        )

        if let rec = try ctx.fetch(req).first {
            ctx.delete(rec)
            try ctx.save()
        }
    }

    func count(for trackerID: UUID) throws -> Int {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        return try ctx.count(for: req)
    }

    func hasRecord(for trackerID: UUID, on date: Date) throws -> Bool {
        let ctx = stack.viewContext
        guard let (start, end) = dayBounds(for: date) else {
            throw TrackerRecordStoreError.dayBoundsFailed(date)
        }

        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.resultType = .countResultType
        req.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, start as CVarArg, end as CVarArg
        )
        return try ctx.count(for: req) > 0
    }
}

private extension TrackerRecordStore {
    /// Начало и конец суток для `date` с учётом календаря/часового пояса.
    func dayBounds(for date: Date) -> (Date, Date)? {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return nil }
        return (start, end)
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
