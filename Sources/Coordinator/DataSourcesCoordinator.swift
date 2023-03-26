//
//  DataSourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2023/3/24.
//

import Foundation

protocol DataSourcesCoordinator: ListCoordinator {
    typealias Offset = (sectionOffset: Int, itemOffset: Int)
    var contexts: ContiguousArray<ListCoordinatorContext> { get set }
    var contextsOffsets: ContiguousArray<Offset> { get set }
    var count: Count { get set }
    var indices: ContiguousArray<(indices: [Int], index: Int?)> { get set }
    var subselectors: Set<Selector> { get set }
    var needSetupWithListView: Bool { get set }
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
                contextsOffsets.append((sectionOffset: sections.count + (pre == nil ? 0 : 1), itemOffset: next ?? 0))
                addIndices(pre: next, next: elementCount)
                count = .sections(pre, sections, next + elementCount)
            case let (.sections(pre, sections, next), .sections(elementPre, elementSections, elementNext)):
                let sectionOffset = elementPre == nil ? (next == nil ? 0 : 1) : 0
                let itemOffset = elementPre == nil ? 0 : (next ?? 0)
                contextsOffsets.append((sectionOffset + sections.count + (pre == nil ? 0 : 1), itemOffset))
                addIndices(pre: next, next: elementPre)
                elementSections.forEach { indices.append((.init(repeating: index, count: $0), index)) }
                addIndices(pre: nil, next: elementNext)
                count = .sections(pre, sections + ((next + elementPre).map { [$0] } ?? []) + elementSections, elementNext)
            }
        }
    }
}
