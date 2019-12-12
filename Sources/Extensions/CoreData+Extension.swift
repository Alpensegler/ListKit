//
//  CoreData+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

#if canImport(CoreData)
import CoreData

open class FetchedResultsController<Item>: NSObject, NSFetchedResultsControllerDelegate
where Item: NSFetchRequestResult {
    open var fetchedResultController: NSFetchedResultsController<Item>

    public init(_ fetchedResultController: NSFetchedResultsController<Item>) {
        self.fetchedResultController = fetchedResultController
        super.init()
        self.fetchedResultController.delegate = self
    }

    public init(
        fetchRequest: NSFetchRequest<Item>,
        managedObjectContext context: NSManagedObjectContext,
        sectionNameKeyPath: String? = nil,
        cacheName name: String? = nil
    ) {
        fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: name
        )
        super.init()
        fetchedResultController.delegate = self
    }
    
    public func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
//        startUpdate()
    }
    
    public func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
//        endUpdate()
//        contentChangeDidEnd()
    }
    
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
//        switch type {
//        case .delete: deleteSections([sectionIndex])
//        case .insert: insertSections([sectionIndex])
//        case .update: reloadSections([sectionIndex])
//        default: break
//        }
    }
    
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
//        switch type {
//        case .insert: insertItems(at: [newIndexPath!])
//        case .delete: deleteItems(at: [indexPath!])
//        case .update: reloadItems(at: [indexPath!])
//        case .move: moveItem(at: indexPath!, to: newIndexPath!)
//        @unknown default: break
//        }
    }
}

extension FetchedResultsController: NSDataSource {
    public func item(at section: Int, item: Int) -> Item {
        fetchedResultController.object(at: IndexPath(item: item, section: section))
    }
    
    public func numbersOfSections() -> Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    public func numbersOfItem(in section: Int) -> Int {
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
}

#endif
