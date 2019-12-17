//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

final class SourcesCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    var subsources = [SourceBase.Source.Element]()
    var subCoordinators = [ItemTypedCoorinator<Item>]()
    var anysubCoordinators: [BaseCoordinator] { subCoordinators }
    var isAnyType = Item.self == Any.self
    
    var sourcesDelegates = [ObjectIdentifier: SourcesDelegates<SourceBase>]()
    override var delegatesStorage: [ObjectIdentifier: ListDelegates<SourceBase>] {
        get { sourcesDelegates }
        set { fatalError() }
    }
    
    override var isEmpty: Bool { sourceIndices.isEmpty }
    
    override func item<Path: PathConvertible>(at path: Path) -> Item {
        let indexAt = sourceIndices.index(of: path)
        let offset = offsets[indexAt]
        let subcoordinator = subCoordinators[indexAt]
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
        subCoordinators = subcoordinators
        resetAndConfigIndicesAndOffsets()
    }
    
    override func itemSources<Source: DataSource>(
        source: Source
    ) -> ItemSource where Source.SourceBase.Item == Item {
        .inSource(.init(source: source, coordinator: self) {
            zip(self.subsources, self.subCoordinators).map { (source, coordinator) in
                coordinator.itemSources(source: source)
            }
        })
    }
    
    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
        .inSource(.init(source: source, coordinator: self) {
            self.subsectionSources(
                subcoordinators: self.subCoordinators,
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
        subCoordinators = subcoordinators
        resetAndConfigIndicesAndOffsets()
    }
    
    @discardableResult
    override func setup(
        listView: SetuptableListView,
        objectIdentifier: ObjectIdentifier,
        sectionOffset: Int = 0,
        itemOffset: Int = 0,
        isRoot: Bool = false
    ) -> Delegates {
        if let delegates = sourcesDelegates[objectIdentifier] {
            delegates.sectionOffset = sectionOffset
            delegates.itemOffset = itemOffset
            delegates.configSubdelegatesOffsets()
            return delegates
        }
        let delegates = SourcesDelegates(
            coordinator: self,
            listView: listView
        )
        delegates.sectionOffset = sectionOffset
        delegates.itemOffset = itemOffset
        sourcesDelegates[objectIdentifier] = delegates
        if !didSetup {
            setupCoordinators()
            rangeReplacable = true
            let hasSectioned = configSubdelegates(
                for: [(objectIdentifier, delegates)],
                isReset: true
            )
            sourceType = (delegates.selectorSets.hasIndex || hasSectioned) ? .section : .cell
            didSetup = true
        } else {
            configSubdelegates(for: [(objectIdentifier, delegates)], isReset: false)
        }
        delegates.setup(isRoot: isRoot, listView: listView)
        return delegates
    }
    
    func resetAndConfigIndicesAndOffsets() {
        offsets.removeAll(keepingCapacity: true)
        sourceIndices.removeAll(keepingCapacity: true)
        sourcesDelegates.values.forEach { $0.subdelegates.removeAll(keepingCapacity: true) }
        configSubdelegates(for: sourcesDelegates, isReset: true)
    }
    
    func setupCoordinators() {
        for subsource in source {
            subsources.append(subsource)
            subCoordinators.append(subsource.itemTypedCoordinator)
        }
    }
    
    @discardableResult
    func configSubdelegates<C: Collection>(
        for collection: C,
        isReset: Bool = true
    ) -> Bool where C.Element == (key: ObjectIdentifier, value: SourcesDelegates<SourceBase>) {
        var hasSectioned = false
        if isReset {
            var offset = Path()
            for coordinator in anysubCoordinators {
                collection.forEach { setCoordinator(coordinator, context: $0, offset: offset) }
                appendCoordinator(coordinator, offset: &offset, hasSection: &hasSectioned)
            }
        } else {
            for (subcoordinator, offset) in zip(anysubCoordinators, offsets) {
                collection.forEach { setCoordinator(subcoordinator, context: $0, offset: offset) }
            }
        }
        
        collection.forEach { $0.1.setupSelectorSets() }
        return hasSectioned
    }
    
    func appendCoordinator(
        _ subcoordinator: BaseCoordinator,
        offset: inout Path,
        hasSection: inout Bool
    ) {
        offsets.append(offset)
        switch (subcoordinator.sourceType, sourceIndices.last) {
        case (.section, _):
            let sections = subcoordinator.sourceIndices.sections(with: offsets.count - 1)
            guard !sections.isEmpty else { break }
            hasSection = true
            sourceIndices.append(contentsOf: sections)
            offset = Path(section: sourceIndices.count)
        case (.cell, .cell(var cells)?):
            let cellCounts = subcoordinator.numbersOfItems(in: 0)
            guard cellCounts != 0 else { break }
            cells.append(contentsOf: repeatElement(offsets.count - 1, count: cellCounts))
            offset.item = cells.count
            sourceIndices[sourceIndices.lastIndex] = .cell(indices: cells)
        case (.cell, _):
            let cellCounts = subcoordinator.numbersOfItems(in: 0)
            guard cellCounts != 0 else { break }
            let indices = Array(repeating: offset.section, count: cellCounts)
            sourceIndices.append(.cell(indices: indices))
            offset = Path(section: sourceIndices.count)
        }
    }
    
    func setCoordinator(
        _ subcoordinator: BaseCoordinator,
        context: (ObjectIdentifier, SourcesDelegates<SourceBase>),
        offset: Path
    ) {
        guard let listView = context.1.listView() else { return }
        let delegates = subcoordinator.setup(
            listView: listView,
            objectIdentifier: context.0,
            sectionOffset: offset.section + context.1.sectionOffset,
            itemOffset: offset.item + context.1.itemOffset
        )
        context.1.subdelegates.append((delegates, subcoordinator.isEmpty))
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
