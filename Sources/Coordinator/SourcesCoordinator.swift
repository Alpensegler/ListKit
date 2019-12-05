//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

class SourcesCoordinator<Source: DataSource>: SourceListCoordinator<Source>
where
    Source.Source: RangeReplaceableCollection,
    Source.Source.Element: DataSource,
    Source.Source.Element.SourceBase.Item == Source.Item
{
    var subsources = [Source.Source.Element]()
    var subitemCoordinators = [ItemListCoordinator<Item>]()
    var anysubCoordinators: [ListCoordinator] { subitemCoordinators }
    var sectionedSourceIndices = [SourceIndices]()
    var subsourcesHasSectioned = false
    
    var offsets = [Path]()
    
    override func item(at path: Path) -> Item {
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
            self.subSectionSources(
                subcoordinators: self.anysubCoordinators,
                getter: ListCoordinator.anySectionSources
            )
        })
    }
    
    override func anySourceUpdate(to sources: [AnyDiffableSourceValue]) {
        var anySubsources = [Any]()
        var subcoordinators = [ListCoordinator]()
        for source in sources {
            anySubsources.append(source.value)
            subcoordinators.append(source.coordinator)
        }
        subsources = anySubsources as! [Source.Source.Element]
        subitemCoordinators = subcoordinators as! [ItemListCoordinator<Item>]
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
            self.subSectionSources(
                subcoordinators: self.subitemCoordinators,
                getter: ItemListCoordinator<Item>.sectionSources
            )
        })
    }
    
    override func sourceUpdate(to sources: [DiffableSourceValue]) {
        var anySubsources = [Any]()
        var subcoordinators = [ItemListCoordinator<Item>]()
        for source in sources {
            anySubsources.append(source.value)
            subcoordinators.append(source.coordinator)
        }
        subsources = anySubsources as! [Source.Source.Element]
        subitemCoordinators = subcoordinators
        resetAndConfigIndicesAndOffsets()
    }
    
    override func setup() {
        setupCoordinators()
        configIndicesAndOffsets()
        rangeReplacable = true
    }
    
    func resetAndConfigIndicesAndOffsets() {
        offsets.removeAll(keepingCapacity: true)
        sourceIndices.removeAll(keepingCapacity: true)
        subsourcesHasSectioned = false
        configIndicesAndOffsets()
    }
    
    func setupCoordinators() {
        for subsource in source {
            subsources.append(subsource)
            subitemCoordinators.append(subsource.listCoordinator as! ItemListCoordinator<Item>)
        }
    }
    
    func index(of path: Path) -> Int {
        switch sourceIndices[path.section] {
        case let .section(_, count: count): return count
        case let .cell(indices: indices): return indices.count
        }
    }
    
    func configIndicesAndOffsets() {
        var offset = Path()
        for subcoordinator in anysubCoordinators {
            switch (subcoordinator.sourceType, sourceIndices.last) {
            case (.section, _):
                subsourcesHasSectioned = true
                offset = Path(section: sourceIndices.count)
                let sections = subcoordinator.sourceIndices.sections(with: offsets.count)
                sourceIndices.append(contentsOf: sections)
            case (.cell, .cell(var cells)?):
                offset.item = cells.count
                let cellCounts = subcoordinator.numbersOfItems(in: 0)
                cells.append(contentsOf: repeatElement(offsets.count, count: cellCounts))
                sourceIndices[sourceIndices.lastIndex] = .cell(indices: cells)
            case (.cell, _):
                offset = Path(section: sourceIndices.count)
                let cellCounts = subcoordinator.numbersOfItems(in: 0)
                let indices = Array(repeating: offset.section, count: cellCounts)
                sourceIndices.append(.cell(indices: indices))
            }

            offsets.append(offset)
        }
    }
    
    func subSectionSources<C: ListCoordinator, V, D>(
        subcoordinators: [C],
        getter: (C) -> (Source.Source.Element) -> SectionSourceValue<C, V, D>
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

class AnySourcesCoordinator<Source: DataSource>: SourcesCoordinator<Source>
where
    Source.Source: RangeReplaceableCollection,
    Source.Source.Element: DataSource,
    Source.Source.Element.SourceBase.Item == Source.Item,
    Source.Source.Element.SourceBase.Item == Any
{
    var subcoordinators = [ListCoordinator]()
    override var anysubCoordinators: [ListCoordinator] { subcoordinators }
    
    override func anyItem(at path: Path) -> Any {
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
        var coordinators = [ListCoordinator]()
        for source in sources {
            anySubsources.append(source.value)
            coordinators.append(source.coordinator)
        }
        subsources = anySubsources as! [Source.Source.Element]
        subcoordinators = coordinators
        resetAndConfigIndicesAndOffsets()
    }
}

fileprivate extension BidirectionalCollection {
    var lastIndex: Index {
        return Swift.max(index(before: endIndex), startIndex)
    }
}

fileprivate extension Collection where Element == ListCoordinator.SourceIndices {
    func sections(with offset: Int) -> [ListCoordinator.SourceIndices] {
        map { .section(index: offset, count: $0.count) }
    }
}
