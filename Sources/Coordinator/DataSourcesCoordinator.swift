//
//  DataSourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2023/3/24.
//

import Foundation

public protocol DataSourcesCoordinator: ListCoordinator {
    typealias Offset = (sectionOffset: Int, itemOffset: Int)
    var contexts: ContiguousArray<ListCoordinatorContext> { get set }
    var contextsOffsets: ContiguousArray<Offset> { get set }
    var count: Count { get set }
    var indices: ContiguousArray<(indices: [Int], index: Int?)> { get set }
    var subselectors: Set<Selector> { get set }
    var needSetupWithListView: Bool { get set }
}

public extension DataSourcesCoordinator {
    var selectors: Set<Selector>? { subselectors }

    func apply<Input, Output>(
        _ selector: Selector,
        for context: ListCoordinatorContext,
        view: AnyObject,
        with input: Input
    ) -> Output? {
        var output: Output? = _apply(selector, for: context, view: view, with: input)
        guard output == nil || Output.self == Void.self, subselectors.contains(selector) else { return output }
        for context in contexts {
            output = output ?? context.coordinator.apply(selector, for: context, view: view, with: input)
        }
        return output
    }

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
              subselectors.contains(selector),
              let contextIndex = index.contextIndex(at: indices) else { return output }
        let (sectionOffset, itemOffset) = contextsOffsets[contextIndex]
        let withoutOffset = index.offseted(section: -sectionOffset, item: -itemOffset)
        return contexts[contextIndex].apply(selector, view: view, with: input, index: withoutOffset, rawIndex)
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
            
            func appendIndices(sectionOffset: Int, itemOffset: Int, preNext: Int?, nextPre: Int? = nil, sections: [Int]? = nil, nextNext: Int? = nil) {
                contextsOffsets.append((sectionOffset, itemOffset))
                addIndices(pre: preNext, next: nextPre)
                sections?.forEach { indices.append((.init(repeating: index, count: $0), index)) }
                addIndices(next: nextNext)
            }

            switch (count, context.count, context.coordinator.count) {
            case let (.items(preNext), .coordinatorCount, .items(nextPre)):
                appendIndices(sectionOffset: 0, itemOffset: preNext ?? 0, preNext: preNext, nextPre: nextPre)
                count = .items(preNext + nextPre)
            case let (.items(preNext), .coordinatorCount, .sections(nextPre, sections, nextNext)):
                let sectionOffset = nextPre == nil ? (preNext == nil ? 0 : 1) : 0
                let itemOffset = nextPre == nil ? 0 : (preNext ?? 0)
                appendIndices(sectionOffset: sectionOffset, itemOffset: itemOffset, preNext: preNext, nextPre: nextPre, sections: sections, nextNext: nextNext)
                count = .sections(preNext + nextPre, sections, nextNext)
            case let (.items(preNext), .sectioned(sections, style: _), _):
                appendIndices(sectionOffset: preNext == nil ? 0 : 1, itemOffset: 0, preNext: preNext, sections: sections)
                count = .sections(preNext, sections, nil)
            case let (.sections(prePre, sections, preNext), .coordinatorCount, .items(nextPre)):
                let sectionOffset = sections.count + (prePre == nil ? 0 : 1)
                let itemOffset = preNext ?? 0
                appendIndices(sectionOffset: sectionOffset, itemOffset: itemOffset, preNext: preNext, nextPre: nextPre)
                count = .sections(prePre, sections, preNext + nextPre)
            case let (.sections(prePre, preSections, preNext), .coordinatorCount, .sections(nextPre, nextSections, nextNext)):
                let sectionOffset = (nextPre == nil ? (preNext == nil ? 0 : 1) : 0) + preSections.count + (prePre == nil ? 0 : 1)
                let itemOffset = nextPre == nil ? 0 : (preNext ?? 0)
                appendIndices(sectionOffset: sectionOffset, itemOffset: itemOffset, preNext: preNext, nextPre: nextPre, sections: nextSections, nextNext: nextNext)
                count = .sections(prePre, preSections + ((preNext + nextPre).map { [$0] } ?? []) + nextSections, nextNext)
            case let (.sections(prePre, preSections, preNext), .sectioned(nextSections, style: _), _):
                let sectionOffset = (preNext == nil ? 0 : 1) + preSections.count + (prePre == nil ? 0 : 1)
                appendIndices(sectionOffset: sectionOffset, itemOffset: 0, preNext: preNext, sections: nextSections)
                count = .sections(prePre, preSections + (preNext.map { [$0] } ?? []) + nextSections, nil)
            }
        }
    }
}
