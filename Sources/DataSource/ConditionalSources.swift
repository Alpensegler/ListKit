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
    public var listCoordinator: ListCoordinator { Coordinator(list: list, context: list.context) }
}

extension ConditionalSources: TableList where TrueContent: TableList, FalseContent: TableList { }
extension ConditionalSources: CollectionList where TrueContent: CollectionList, FalseContent: CollectionList { }
extension ConditionalSources: ListAdapter where TrueContent: ListAdapter, FalseContent: ListAdapter, TrueContent.View == FalseContent.View {
    public typealias View = TrueContent.View
}

extension ConditionalSources.Coordinator {
    var count: Count { context.count }
    var selectors: Set<Selector>? { context.coordinator.selectors }
    var needSetupWithListView: Bool { context.coordinator.needSetupWithListView }
    func setupWithListView(
        offset: IndexPath,
        storages: inout [CoordinatorStorage: [IndexPath]]
    ) {
        context.coordinator.setupWithListView(offset: offset, storages: &storages)
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
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
        self.context.coordinator.apply(selector, for: self.context, view: view, with: input)
    }

    @discardableResult
    func apply<Input, Output, Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ offset: Index
    ) -> Output? {
        self.context.coordinator.apply(selector, for: self.context, view: view, with: input, index: index, offset)
    }
}
