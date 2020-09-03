//
//  CoreData+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

#if canImport(CoreData)
import CoreData
import Foundation

public class ListFetchedResultsController<Item>: NSObject, NSFetchedResultsControllerDelegate
where Item: NSFetchRequestResult {
    public var fetchedResultController: NSFetchedResultsController<Item>
    public var listUpdate = ListUpdate<ListFetchedResultsController<Item>>.Whole.appendOrRemoveLast
    public var listDiffer = ListDiffer<ListFetchedResultsController<Item>>.diff
    public var listOptions = ListOptions<ListFetchedResultsController<Item>>.keepEmptySection
    public var didChangeContent: (() -> Void)?
    public var willChangeContent: (() -> Void)?
    
    public var willStartUpdate: (() -> Void)?
    public var updateCompletion: ((ListView, Bool) -> Void)?
    
    public var insertSection: ((NSFetchedResultsSectionInfo, Int) -> Void)?
    public var removeSection: ((Int) -> Void)?
    public var shouldReloadSection: ((NSFetchedResultsSectionInfo, Int) -> Bool)?
    
    public var insertItem: ((Item, IndexPath) -> Void)?
    public var removeItem: ((IndexPath) -> Void)?
    public var shouldReloadItem: ((Item, IndexPath) -> Bool)?
    public var shouldMoveItem: ((Item, IndexPath) -> Bool)?
    
    var update: ListUpdate<SourceBase>!
    var _section: ChangeSets<IndexSet>?
    var _item: ChangeSets<IndexPathSet>?
    
    var section: ChangeSets<IndexSet> {
        get { _section ?? .init() }
        set { _section = newValue }
    }
    
    var item: ChangeSets<IndexPathSet> {
        get { _item ?? .init() }
        set { _item = newValue }
    }
    
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
        (_section, _item) = (nil, nil)
        willChangeContent?()
    }
    
    public func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        willStartUpdate?()
        defer { didChangeContent?() }
        switch (_section, _item) {
        case (.some, .some): prepareUpdate(section: &section, item: &item)
        case (nil, .some): prepareUpdate(sets: &item)
        case (.some, nil): prepareUpdate(sets: &section)
        case (nil, nil): return
        }
        perform(.init(section: _section, item: _item), completion: updateCompletion)
    }
    
    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert: section.insert(sectionIndex)
        case .delete: section.delete(sectionIndex)
        case .update: section.reload(sectionIndex, newIndex: sectionIndex)
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
        case .insert: item.insert(newIndexPath!)
        case .delete: item.delete(indexPath!)
        case .update: item.reload(indexPath!, newIndex: newIndexPath!)
        case .move: item.move(indexPath!, to: newIndexPath!)
        default: break
        }
    }
}

extension ListFetchedResultsController: NSDataSource {
    public func items(at section: Int) -> [Item] {
        fetchedResultController.sections?[section].objects as? [Item] ?? []
    }
    
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

extension ListFetchedResultsController {
    func prepareUpdate(section: inout ChangeSets<IndexSet>, item: inout ChangeSets<IndexPathSet>) {
        prepareUpdate(sets: &section)
        item.move.elements().forEach {
            guard let indexPath = item.dict[$0] else { return }
            let sourceShouldIgnore = section.all.source.contains(indexPath.section)
            let targetShouldIgnore = section.all.target.contains($0.section)
            switch (sourceShouldIgnore, targetShouldIgnore) {
            case (true, true):
                break
            case (true, false):
                item.changes.target.add($0)
            case (false, true):
                item.changes.source.add(indexPath)
            case (false, false):
                prepare(sets: &item, from: indexPath, to: $0, path: \.move, shouldMoveItem)
                return
            }
            item.dict[$0] = nil
        }
        item.reload.elements().forEach {
            guard let indexPath = item.dict[$0] else { return }
            if section.all.target.contains($0.section) {
                item.reload.remove($0)
                item.all.source.remove(indexPath)
                item.all.target.remove($0)
                item.dict[$0] = nil
            } else {
                prepare(sets: &item, from: indexPath, to: $0, path: \.reload, shouldReloadItem)
            }
        }
        item.changes.source.elements().forEach {
            guard section.all.source.contains($0.section) else {
                removeItem?($0)
                return
            }
            item.changes.source.remove($0)
            item.all.source.remove($0)
        }
        item.changes.target.elements().forEach {
            guard section.all.target.contains($0.section) else {
                insertItem?(self.item(at: $0), $0)
                return
            }
            item.changes.target.remove($0)
            item.all.target.remove($0)
        }
        update = .init(section: section, item: item)
    }
    
    func prepareUpdate(sets: inout ChangeSets<IndexSet>) {
        if let remove = removeSection { sets.changes.source.forEach(remove) }
        if let insert = insertSection {
            sets.changes.target.forEach { insert(fetchedResultController.sections![$0], $0) }
        }
        if let shuoldReload = shouldReloadSection {
            sets.reload.forEach {
                if shuoldReload(fetchedResultController.sections![$0], $0) { return }
                section.reload.remove($0)
                section.changes.source.insert($0)
                section.changes.target.insert($0)
                section.dict[$0] = nil
            }
        }
    }
    
    func prepareUpdate(sets: inout ChangeSets<IndexPathSet>) {
        if let remove = removeItem { sets.changes.source.elements().forEach(remove) }
        if let insert = insertItem {
            sets.changes.target.elements().forEach { insert(item(at: $0), $0) }
        }
        if let shouldMoveItem = shouldMoveItem {
            sets.move.elements().forEach {
                prepare(sets: &sets, from: sets.dict[$0], to: $0, path: \.move, shouldMoveItem)
            }
        }
        if let shouldReloadItem = shouldReloadItem {
            sets.reload.elements().forEach {
                prepare(sets: &sets, from: sets.dict[$0], to: $0, path: \.reload, shouldReloadItem)
            }
        }
    }
    
    func prepare(
        sets: inout ChangeSets<IndexPathSet>,
        from: IndexPath?,
        to: IndexPath,
        path: WritableKeyPath<ChangeSets<IndexPathSet>, IndexPathSet>,
        _ shouldUpdate: ((Item, IndexPath) -> Bool)?
    ) {
        guard let from = from, shouldUpdate?(item(at: to), from) == false else { return }
        sets[keyPath: path].remove(to)
        sets.changes.source.add(from)
        sets.changes.target.add(to)
        sets.dict[to] = nil
    }
}

#endif
