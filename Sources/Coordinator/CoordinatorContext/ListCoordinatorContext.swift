//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

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
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output {
        self[keyPath: keyPath].closure!(object, input, sectionOffset, itemOffset)
    }
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) {
        self[keyPath: keyPath].closure?(object, input, sectionOffset, itemOffset)
    }
}


extension ListCoordinatorContext {
    func set<Object: AnyObject, Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        _ closure: @escaping (ListCoordinatorContext<SourceBase>, Object, Input, Int, Int) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3) }
        let delegate = self[keyPath: keyPath]
        switch delegate.index {
        case .none:
            selectorSets.value.remove(delegate.selector)
        case .indexPath:
            selectorSets.withIndexPath.remove(delegate.selector)
        case .index:
            selectorSets.withIndex.remove(delegate.selector)
            selectorSets.hasIndex = true
        }
    }

    func set<Object: AnyObject, Input>(
        _ keyPath: ReferenceWritableKeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        _ closure: @escaping (ListCoordinatorContext<SourceBase>, Object, Input, Int, Int) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned self] in closure(self, $0, $1, $2, $3) }
        let delegate = self[keyPath: keyPath]
        selectorSets.void.remove(delegate.selector)
    }
}
