//
//  ListDelegate.swift
//  ListKit
//
//  Created by Frain on 2020/1/1.
//

import Foundation

public protocol FunctionOutput { }

public protocol ListFunction {
    var selector: Selector { get }
    var hasSectionIndex: Bool { get }
}

public struct ListDelegate: ExpressibleByArrayLiteral {
    public struct Function<View: ListView, Model, Input, Output, Closure>: ListFunction {
        typealias Context = ListContext<View, Model>
        typealias ToOutput = (ListContext<View, Model>, Input) -> Output

        public let selector: Selector
        public var hasSectionIndex: Bool { false }
        let source: ListAdaptation<Model, View>
        let toClosure: (Closure) -> (Context, Input) -> Output

        public func callAsFunction(closure: Closure) -> ListAdaptation<Model, View> {
            toTarget(closure: toClosure(closure))
        }

        public func callAsFunction(_ output: Output) -> ListAdaptation<Model, View> where Output: FunctionOutput {
            toTarget { _, _ in output }
        }

        func toTarget(closure: @escaping ToOutput) -> ListAdaptation<Model, View> {
            var list = source
            list.listDelegate.functions[selector] = { closure(.init(view: $0, context: $1, root: $2), $3) }
            return list
        }
    }

    public struct IndexFunction<View: ListView, Model, Input, Output, Closure, Index>: ListFunction {
        typealias Context = ListIndexContext<View, Model, Index>
        typealias ToOutput = (ListIndexContext<View, Model, Index>, Input) -> Output

        public let selector: Selector
        public let hasSectionIndex: Bool
        let source: ListAdaptation<Model, View>
        let indexForInput: (Input) -> Index
        let toClosure: (Closure) -> (Context, Input) -> Output

        public func callAsFunction(closure: Closure) -> ListAdaptation<Model, View> {
            toTarget(closure: toClosure(closure))
        }

        public func callAsFunction(_ output: Output) -> ListAdaptation<Model, View> where Output: FunctionOutput {
            toTarget { _, _ in output }
        }

        func toTarget(getCache: Any? = nil, closure: @escaping ToOutput) -> ListAdaptation<Model, View> {
            var list = source
            list.listDelegate.getCache = getCache ?? list.listDelegate.getCache
            list.listDelegate.functions[selector] = {
                closure(.init(view: $0, index: $4, offset: $5, context: $1, root: $2), $3)
            }
            list.listDelegate.hasSectionIndex = list.listDelegate.hasSectionIndex || hasSectionIndex
            return list
        }
    }

    var extraSelectors = Set<Selector>()
    var functions = [Selector: Any]()
    var getCache: Any?
    var hasSectionIndex = false

    public init(arrayLiteral elements: ListFunction...) {
        extraSelectors = .init(elements.map(\.selector))
        hasSectionIndex = elements.contains { $0.hasSectionIndex }
    }

    func contains(_ selector: Selector) -> Bool {
        functions[selector] != nil || extraSelectors.contains(selector)
    }

    mutating func formUnion(delegate: Self) {
        extraSelectors.formUnion(delegate.extraSelectors)
        functions.merge(delegate.functions) { _, new in new }
        hasSectionIndex = hasSectionIndex || delegate.hasSectionIndex
        getCache = delegate.getCache ?? self.getCache
    }
}

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

    func toClosure<Output, View>() -> (@escaping (ListIndexContext<View, Model, IndexPath>, Model) -> Output) -> (ListIndexContext<View, Model, IndexPath>, IndexPath) -> Output {
        { closure in { context, _ in closure(context, context.model) } }
    }

    func toClosure<Input, Output, View>() -> (@escaping (ListIndexContext<View, Model, IndexPath>, Input, Model) -> Output) -> (ListIndexContext<View, Model, IndexPath>, (IndexPath, Input)) -> Output {
        { closure in { context, input in closure(context, input.1, context.model) } }
    }

    func toClosure<Input1, Input2, Output, View>() -> (@escaping (ListIndexContext<View, Model, IndexPath>, Input1, Input2, Model) -> Output) -> (ListIndexContext<View, Model, IndexPath>, (IndexPath, Input1, Input2)) -> Output {
        { closure in { context, input in closure(context, input.1, input.2, context.model) } }
    }

    func toClosure<Input, Output, View>() -> (@escaping (ListIndexContext<View, Model, Int>, Input) -> Output) -> (ListIndexContext<View, Model, Int>, (Int, Input)) -> Output {
        { closure in { context, input in closure(context, input.1) } }
    }
    
    func toFunction<Input, Output, Closure>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListKit.ListContext<View, Model>, Input) -> Output
    ) -> ListDelegate.Function<View, Model, Input, Output, Closure> {
        .init(selector: selector, source: list, toClosure: toClosure)
    }

    func toFunction<Input, Output, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ indexForInput: @escaping (Input) -> Index,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Model, Index>, Input) -> Output
    ) -> ListDelegate.IndexFunction<View, Model, Input, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, source: list, indexForInput: indexForInput, toClosure: toClosure)
    }

    func toFunction<Output, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Model, Index>, Index) -> Output
    ) -> ListDelegate.IndexFunction<View, Model, Index, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, source: list, indexForInput: { $0 }, toClosure: toClosure)
    }
}
// swiftlint:enable large_tuple
