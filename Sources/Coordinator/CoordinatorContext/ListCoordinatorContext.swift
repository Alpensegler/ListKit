//
//  ListCoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

public class ListCoordinatorContext<SourceBase: DataSource>: CoordinatorContext
where SourceBase.SourceBase == SourceBase {
    let coordinator: ListCoordinator<SourceBase>
    
    #if os(iOS) || os(tvOS)
    lazy var scrollListDelegate = UIScrollListDelegate()
    lazy var collectionListDelegate = UICollectionListDelegate()
    lazy var tableListDelegate = UITableListDelegate()
    #endif
    
    lazy var selectorSets = initialSelectorSets()
    
    
    var cacheFromItem: ((SourceBase.Item) -> Any)?
    
    var offset = 0
    var index = 0
    var isSectioned = true
    
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
    
    //Selectors
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
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input, Int, Int) -> Output
    ) {
        self[keyPath: keyPath].closure = { [unowned coordinator] in
            closure(coordinator, $0, $1, $2, $3)
        }
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
        _ closure: @escaping (ListCoordinator<SourceBase>, Object, Input, Int, Int) -> Void
    ) {
        self[keyPath: keyPath].closure = { [unowned coordinator] in
            closure(coordinator, $0, $1, $2, $3)
        }
        let delegate = self[keyPath: keyPath]
        selectorSets.void.remove(delegate.selector)
    }
}
