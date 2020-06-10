//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

import Foundation

enum SourcesSubelement<Element> {
    case items(id: Int, () -> ContiguousArray<Element>)
    case element(Element)
}

final class SourcesCoordinator<SourceBase: DataSource, Source>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    enum SubsourceType {
        case fromSourceBase((SourceBase.Source) -> Source, (Source) -> SourceBase.Source)
        case values
    }
    
    typealias Subcoordinator = ListCoordinator<Source.Element.SourceBase>
    typealias Related = ListCoordinatorContext<Source.Element.SourceBase>
    typealias Subsource = ValueRelated<SourcesSubelement<Source.Element>, Related>
    
    var subsourceType: SubsourceType
    var indices = ContiguousArray<Int>()
    var subsourceHasSectioned = false
    
    lazy var subsources: ContiguousArray<Subsource> = {
        guard case let .fromSourceBase(fromSource, _) = subsourceType else { fatalError() }
        let subsources = setupSubsources(for: fromSource(source))
        indices = configOffsetAndIndicesFor(subsources: subsources)
        return subsources
    }()
    
    var subsourcesArray: ContiguousArray<Source.Element> {
        var sources = ContiguousArray<Source.Element>()
        sources.reserveCapacity(subsources.count)
        for element in subsources {
            switch element.value {
            case .items(_, let items): sources += items()
            case .element(let element): sources.append(element)
            }
        }
        return sources
    }
    
    override var multiType: SourceMultipleType { .sources }
    override var isEmpty: Bool { subsources.isEmpty }
    
    func pathAndCoordinator(
        section: Int,
        item: Int
    ) -> (section: Int, item: Int, coordinator: Subcoordinator) {
        var (section, item) = (section, item)
        let index = sourceIndex(for: section, item)
        let context = subsources[index].related
        isSectioned ? (section -= context.offset) : (item -= context.offset)
        return (section, item, context.coordinator)
    }
    
    func sourceIndex(for section: Int, _ item: Int) -> Int {
        indices[isSectioned ? section : item]
    }
    
    func setupSubsources(for source: Source) -> ContiguousArray<Subsource> {
        var id = 0
        subsourceHasSectioned = false
        var (itemSources, subsources) = (ContiguousArray<Subsource>(), ContiguousArray<Subsource>())
        itemSources.reserveCapacity(source.count)
        subsources.reserveCapacity(source.count)
        
        func addItemSources() {
            itemSources.forEach { $0.related.isSectioned = false }
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: itemSources,
                update: update
            )
            let context = coordinator.context()
            let source = Subsource(.items(id: id) { coordinator.subsourcesArray }, related: context)
            subsources.append(source)
            itemSources.removeAll()
            id += 1
        }
        
        for element in source {
            let coordinator = element.listCoordinator
            let context = coordinator.context(with: element.listContextSetups)
            if coordinator.isSectioned {
                if !itemSources.isEmpty { addItemSources() }
                subsources.append(.init(.element(element), related: context))
                subsourceHasSectioned = true
            } else {
                itemSources.append(.init(.element(element), related: context))
            }
        }
        
        switch (subsourceHasSectioned, itemSources.isEmpty) {
        case (true, false): addItemSources()
        case (false, false): subsources = itemSources
        default: break
        }
        
        return subsources
    }
    
    func configOffsetAndIndicesFor(subsources: ContiguousArray<Subsource>) -> ContiguousArray<Int> {
        var offset = 0
        var indices = ContiguousArray<Int>()
        indices.reserveCapacity(subsources.count)
        for (index, subsource) in subsources.enumerated() {
            let context = subsource.related
            context.offset = offset
            let count = isSectioned ? context.numbersOfSections() : context.numbersOfItems(in: 0)
            if count == 0 { continue }
            indices.append(contentsOf: repeatElement(index, count: count))
            offset += count
        }
        return indices
    }
    
    func difference(
        to isTo: Bool,
        _ subsources: ContiguousArray<Subsource>,
        _ indices: ContiguousArray<Int>,
        _ source: SourceBase.Source!,
        _ differ: Differ<Item>
    ) -> SourcesCoordinatorDifference<Source.Element> {
        let mapping = isTo
            ? (source: self.subsources, target: subsources)
            : (source: subsources, target: self.subsources)
        let source: Mapping = isTo ? (self.source, source) : (source, self.source)
        let indices: Mapping = isTo ? (self.indices, indices) : (indices, self.indices)
        let diff = SourcesCoordinatorDifference(mapping: mapping, itemDiffer: differ)
        diff.isSectioned = isSectioned
        diff.coordinatorChange = {
            self.subsources = mapping.target
            self.source = source.target
            self.indices = indices.target
        }
        diff.updateIndices = {
            self.indices = self.configOffsetAndIndicesFor(subsources: self.subsources)
        }
        diff.extraCoordinatorChange = {
            self.subsources = $0
            self.indices = self.configOffsetAndIndicesFor(subsources: $0)
            guard case let .fromSourceBase(_, fromSource) = self.subsourceType else { return }
            self.source = fromSource(.init($0.flatMap { (source: Subsource) -> ContiguousArray<Source.Element> in
                switch source.value {
                case let .items(_, items):
                    return items()
                case let .element(element):
                    return [element]
                }
            }))
        }
        
        if !isTo {
            self.source = source.source
            self.subsources = subsources
        }
        return diff
    }
    
    init(
        _ sourceBase: SourceBase,
        toSource: @escaping (SourceBase.Source) -> (Source),
        fromSource:  @escaping (Source) -> SourceBase.Source
    ) {
        let source = sourceBase.source
        subsourceType = .fromSourceBase(toSource, fromSource)
        super.init(source: source, update: sourceBase.listUpdate, options: sourceBase.listOptions)
    }
    
    init(
        elements: ContiguousArray<Subsource>,
        update: ListUpdate<SourceBase.Item>
    ) {
        subsourceType = .values
        super.init(source: nil, update: update)
        subsources = elements
        isSectioned = false
    }
    
    override func item(at section: Int, _ item: Int) -> Item {
        let (section, item, subcoordinator) = pathAndCoordinator(section: section, item: item)
        return subcoordinator.item(at: section, item)
    }
    
    override func itemRelatedCache(at section: Int, _ item: Int) -> ItemRelatedCache {
        let (section, item, subcoordinator) = pathAndCoordinator(section: section, item: item)
        return subcoordinator.itemRelatedCache(at: section, item)
    }
    
    override func numbersOfSections() -> Int {
        isSectioned ? indices.count : isEmpty && !keepSection ? 0 : 1
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        guard isSectioned else { return indices.count }
        let index = indices[section]
        let context = subsources[index].related
        return context.coordinator.numbersOfItems(in: section - context.offset)
    }
    
    override func configureIsSectioned() -> Bool {
        subsourceHasSectioned || selectorsHasSection
    }
    
    // Setup
    override func context(
        with setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) -> ListCoordinatorContext<SourceBase> {
        let context = SourcesCoordinatorContext(self, setups: setups)
        listContexts.append(.init(context))
        return context
    }
    
    // Updates:
    override func difference(
        to source: SourceBase.Source,
        differ: Differ<Item>
    ) -> CoordinatorDifference {
        guard case let .fromSourceBase(fromSource, _) = subsourceType else { fatalError() }
        let subsource = setupSubsources(for: fromSource(source))
        let indices = configOffsetAndIndicesFor(subsources: subsource)
        return difference(to: true, subsource, indices, source, differ)
    }
}

extension SourcesCoordinator where SourceBase.Source == Source {
    convenience init(sources sourceBase: SourceBase) {
        self.init(sourceBase, toSource: { $0 }, fromSource: { $0 })
    }
}
