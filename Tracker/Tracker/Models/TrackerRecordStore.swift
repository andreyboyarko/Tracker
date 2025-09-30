

import CoreData

// MARK: - Абстракция
protocol TrackerRecordStoring: AnyObject {
    func add(_ record: TrackerRecord) throws
    func remove(_ record: TrackerRecord) throws
    func isCompleted(_ id: UUID, on date: Date) throws -> Bool
    func completedCount(for id: UUID) throws -> Int
}

// MARK: - Реализация
final class TrackerRecordStore: TrackerRecordStoring {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) { self.stack = stack }

    func add(_ record: TrackerRecord) throws {
        let ctx = stack.viewContext

        guard let trackerObj = try fetchTrackerCoreData(id: record.trackerId, in: ctx) else { return }

        let obj = TrackerRecordCoreData(context: ctx)
        obj.id = UUID()
        obj.date = Calendar.current.startOfDay(for: record.date)
        obj.tracker = trackerObj
        try ctx.save()
    }

    func remove(_ record: TrackerRecord) throws {
        let ctx = stack.viewContext
        let date = Calendar.current.startOfDay(for: record.date)

        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", record.trackerId as CVarArg),
            NSPredicate(format: "date == %@", date as NSDate)
        ])
        if let obj = try ctx.fetch(req).first {
            ctx.delete(obj)
            try ctx.save()
        }
    }

    func isCompleted(_ id: UUID, on date: Date) throws -> Bool {
        let ctx = stack.viewContext
        let d = Calendar.current.startOfDay(for: date)
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", id as CVarArg),
            NSPredicate(format: "date == %@", d as NSDate)
        ])
        return try ctx.count(for: req) > 0
    }

    func completedCount(for id: UUID) throws -> Int {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "tracker.id == %@", id as CVarArg)
        return try ctx.count(for: req)
    }

    // MARK: - Helpers

    private func fetchTrackerCoreData(id: UUID, in ctx: NSManagedObjectContext) throws -> TrackerCoreData? {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try ctx.fetch(req).first
    }
}
