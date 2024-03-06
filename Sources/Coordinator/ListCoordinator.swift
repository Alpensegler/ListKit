//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

import Foundation

public enum Count: Equatable {
    case items(Int?)
    case sections(Int?, [Int], Int?)
}

public protocol ListCoordinator {
    var selectors: Set<Selector>? { get }
    var count: Count { get }
    var needSetupWithListView: Bool { get }
    func setupWithListView(
        offset: IndexPath,
        storages: inout [CoordinatorStorage: [IndexPath]]
    )

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates

    @discardableResult
    mutating func performUpdate(
        update: inout BatchUpdates,
        at position: IndexPath,
        to context: ListCoordinatorContext
    ) -> Bool

    @discardableResult
    func apply<Input, Output>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output?

    @discardableResult
    func apply<Input, Output, Index: ListKit.Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ rawIndex: Index
    ) -> Output?
}

public extension ListCoordinator {
    var selectors: Set<Selector>? { nil }
    var needSetupWithListView: Bool { false }

    func setupWithListView(offset: IndexPath, storages: inout [CoordinatorStorage: [IndexPath]]) { }

    mutating func performUpdate(
        update: inout BatchUpdates,
        at position: IndexPath,
        to context: ListCoordinatorContext
    ) -> Bool { false }

    func apply<Input, Output>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        _apply(selector, for: context, view: view, with: input)
    }

    func apply<Input, Output, Index: ListKit.Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ rawIndex: Index
    ) -> Output? {
        _apply(selector, for: context, view: view, with: input, index: index, rawIndex)
    }
}

extension ListCoordinator {
    @discardableResult
    func _apply<Input, Output>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        guard let rawClosure = context.functions[selector],
              let closure = rawClosure as? (AnyObject, ListCoordinatorContext, Input) -> Output
        else { return nil }
        return closure(view, context, input)
    }

    @discardableResult
    func _apply<Input, Output, Index: ListKit.Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ rawIndex: Index
    ) -> Output? {
        guard let rawClosure = context.functions[selector],
              let closure = rawClosure as? (AnyObject, Index, Index, ListCoordinatorContext, Input) -> Output
        else { return nil }
        return closure(view, index, rawIndex, context, input)
    }
}

    // Updates:
//    func identifier(for sourceBase: SourceBase) -> [AnyHashable] {
//        let id = ObjectIdentifier(sourceBaseType)
//        guard let identifier = differ.identifier else { return [id, sourceType] }
//        return [id, sourceType, identifier(sourceBase)]
//    }
//
//    func equal(lhs: SourceBase, rhs: SourceBase) -> Bool {
//        differ.areEquivalent?(lhs, rhs) ?? true
//    }
//
//    func update(
//        update: ListUpdate<SourceBase>,
//        options: ListOptions? = nil
//    ) -> ListCoordinatorUpdate<SourceBase> {
//        notImplemented()
//    }

//    func update(
//        from coordinator: ListCoordinator
//        updateWay: ListUpdateWay<Model>?
//    ) -> ListCoordinatorUpdate<Model> {
//        .init(self, options: (coordinator.options, options))
//    }

//extension ListCoordinator {
//    func contextAndUpdates(update: CoordinatorUpdate) -> [(CoordinatorContext, CoordinatorUpdate)]? {
//        var results: [(CoordinatorContext, CoordinatorUpdate)]?
//        for context in listContexts {
//            guard let context = context.context else { continue }
//            if context.listView != nil {
//                results = results.map { $0 + [(context, update)] } ?? [(context, update)]
//            } else if let parentUpdate = context.update?(context.index, update) {
//                results = results.map { $0 + parentUpdate } ?? parentUpdate
//            }
//        }
//        return results
//    }
//
//    func offsetAndRoot(offset: IndexPath, list: ListView) -> [(IndexPath, CoordinatorContext)] {
//        var results = [(IndexPath, CoordinatorContext)]()
//        for context in self.listContexts {
//            guard let context = context.context else { continue }
//            if context.listView === list {
//                results.append((offset, context))
//            }
//
//            results += context.contextAtIndex?(context.index, rawIndex, list) ?? []
//        }
//        return results
//    }
//
//    func resetDelegates() {
//        listContexts.forEach { $0.context?.reconfig() }
//    }
//}
