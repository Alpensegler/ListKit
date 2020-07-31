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
    open var completion: ((ListView, Bool) -> Void)?
    open var listUpdate = ListUpdate<FetchedResultsController<Item>>.Whole.appendOrRemoveLast
    open var listOptions = ListOptions<FetchedResultsController<Item>>()
    var update: ListUpdate<SourceBase>!

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
        update = .init()
    }
    
    public func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        perform(update, completion: completion)
    }
    
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .delete: update.add(.deleteSection(sectionIndex))
        case .insert: update.add(.insertSection(sectionIndex))
        case .update: update.add(.reloadSection(sectionIndex))
        default: break
        }
    }
    
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert: update.add(.insertItem(at: newIndexPath!))
        case .delete: update.add(.deleteItem(at: indexPath!))
        case .update: update.add(.reloadItem(at: indexPath!))
        case .move: update.add(.moveItem(at: indexPath!, to: newIndexPath!))
        @unknown default: break
        }
    }
}

extension FetchedResultsController: NSDataSource {
    public func item(at section: Int, _ item: Int) -> Item {
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
