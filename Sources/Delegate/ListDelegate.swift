//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

public protocol FunctionOutput { }

public struct Function<List: DataSource, View, Input, Output, Closure> {
    public let selector: Selector
    public let list: List
    public var listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    let toClosure: (Closure) -> (ListContext<View>, Input) -> Output

    public func callAsFunction(closure: Closure) -> Self {
        toTarget(closure: toClosure(closure))
    }

    public func callAsFunction(_ output: Output) -> Self where Output: FunctionOutput {
        toTarget { _, _ in output }
    }

    func toTarget(closure: @escaping (ListContext<View>, Input) -> Output) -> Self {
        var function = self
        function.listCoordinatorContext.functions[selector] = { closure(.init(view: $0, context: $1), $2) }
        return self
    }

    init(selector: Selector, list: List, toClosure: @escaping (Closure) -> (ListContext<View>, Input) -> Output) {
        self.selector = selector
        self.list = list
        self.listCoordinator = list.listCoordinator
        var context = list.listCoordinatorContext
        context.selectors.insert(selector)
        self.listCoordinatorContext = context
        self.toClosure = toClosure
    }
}

public struct IndexFunction<List: DataSource, View, Input, Output, Closure, Index> {
    public let selector: Selector
    public let hasSectionIndex: Bool
    public let list: List
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    let indexForInput: (Input) -> Index
    let toClosure: (Closure) -> (ListIndexContext<View, Index>, Input) -> Output

    public func callAsFunction(closure: Closure) -> Self {
        toTarget(closure: toClosure(closure))
    }

    public func callAsFunction(_ output: Output) -> Self where Output: FunctionOutput {
        toTarget { _, _ in output }
    }

    public func callAsFunction(
        closure: @escaping (ListIndexContext<View, Index>, List.ContainType) -> Output
    ) -> Self where Closure == (ListIndexContext<View, Index>) -> Output, List: ContainerDataSource, Index == IndexPath {
        toTarget { context, _ in
            closure(context, context.containedType as! List.ContainType)
        }
    }

    func toTarget(
        closure: @escaping (ListIndexContext<View, Index>, Input) -> Output
    ) -> Self {
        var function = self
        function.listCoordinatorContext.functions[selector] = {
            closure(.init(view: $0, index: $3, offset: $4, context: $1), $2)
        }
        if hasSectionIndex {
            function.listCoordinatorContext.section.sectioned = true
        }
        return function
    }

    init(
        selector: Selector,
        hasSectionIndex: Bool,
        list: List,
        indexForInput: @escaping (Input) -> Index,
        toClosure: @escaping (Closure) -> (ListIndexContext<View, Index>, Input) -> Output
    ) {
        self.selector = selector
        self.hasSectionIndex = hasSectionIndex
        self.list = list
        self.listCoordinator = list.listCoordinator
        var context = list.listCoordinatorContext
        context.selectors.insert(selector)
        self.listCoordinatorContext = context
        self.indexForInput = indexForInput
        self.toClosure = toClosure
    }
}

extension Function: ListAdapter { }
extension Function: TableList where View == TableView { }
extension Function: CollectionList where View == CollectionView { }

extension IndexFunction: ListAdapter { }
extension IndexFunction: TableList where View == TableView { }
extension IndexFunction: CollectionList where View == CollectionView { }

extension String: FunctionOutput { }
extension Bool: FunctionOutput { }
extension Int: FunctionOutput { }
extension IndexPath: FunctionOutput { }
extension NSObject: FunctionOutput { }
extension Optional: FunctionOutput where Wrapped: FunctionOutput { }
extension Array: FunctionOutput where Element: FunctionOutput { }

#if canImport(UIKit)
import UIKit

extension UIEdgeInsets: FunctionOutput { }
extension CGSize: FunctionOutput { }
extension CGFloat: FunctionOutput { }
extension UITableViewCell.EditingStyle: FunctionOutput { }
#endif

// swiftlint:disable large_tuple
extension DataSource {
    func toClosure<Input, Output, Context>() -> (@escaping (Context) -> Output) -> (Context, Input) -> Output {
        { closure in { context, _ in closure(context) } }
    }

    func toClosure<Input, Output, Context>() -> (@escaping (Context, Input) -> Output) -> (Context, Input) -> Output {
        { closure in { context, input in closure(context, input) } }
    }

    func toClosure<Input1, Input2, Output, Context>() -> (@escaping (Context, Input1, Input2) -> Output) -> (Context, (Input1, Input2)) -> Output {
        { closure in { context, input in closure(context, input.0, input.1) } }
    }

//    func toClosure<Output, View>() -> (@escaping (ListIndexContext<View, IndexPath>) -> Output) -> (ListIndexContext<View, IndexPath>, IndexPath) -> Output {
//        { closure in { context, _ in closure(context) } }
//    }

    func toClosure<Input, Output, View>() -> (@escaping (ListIndexContext<View, IndexPath>, Input) -> Output) -> (ListIndexContext<View, IndexPath>, (IndexPath, Input)) -> Output {
        { closure in { context, input in closure(context, input.1) } }
    }

    func toClosure<Input1, Input2, Output, View>() -> (@escaping (ListIndexContext<View, IndexPath>, Input1, Input2) -> Output) -> (ListIndexContext<View, IndexPath>, (IndexPath, Input1, Input2)) -> Output {
        { closure in { context, input in closure(context, input.1, input.2) } }
    }

    func toClosure<Input, Output, View>() -> (@escaping (ListIndexContext<View, Int>, Input) -> Output) -> (ListIndexContext<View, Int>, (Int, Input)) -> Output {
        { closure in { context, input in closure(context, input.1) } }
    }
    
    func toFunction<Input, Output, Closure, View>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListKit.ListContext<View>, Input) -> Output
    ) -> Function<Self, View, Input, Output, Closure> {
        .init(selector: selector, list: self, toClosure: toClosure)
    }

    func toFunction<Input, Output, Closure, View, Index: ListIndex>(
        _ selector: Selector,
        _ indexForInput: @escaping (Input) -> Index,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Index>, Input) -> Output
    ) -> IndexFunction<Self, View, Input, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, list: self, indexForInput: indexForInput, toClosure: toClosure)
    }

    func toFunction<Output, Closure, View, Index: ListIndex>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Index>, Index) -> Output
    ) -> IndexFunction<Self, View, Index, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, list: self, indexForInput: { $0 }, toClosure: toClosure)
    }
}
// swiftlint:enable large_tuple
