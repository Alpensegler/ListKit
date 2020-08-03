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
    
    lazy var selectorSets = initialSelectorSets()
    lazy var itemCaches: [AnyHashable: Any] = {
        hasItemCaches = true
        return .init()
    }()
    
    lazy var itemNestedCache: [AnyHashable: (Any) -> Void] = {
        hasNestedCaches = true
        return .init()
    }()
    
    var index = 0
    var isSectioned = true
    var listViewGetter: ((ListCoordinator<SourceBase>) -> ListView?)?
    var parentUpdate: ((CoordinatorUpdate<SourceBase>?, Int) -> [(CoordinatorContext, BatchUpdates)])?
    
    var listView: ListView? { listViewGetter?(coordinator) }
    
    init(
        _ coordinator: ListCoordinator<SourceBase>,
        setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) {
        self.coordinator = coordinator
        setups.forEach { $0(self) }
    }
    
    func isCoordinator<SourceBase>(_ coordinator: ListCoordinator<SourceBase>) -> Bool {
        self.coordinator === coordinator
    }
    
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
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input, root, sectionOffset, itemOffset)
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
                Log.log("------------------------------")
                Log.log(batchUpdate.description)
                let isLast = offset == batchUpdates.count - 1
                let completion: ((Bool) -> Void)? = isLast ? { [weak list] finish in
                    list.map { completion?($0, finish) }
                } : nil
                list.perform({
                    if hasItemCaches { batchUpdate.apply(by: &itemCaches) }
                    batchUpdate.apply(by: list)
                }, animated: animated, completion: completion)
            }
        }
    }
}


extension ListCoordinatorContext {
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
