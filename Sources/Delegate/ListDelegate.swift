//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

public protocol FunctionOutput { }

public struct Function<V, List, Input, Output, Closure>: ListAdapter {
    public typealias View = V
    public let selector: Selector
    public let list: List
    public var listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    let toClosure: (Closure) -> (ListContext<V>, Input) -> Output

    public func callAsFunction(closure: Closure) -> Modifier<V, List> {
        toTarget(closure: toClosure(closure))
    }

    public func callAsFunction(_ output: Output) -> Modifier<V, List> where Output: FunctionOutput {
        toTarget { _, _ in output }
    }

    func toTarget(closure: @escaping (ListContext<V>, Input) -> Output) -> Modifier<V, List> {
        var listCoordinatorContext = self.listCoordinatorContext
        listCoordinatorContext.functions[selector] = { closure(.init(view: $0, context: $1), $2) }
        return .init(list: list, listCoordinator: listCoordinator, listCoordinatorContext: listCoordinatorContext)
    }

    init(
        selector: Selector,
        list: List,
        listCoordinator: ListCoordinator,
        listCoordinatorContext: ListCoordinatorContext,
        toClosure: @escaping (Closure) -> (ListContext<V>, Input) -> Output
    ) {
        self.selector = selector
        self.list = list
        self.listCoordinator = listCoordinator
        var context = listCoordinatorContext
        context.selectors.insert(selector)
        self.listCoordinatorContext = context
        self.toClosure = toClosure
    }
}

public struct IndexFunction<V, List, Input, Output, Closure, Index>: ListAdapter {
    public typealias View = V
    public let selector: Selector
    public let hasSectionIndex: Bool
    public let list: List
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    let indexForInput: (Input) -> Index
    let toClosure: (Closure) -> (ListIndexContext<V, Index>, Input) -> Output

    public func callAsFunction(closure: Closure) -> Modifier<V, List> {
        toTarget(closure: toClosure(closure))
    }

    public func callAsFunction(_ output: Output) -> Modifier<V, List> where Output: FunctionOutput {
        toTarget { _, _ in output }
    }

    public func callAsFunction(
        closure: @escaping (ListIndexContext<V, Index>, List.Element) -> Output
    ) -> Modifier<V, List> where Closure == (ListIndexContext<V, Index>) -> Output, List: TypedListAdapter, Index == IndexPath {
        toTarget { context, _ in
            closure(context, context.element(for: List.self))
        }
    }

    func toTarget(
        closure: @escaping (ListIndexContext<V, Index>, Input) -> Output
    ) -> Modifier<V, List> {
        var listCoordinatorContext = self.listCoordinatorContext
        listCoordinatorContext.functions[selector] = {
            closure(.init(view: $0, index: $1, rawIndex: $2, context: $3), $4)
        }
        if hasSectionIndex {
            listCoordinatorContext.configSectioned()
        }
        return .init(list: list, listCoordinator: listCoordinator, listCoordinatorContext: listCoordinatorContext)
    }

    init(
        selector: Selector,
        hasSectionIndex: Bool,
        list: List,
        listCoordinator: ListCoordinator,
        listCoordinatorContext: ListCoordinatorContext,
        indexForInput: @escaping (Input) -> Index,
        toClosure: @escaping (Closure) -> (ListIndexContext<V, Index>, Input) -> Output
    ) {
        self.selector = selector
        self.hasSectionIndex = hasSectionIndex
        self.list = list
        self.listCoordinator = listCoordinator
        var context = listCoordinatorContext
        context.selectors.insert(selector)
        self.listCoordinatorContext = context
        self.indexForInput = indexForInput
        self.toClosure = toClosure
    }
}

extension Function: TableList where View == TableView { }
extension Function: CollectionList where View == CollectionView { }
extension Function: TypedListAdapter where List: TypedListAdapter { }

extension IndexFunction: TableList where View == TableView { }
extension IndexFunction: CollectionList where View == CollectionView { }
extension IndexFunction: TypedListAdapter where List: TypedListAdapter { }

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
extension ListAdapter {
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
    ) -> ListKit.Function<View, List, Input, Output, Closure> {
        .init(selector: selector, list: list, listCoordinator: listCoordinator, listCoordinatorContext: listCoordinatorContext, toClosure: toClosure)
    }

    func toFunction<Input, Output, Closure, View, Index: ListIndex>(
        _ selector: Selector,
        _ indexForInput: @escaping (Input) -> Index,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Index>, Input) -> Output
    ) -> IndexFunction<View, List, Input, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, list: list, listCoordinator: listCoordinator, listCoordinatorContext: listCoordinatorContext, indexForInput: indexForInput, toClosure: toClosure)
    }

    func toFunction<Output, Closure, View, Index: ListIndex>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Index>, Index) -> Output
    ) -> IndexFunction<View, List, Index, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, list: list, listCoordinator: listCoordinator, listCoordinatorContext: listCoordinatorContext, indexForInput: { $0 }, toClosure: toClosure)
    }
}
// swiftlint:enable large_tuple
