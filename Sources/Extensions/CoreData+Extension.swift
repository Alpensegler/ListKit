//
//  CoreData+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

#if canImport(CoreData)
import CoreData
import Foundation

public struct SectionUpdates {
    public let insert: IndexSet
    public let remove: IndexSet
    public let reload: IndexSet
    
    public let allSourceChange: IndexSet
    public let allTargetChange: IndexSet
}

public struct ItemUpdates {
    public let insert: [IndexPath]
    public let remove: [IndexPath]
    public let reload: [IndexPath]
    public let moves: [(IndexPath, IndexPath)]
    
    public let allSourceChange: [IndexPath]
    public let allTargetChange: [IndexPath]
}

open class ListFetchedResultsController<Item>: NSObject, NSFetchedResultsControllerDelegate
where Item: NSFetchRequestResult {
    public struct Section {
        public let info: NSFetchedResultsSectionInfo
        public var indexTitle: String? { info.indexTitle }
        public var count: Int { info.numberOfObjects }
        public var name: String { info.name }
        public var items: [Item] { info.objects as? [Item] ?? [] }
    }
    
    public typealias SourceBase = ListFetchedResultsController<Item>
    public var fetchedResultController: NSFetchedResultsController<Item>
    public var listUpdate = ListUpdate<SourceBase>.Whole.reload
    public var listDiffer = ListDiffer<SourceBase>.diff
    public var listOptions = ListOptions()
    
    public var didChangeContent: (() -> Void)?
    public var willChangeContent: (() -> Void)?
    
    public var willStartUpdate: (() -> Void)?
    public var shouldUpdate: ((SourceBase) -> Bool)?
    public var didUpdate: ((SourceBase) -> Void)?
    public var updateCompletion: ((ListView, Bool) -> Void)?
    
    public var shouldReloadSection: ((SourceBase, NSFetchedResultsSectionInfo, Int) -> Bool)?
    public var shouldReloadItem: ((SourceBase, Item, IndexPath, IndexPath) -> Bool)?
    public var shouldMoveItem: ((SourceBase, Item, IndexPath, IndexPath) -> Bool)?
    
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
        
        guard shouldUpdate?(self) != false else { return }
        perform(.init(section: _section, item: _item), completion: updateCompletion)
        didUpdate?(self)
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
    public func section(at section: Int) -> Section {
        .init(info: fetchedResultController.sections![section])
    }
    
    public func items(at section: Int) -> [Item] {
        self.section(at: section).items
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        fetchedResultController.object(at: indexPath)
    }
    
    public func numbersOfSections() -> Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    public func numbersOfItem(in section: Int) -> Int {
        self.section(at: section).count
    }
}

public extension ListFetchedResultsController {
    var itemUpdates: ItemUpdates? {
        _item.map { items in
            .init(
                insert: items.changes.target.elements(),
                remove: items.changes.source.elements(),
                reload: items.reload.elements(),
                moves: items.move.elements().map { (items.moveDict[$0]!, $0) },
                allSourceChange: items.all.source.elements(),
                allTargetChange: items.all.target.elements()
            )
        }
    }
    
    var sectionUpdates: SectionUpdates? {
        _section.map {
            .init(
                insert: $0.changes.target,
                remove: $0.changes.source,
                reload: $0.reload,
                allSourceChange: $0.all.source,
                allTargetChange: $0.all.target
            )
        }
    }
}

extension ListFetchedResultsController {
    func prepareUpdate(section: inout ChangeSets<IndexSet>, item: inout ChangeSets<IndexPathSet>) {
        prepareUpdate(sets: &section)
        item.move.elements().forEach {
            guard let indexPath = item.moveDict[$0] else { fatalError() }
            let sourceShouldIgnore = section.all.source.contains(indexPath.section)
            let targetShouldIgnore = section.all.target.contains($0.section)
            switch (sourceShouldIgnore, targetShouldIgnore) {
            case (true, true):
                item.all.source.remove(indexPath)
                item.all.target.remove($0)
            case (true, false):
                item.all.source.remove(indexPath)
                item.changes.target.add($0)
            case (false, true):
                item.changes.source.add(indexPath)
                item.all.target.remove($0)
            case (false, false):
                return prepare(move: &item, from: indexPath, to: $0)
            }
            item.move.remove($0)
            item.moveDict[$0] = nil
        }
        item.reload.elements().forEach {
            guard let newIndexPath = item.reloadDict[$0] else { fatalError() }
            if section.all.source.contains($0.section) {
                item.all.source.remove($0)
                item.all.target.remove(newIndexPath)
                item.reload.remove($0)
                item.reloadDict[$0] = nil
            } else {
                prepare(reload: &item, from: newIndexPath, to: $0)
            }
        }
        item.changes.source.elements().forEach {
            guard section.all.source.contains($0.section) else { return }
            item.changes.source.remove($0)
            item.all.source.remove($0)
        }
        item.changes.target.elements().forEach {
            guard section.all.target.contains($0.section) else { return }
            item.changes.target.remove($0)
            item.all.target.remove($0)
        }
        update = .init(section: section, item: item)
    }
    
    func prepareUpdate(sets: inout ChangeSets<IndexSet>) {
        guard let shuoldReload = shouldReloadSection else { return }
        sets.reload.forEach {
            if shuoldReload(self, fetchedResultController.sections![$0], $0) { return }
            section.reload.remove($0)
            section.changes.source.insert($0)
            section.changes.target.insert($0)
            section.reloadDict[$0] = nil
        }
    }
    
    func prepareUpdate(sets: inout ChangeSets<IndexPathSet>) {
        if shouldMoveItem != nil {
            sets.move.elements().forEach { prepare(move: &sets, from: sets.moveDict[$0], to: $0) }
        }
        if shouldReloadItem != nil {
            sets.reload.elements().forEach {
                prepare(reload: &sets, from: $0, to: sets.reloadDict[$0])
            }
        }
    }
    
    func prepare(move sets: inout ChangeSets<IndexPathSet>, from: IndexPath!, to: IndexPath) {
        guard shouldMoveItem?(self, item(at: to), from, to) == false else { return }
        sets.move.remove(to)
        sets.changes.source.add(from)
        sets.changes.target.add(to)
        sets.moveDict[to] = nil
    }
    
    func prepare(reload sets: inout ChangeSets<IndexPathSet>, from: IndexPath, to: IndexPath!) {
        guard shouldReloadItem?(self, item(at: to), from, to) == false else { return }
        sets.reload.remove(from)
        sets.all.source.remove(from)
        sets.all.target.remove(to)
        sets.reloadDict[from] = nil
    }
}

#endif
