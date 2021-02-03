//
//  CoordinatorContext.swift
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
        with input: Input,
        _ offset: Index
    ) -> Output?
    
    func perform(updates: BatchUpdates, animated: Bool, completion: ((ListView, Bool) -> Void)?)
}
