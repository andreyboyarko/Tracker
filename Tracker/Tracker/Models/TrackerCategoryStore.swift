


import CoreData

// MARK: - Абстракция
protocol TrackerCategoryStoring: AnyObject {
    func categories() throws -> [TrackerCategory]
    func create(title: String) throws
    func delete(title: String) throws
    func rename(oldTitle: String, to newTitle: String) throws

    // утилита для TrackerStore: получить/создать объект категории
    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData
}

// MARK: - Реализация
final class TrackerCategoryStore: TrackerCategoryStoring {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) { self.stack = stack }

    func categories() throws -> [TrackerCategory] {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return try ctx.fetch(req).map { $0.toDomain() }
    }

    func create(title: String) throws {
        let ctx = stack.viewContext
        let obj = TrackerCategoryCoreData(context: ctx)
        obj.title = title
        try ctx.save()
    }

    func delete(title: String) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", title)
        if let obj = try ctx.fetch(req).first {
            ctx.delete(obj)
            try ctx.save()
        }
    }

    func rename(oldTitle: String, to newTitle: String) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", oldTitle)
        if let obj = try ctx.fetch(req).first {
            obj.title = newTitle
            try ctx.save()
        }
    }

    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try ctx.fetch(req).first {
            return existing
        }
        let obj = TrackerCategoryCoreData(context: ctx)
        obj.title = title
        return obj
    }
}

// MARK: - Mapping
private extension TrackerCategoryCoreData {
    func toDomain() -> TrackerCategory {
        let trackers = (trackers as? Set<TrackerCoreData> ?? []).map { $0.toDomain() }
        return TrackerCategory(title: title ?? "", trackers: trackers)
    }
}
