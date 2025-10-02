import CoreData

final class CoreDataStack {

    // MARK: - Public
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Init
    init(modelName: String = "TrackerModel") {
        container = NSPersistentContainer(name: modelName)

        // Авто-миграции (чтобы не падало при добавлении атрибутов)
        if let d = container.persistentStoreDescriptions.first {
            d.shouldMigrateStoreAutomatically = true
            d.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("CoreData load error: \(error)")
            }
        }

        // Базовая настройка контекста UI
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
    }

    // MARK: - Helpers
    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        ctx.undoManager = nil
        return ctx
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        container.performBackgroundTask { ctx in
            do {
                try block(ctx)
                if ctx.hasChanges { try ctx.save() }
            } catch {
                assertionFailure("CoreData background error: \(error)")
            }
        }
    }

    func saveViewContextIfNeeded() {
        let ctx = viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() } catch {
            assertionFailure("CoreData save error: \(error)")
        }
    }
}

