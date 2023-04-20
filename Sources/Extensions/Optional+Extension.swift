//
//  Optional+Extension.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

import Foundation

extension Optional: DataSource where Wrapped: DataSource {
    struct Coordinator: ListCoordinator {
        var context: ListCoordinatorContext?
    }

    public var listCoordinator: ListCoordinator { Coordinator(context: self?.listCoordinatorContext) }
    public var listCoordinatorContext: ListCoordinatorContext {
        .init(coordinator: listCoordinator)
    }
}

extension Optional: TableList where Wrapped: TableList { }
extension Optional: CollectionList where Wrapped: CollectionList { }
extension Optional: ListAdapter where Wrapped: ListAdapter {
    public typealias View = Wrapped.View
    public var list: Self { self }
}

extension Optional {
    mutating func or(_ wrapped: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? {
            let wrapped = wrapped()
            self = wrapped
            return wrapped
        }()
    }
}

extension Optional.Coordinator {
    var count: Count { context?.coordinatorCount ?? .items(nil) }
    var selectors: Set<Selector>? { context?.selectors }
    var needSetupWithListView: Bool { context?.coordinator.needSetupWithListView ?? false }
    func setupWithListView(
        offset: IndexPath,
        storages: inout [CoordinatorStorage: [IndexPath]]
    ) {
        context?.coordinator.setupWithListView(offset: offset, storages: &storages)
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }

    mutating func performUpdate(
        update: inout BatchUpdates,
        at position: IndexPath,
        to context: ListCoordinatorContext
    ) -> Bool {
        return self.context?.coordinator.performUpdate(update: &update, at: position, to: context) ?? false
    }

    @discardableResult
    func apply<Input, Output>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        let output: Output? = _apply(selector, for: context, view: view, with: input)
        guard output == nil || Output.self == Void.self,
              let context = self.context else { return nil }
        return context.apply(selector, view: view, with: input)
    }

    @discardableResult
    func apply<Input, Output, Index: ListKit.Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ rawIndex: Index
    ) -> Output? {
        let output: Output? = _apply(selector, for: context, view: view, with: input, index: index, rawIndex)
        guard output == nil || Output.self == Void.self,
              let context = self.context else { return nil }
        return context.apply(selector, view: view, with: input, index: index, rawIndex)
    }
}

func +(lhs: Int?, rhs: Int?) -> Int? {
    guard let lhs = lhs else { return rhs }
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}

func + (lhs: (() -> Void)?, rhs: (() -> Void)?) -> (() -> Void)? {
    switch (lhs, rhs) {
    case let (lhs?, rhs?):
        return {
            lhs()
            rhs()
        }
    case let (lhs?, .none):
        return lhs
    case let (.none, rhs?):
        return rhs
    case (.none, .none):
        return nil
    }
}

func notImplemented(function: StaticString = #function) -> Never {
    fatalError("\(function) not implemented")
}
