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
    
    lazy var selectorSets = initialSelectorSets()
    
    var cacheFromItem: ((SourceBase.Item) -> Any)?
    var hasCaches = false
    lazy var caches: ContiguousArray<ContiguousArray<RelatedCache>> = {
        hasCaches = true
        return getCaches
    }()
    
    var getCaches: ContiguousArray<ContiguousArray<RelatedCache>> {
        if coordinator.isEmpty { return .init() }
        return (0..<numbersOfSections()).mapContiguous {
            (0..<numbersOfItems(in: $0)).mapContiguous { _ in .init() }
        }
    }
    
    var index = 0
    var isSectioned = true
    var listViewGetter: ((ListCoordinator<SourceBase>) -> ListView?)?
    var parentUpdate: ((CoordinatorUpdate<SourceBase>?, Int) -> [(ListView, BatchUpdates)])?
    
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
