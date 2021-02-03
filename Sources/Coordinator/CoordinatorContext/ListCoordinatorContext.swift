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
    typealias Context = ListCoordinatorContext<SourceBase>
    
    let listCoordinator: ListCoordinator<SourceBase>
    
    var _itemCaches: Caches<Any>?
    var _itemNestedCache: Caches<((Any) -> Void)>?
    
    var listDelegate = ListDelegate()
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
    var update: ((Int, CoordinatorUpdate) -> [(CoordinatorContext, CoordinatorUpdate)]?)?
    var contextAtIndex: ((Int, IndexPath, ListView) -> [(IndexPath, CoordinatorContext)])?
    
    var listView: ListView? { listViewGetter?() }
    var extraSelectors: Set<Selector> { listDelegate.extraSelectors }
    var valid: Bool {
        guard let storage = listCoordinator.storage else { return true }
        return !storage.isObjectAssciated || storage.object != nil
    }
    
    init(_ coordinator: ListCoordinator<SourceBase>) {
        self.listCoordinator = coordinator
    }
    
    func context(with listDelegate: ListDelegate) -> Self {
        self.listDelegate.formUnion(delegate: listDelegate)
        return self
    }
    
    func isCoordinator(_ coordinator: AnyObject) -> Bool { self.listCoordinator === coordinator }
    
    func reconfig() { }
    func numbersOfSections() -> Int { listCoordinator.numbersOfSections() }
    func numbersOfItems(in section: Int) -> Int { listCoordinator.numbersOfItems(in: section) }
    func cache<ItemCache>(for cached: inout Any?, at indexPath: IndexPath) -> ItemCache {
        cached as? ItemCache ?? {
            guard let getCache = listDelegate.getCache as? (Item) -> ItemCache else {
                fatalError("\(SourceBase.self) no cache with \(ItemCache.self)")
            }
            let cache = getCache(listCoordinator.item(at: indexPath))
            cached = cache
            return cache
        }()
    }
    
    // Selectors
    @discardableResult
    func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        guard let c = listDelegate.functions[function.selector],
              let closure = c as? (ListContext<Object, SourceBase>, Input) -> Output
        else { return nil }
        return closure(.init(listView: object, context: self, root: root), input)
    }
    
    @discardableResult
    func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        guard let c = listDelegate.functions[function.selector],
              let closure = c as? (ListIndexContext<Object, SourceBase, Index>, Input) -> Output
        else { return nil }
        let index = function.indexForInput(input)
        return closure(.init(listView: object, index: index, offset: offset, context: self, root: root), input)
    }
    
    func contain(selector: Selector) -> Bool {
        listDelegate.contains(selector) || extraSelectors.contains(selector)
    }
    
    func cachesOrCreate<Cache>(_ caches: inout Caches<Cache>?) -> Caches<Cache> {
        caches.or((0..<numbersOfSections()).mapContiguous {
            (0..<numbersOfItems(in: $0)).mapContiguous { _ in nil }
        })
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
