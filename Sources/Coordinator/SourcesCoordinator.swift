//
//  SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

import Foundation

struct SourceElement<Element> where Element: DataSource {
    enum Subelement {
        case items(id: Int, () -> ContiguousArray<Element>)
        case element(Element)
    }
    
    let element: Subelement
    let context: ListCoordinatorContext<Element.SourceBase>
    let offset: Int
    let count: Int
    
    var coordinator: ListCoordinator<Element.SourceBase> { context.coordinator }
    
    func setting(offset: Int, count: Int? = nil) -> Self {
        .init(element: element, context: context, offset: offset, count: count ?? self.count)
    }
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
        
        var from: ((SourceBase.Source) -> Source)? {
            guard case let .fromSourceBase(from, _) = self else { return nil }
            return from
        }
    }
    
    typealias Subcoordinator = ListCoordinator<Source.Element.SourceBase>
    typealias Related = ListCoordinatorContext<Source.Element.SourceBase>
    typealias Subsource = SourceElement<Source.Element>
    
    var subsourceType: SubsourceType
    var subsourceHasSectioned = false
    
    lazy var indices = toIndices(subsources)
    lazy var subsources: ContiguousArray<Subsource> = {
        guard case let .fromSourceBase(fromSource, _) = subsourceType else { fatalError() }
        return toSubsources(fromSource(source))
    }()
    
    var subsourcesArray: ContiguousArray<Source.Element> {
        var sources = ContiguousArray<Source.Element>(capacity: subsources.count)
        for element in subsources {
            switch element.element {
            case .items(_, let items): sources += items()
            case .element(let element): sources.append(element)
            }
        }
        return sources
    }
    
    override var isEmpty: Bool { indices.isEmpty }
    
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
        update: ListUpdate<SourceBase>.Whole
    ) {
        subsourceType = .values
        super.init(source: nil, update: update)
        subsources = elements
        sectioned = false
    }
    
    func set(
        source: Source? = nil,
        values: ContiguousArray<Subsource>,
        indices: Indices
    ) {
        defer { resetDelegates() }
        (self.subsources, self.indices) = (values, indices)
        guard case let .fromSourceBase(_, map) = subsourceType, let source = source else { return }
        self.source = map(source)
    }
    
    func resetDelegates() {
        listContexts.forEach {
            ($0.context as? SourcesCoordinatorContext<SourceBase, Source>)?.reconfigSelectorSet()
        }
    }
    
    func settingIndex(values: ContiguousArray<Subsource>) -> ContiguousArray<Subsource> {
        values.enumerated().forEach { $0.element.context.index = $0.offset }
        return values
    }
    
    func pathAndCoordinator(
        section: Int,
        item: Int
    ) -> (section: Int, item: Int, coordinator: Subcoordinator) {
        var (section, item) = (section, item)
        let index = sourceIndex(for: section, item)
        let context = subsources[index]
        sectioned ? (section -= context.offset) : (item -= context.offset)
        return (section, item, context.coordinator)
    }
    
    func sourceIndex(for section: Int, _ item: Int) -> Int {
        indices[sectioned ? section : item].index
    }
    
    func toSubsources(_ source: Source) -> ContiguousArray<Subsource> {
        subsourceHasSectioned = false
        var (id, offset, itemOffset) = (0, 0, 0)
        var itemSources = ContiguousArray<Subsource>(capacity: source.count)
        var subsources = ContiguousArray<Subsource>(capacity: source.count)
        
        func addItemSources() {
            itemSources.forEach { $0.context.isSectioned = false }
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: settingIndex(values: itemSources),
                update: .init(way: update.way)
            )
            let context = coordinator.context()
            let item = Subsource.Subelement.items(id: id) { coordinator.subsourcesArray }
            let count = context.numbersOfSections()
            subsources.append(.init(element: item, context: context, offset: offset, count: count))
            itemSources.removeAll()
            id += 1
            itemOffset = 0
        }
        
        for element in source {
            let coordinator = element.listCoordinator
            let context = coordinator.context(with: element.listContextSetups)
            if coordinator.sectioned {
                if !itemSources.isEmpty { addItemSources() }
                let count = context.numbersOfSections()
                let element = Subsource.Subelement.element(element)
                subsources.append(.init(element: element, context: context, offset: offset, count: count))
                subsourceHasSectioned = true
                offset += count
            } else {
                let count = context.numbersOfItems(in: 0)
                itemSources.append(.init(element: .element(element), context: context, offset: itemOffset, count: count))
                itemOffset += count
            }
        }
        
        switch (subsourceHasSectioned, itemSources.isEmpty) {
        case (true, false): addItemSources()
        case (false, false): subsources = itemSources
        default: break
        }
        
        return settingIndex(values: subsources)
    }
    
    func toIndices(_ subsources: ContiguousArray<Subsource>) -> Indices {
        var indices = Indices(capacity: subsources.count)
        for (index, subsource) in subsources.enumerated() {
            subsource.context.index = index
            let count = subsource.count
            if count == 0 { continue }
            indices.append(repeatElement: (index,false), count: count)
        }
        return(indices)
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
        if index.isFake { return 0 }
        let context = subsources[index.index]
        let count = context.coordinator.numbersOfItems(in: section - context.offset)
        return count
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
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        let coordinator = coordinator as! SourcesCoordinator<SourceBase, Source>
        return SourcesCoordinatorUpdate(
            coordinator: self,
            update: ListUpdate(updateWay, or: update),
            values: (coordinator.subsources, subsources),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            keepSectionIfEmpty: (coordinator.options.keepEmptySection, options.keepEmptySection),
            isSectioned: sectioned
        )
    }
    
    override func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate {
        let sourcesAfterUpdate = update.source
        let subsourcesAfterUpdate = sourcesAfterUpdate.flatMap { value in
            subsourceType.from.map { toSubsources($0(value)) }
        }
        let indicesAfterUpdate = subsourcesAfterUpdate.map(toIndices)
        defer {
            source = sourcesAfterUpdate ?? source
            subsources = subsourcesAfterUpdate ?? subsources
            indices = indicesAfterUpdate ?? indices
        }
        return SourcesCoordinatorUpdate(
            coordinator: self,
            update: update,
            values: (subsources, subsourcesAfterUpdate ?? subsources),
            sources: (source, sourcesAfterUpdate ?? source),
            indices: (indices, indicesAfterUpdate ?? indices),
            keepSectionIfEmpty: (options.keepEmptySection, options.keepEmptySection),
            isSectioned: sectioned
        )
    }
}

extension SourcesCoordinator where SourceBase.Source == Source {
    convenience init(sources sourceBase: SourceBase) {
        self.init(sourceBase, toSource: { $0 }, fromSource: { $0 })
    }
}
