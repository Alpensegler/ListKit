//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

import Foundation

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
    
    func updateFrom(_ cache: ItemRelatedCache) {
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
    struct UnownedListContext {
        unowned var context: ListContext
        
        init(_ context: ListContext) {
            self.context = context
        }
    }
    
    typealias Item = SourceBase.Item
    
    weak var storage: CoordinatorStorage<SourceBase>?
    var listContexts = [ObjectIdentifier: UnownedListContext]() {
        didSet {
            switch (oldValue.isEmpty, listContexts.isEmpty) {
            case (true, false): storage?.coordinators[ObjectIdentifier(self)] = self
            case (false, true): storage?.coordinators[ObjectIdentifier(self)] = nil
            default: break
            }
        }
    }
    
    var contexts: [(Int, Int, ListView, ListContext?)] {
        listContexts.values.flatMap { $0.context.contexts() }
    }
    
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
    var didSetup = false
    
    var defaultUpdate = ListUpdate<Item>()
    var differ = Differ<SourceBase>()
    var options = DataSourceOptions()
    
    var source: SourceBase.Source!
    
    init(
        id: AnyHashable = ObjectIdentifier(SourceBase.self),
        defaultUpdate: ListUpdate<Item> = .init(),
        differ: Differ<SourceBase> = .init(),
        options: DataSourceOptions = .init(),
        source: SourceBase.Source!,
        storage: CoordinatorStorage<SourceBase>?
    ) {
        self.id = id
        self.storage = storage
        self.defaultUpdate = defaultUpdate
        self.differ = differ
        self.source = source
        self.options = options
    }
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        self.id = ObjectIdentifier(SourceBase.self)
        self.storage = storage
        self.defaultUpdate = sourceBase.listUpdate
        self.differ = sourceBase.differ
        self.source = sourceBase.source(storage: storage)
        self.options = sourceBase.dataSourceOptions
    }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
    
    func item(at path: IndexPath) -> Item { fatalError() }
    func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache { fatalError() }
    
    //Diffs:
    func identifier(for sourceBase: SourceBase) -> AnyHashable {
        guard let identifier = differ.identifier else {
            return HashCombiner(id, sourceType, multiType)
        }
        return HashCombiner(id, sourceType, multiType, identifier(sourceBase))
    }
    
    func equal(lhs: SourceBase, rhs: SourceBase) -> Bool {
        differ.areEquivalent?(lhs, rhs) ?? true
    }
    
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
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input, sectionOffset, itemOffset)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        self[keyPath: keyPath].closure?(object, input, sectionOffset, itemOffset)
    }
    
    func selectorSets(applying: (inout SelectorSets) -> Void) {
        applying(&selectorSets)
    }
    
    //Setup
    
    func setup() { }
    
    func setupContext(listContext: ListContext) {
        listContexts[ObjectIdentifier(listContext)] = .init(listContext)
    }
    
    func removeContext(listContext: ListContext) {
        listContexts[ObjectIdentifier(listContext)] = nil
    }
}

extension ListCoordinator {
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<Coordinator, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input, Int, Int) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none:
            selectorSets { $0.value.remove(delegate.selector) }
        case .indexPath:
            selectorSets { $0.withIndexPath.remove(delegate.selector) }
        case .index:
            selectorSets {
                $0.withIndex.remove(delegate.selector)
                $0.hasIndex = true
            }
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<Coordinator, Delegate<Object, Input, Void>>,
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input, Int, Int) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3) }
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
//        for (sectionOffset, itemOffset, listView, context) in contexts {
//            if context != nil {
//                
//            } else {
//                listView.reloadSynchronously(animated: animated)
//                completion?(listView, true)
//            }
//        }
    }
    
    func perform(
        diff differ: Differ<Item>,
        to source: SourceBase.Source,
        _ animated: Bool,
        _ completion: ((ListView, Bool) -> Void)?,
        _ updateData: ((SourceBase.Source) -> Void)?
    ) {
        let contexts = self.contexts
        if contexts.isEmpty { return }
        let change = updateData.map { update in { update(self.source) } }
        let difference = self.difference(to: source, differ: differ)
        guard difference.updates != nil else {
            contexts.forEach { completion?($0.2, true) }
            return
        }
        for (sectionOffset, itemOffset, listView, context) in contexts {
            let updates = difference.generateListUpdates(itemSources: context?.itemSources)
            listView.perform(
                updates: updates,
                sectionOffset: sectionOffset,
                itemOffset: itemOffset,
                animated: animated,
                change: change,
                completion: completion
            )
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
    
}

extension ListCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
