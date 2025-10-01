import CoreData

protocol TrackerRecordStoring: AnyObject {
    var onChange: (() -> Void)? { get set }
    func records() throws -> [TrackerRecord]
    func add(_ record: TrackerRecord) throws
    func remove(for trackerID: UUID, on date: Date) throws
    func count(for trackerID: UUID) throws -> Int
    func hasRecord(for trackerID: UUID, on date: Date) throws -> Bool
}

final class TrackerRecordStore: NSObject, TrackerRecordStoring {
    private let stack: CoreDataStack
    var onChange: (() -> Void)?

    private lazy var frc: NSFetchedResultsController<TrackerRecordCoreData> = {
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        // сортируем по дате для предсказуемости
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

        let rec = TrackerRecordCoreData(context: ctx)
        rec.id   = UUID() // это id самой записи, не трекера
        rec.date = Calendar.current.startOfDay(for: record.date)

        // находим связанный TrackerCoreData по trackerId
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)

        guard let trackerObj = try ctx.fetch(req).first else {
            // если трекер не найден, это логическая ошибка – решай, как обрабатывать
            return
        }
        rec.tracker = trackerObj

        try ctx.save()
    }

    func remove(for trackerID: UUID, on date: Date) throws {
        let ctx = stack.viewContext
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!

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
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!

        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.resultType = .countResultType
        req.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg, start as CVarArg, end as CVarArg
        )
        return (try ctx.count(for: req)) > 0
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
