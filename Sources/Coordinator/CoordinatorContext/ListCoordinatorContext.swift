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
    
    let coordinator: ListCoordinator<SourceBase>
    
    #if os(iOS) || os(tvOS)
    lazy var scrollListDelegate = UIScrollListDelegate()
    lazy var collectionListDelegate = UICollectionListDelegate()
    lazy var tableListDelegate = UITableListDelegate()
    #endif
    
    var hasItemCaches = false
    var hasNestedCaches = false
    
    lazy var selfSelectorSets = initialSelectorSets()
    lazy var itemCaches: ContiguousArray<ContiguousArray<Any?>> = {
        hasItemCaches = true
        return initialCaches()
    }()
    
    lazy var itemNestedCache: ContiguousArray<ContiguousArray<((Any) -> Void)?>> = {
        hasNestedCaches = true
        return initialCaches()
    }()
    
    var index = 0
    var isSectioned = true
    var listViewGetter: (() -> ListView?)?
    var resetDelegates: (() -> Void)?
    var update: ((Int, CoordinatorUpdate, Bool) -> [(CoordinatorContext, CoordinatorUpdate)])?
    
    var listView: ListView? { listViewGetter?() }
    var selectorSets: SelectorSets { selfSelectorSets }
    
    init(
        _ coordinator: ListCoordinator<SourceBase>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) {
        self.coordinator = coordinator
        setups.forEach { $0(self) }
    }
    
    func isCoordinator(_ coordinator: AnyObject) -> Bool { self.coordinator === coordinator }
    
    func reconfig() { }
    func numbersOfSections() -> Int { coordinator.numbersOfSections() }
    func numbersOfItems(in section: Int) -> Int { coordinator.numbersOfItems(in: section) }
    
    // Selectors
    func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output? {
        self[keyPath: keyPath].closure?(object, input, root, sectionOffset, itemOffset)
    }
    
    func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        self[keyPath: keyPath].closure?(object, input, root, sectionOffset, itemOffset)
    }
    
    func perform(updates: BatchUpdates, animated: Bool, completion: ((ListView, Bool) -> Void)?) {
        guard let list = listView else { return }
        switch updates {
        case let .reload(change: change):
            change?()
            list.reloadSynchronously(animated: animated)
            completion?(list, true)
        case let .batch(batchUpdates):
            for (offset, batchUpdate) in batchUpdates.enumerated() {
                Log.log("---batch-update---")
                Log.log(batchUpdate.description)
                let isLast = offset == batchUpdates.count - 1
                let completion: ((Bool) -> Void)? = isLast ? { [weak list] finish in
                    list.map { completion?($0, finish) }
                } : nil
                list.perform({
                    switch (hasItemCaches, hasNestedCaches) {
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
    func initialCaches<Cache>() -> ContiguousArray<ContiguousArray<Cache?>> {
        if coordinator.isEmpty { return .init() }
        return (0..<numbersOfSections()).mapContiguous {
            (0..<numbersOfItems(in: $0)).mapContiguous { _ in nil }
        }
    }
    
    func set<Object: AnyObject, Input, Output, Index>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, Delegate<Object, Input, Output, Index>>,
        _ closure: @escaping (ListCoordinatorContext<SourceBase>, Object, Input, CoordinatorContext, Int, Int) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3, $4) }
        let delegate = self[keyPath: keyPath]
        if Index.self == Int.self {
            selectorSets.withIndex.remove(delegate.selector)
            selectorSets.hasIndex = true
        } else if Index.self == IndexPath.self {
            selectorSets.withIndexPath.remove(delegate.selector)
        } else {
            selectorSets.value.remove(delegate.selector)
        }
    }

    func set<Object: AnyObject, Input, Index>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, Delegate<Object, Input, Void, Index>>,
        _ closure: @escaping (ListCoordinatorContext<SourceBase>, Object, Input, CoordinatorContext, Int, Int) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3, $4) }
        let delegate = self[keyPath: keyPath]
        selectorSets.void.remove(delegate.selector)
    }
}
