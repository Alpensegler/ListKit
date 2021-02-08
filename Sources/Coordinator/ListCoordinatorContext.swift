//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

import Foundation

protocol CoordinatorContext: AnyObject {
    var valid: Bool { get }
    var itemCaches: ContiguousArray<ContiguousArray<Any?>> { get set }
    var itemNestedCache: ContiguousArray<ContiguousArray<((Any) -> Void)?>> { get set }
    
    func isCoordinator(_ coordinator: AnyObject) -> Bool
    
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
    
    func contain(selector: Selector) -> Bool
    
    func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output?
    
    func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output?
    
    func perform(updates: BatchUpdates, animated: Bool, completion: ((ListView, Bool) -> Void)?)
}

public final class ListCoordinatorContext<SourceBase: DataSource>: CoordinatorContext
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Caches<Cache> = ContiguousArray<ContiguousArray<Cache?>>
    
    let listCoordinator: ListCoordinator<SourceBase>
    
    var _itemCaches: Caches<Any>?
    var _itemNestedCache: Caches<((Any) -> Void)>?
    
    var listDelegate = ListDelegate()
    
    var index = 0
    var isSectioned = true
    var listViewGetter: (() -> ListView?)?
    var resetDelegates: (() -> Void)?
    var update: ((Int, CoordinatorUpdate) -> [(CoordinatorContext, CoordinatorUpdate)]?)?
    var contextAtIndex: ((Int, IndexPath, ListView) -> [(IndexPath, CoordinatorContext)])?
    
    lazy var extraSelectors: Set<Selector> = {
        guard listDelegate.extraSelectors.isEmpty else { return listDelegate.extraSelectors }
        return listCoordinator.configExtraSelector() ?? []
    }()
    
    var listView: ListView? { listViewGetter?() }
    var valid: Bool {
        guard let storage = listCoordinator.storage else { return true }
        return !storage.isObjectAssciated || storage.object != nil
    }
    
    var itemCaches: Caches<Any> {
        get { cachesOrCreate(&_itemCaches) }
        set { _itemCaches = newValue }
    }
    
    var itemNestedCache: Caches<((Any) -> Void)> {
        get { cachesOrCreate(&_itemNestedCache) }
        set { _itemNestedCache = newValue }
    }
    
    init(_ coordinator: ListCoordinator<SourceBase>, listDelegate: ListDelegate = .init()) {
        self.listCoordinator = coordinator
        self.listDelegate = listDelegate
        coordinator.listContexts.append(.init(context: self))
    }
    
    func context(with listDelegate: ListDelegate) -> Self {
        self.listDelegate.formUnion(delegate: listDelegate)
        return self
    }
    
    func isCoordinator(_ coordinator: AnyObject) -> Bool { self.listCoordinator === coordinator }
    
    func reconfig() { }
    func numbersOfSections() -> Int { listCoordinator.numbersOfSections() }
    func numbersOfItems(in section: Int) -> Int { listCoordinator.numbersOfItems(in: section) }
    
    // Selectors
    @discardableResult
    func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        listCoordinator.apply(function, for: self, root: root, object: object, with: input)
    }
    
    @discardableResult
    func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        listCoordinator.apply(function, for: self, root: root, object: object, with: input, .zero)
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
                    if listDelegate.extraSelectors.isEmpty,
                       let selectors = listCoordinator.configExtraSelector() {
                        extraSelectors = selectors
                        listView?.resetDelegates(toNil: false)
                    }
                }, animated: animated, completion: completion)
            }
        }
    }
}
