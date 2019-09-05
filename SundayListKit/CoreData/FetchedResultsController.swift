//
//  FetchedResultsController.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/24.
//  Copyright © 2019 Frain. All rights reserved.
//

import CoreData

public protocol FetchedResultControllerDataSource: FetchedResultsControllerDelegate, ListUpdatable, DataSource where Item: NSFetchRequestResult {
    var fetchedResultController: NSFetchedResultsController<Item> { get }
    
    func contentChangeDidEnd()
}

public extension FetchedResultControllerDataSource {
    func contentChangeDidEnd() { }
}

public protocol FetchedResultDataSource: FetchedResultControllerDataSource {
    var fetchRequest: NSFetchRequest<Item> { get }
    var managedObjectContext: NSManagedObjectContext { get }
    var sectionNameKeyPath: String? { get }
    var cacheName: String? { get }
}

private var fetchedResultControllerKey: Void?

public extension FetchedResultDataSource {
    var sectionNameKeyPath: String? { return nil }
    var cacheName: String? { return nil }
    
    var fetchedResultController: NSFetchedResultsController<Item> {
        return Associator.getValue(key: &fetchedResultControllerKey, from: self, initialValue: {
            let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
            fetchedResultController.delegate = asNSFetchedResultsControllerDelegate
            return fetchedResultController
        }())
    }
}

public extension FetchedResultControllerDataSource {
    func item(at indexPath: IndexPath) -> Item {
        return fetchedResultController.object(at: indexPath)
    }
    
    func numbersOfItems(in section: Int) -> Int {
        return fetchedResultController.sections![section].objects!.count
    }
    
    func numbersOfSections() -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        startUpdate()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        endUpdate()
        contentChangeDidEnd()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete: deleteSections([sectionIndex])
        case .insert: insertSections([sectionIndex])
        case .update: reloadSections([sectionIndex])
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: insertItems(at: [newIndexPath!])
        case .delete: deleteItems(at: [indexPath!])
        case .update: reloadItems(at: [indexPath!])
        case .move: moveItem(at: indexPath!, to: newIndexPath!)
        @unknown default: break
        }
    }
}

open class FetchedResultsController<FetchResult: NSFetchRequestResult>: FetchedResultControllerDataSource {
    public typealias Item = FetchResult
    public let listUpdater = ListUpdater()
    open var fetchedResultController: NSFetchedResultsController<FetchResult>

    public init(fetchedResultController: NSFetchedResultsController<FetchResult>) {
        self.fetchedResultController = fetchedResultController
        self.fetchedResultController.delegate = asNSFetchedResultsControllerDelegate
    }

    public init(fetchRequest: NSFetchRequest<FetchResult>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String? = nil, cacheName name: String? = nil) {
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
        fetchedResultController.delegate = asNSFetchedResultsControllerDelegate
    }
}

public protocol FetchedResultsControllerDelegate: class {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String?
}

private var fetchedResultsControllerDelegateKey: Void?

public extension FetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) { }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) { }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? { return controller.sectionIndexTitle(forSectionName: sectionName) }
    
    var asNSFetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
        return Associator.getValue(key: &fetchedResultsControllerDelegateKey, from: self, initialValue: FetchedResultsControllerDelegateWrapper(self))
    }
}

class FetchedResultsControllerDelegateWrapper: NSObject, NSFetchedResultsControllerDelegate {
    var controllerDidChangeAtForNewIndexPathBlock: (NSFetchedResultsController<NSFetchRequestResult>, Any, IndexPath?, NSFetchedResultsChangeType, IndexPath?) -> Void
    var controllerDidChangeAtSectionIndexForBlock: (NSFetchedResultsController<NSFetchRequestResult>, NSFetchedResultsSectionInfo, Int, NSFetchedResultsChangeType) -> Void
    var controllerWillChangeContentBlock: (NSFetchedResultsController<NSFetchRequestResult>) -> Void
    var controllerDidChangeContentBlock: (NSFetchedResultsController<NSFetchRequestResult>) -> Void
    var controllerSectionIndexTitleForSectionNameBlock: (NSFetchedResultsController<NSFetchRequestResult>, String) -> String?
    
    init(_ delegate: FetchedResultsControllerDelegate) {
        controllerDidChangeAtForNewIndexPathBlock = { [unowned delegate] in delegate.controller($0, didChange: $1, at: $2, for: $3, newIndexPath: $4) }
        controllerDidChangeAtSectionIndexForBlock = { [unowned delegate] in delegate.controller($0, didChange: $1, atSectionIndex: $2, for: $3) }
        controllerWillChangeContentBlock = { [unowned delegate] in delegate.controllerWillChangeContent($0) }
        controllerDidChangeContentBlock = { [unowned delegate] in delegate.controllerDidChangeContent($0) }
        controllerSectionIndexTitleForSectionNameBlock = { [unowned delegate] in delegate.controller($0, sectionIndexTitleForSectionName: $1) }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        controllerDidChangeAtForNewIndexPathBlock(controller, anObject, indexPath, type, newIndexPath)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        controllerDidChangeAtSectionIndexForBlock(controller, sectionInfo, sectionIndex, type)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        controllerWillChangeContentBlock(controller)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        controllerDidChangeContentBlock(controller)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return controllerSectionIndexTitleForSectionNameBlock(controller, sectionName)
    }
}
