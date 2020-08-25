//
//  CoordinatorContext.swift
//  ListKit
//
//  Created by Frain on 2020/6/8.
//

protocol CoordinatorContext: AnyObject {
    #if os(iOS) || os(tvOS)
    var scrollListDelegate: UIScrollListDelegate { get set }
    var collectionListDelegate: UICollectionListDelegate { get set }
    var tableListDelegate: UITableListDelegate { get set }
    #endif
    
    var selectorSets: SelectorSets { get }
    var itemCaches: ContiguousArray<ContiguousArray<Any?>> { get set }
    var itemNestedCache: ContiguousArray<ContiguousArray<((Any) -> Void)?>> { get set }
    
    func isCoordinator(_ coordinator: AnyObject) -> Bool
    
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
    
    func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output?
    
    func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, IndexDelegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    )
    
    func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output
    
    func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    )
    
    func perform(updates: BatchUpdates, animated: Bool, completion: ((ListView, Bool) -> Void)?)
}
