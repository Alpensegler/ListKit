//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

public class ListCoordinatorContext<SourceBase: DataSource>: CoordinatorContext
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Caches<Cache> = ContiguousArray<ContiguousArray<Cache?>>
    
    let listCoordinator: ListCoordinator<SourceBase>
    
    #if os(iOS) || os(tvOS)
    lazy var scrollListDelegate = UIScrollListDelegate()
    lazy var collectionListDelegate = UICollectionListDelegate()
    lazy var tableListDelegate = UITableListDelegate()
    #endif
    
    var _itemCaches: Caches<Any>?
    var _itemNestedCache: Caches<((Any) -> Void)>?
    
    lazy var selfSelectorSets = SelectorSets()
    var itemCaches: Caches<Any> {
        get { cachesOrCreate(&_itemCaches) }
        set { _itemCaches = newValue }
    }
    
    var itemNestedCache: Caches<((Any) -> Void)> {
        get { cachesOrCreate(&_itemNestedCache) }
        set { _itemNestedCache = newValue }
    }
    
    var index = 0
    var isSectioned = true
    var listViewGetter: (() -> ListView?)?
    var resetDelegates: (() -> Void)?
    var update: ((Int, CoordinatorUpdate) -> [(CoordinatorContext, CoordinatorUpdate)])?
    var contextAtIndex: ((Int, IndexPath, ListView) -> [(IndexPath, CoordinatorContext)])?
    
    var listView: ListView? { listViewGetter?() }
    var selectorSets: SelectorSets { selfSelectorSets }
    
    init(
        _ coordinator: ListCoordinator<SourceBase>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) {
        self.listCoordinator = coordinator
        setups.forEach { $0(self) }
    }
    
    func isCoordinator(_ coordinator: AnyObject) -> Bool { self.listCoordinator === coordinator }
    
    func reconfig() { }
    func numbersOfSections() -> Int { listCoordinator.numbersOfSections() }
    func numbersOfItems(in section: Int) -> Int { listCoordinator.numbersOfItems(in: section) }
    
    // Selectors
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input, root)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) {
        self[keyPath: keyPath].closure?(object, input, root)
    }
    
    func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        self[keyPath: keyPath].closure?(object, input, root, offset)
    }
    
    func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) {
        self[keyPath: keyPath].closure?(object, input, root, offset)
    }
    
    func perform(updates: BatchUpdates, animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        guard let list = listView else { return }
        switch updates {
        case let .reload(change: change):
            (_itemCaches, _itemNestedCache) = (nil, nil)
            change?()
            list.reloadSynchronously(animated: animated)
            completion?(list, true)
        case let .batch(batchUpdates):
            for (offset, batchUpdate) in batchUpdates.enumerated() {
                let isLast = offset == batchUpdates.count - 1
                Log.log("---batch-update-isLast: \(isLast)---")
                Log.log(batchUpdate.description)
                let completion: ((Bool) -> Void)? = isLast ? { [weak list] finish in
                    list.map { completion?($0, finish) }
                } : nil
                list.perform({
                    switch (_itemCaches != nil, _itemNestedCache != nil) {
                    case (true, true):
                        batchUpdate.apply(caches: &itemCaches, countIn: numbersOfItems(in:)) {
                            $0.apply(caches: &itemNestedCache, countIn: numbersOfItems(in:))
                        }
                    case (true, false):
                        batchUpdate.apply(caches: &itemCaches, countIn: numbersOfItems(in:))
                    case (false, true):
                        batchUpdate.apply(caches: &itemNestedCache, countIn: numbersOfItems(in:))
                    case (false, false):
                        batchUpdate.applyData()
                    }
                    batchUpdate.apply(by: list)
                }, animated: animated, completion: completion)
            }
        }
    }
}


extension ListCoordinatorContext {
    typealias Context = ListCoordinatorContext<SourceBase>
    
    func cachesOrCreate<Cache>(_ caches: inout Caches<Cache>?) -> Caches<Cache> {
        caches.or((0..<numbersOfSections()).mapContiguous {
            (0..<numbersOfItems(in: $0)).mapContiguous { _ in nil }
        })
    }
    
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        _ closure: @escaping (Context, Object, Input, CoordinatorContext) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2) }
        selfSelectorSets.value.insert(self[keyPath: keyPath].selector)
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        _ closure: @escaping (Context, Object, Input, CoordinatorContext) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2) }
        selfSelectorSets.void.insert(self[keyPath: keyPath].selector)
    }
    
    func set<Object: AnyObject, Input, Output, Index>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        _ closure: @escaping (Context, Object, Input, CoordinatorContext, Index) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3) }
        if Index.isSection {
            selfSelectorSets.withIndex.insert(self[keyPath: keyPath].selector)
        } else {
            selfSelectorSets.withIndexPath.insert(self[keyPath: keyPath].selector)
        }
    }
    
    func set<Object: AnyObject, Input, Index>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, IndexDelegate<Object, Input, Void, Index>>,
        _ closure: @escaping (Context, Object, Input, CoordinatorContext, Index) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3) }
        selfSelectorSets.void.insert(self[keyPath: keyPath].selector)
    }
}
