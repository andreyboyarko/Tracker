

import UIKit

final class CategoryViewModel {
    private let store: TrackerCategoryStore
    private(set) var categories: [String] = []
    private(set) var selectedIndex: Int?
    var onDataFetched: (() -> Void)?

    init() {
        let store = (UIApplication.shared.delegate as! AppDelegate).storeContainer.categoryStore
        self.store = store
    }
    
    func loadCategories() {
        categories = (try? store.categories())?.map { $0.title } ?? []
        onDataFetched?()
    }
    
    func addCategory(with title: String) {
        let category = TrackerCategory(title: title, trackers: [])
        try? store.create(title: title)
        
        loadCategories()
    }
    
    func numberOfRows() -> Int { categories.count }
    
    func isNotEmpty() -> Bool { categories.count > 0 }

    func titleForRow(at index: Int) -> String { categories[index] }

    func didSelectRow(at index: Int) {
        selectedIndex = index
        onDataFetched?()
    }
    
    func isSelected(at index: Int) -> Bool { selectedIndex == index }
}

