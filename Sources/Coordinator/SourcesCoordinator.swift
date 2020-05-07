//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

import Foundation

final class SourcesCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    enum Source {
        case other
        case value(Diffable<Element>)
    }
    
    typealias Element = SourceBase.Source.Element
    typealias Subcoordinator = ListCoordinator<Element.SourceBase>
    
    var sourceIndices = [SourceIndices]()
    var subsources = [SourceBase.Source.Element]()
    var subcoordinators = [Subcoordinator]()
    var offsets = [IndexPath]()
    var isAnyType = Item.self == Any.self
    
    lazy var selfSelectorSets = initialSelectorSets()
    var others = SelectorSets()
    
    override var multiType: SourceMultipleType { .sources }
    override var isEmpty: Bool { sourceIndices.isEmpty }
    
    func pathAndCoordinator(path: IndexPath) -> (path: IndexPath, coordinator: Subcoordinator) {
        let indexAt = sourceIndices.index(of: path)
        return (path - offsets[indexAt], subcoordinators[indexAt])
    }
    
    func setupSelectorSets() {
        others = initialSelectorSets(withoutIndex: true)
        for coordinator in subcoordinators where coordinator.isEmpty == false {
            others.void.formIntersection(coordinator.selectorSets.void)
            others.withIndex.formUnion(coordinator.selectorSets.withIndex)
            others.withIndexPath.formUnion(coordinator.selectorSets.withIndexPath)
            others.hasIndex = others.hasIndex || coordinator.selectorSets.hasIndex
        }
        selectorSets = SelectorSets(merging: selfSelectorSets, others)
    }
    
    func subcoordinator<Object: AnyObject, Input, Output>(
        for delegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> Coordinator? {
        guard let index = delegate.index else { return nil }
        let (sectionOffset, itemOffset) = offset(for: object)
        let offset: Int
        switch index {
        case let .index(keyPath):
            let section = input[keyPath: keyPath]
            guard let index = sourceIndices.index(of: section - sectionOffset) else {
                return nil
            }
            offset = index
        case let .indexPath(keyPath):
            let path = input[keyPath: keyPath]
            let index = path.adding(section: -sectionOffset, item: -itemOffset)
            offset = sourceIndices.index(of: index)
        }
        let coordinator = subcoordinators[offset]
        return coordinator.selectorSets.contains(delegate.selector) ? nil : coordinator
    }
    
    func resetAndConfigIndicesAndOffsets() {
        offsets.removeAll(keepingCapacity: true)
        sourceIndices.removeAll(keepingCapacity: true)
        setup()
        configSubcoordinator(for: listContexts)
        setupSelectorSets()
    }
    
    func setupCoordinators() {
        for subsource in source {
            subsources.append(subsource)
            subcoordinators.append(subsource.makeListCoordinator())
        }
    }
    
    func configSubcoordinator(for contexts: [ObjectIdentifier: ListContext]) {
        for (subcoordinator, offset) in zip(subcoordinators, offsets) {
            for (key, value) in contexts {
                guard let listView = value.listView else { continue }
                subcoordinator.setupContext(
                    listView: listView,
                    key: key,
                    sectionOffset: offset.section + value.sectionOffset,
                    itemOffset: offset.item + value.itemOffset,
                    supercoordinator: self
                )
            }
        }
    }
    
    func appendCoordinator(
        _ subcoordinator: Coordinator,
        offset: inout IndexPath,
        hasSection: inout Bool
    ) {
        if subcoordinator.isEmpty { return }
        switch (subcoordinator.sourceType, sourceIndices.last) {
        case (.section, .cell):
            offset = IndexPath(section: offset.section + 1)
            fallthrough
        case (.section, _):
            offsets.append(offset)
            sourceIndices += (0..<subcoordinator.numbersOfSections()).map {
                .section(index: offsets.count - 1, count: subcoordinator.numbersOfItems(in: $0))
            }
            hasSection = true
            offset = IndexPath(section: sourceIndices.count)
        case (.cell, .cell(var cells)?):
            offsets.append(offset)
            let cellCounts = subcoordinator.numbersOfItems(in: 0)
            cells.append(contentsOf: repeatElement(offsets.count - 1, count: cellCounts))
            sourceIndices[sourceIndices.lastIndex] = .cell(indices: cells)
            offset.item = cells.count
        case (.cell, _):
            offsets.append(offset)
            let cellCounts = subcoordinator.numbersOfItems(in: 0)
            let cells = Array(repeating: offsets.count - 1, count: cellCounts)
            sourceIndices.append(.cell(indices: cells))
            offset.item = cells.count
        }
    }
    
    override func item(at path: IndexPath) -> Item {
        let (path, subcoordinator) = pathAndCoordinator(path: path)
        return subcoordinator.item(at: path)
    }
    
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache {
        let (path, subcoordinator) = pathAndCoordinator(path: path)
        return subcoordinator.itemRelatedCache(at: path)
    }
    
    override func numbersOfSections() -> Int { sourceIndices.count }
    override func numbersOfItems(in section: Int) -> Int { sourceIndices[section].count }
    
    override func subsourceOffset(at index: Int) -> IndexPath { offsets[index] }
    override func subsource(at index: Int) -> Coordinator { subcoordinators[index] }
    
    override func setup() {
        if !didSetup { setupCoordinators() }
        var hasSectioned = false
        var offset = IndexPath(section: 0, item: 0)
        for coordinator in subcoordinators {
            coordinator.setupIfNeeded()
            appendCoordinator(coordinator, offset: &offset, hasSection: &hasSectioned)
        }
        
        setupSelectorSets()
        if didSetup { return }
        sourceType = (hasSectioned || selectorSets.hasIndex) ? .section : .cell
    }
    
    override func setupContext(
        listView: ListView,
        key: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        supercoordinator: Coordinator? = nil
    ) {
        if let context = listContexts[key] {
            context.sectionOffset = sectionOffset
            context.itemOffset = itemOffset
            configSubcoordinator(for: [key: context])
            return
        }
        
        let context = ListContext(
            listView: listView,
            sectionOffset: sectionOffset,
            itemOffset: itemOffset,
            supercoordinator: supercoordinator
        )
        listContexts[key] = context
        configSubcoordinator(for: [key: context])
    }
    
    override func selectorSets(applying: (inout SelectorSets) -> Void) {
        super.selectorSets(applying: applying)
        applying(&selfSelectorSets)
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        return coordinator?.apply(keyPath, object: object, with: input)
            ?? super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<Coordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        coordinator?.apply(keyPath, object: object, with: input)
        super.apply(keyPath, object: object, with: input)
    }
}

fileprivate extension BidirectionalCollection {
    var lastIndex: Index {
        return Swift.max(index(before: endIndex), startIndex)
    }
}

fileprivate extension Collection where Element == SourceIndices {
    func sections(with offset: Int) -> [SourceIndices] {
        map { .section(index: offset, count: $0.count) }
    }
}
