

final class StoreContainer {
    let core = CoreDataStack(modelName: "TrackerModel")
    lazy var categoryStore = TrackerCategoryStore(stack: core)
    lazy var trackerStore = TrackerStore(stack: core, categoryStore: categoryStore)
    lazy var recordStore = TrackerRecordStore(stack: core)
}

// StoreContainer.swift
//import Foundation
//
//final class StoreContainer {
//    // общий стек Core Data для всех сто́ров
//    let stack: CoreDataStack
//
//    // публичные сторы, которыми будут пользоваться экран(ы) и тесты
//    let categoryStore: TrackerCategoryStore
//    let trackerStore: TrackerStore
//    let recordStore: TrackerRecordStore
//
//    init() {
//        // ⚠️ Если твой CoreDataStack требует имя модели — укажи его:
//        // stack = CoreDataStack(modelName: "TrackerModel")
//        // иначе оставь без параметров:
//        stack = CoreDataStack()
//
//        categoryStore = TrackerCategoryStore(stack: stack)
//        trackerStore  = TrackerStore(stack: stack, categoryStore: categoryStore)
//        recordStore   = TrackerRecordStore(stack: stack)
//    }

