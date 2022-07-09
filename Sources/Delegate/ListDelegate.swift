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
    public struct Function<Object, Source, Target, Input, Output, Closure>: ListFunction
    where Source: DataSource, Target: ScrollList<Source.AdapterBase> {
        typealias Context = ListContext<Object, Source>
        typealias ToOutput = (ListContext<Object, Source>, Input) -> Output

        public let selector: Selector
        public var hasSectionIndex: Bool { false }
        let noOutput: Bool
        let sourceBase: Source
        let toClosure: (Closure) -> (Context, Input) -> Output

        public func callAsFunction(closure: Closure) -> Target {
            toTarget(closure: toClosure(closure))
        }

        public func callAsFunction(_ output: Output) -> Target where Output: FunctionOutput {
            toTarget { _, _ in output }
        }

        func toTarget(closure: @escaping ToOutput) -> Target {
            var delegate = sourceBase.listDelegate
            delegate.functions[selector] = { closure(.init(listView: $0, context: $1, root: $2), $3) }
            return .init(sourceBase.adapterBase, listDelegate: delegate)
        }
    }

    public struct IndexFunction<Object, Source, Target, Input, Output, Closure, Index>: ListFunction
    where Source: DataSource, Target: ScrollList<Source.AdapterBase> {
        typealias Context = ListIndexContext<Object, Source, Index>
        typealias ToOutput = (ListIndexContext<Object, Source, Index>, Input) -> Output

        public let selector: Selector
        public let hasSectionIndex: Bool
        let noOutput: Bool
        let sourceBase: Source
        let indexForInput: (Input) -> Index
        let toClosure: (Closure) -> (Context, Input) -> Output

        public func callAsFunction(closure: Closure) -> Target {
            toTarget(closure: toClosure(closure))
        }

        public func callAsFunction(_ output: Output) -> Target where Output: FunctionOutput {
            toTarget { _, _ in output }
        }

        func toTarget(getCache: Any? = nil, closure: @escaping ToOutput) -> Target {
            var delegate = sourceBase.listDelegate
            delegate.getCache = getCache ?? delegate.getCache
            delegate.functions[selector] = {
                closure(.init(listView: $0, index: $4, offset: $5, context: $1, root: $2), $3)
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

    func toClosure<Output, Object>() -> (@escaping (ListIndexContext<Object, Self, IndexPath>, Item) -> Output) -> (ListIndexContext<Object, Self, IndexPath>, IndexPath) -> Output {
        { closure in { context, _ in closure(context, context.itemValue) } }
    }

    func toClosure<Input, Output, Object>() -> (@escaping (ListIndexContext<Object, Self, IndexPath>, Input, Item) -> Output) -> (ListIndexContext<Object, Self, IndexPath>, (IndexPath, Input)) -> Output {
        { closure in { context, input in closure(context, input.1, context.itemValue) } }
    }

    func toClosure<Input1, Input2, Output, Object>() -> (@escaping (ListIndexContext<Object, Self, IndexPath>, Input1, Input2, Item) -> Output) -> (ListIndexContext<Object, Self, IndexPath>, (IndexPath, Input1, Input2)) -> Output {
        { closure in { context, input in closure(context, input.1, input.2, context.itemValue) } }
    }

    func toClosure<Input, Output, Object>() -> (@escaping (ListIndexContext<Object, Self, Int>, Input) -> Output) -> (ListIndexContext<Object, Self, Int>, (Int, Input)) -> Output {
        { closure in { context, input in closure(context, input.1) } }
    }

    func toFunction<Object, Target, Input, Output, Closure>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListContext<Object, Self>, Input) -> Output
    ) -> ListDelegate.Function<Object, Self, Target, Input, Output, Closure> {
        .init(selector: selector, noOutput: false, sourceBase: self, toClosure: toClosure)
    }

    func toFunction<Object, Target, Input, Closure>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListContext<Object, Self>, Input) -> Void
    ) -> ListDelegate.Function<Object, Self, Target, Input, Void, Closure> {
        .init(selector: selector, noOutput: true, sourceBase: self, toClosure: toClosure)
    }

    func toFunction<Object, Target, Input, Output, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ indexForInput: @escaping (Input) -> Index,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<Object, Self, Index>, Input) -> Output
    ) -> ListDelegate.IndexFunction<Object, Self, Target, Input, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, noOutput: false, sourceBase: self, indexForInput: indexForInput, toClosure: toClosure)
    }

    func toFunction<Object, Target, Input, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ indexForInput: @escaping (Input) -> Index,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<Object, Self, Index>, Input) -> Void
    ) -> ListDelegate.IndexFunction<Object, Self, Target, Input, Void, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, noOutput: true, sourceBase: self, indexForInput: indexForInput, toClosure: toClosure)
    }

    func toFunction<Object, Target, Output, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<Object, Self, Index>, Index) -> Output
    ) -> ListDelegate.IndexFunction<Object, Self, Target, Index, Output, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, noOutput: false, sourceBase: self, indexForInput: { $0 }, toClosure: toClosure)
    }

    func toFunction<Object, Target, Closure, Index: ListIndex>(
        _ selector: Selector,
        _ toClosure: @escaping (Closure) -> (ListIndexContext<Object, Self, Index>, Index) -> Void
    ) -> ListDelegate.IndexFunction<Object, Self, Target, Index, Void, Closure, Index> {
        .init(selector: selector, hasSectionIndex: Index.isSection, noOutput: true, sourceBase: self, indexForInput: { $0 }, toClosure: toClosure)
    }
}
// swiftlint:enable large_tuple
