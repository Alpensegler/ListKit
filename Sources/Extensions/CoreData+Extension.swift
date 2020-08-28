//
//  CoreData+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

#if canImport(CoreData)
import CoreData

public class ListFetchedResultsController<Item>: NSObject, NSFetchedResultsControllerDelegate
where Item: NSFetchRequestResult {
    public var fetchedResultController: NSFetchedResultsController<Item>
    public var listUpdate = ListUpdate<ListFetchedResultsController<Item>>.Whole.appendOrRemoveLast
    public var listDiffer = ListDiffer<ListFetchedResultsController<Item>>.diff
    public var listOptions = ListOptions<ListFetchedResultsController<Item>>.keepEmptySection
    public var didChangeContent: (() -> Void)?
    public var updateCompletion: ((ListView, Bool) -> Void)?
    public var shouldReloadItem: ((Item, IndexPath) -> Bool)?
    public var shouldMoveItem: ((Item, IndexPath) -> Bool)?
    var update: ListUpdate<SourceBase>!
    
    public var fetchedObjects: [Item] {
        fetchedResultController.fetchedObjects ?? []
    }
    
    public var sectionInfo: [NSFetchedResultsSectionInfo] {
        fetchedResultController.sections ?? []
    }

    public init(_ fetchedResultController: NSFetchedResultsController<Item>) {
        self.fetchedResultController = fetchedResultController
        super.init()
        self.fetchedResultController.delegate = self
        guard fetchedResultController.sectionNameKeyPath?.isEmpty == false else { return }
        listOptions.insert(.preferSection)
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
        guard sectionNameKeyPath?.isEmpty == false else { return }
        listOptions.insert(.preferSection)
    }
    
    public func performFetch() throws {
        try fetchedResultController.performFetch()
    }
    
    public func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        update = .init()
    }
    
    public func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        perform(update, completion: updateCompletion)
        didChangeContent?()
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
        case .update: reload(at: indexPath, newIndexPath: newIndexPath, object: anObject)
        case .move: move(at: indexPath, newIndexPath: newIndexPath, object: anObject)
        default: break
        }
    }
    
    func reload(at indexPath: IndexPath?, newIndexPath: IndexPath?, object: Any) {
        guard let indexPath = indexPath, let object = object as? Item else { return }
        if shouldReloadItem?(object, indexPath) == false { return }
        update.add(.reloadItem(at: indexPath, newIndexPath: newIndexPath))
    }
    
    func move(at indexPath: IndexPath?, newIndexPath: IndexPath?, object: Any) {
        guard let indexPath = indexPath, let object = object as? Item else { return }
        if shouldMoveItem?(object, indexPath) == false {
            update.add(.deleteItem(at: indexPath))
            update.add(.insertItem(at: newIndexPath!))
        } else {
            update.add(.moveItem(at: indexPath, to: newIndexPath!))
        }
    }
}

extension ListFetchedResultsController: NSDataSource {
    public func item(at indexPath: IndexPath) -> Item {
        fetchedResultController.object(at: indexPath)
    }
    
    public func numbersOfSections() -> Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    public func numbersOfItem(in section: Int) -> Int {
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
}

#endif
