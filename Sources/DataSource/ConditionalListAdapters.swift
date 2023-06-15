//
//  ConditionalSources.swift
//  ListKit
//
//  Created by Frain on 2020/9/3.
//

import Foundation

public struct ConditionalListAdapters<TrueContent: ListAdapter, FalseContent: ListAdapter>: ListAdapter, ListCoordinator {
    public typealias View = TrueContent.View
    public enum Value {
        case first(TrueContent), second(FalseContent)

        var context: ListCoordinatorContext {
            switch self {
            case .first(let content): return content.listCoordinatorContext
            case .second(let content): return content.listCoordinatorContext
            }
        }
    }

    public let value: Value
    var context: ListCoordinatorContext

    init(_ value: Value) {
        self.value = value
        self.context = value.context
    }
}

extension ConditionalListAdapters: TableList where TrueContent: TableList, FalseContent: TableList { }
extension ConditionalListAdapters: CollectionList where TrueContent: CollectionList, FalseContent: CollectionList { }

public extension ConditionalListAdapters {
    var count: Count { context.coordinatorCount }
    var selectors: Set<Selector>? { context.selectors }
    var needSetupWithListView: Bool { context.coordinator.needSetupWithListView }
    func setupWithListView(
        offset: IndexPath,
        storages: inout [CoordinatorStorage: [IndexPath]]
    ) {
        context.coordinator.setupWithListView(offset: offset, storages: &storages)
    }

    mutating func performUpdate(
        update: inout BatchUpdates,
        at position: IndexPath,
        to context: ListCoordinatorContext
    ) -> Bool {
        self.context.coordinator.performUpdate(update: &update, at: position, to: context)
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
              self.context.selectors.contains(selector) else { return output }
        return self.context.apply(selector, view: view, with: input)
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
              self.context.selectors.contains(selector) else { return output }
        return self.context.apply(selector, view: view, with: input, index: index, rawIndex)
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
