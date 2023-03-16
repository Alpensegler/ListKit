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

    var sectioned: Bool {
        if case .items = self { return false }
        return true
    }
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
    func model(at indexPath: IndexPath) -> Any

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
    func apply<Input, Output, Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ offset: Index
    ) -> Output?
}

protocol DataSourcesCoordinator: ListCoordinator {
    typealias Offset = (sectionOffset: Int, itemOffset: Int)
    var contexts: ContiguousArray<ListCoordinatorContext> { get set }
    var contextsOffsets: ContiguousArray<Offset> { get set }
    var count: Count { get set }
    var indices: ContiguousArray<(indices: [Int], index: Int?)> { get set }
    var subselectors: Set<Selector> { get set }
    var needSetupWithListView: Bool { get set }
}

public extension ListCoordinator {
    var selectors: Set<Selector>? { .init() }
    var needSetupWithListView: Bool { false }

    func setupWithListView(offset: IndexPath, storages: inout [CoordinatorStorage: [IndexPath]]) { }
    func model(at indexPath: IndexPath) -> Any { fatalError() }

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

    func apply<Input, Output, Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ offset: Index
    ) -> Output? {
        _apply(selector, for: context, view: view, with: input, index: index, offset)
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
    func _apply<Input, Output, Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ offset: Index
    ) -> Output? {
        guard let rawClosure = context.functions[selector],
              let closure = rawClosure as? (AnyObject, ListCoordinatorContext, Input, Index, Index) -> Output
        else { return nil }
        return closure(view, context, input, index, offset)
    }
}

extension DataSourcesCoordinator {
    var selectors: Set<Selector>? { subselectors }

    func apply<Input, Output>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        guard subselectors.contains(selector) else {
            return _apply(selector, for: context, view: view, with: input)
        }
        if Output.self == Void.self {
            let output: Output? = contexts.compactMap { (context) in
                context.coordinator.apply(selector, for: context, view: view, with: input)
            }.first
            return _apply(selector, for: context, view: view, with: input) ?? output
        } else {
            let output: Output? = contexts.lazy.compactMap { (context) in
                context.coordinator.apply(selector, for: context, view: view, with: input)
            }.first
            return output ?? _apply(selector, for: context, view: view, with: input)
        }
    }

    func apply<Input, Output, Index>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input,
        index: Index,
        _ offset: Index
    ) -> Output? {
        guard subselectors.contains(selector) else {
            return _apply(selector, for: context, view: view, with: input, index: index, offset)
        }
        var output: Output?
        if let index = index as? IndexPath, var offset = offset as? IndexPath {
            let offsetted = index.offseted(offset, plus: false)
            let (sectionOffset, itemOffset) = contextsOffsets[indices[offsetted.section].indices[offsetted.item]]
            let context = contexts[indices[offsetted.section].indices[offsetted.item]]
            offset = offset.offseted(sectionOffset, itemOffset)
            output = context.coordinator.apply(selector, for: context, view: view, with: input, index: index, offset)
        } else if let index = index as? Int, var offset = offset as? Int {
            let offsetted = index.offseted(offset, plus: false)
            guard let contextIndex = indices[offsetted].index else {
                return _apply(selector, for: context, view: view, with: input, index: index, offset)
            }
            offset = offset.offseted(contextsOffsets[contextIndex].sectionOffset)
            let context = contexts[contextIndex]
            output = context.coordinator.apply(selector, for: context, view: view, with: input, index: index, offset)
        } else {
            return _apply(selector, for: context, view: view, with: input, index: index, offset)
        }
        if Output.self == Void.self {
            return _apply(selector, for: context, view: view, with: input, index: index, offset) ?? output
        } else {
            return output ?? _apply(selector, for: context, view: view, with: input, index: index, offset)
        }
    }

    func setupWithListView(offset: IndexPath, storages: inout [CoordinatorStorage: [IndexPath]]) {
        for (index, context) in contexts.enumerated() {
            if context.coordinator.needSetupWithListView {
                context.coordinator.setupWithListView(offset: offset.appending(index), storages: &storages)
            }
            guard let storage = context.storage else { continue }
            storages[storage, default: []].append(offset.appending(index))
        }
    }

    mutating func performUpdate(update: inout BatchUpdates, at position: IndexPath, to context: ListCoordinatorContext) -> Bool {
        var position = position
        let index = position.removeFirst()

        let shouldConfig: Bool
        if position.isEmpty {
            shouldConfig = context.count != contexts[index].count || context.selectors != contexts[index].selectors
            contexts[index] = context
        } else {
            shouldConfig = contexts[index].coordinator.performUpdate(update: &update, at: position, to: context)
        }
        if shouldConfig {
            configCount()
        }
        return shouldConfig
    }

    mutating func configCount() {
        contextsOffsets = .init(capacity: contexts.count)
        indices = .init(capacity: contexts.count)
        count = .items(nil)
        needSetupWithListView = false
        subselectors.removeAll(keepingCapacity: true)

        for (index, context) in contexts.enumerated() {
            needSetupWithListView = needSetupWithListView || context.storage != nil || context.coordinator.needSetupWithListView
            subselectors.formUnion(context.selectors)

            func addIndices(pre: Int?, next: Int?) {
                guard let next = next else { return }
                if pre == nil {
                    indices.append((.init(repeating: index, count: next), nil))
                } else {
                    indices[indices.count - 1].indices.append(repeatElement: index, count: next)
                }
            }

            switch (count, context.count) {
            case let (.items(totalCount), .items(elementCount)):
                contextsOffsets.append((sectionOffset: 0, itemOffset: totalCount ?? 0))
                addIndices(pre: totalCount, next: elementCount)
                count = .items(totalCount + elementCount)
            case let (.items(totalCount), .sections(pre, sections, next)):
                let sectionOffset = pre == nil ? (totalCount == nil ? 0 : 1) : 0
                let itemOffset = pre == nil ? 0 : (totalCount ?? 0)
                contextsOffsets.append((sectionOffset, itemOffset))
                addIndices(pre: totalCount, next: pre)
                sections.forEach { indices.append((.init(repeating: index, count: $0), index)) }
                addIndices(pre: nil, next: next)
                count = .sections(totalCount + pre, sections, next)
            case let (.sections(pre, sections, next), .items(elementCount)):
                contextsOffsets.append((sectionOffset: sections.count, itemOffset: next ?? 0))
                addIndices(pre: next, next: elementCount)
                count = .sections(pre, sections, next + elementCount)
            case let (.sections(pre, sections, next), .sections(elementPre, elementSections, elementNext)):
                let sectionOffset = elementPre == nil ? (next == nil ? 0 : 1) : 0
                let itemOffset = elementPre == nil ? 0 : (next ?? 0)
                contextsOffsets.append((sectionOffset, itemOffset))
                addIndices(pre: next, next: elementPre)
                elementSections.forEach { indices.append((.init(repeating: index, count: $0), index)) }
                addIndices(pre: nil, next: elementNext)
                count = .sections(pre, sections + ((next + elementPre).map { [$0] } ?? []) + elementSections, elementNext)
            }
        }
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
//            results += context.contextAtIndex?(context.index, offset, list) ?? []
//        }
//        return results
//    }
//
//    func resetDelegates() {
//        listContexts.forEach { $0.context?.reconfig() }
//    }
//}
