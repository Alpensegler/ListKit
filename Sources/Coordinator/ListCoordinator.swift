//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

import Foundation

final class ListContext {
    weak var listView: ListView?
    weak var supercoordinator: Coordinator?
    var sectionOffset: Int
    var itemOffset: Int
    
    init(listView: ListView?, sectionOffset: Int, itemOffset: Int, supercoordinator: Coordinator?) {
        self.listView = listView
        self.sectionOffset = sectionOffset
        self.itemOffset = itemOffset
        self.supercoordinator = supercoordinator
    }
}

final class ItemRelatedCache {
    var nestedAdapterItemUpdateDidConfig = false
    var cacheForItemDidConfig = false
    
    lazy var nestedAdapterItemUpdate: [AnyHashable: (Bool, (Any) -> Void)] = {
        nestedAdapterItemUpdateDidConfig = true
        return .init()
    }()
    
    lazy var cacheForItem: [ObjectIdentifier: Any] = {
        cacheForItemDidConfig = true
        return .init()
    }()
    
    func from(cache: ItemRelatedCache) {
        if cache.nestedAdapterItemUpdateDidConfig {
            nestedAdapterItemUpdate = cache.nestedAdapterItemUpdate
            nestedAdapterItemUpdateDidConfig = true
        }
        if cache.cacheForItemDidConfig {
            cacheForItem = cache.cacheForItem
            cacheForItemDidConfig = true
        }
    }
}

public class ListCoordinator<SourceBase: DataSource>: Coordinator
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    
    weak var storage: CoordinatorStorage<SourceBase>?
    lazy var selectorSets = initialSelectorSets()
    
    #if os(iOS) || os(tvOS)
    lazy var scrollListDelegate = UIScrollListDelegate()
    lazy var collectionListDelegate = UICollectionListDelegate()
    lazy var tableListDelegate = UITableListDelegate()
    #endif
    
    //Source Diffing
    var didUpdateToCoordinator = [(Coordinator, Coordinator) -> Void]()
    var didUpdateIndices = [() -> Void]()
    
    var id: AnyHashable
    
    var sourceType = SourceType.cell
    var multiType: SourceMultipleType { .sources }
    var isEmpty: Bool { false }
    
    var cacheFromItem: ((Item) -> Any)?
    var listContexts = [ObjectIdentifier: ListContext]()
    var didSetup = false
    
    var defaultUpdate = ListUpdate<Item>()
    var differ = Differ<SourceBase>()
    
    var source: SourceBase.Source!
    
    init(
        id: AnyHashable = ObjectIdentifier(SourceBase.self),
        defaultUpdate: ListUpdate<Item> = .init(),
        source: SourceBase.Source!,
        storage: CoordinatorStorage<SourceBase>?
    ) {
        self.id = id
        self.storage = storage
        self.defaultUpdate = defaultUpdate
        self.source = source
        storage?.coordinators.append(self)
    }
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        self.id = ObjectIdentifier(SourceBase.self)
        self.storage = storage
        self.defaultUpdate = sourceBase.listUpdate
        self.source = sourceBase.source(storage: storage)
        storage?.coordinators.append(self)
    }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
    
    func item(at path: IndexPath) -> Item { fatalError() }
    func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache { fatalError() }
    
    //Diffs:
    func difference<Value>(from: Coordinator, differ: Differ<Value>?) -> CoordinatorDifference? {
        fatalError("should be implemented by subclass")
    }
    
    func difference(to source: SourceBase.Source, differ: Differ<Item>) -> CoordinatorDifference {
        fatalError("should be implemented by subclass")
    }
    
    func updateTo(_ source: SourceBase.Source) {
        fatalError("should be implemented by subclass")
    }
    
    //Selectors
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        self[keyPath: keyPath].closure?(object, input)
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    //Setup
    
    func setup() { }
    
    func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: Coordinator? = nil
    ) {
        if let context = listContexts[key] {
            context.sectionOffset = sectionOffset
            context.itemOffset = itemOffset
            return
        }
        
        let context = ListContext(
            listView: listView,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        listContexts[key] = context
    }
}

extension ListCoordinator {
    func offset(for object: AnyObject) -> (Int, Int) {
        guard let context = listContexts[ObjectIdentifier(object)] else { return (0, 0) }
        return (context.sectionOffset, context.itemOffset)
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Coordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none: selectorSets { $0.value.remove(delegate.selector) }
        case .indexPath: selectorSets { $0.withIndexPath.remove(delegate.selector) }
        case .index:
            selectorSets {
                $0.withIndex.remove(delegate.selector)
                $0.hasIndex = true
            }
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<Coordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1) }
        let delegate = self[keyPath: keyPath]
        selectorSets { $0.void.remove(delegate.selector) }
    }
}

//Updating
extension ListCoordinator {
    func performReload(
        to sourceBase: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        updateTo(sourceBase)
        updateData?(sourceBase)
        for context in listContexts.values {
            guard let listView = context.listView else { continue }
            if let coordinator = context.supercoordinator {
                _ = coordinator
            } else {
                context.listView?.reloadSynchronously(animated: animated)
                completion?(listView, true)
            }
        }
    }
    
    func perform(
        diff differ: Differ<Item>,
        to source: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        let updates = difference(to: source, differ: differ).generateUpdates()
        for context in listContexts.values {
            guard let listView = context.listView else { continue }
            listView.perform(updates: updates, animated: animated, completion: completion)
        }
    }
    
    func perform(
        _ update: ListUpdate<Item>,
        to source: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        Log.log("update from \(self.source!)")
        Log.log("update to   \(source)")
        switch update.way {
        case .diff(let diff):
            perform(diff: diff, to: source, animated, completion, updateData)
        case .reload:
            performReload(to: source, animated, completion, updateData)
        }
    }
    
    func removeCurrent(animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        
    }
    
    func update(
        from coordinator: Coordinator,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) -> Bool {
        false
    }
    
}

extension ListCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
