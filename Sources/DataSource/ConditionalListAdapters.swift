//
//  ConditionalSources.swift
//  ListKit
//
//  Created by Frain on 2020/9/3.
//

import Foundation

public enum ConditionalValue<FirstContent, SecondContent> {
    case first(FirstContent), second(SecondContent)
}

public struct ConditionalListAdapters<TrueContent: ListAdapter, FalseContent: ListAdapter>: ListAdapter, ListCoordinator {
    public typealias View = TrueContent.View

    public let value: ConditionalValue<TrueContent, FalseContent>
    var context: ListCoordinatorContext

    init(_ value: ConditionalValue<TrueContent, FalseContent>) {
        switch value {
        case .first(let content): context = content.listCoordinatorContext
        case .second(let content): context = content.listCoordinatorContext
        }
        self.value = value
    }
}

extension ConditionalListAdapters: TableList where TrueContent: TableList, FalseContent: TableList { }
extension ConditionalListAdapters: CollectionList where TrueContent: CollectionList, FalseContent: CollectionList { }
extension ConditionalListAdapters: TypedListAdapter where TrueContent: TypedListAdapter, FalseContent: TypedListAdapter {
    public typealias Element = ConditionalValue<TrueContent.Element, FalseContent.Element>
    public func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        switch value {
        case .first(let adapter):
            return .first(adapter.element(at: context))
        case .second(let adapter):
            return .second(adapter.element(at: context))
        }
    }
}

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
