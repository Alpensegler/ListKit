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
    
    func isCoordinator<SourceBase>(_ coordinator: ListCoordinator<SourceBase>) -> Bool
    
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
    
    func apply<Object: AnyObject, Input, Output, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Output, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Output
    
    func apply<Object: AnyObject, Input, Index>(
        _ keyPath: KeyPath<CoordinatorContext, Delegate<Object, Input, Void, Index>>,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ sectionOffset: Int,
        _ itemOffset: Int
    )
}

extension CoordinatorContext {
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
    
    func initialSelectorSets(withoutIndex: Bool = false) -> SelectorSets {
        var selectorSets = SelectorSets()
        selectorSets.withoutIndex = withoutIndex
        
        #if os(iOS) || os(tvOS)
        scrollListDelegate.add(by: &selectorSets)
        collectionListDelegate.add(by: &selectorSets)
        tableListDelegate.add(by: &selectorSets)
        #endif
        
        return selectorSets
    }
}
