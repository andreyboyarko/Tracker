

final class StoreContainer {
    let core = CoreDataStack(modelName: "TrackerModel")
    lazy var categoryStore = TrackerCategoryStore(stack: core)
    lazy var trackerStore = TrackerStore(stack: core, categoryStore: categoryStore)
    lazy var recordStore = TrackerRecordStore(stack: core)
}
