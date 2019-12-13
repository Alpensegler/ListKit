//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

import ObjectiveC.runtime

class SourcesCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    var subsources = [SourceBase.Source.Element]()
    var subitemCoordinators = [ItemTypedCoorinator<Item>]()
    var anysubCoordinators: [BaseCoordinator] { subitemCoordinators }
    var subsourcesHasSectioned = false
    override var sourceType: SourceType {
        get { subsourcesHasSectioned || selectorSets.hasIndex ? .section : .cell }
        set { fatalError() }
    }
    
    lazy var subselectorSets = initialSelectorSets(withoutIndex: true)
    
    var offsets = [Path]()
    
    override var isEmpty: Bool { sourceIndices.isEmpty }
    
    override func item<Path: PathConvertible>(at path: Path) -> Item {
        let indexAt = index(of: path)
        let offset = offsets[indexAt]
        let subcoordinator = subitemCoordinators[indexAt]
        return subcoordinator.item(at: path - offset)
    }
    
    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
        .inSource(.init(source: source, coordinator: self) {
            zip(self.subsources, self.anysubCoordinators).map { (source, coordinator) in
                coordinator.anyItemSources(source: source)
            }
        })
    }
    
    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
        .inSource(.init(source: source, coordinator: self) {
            self.subsectionSources(
                subcoordinators: self.anysubCoordinators,
                getter: BaseCoordinator.anySectionSources
            )
        })
    }
    
    override func anySourceUpdate(to sources: [AnyDiffableSourceValue]) {
        var anySubsources = [SourceBase.Source.Element]()
        var subcoordinators = [ItemTypedCoorinator<Item>]()
        for source in sources {
            anySubsources.append(source.value() as! SourceBase.Source.Element)
            subcoordinators.append(source.coordinator as! ItemTypedCoorinator<Item>)
        }
        subsources = anySubsources
        subitemCoordinators = subcoordinators
        resetAndConfigIndicesAndOffsets()
    }
    
    override func itemSources<Source: DataSource>(
        source: Source
    ) -> ItemSource where Source.SourceBase.Item == Item {
        .inSource(.init(source: source, coordinator: self) {
            zip(self.subsources, self.subitemCoordinators).map { (source, coordinator) in
                coordinator.itemSources(source: source)
            }
        })
    }
    
    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
        .inSource(.init(source: source, coordinator: self) {
            self.subsectionSources(
                subcoordinators: self.subitemCoordinators,
                getter: ItemTypedCoorinator<Item>.sectionSources
            )
        })
    }
    
    override func sourceUpdate(to sources: [DiffableSourceValue]) {
        var anySubsources = [SourceBase.Source.Element]()
        var subcoordinators = [ItemTypedCoorinator<Item>]()
        for source in sources {
            anySubsources.append(source.value() as! SourceBase.Source.Element)
            subcoordinators.append(source.coordinator)
        }
        subsources = anySubsources
        subitemCoordinators = subcoordinators
        resetAndConfigIndicesAndOffsets()
    }
    
    override func apply<Object: AnyObject, Input, Output>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Output>>,
        object: Object,
        with input: Input
    ) -> Output {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        return coordinator?.apply(keyPath, object: object, with: input)
            ?? super.apply(keyPath, object: object, with: input)
    }
    
    override func apply<Object: AnyObject, Input>(
        _ keyPath: KeyPath<BaseCoordinator, Delegate<Object, Input, Void>>,
        object: Object,
        with input: Input
    ) {
        let closure = self[keyPath: keyPath]
        let coordinator = subcoordinator(for: closure, object: object, with: input)
        coordinator?.apply(keyPath, object: object, with: input)
        super.apply(keyPath, object: object, with: input)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || aSelector.map(subselectorSets.contains) != true
    }
    
    override func setup() {
        setupCoordinators()
        configIndicesAndOffsets()
        configSubselectorSets()
        rangeReplacable = true
    }
    
    func resetAndConfigIndicesAndOffsets() {
        offsets.removeAll(keepingCapacity: true)
        sourceIndices.removeAll(keepingCapacity: true)
        subsourcesHasSectioned = false
        reconfigSubselectorSets()
        configIndicesAndOffsets()
    }
    
    func reconfigSubselectorSets() {
        subselectorSets = initialSelectorSets(withoutIndex: true)
        configSubselectorSets()
    }
    
    func setupCoordinators() {
        for subsource in source {
            subsources.append(subsource)
            subitemCoordinators.append(subsource.itemTypedCoordinator)
        }
    }
    
    func index<Path: PathConvertible>(of path: Path) -> Int {
        switch sourceIndices[path.section] {
        case let .section(offset, _): return offset
        case let .cell(indices: indices): return indices[path.item]
        }
    }
    
    func index(of section: Int) -> Int? {
        guard case let .section(offset, _) = sourceIndices[section] else { return nil }
        return offset
    }
    
    func configIndicesAndOffsets() {
        var offset = Path()
        for subcoordinator in anysubCoordinators {
            switch (subcoordinator.sourceType, sourceIndices.last) {
            case (.section, _):
                let sections = subcoordinator.sourceIndices.sections(with: offsets.count)
                guard !sections.isEmpty else { break }
                offset = Path(section: sourceIndices.count)
                subsourcesHasSectioned = true
                sourceIndices.append(contentsOf: sections)
            case (.cell, .cell(var cells)?):
                let cellCounts = subcoordinator.numbersOfItems(in: 0)
                guard cellCounts != 0 else { break }
                offset.item = cells.count
                cells.append(contentsOf: repeatElement(offsets.count, count: cellCounts))
                sourceIndices[sourceIndices.lastIndex] = .cell(indices: cells)
            case (.cell, _):
                let cellCounts = subcoordinator.numbersOfItems(in: 0)
                guard cellCounts != 0 else { break }
                offset = Path(section: sourceIndices.count)
                let indices = Array(repeating: offset.section, count: cellCounts)
                sourceIndices.append(.cell(indices: indices))
            }

            offsets.append(offset)
        }
    }
    
    func configSubselectorSets() {
        guard !isEmpty else {
            subselectorSets = initialSelectorSets()
            return
        }
        let notEmptySubcoordinator = anysubCoordinators.filter { !$0.isEmpty }
        if notEmptySubcoordinator.count == 1, notEmptySubcoordinator[0].sourceType == sourceType {
            notEmptySubcoordinator[0].addToSelectorSet(&subselectorSets, isAll: true)
            return
        }
        for coordinator in notEmptySubcoordinator {
            coordinator.addToSelectorSet(&subselectorSets)
        }
    }
    
    func subcoordinator<Object: AnyObject, Input, Output>(
        for closureDelegate: Delegate<Object, Input, Output>,
        object: Object,
        with input: Input
    ) -> BaseCoordinator? {
        guard let index = closureDelegate.index else { return nil }
        let (sectionOffset, itemOffset) = offsets(for: object)
        let offset: Int
        switch index {
        case let .index(keyPath):
            let section = input[keyPath: keyPath]
            guard let sectionOffset = self.index(of: section - sectionOffset) else { return nil }
            offset = sectionOffset
        case let .indexPath(keyPath):
            let path = input[keyPath: keyPath]
            let rawPath = Path(section: path.section - sectionOffset, item: path.item - itemOffset)
            offset = self.index(of: rawPath)
        }
        let subcoordinator = anysubCoordinators[offset]
        return subcoordinator.responds(to: closureDelegate.selector) ? subcoordinator : nil
    }
    
    func subsectionSources<C: BaseCoordinator, V, D>(
        subcoordinators: [C],
        getter: (C) -> (SourceBase.Source.Element) -> SectionSourceValue<C, V, D>
    ) -> [SectionSourceValue<C, V, D>] {
        var results = [SourceValue<Other<C, V, D>, C, V, D>]()
        for (source, coordinator) in zip(subsources, subcoordinators) {
            let sectionSource = getter(coordinator)(source)
            switch (sectionSource, results.last) {
            case let (.other(other), .other(others))
                where other.type == .cellContainer && others.type == .cellContainer:
                let diffables = others.diffables() + other.diffables()
                let resultOther = Other(type: .cellContainer, diffables: { diffables })
                results[results.lastIndex] = .other(resultOther)
            default:
                results.append(getter(coordinator)(source))
            }
        }
        return results
    }
}

