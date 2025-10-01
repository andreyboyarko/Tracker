import CoreData

protocol TrackerCategoryStoring: AnyObject {
    var onChange: (() -> Void)? { get set }
    func categories() throws -> [TrackerCategory]
    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoring {
    private let stack: CoreDataStack
    var onChange: (() -> Void)?

    private lazy var frc: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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

    func categories() throws -> [TrackerCategory] {
        (frc.fetchedObjects ?? []).map { $0.toDomain() }
    }

    /// Создаёт или возвращает существующую категорию в указанном контексте
    func ensureCategory(title: String, in ctx: NSManagedObjectContext) throws -> TrackerCategoryCoreData {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "title == %@", title)
        if let exist = try ctx.fetch(req).first { return exist }
        let obj = TrackerCategoryCoreData(context: ctx)
        obj.title = title
        return obj
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}

