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

            func addIndices(pre: Int? = nil, next: Int?) {
                guard let next = next else { return }
                if pre == nil {
                    indices.append((.init(repeating: index, count: next), nil))
                } else {
                    indices[indices.count - 1].indices.append(repeatElement: index, count: next)
                }
            }
            
            func appendIndices(sectionOffset: Int, itemOffset: Int, preNext: Int?, nextPre: Int?, sections: [Int]? = nil, nextNext: Int? = nil) {
                contextsOffsets.append((sectionOffset, itemOffset))
                addIndices(pre: preNext, next: nextPre)
                sections?.forEach { indices.append((.init(repeating: index, count: $0), index)) }
                addIndices(next: nextNext)
            }

            switch (count, context.count) {
            case let (.items(preNext), .items(nextPre)):
                appendIndices(sectionOffset: 0, itemOffset: preNext ?? 0, preNext: preNext, nextPre: nextPre)
                count = .items(preNext + nextPre)
            case let (.items(preNext), .sections(nextPre, sections, nextNext)):
                let sectionOffset = nextPre == nil ? (preNext == nil ? 0 : 1) : 0
                let itemOffset = nextPre == nil ? 0 : (preNext ?? 0)
                appendIndices(sectionOffset: sectionOffset, itemOffset: itemOffset, preNext: preNext, nextPre: nextPre, sections: sections, nextNext: nextNext)
                count = .sections(preNext + nextPre, sections, nextNext)
            case let (.sections(prePre, sections, preNext), .items(nextPre)):
                let sectionOffset = sections.count + (prePre == nil ? 0 : 1)
                let itemOffset = preNext ?? 0
                appendIndices(sectionOffset: sectionOffset, itemOffset: itemOffset, preNext: preNext, nextPre: nextPre)
                count = .sections(prePre, sections, preNext + nextPre)
            case let (.sections(prePre, preSections, preNext), .sections(nextPre, nextSections, nextNext)):
                let sectionOffset = (nextPre == nil ? (preNext == nil ? 0 : 1) : 0) + preSections.count + (prePre == nil ? 0 : 1)
                let itemOffset = nextPre == nil ? 0 : (preNext ?? 0)
                appendIndices(sectionOffset: sectionOffset, itemOffset: itemOffset, preNext: preNext, nextPre: nextPre, sections: nextSections, nextNext: nextNext)
                count = .sections(prePre, preSections + ((preNext + nextPre).map { [$0] } ?? []) + nextSections, nextNext)
            }
        }
    }

}
