

import CoreData

protocol StoreWithFRC: AnyObject, NSFetchedResultsControllerDelegate {
    associatedtype Entity: NSManagedObject
    var frc: NSFetchedResultsController<Entity> { get }
    var onChange: (() -> Void)? { get set }
}

extension StoreWithFRC {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?()
    }
}
