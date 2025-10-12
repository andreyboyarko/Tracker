
import CoreData
import UIKit

protocol TrackerStoring: AnyObject {
    var onChange: (() -> Void)? { get set }
    func create(_ tracker: Tracker, categoryTitle: String) throws
    func delete(id: UUID) throws
    func update(_ tracker: Tracker, categoryTitle: String) throws
    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)]
    func tracker(by id: UUID) throws -> Tracker?
}

final class TrackerStore: NSObject, TrackerStoring {
    private let stack: CoreDataStack
    private let categoryStore: TrackerCategoryStoring

    // UI подпишется сюда
    var onChange: (() -> Void)?

    // FRC: группируем по названию категории (для секций)
    private lazy var frc: NSFetchedResultsController<TrackerCoreData> = {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name",            ascending: true)
        ]
        let frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: stack.viewContext,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    init(stack: CoreDataStack, categoryStore: TrackerCategoryStoring) {
        self.stack = stack
        self.categoryStore = categoryStore
        super.init()
        _ = frc // прогреть
    }

    // MARK: CRUD
    func create(_ tracker: Tracker, categoryTitle: String) throws {
        let ctx = stack.viewContext
        let obj = TrackerCoreData(context: ctx)
        obj.id = tracker.id
        obj.name = tracker.title
        obj.emoji = tracker.emoji
        obj.colorHex = tracker.color.hex6
        obj.scheduleMask = Int16(WeekdayMask.make(from: Set(tracker.weekdays)))
        obj.category = try categoryStore.ensureCategory(title: categoryTitle, in: ctx)
        try ctx.save()
    }

    func delete(id: UUID) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let obj = try ctx.fetch(req).first {
            ctx.delete(obj)
            try ctx.save()
        }
    }

    func update(_ tracker: Tracker, categoryTitle: String) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        guard let obj = try ctx.fetch(req).first else { return }
        obj.name = tracker.title
        obj.emoji = tracker.emoji
        obj.colorHex = tracker.color.hex6
        obj.scheduleMask = Int16(WeekdayMask.make(from: Set(tracker.weekdays)))
        obj.category = try categoryStore.ensureCategory(title: categoryTitle, in: ctx)
        try ctx.save()
    }

    func tracker(by id: UUID) throws -> Tracker? {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try ctx.fetch(req).first.map { $0.toDomain() }
    }

    /// Снимок для UI (категория + модель)
    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)] {
        let rows = frc.fetchedObjects ?? []
        return rows.compactMap { obj in
            guard let cat = obj.category?.title else { return nil }
            return (obj.toDomain(), cat)
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}