class AnySourcesCoordinator<SourceBase: DataSource>: SourcesCoordinator<SourceBase>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item,
    SourceBase.Source.Element.SourceBase.Item == Any
{
    var subcoordinators = [BaseCoordinator]()
    override var anysubCoordinators: [BaseCoordinator] { subcoordinators }
    
    override func anyItem<Path: PathConvertible>(at path: Path) -> Any {
        let indexAt = index(of: path)
        let offset = offsets[indexAt]
        let subcoordinator = subcoordinators[indexAt]
        return subcoordinator.anyItem(at: path - offset)
    }
    
    override func setupCoordinators() {
        for subsource in source {
            subsources.append(subsource)
            subcoordinators.append(subsource.listCoordinator)
        }
    }
    
    override func anySourceUpdate(to sources: [AnyDiffableSourceValue]) {
        var anySubsources = [Any]()
        var coordinators = [BaseCoordinator]()
        for source in sources {
            anySubsources.append(source.value)
            coordinators.append(source.coordinator)
        }
        subsources = anySubsources as! [SourceBase.Source.Element]
        subcoordinators = coordinators
        resetAndConfigIndicesAndOffsets()
    }
}

fileprivate extension BidirectionalCollection {
    var lastIndex: Index {
        return Swift.max(index(before: endIndex), startIndex)
    }
}

fileprivate extension Collection where Element == BaseCoordinator.SourceIndices {
    func sections(with offset: Int) -> [BaseCoordinator.SourceIndices] {
        map { .section(index: offset, count: $0.count) }
    }
}
