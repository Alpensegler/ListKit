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
    public struct Function<View: ListView, Source: DataSource, Input, Output, Closure>: ListFunction {
        typealias Context = ListContext<View, Source>
        typealias ToOutput = (ListContext<View, Source>, Input) -> Output

        public let selector: Selector
        public var hasSectionIndex: Bool { false }
        let sourceBase: Source
        let toClosure: (Closure) -> (Context, Input) -> Output

        public func callAsFunction(closure: Closure) -> ListAdaptation<Source.AdapterBase, View> {
            toTarget(closure: toClosure(closure))
        }

        public func callAsFunction(_ output: Output) -> ListAdaptation<Source.AdapterBase, View> where Output: FunctionOutput {
            toTarget { _, _ in output }
        }

        func toTarget(closure: @escaping ToOutput) -> ListAdaptation<Source.AdapterBase, View> {
            var delegate = sourceBase.listDelegate
            delegate.functions[selector] = { closure(.init(view: $0, context: $1, root: $2), $3) }
            return .init(sourceBase.adapterBase, listDelegate: delegate)
        }
    }

    public struct IndexFunction<View: ListView, Source: DataSource, Input, Output, Closure, Index>: ListFunction {
        typealias Context = ListIndexContext<View, Source, Index>
        typealias ToOutput = (ListIndexContext<View, Source, Index>, Input) -> Output

        public let selector: Selector
        public let hasSectionIndex: Bool
        let sourceBase: Source
        let indexForInput: (Input) -> Index
        let toClosure: (Closure) -> (Context, Input) -> Output

        public func callAsFunction(closure: Closure) -> ListAdaptation<Source.AdapterBase, View> {
            toTarget(closure: toClosure(closure))
        }

        public func callAsFunction(_ output: Output) -> ListAdaptation<Source.AdapterBase, View> where Output: FunctionOutput {
            toTarget { _, _ in output }
        }

        func toTarget(getCache: Any? = nil, closure: @escaping ToOutput) -> ListAdaptation<Source.AdapterBase, View> {
            var delegate = sourceBase.listDelegate
            delegate.getCache = getCache ?? delegate.getCache
            delegate.functions[selector] = {
                closure(.init(view: $0, index: $4, offset: $5, context: $1, root: $2), $3)
            }
            delegate.hasSectionIndex = delegate.hasSectionIndex || hasSectionIndex
            return .init(sourceBase.adapterBase, listDelegate: delegate)
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

    func toClosure<Output, View>() -> (@escaping (ListIndexContext<View, Self, IndexPath>, Model) -> Output) -> (ListIndexContext<View, Self, IndexPath>, IndexPath) -> Output {
        { closure in { context, _ in closure(context, context.model) } }
    }

    func toClosure<Input, Output, View>() -> (@escaping (ListIndexContext<View, Self, IndexPath>, Input, Model) -> Output) -> (ListIndexContext<View, Self, IndexPath>, (IndexPath, Input)) -> Output {
        { closure in { context, input in closure(context, input.1, context.model) } }
    }

    func toClosure<Input1, Input2, Output, View>() -> (@escaping (ListIndexContext<View, Self, IndexPath>, Input1, Input2, Model) -> Output) -> (ListIndexContext<View, Self, IndexPath>, (IndexPath, Input1, Input2)) -> Output {
        { closure in { context, input in closure(context, input.1, input.2, context.model) } }
    }

    func toClosure<Input, Output, View>() -> (@escaping (ListIndexContext<View, Self, Int>, Input) -> Output) -> (ListIndexContext<View, Self, Int>, (Int, Input)) -> Output {
        { closure in { context, input in closure(context, input.1) } }
    }

    func toFunction<View, Input, Output, Closure>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListContext<View, Self>, Input) -> Output
    ) -> ListDelegate.Function<View, Self, Input, Output, Closure> {
        .init(selector: selector, sourceBase: self, toClosure: toClosure)
    }

    func toFunction<View, Input, Output, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ indexForInput: @escaping (Input) -> Index,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Self, Index>, Input) -> Output
    ) -> ListDelegate.IndexFunction<View, Self, Input, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, sourceBase: self, indexForInput: indexForInput, toClosure: toClosure)
    }

    func toFunction<View, Output, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<View, Self, Index>, Index) -> Output
    ) -> ListDelegate.IndexFunction<View, Self, Index, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, sourceBase: self, indexForInput: { $0 }, toClosure: toClosure)
    }
}
// swiftlint:enable large_tuple
