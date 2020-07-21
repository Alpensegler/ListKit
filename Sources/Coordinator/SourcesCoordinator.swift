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
    typealias Subsource = (value: SourcesSubelement<Source.Element>, related: Related, offset: Int)
    
    var subsourceType: SubsourceType
    var subsourceHasSectioned = false
    
    lazy var indices = configure(subsources: subsources)
    lazy var subsources: ContiguousArray<Subsource> = {
        guard case let .fromSourceBase(fromSource, _) = subsourceType else { fatalError() }
        return setupSubsources(for: fromSource(source))
    }()
    
    var subsourcesArray: ContiguousArray<Source.Element> {
        var sources = ContiguousArray<Source.Element>(capacity: subsources.count)
        for element in subsources {
            switch element.value {
            case .items(_, let items): sources += items()
            case .element(let element): sources.append(element)
            }
        }
        return sources
    }
    
    override var multiType: SourceMultipleType { .sources }
    override var isEmpty: Bool { indices.isEmpty }
    
    func set(
        source: Source? = nil,
        values: ContiguousArray<Subsource>,
        indices: ContiguousArray<Int>
    ) {
        (self.subsources, self.indices) = (values, indices)
        guard case let .fromSourceBase(_, map) = subsourceType, let source = source else { return }
        self.source = map(source)
    }
    
    func pathAndCoordinator(
        section: Int,
        item: Int
    ) -> (section: Int, item: Int, coordinator: Subcoordinator) {
        var (section, item) = (section, item)
        let index = sourceIndex(for: section, item)
        let context = subsources[index]
        sectioned ? (section -= context.offset) : (item -= context.offset)
        return (section, item, context.related.coordinator)
    }
    
    func sourceIndex(for section: Int, _ item: Int) -> Int {
        indices[sectioned ? section : item]
    }
    
    func setupSubsources(for source: Source) -> ContiguousArray<Subsource> {
        subsourceHasSectioned = false
        var (id, offset, itemOffset) = (0, 0, 0)
        var itemSources = ContiguousArray<Subsource>(capacity: source.count)
        var subsources = ContiguousArray<Subsource>(capacity: source.count)
        
        func addItemSources() {
            itemSources.forEach { $0.related.isSectioned = false }
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: itemSources,
                update: .init(way: update.way)
            )
            let context = coordinator.context()
            subsources.append((.items(id: id) { coordinator.subsourcesArray }, context, offset))
            itemSources.removeAll()
            id += 1
            itemOffset = 0
        }
        
        for element in source {
            let coordinator = element.listCoordinator
            let context = coordinator.context(with: element.listContextSetups)
            if coordinator.sectioned {
                if !itemSources.isEmpty { addItemSources() }
                subsources.append((.element(element), context, offset))
                subsourceHasSectioned = true
                offset += context.numbersOfSections()
            } else {
                itemSources.append((.element(element), context, offset))
                itemOffset += context.numbersOfItems(in: 0)
            }
        }
        
        switch (subsourceHasSectioned, itemSources.isEmpty) {
        case (true, false): addItemSources()
        case (false, false): subsources = itemSources
        default: break
        }
        
        return subsources
    }
    
    func configure(subsources: ContiguousArray<Subsource>) -> ContiguousArray<Int> {
        var indices = ContiguousArray<Int>(capacity: subsources.count)
        for (index, subsource) in subsources.enumerated() {
            let context = subsource.related
            context.index = index
            let count = sectioned ? context.numbersOfSections() : context.numbersOfItems(in: 0)
            if count == 0 { continue }
            indices.append(contentsOf: repeatElement(index, count: count))
        }
        return(indices)
    }
    
    func configOffsetAndIndices() {
        indices = configure(subsources: subsources)
    }
    
//    func difference(
//        to isTo: Bool,
//        _ subsources: ContiguousArray<Subsource>,
//        _ indices: ContiguousArray<Int>,
//        _ source: SourceBase.Source!,
//        _ differ: Differ<Item>
//    ) -> SourcesCoordinatorDifference<Source.Element> {
//        let mapping = isTo
//            ? (source: self.subsources, target: subsources)
//            : (source: subsources, target: self.subsources)
//        let source: Mapping = isTo ? (self.source, source) : (source, self.source)
//        let indices: Mapping = isTo ? (self.indices, indices) : (indices, self.indices)
//        let diff = SourcesCoordinatorDifference(mapping: mapping, itemDiffer: differ)
//        diff.isSectioned = sectioned
//        diff.coordinatorChange = {
//            self.subsources = mapping.target
//            self.source = source.target
//            self.indices = indices.target
//        }
//        diff.updateIndices = configOffsetAndIndices
//        diff.extraCoordinatorChange = {
//            self.subsources = $0
//            self.configOffsetAndIndices()
//            guard case let .fromSourceBase(_, fromSource) = self.subsourceType else { return }
//            self.source = fromSource(.init($0.flatMap { source -> ContiguousArray<Source.Element> in
//                switch source.value {
//                case let .items(_, items):
//                    return items()
//                case let .element(element):
//                    return [element]
//                }
//            }))
//        }
//
//        if !isTo {
//            self.source = source.source
//            self.subsources = subsources
//        }
//        return diff
//    }
    
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
        update: ListUpdate<SourceBase>
    ) {
        subsourceType = .values
        super.init(source: nil, update: update)
        subsources = elements
        sectioned = false
    }
    
    override func item(at section: Int, _ item: Int) -> Item {
        let (section, item, subcoordinator) = pathAndCoordinator(section: section, item: item)
        return subcoordinator.item(at: section, item)
    }
    
    override func numbersOfSections() -> Int {
        sectioned ? indices.count : isEmpty && !options.keepEmptySection ? 0 : 1
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        guard sectioned else { return indices.count }
        let index = indices[section]
        let context = subsources[index]
        return context.related.coordinator.numbersOfItems(in: section - context.offset)
    }
    
    override func isSectioned() -> Bool { subsourceHasSectioned || super.isSectioned() }
    
    // Setup
    override func context(
        with setups: [(ListCoordinatorContext<SourceBase>) -> Void] = []
    ) -> ListCoordinatorContext<SourceBase> {
        let context = SourcesCoordinatorContext(self, setups: setups)
        listContexts.append(.init(context: context))
        return context
    }
    
//    // Updates:
//    override func difference(
//        to source: SourceBase.Source,
//        differ: Differ<Item>
//    ) -> CoordinatorDifference {
//        guard case let .fromSourceBase(fromSource, _) = subsourceType else { fatalError() }
//        let subsource = setupSubsources(for: fromSource(source))
//        let indices = offsetAndIndicesFor(subsources: subsource)
//        return difference(to: true, subsource, indices, source, differ)
//    }
}

extension SourcesCoordinator where SourceBase.Source == Source {
    convenience init(sources sourceBase: SourceBase) {
        self.init(sourceBase, toSource: { $0 }, fromSource: { $0 })
    }
}
