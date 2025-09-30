import UIKit

import CoreData

// MARK: - Абстракция
protocol TrackerStoring: AnyObject {
    var onChange: (() -> Void)? { get set }
    func create(_ tracker: Tracker, categoryTitle: String) throws
    func delete(id: UUID) throws
    func update(_ tracker: Tracker, categoryTitle: String) throws
    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)]
    func tracker(by id: UUID) throws -> Tracker?
}

// MARK: - Реализация
final class TrackerStore: NSObject, TrackerStoring {

    // Зависимости
    private let stack: CoreDataStack
    private let categoryStore: TrackerCategoryStoring

    // Колбэк для VC — дергаем при любых изменениях данных
    var onChange: (() -> Void)?

    // FRC: группы по названию категории, сортировка: категория → имя
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

    // MARK: - Init
    init(stack: CoreDataStack, categoryStore: TrackerCategoryStoring) {
        self.stack = stack
        self.categoryStore = categoryStore
        super.init()
        _ = frc // прогреем
    }

    // MARK: - CRUD

    /// Создать трекер в указанной категории
    func create(_ tracker: Tracker, categoryTitle: String) throws {
        let ctx = stack.viewContext

        let obj = TrackerCoreData(context: ctx)
        obj.id = tracker.id
        obj.name = tracker.title
        obj.emoji = tracker.emoji

        // UIColor → HEX (в ассетах храните, а в БД — строка)
        obj.colorHex = tracker.color.hexString

        // [WeekdaysEnum] → Int16 (битовая маска)
        obj.scheduleMask = Int16(WeekdayMask.make(from: Set(tracker.weekdays)))

        // обеспечить/получить категорию
        obj.category = try categoryStore.ensureCategory(title: categoryTitle, in: ctx)

        try ctx.save()
    }

    /// Удалить трекер
    func delete(id: UUID) throws {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let obj = try ctx.fetch(req).first {
            ctx.delete(obj)
            try ctx.save()
        }
    }

    /// Обновить трекер (и при необходимости перенести в другую категорию)
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

    /// Найти доменную модель по id
    func tracker(by id: UUID) throws -> Tracker? {
        let ctx = stack.viewContext
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try ctx.fetch(req).first.map { $0.toDomain() }
    }

    /// Снимок для построения секций в UI
    func snapshot() throws -> [(tracker: Tracker, categoryTitle: String)] {
        let rows = frc.fetchedObjects ?? []
        return rows.compactMap { obj in
            guard let cat = obj.category?.title else { return nil }
            return (obj.toDomain(), cat)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}

//// MARK: - Mapping CoreData ↔ Domain
//private extension TrackerCoreData {
//    func toDomain() -> Tracker {
//        // HEX → UIColor (см. ваш UIColor+HexHelpers)
//        let uiColor = UIColor(hex6: colorHex ?? "#999999") ?? .systemGray
//
//        // Int16 → [WeekdaysEnum]
//        let daysSet = WeekdayMask.toSet(UInt16(scheduleMask))
//        let days = Array(daysSet) // порядок для UI не критичен; отсортируйте при желании
//
//        return Tracker(
//            id: id ?? UUID(),
//            title: name ?? "",
//            color: uiColor,
//            emoji: emoji ?? "🙂",
//            weekdays: days
//        )
//    }
//}
