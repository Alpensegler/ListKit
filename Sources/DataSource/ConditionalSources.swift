//
//  ConditionalSources.swift
//  ListKit
//
//  Created by Frain on 2020/9/3.
//

import Foundation

public struct ConditionalSources<TrueContent: DataSource, FalseContent: DataSource>: DataSource {
    public enum List {
        case first(TrueContent), second(FalseContent)

        var context: ListCoordinatorContext {
            switch self {
            case .first(let content): return content.listCoordinatorContext
            case .second(let content): return content.listCoordinatorContext
            }
        }
    }

    struct Coordinator: ListCoordinator {
        var list: List
        var context: ListCoordinatorContext
    }

    public var list: List
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext

    init(_ content: List) {
        list = content
        listCoordinator = Coordinator(list: list, context: content.context)
        listCoordinatorContext = .init(coordinator: listCoordinator)
    }
}

extension ConditionalSources: TableList where TrueContent: TableList, FalseContent: TableList { }
extension ConditionalSources: CollectionList where TrueContent: CollectionList, FalseContent: CollectionList { }
extension ConditionalSources: ListAdapter where TrueContent: ListAdapter, FalseContent: ListAdapter, TrueContent.View == FalseContent.View {
    public typealias View = TrueContent.View
}

extension ConditionalSources.Coordinator {
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
