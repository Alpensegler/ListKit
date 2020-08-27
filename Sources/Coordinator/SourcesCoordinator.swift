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
    
    var coordinator: ListCoordinator<Element.SourceBase> { context.listCoordinator }
    
    func setting(offset: Int, count: Int? = nil) -> Self {
        .init(element: element, context: context, offset: offset, count: count ?? self.count)
    }
}

extension SourceElement: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch element {
        case let .items(id: id, items):
            return "Items(\(id), \(items().map { $0 }))"
        case let .element(element):
            return "Element(\(element))"
        }
    }
    
    var debugDescription: String { description }
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
    
    lazy var indices = Self.toIndices(subsources)
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
    
    init(
        _ sourceBase: SourceBase,
        toSource: @escaping (SourceBase.Source) -> (Source),
        fromSource:  @escaping (Source) -> SourceBase.Source
    ) {
        let source = sourceBase.source
        subsourceType = .fromSourceBase(toSource, fromSource)
        super.init(
            source: source,
            update: sourceBase.listUpdate,
            differ: sourceBase.listDiffer,
            options: sourceBase.listOptions
        )
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
    
    func settingIndex(_ values: ContiguousArray<Subsource>) -> ContiguousArray<Subsource> {
        values.enumerated().forEach { $0.element.context.index = $0.offset }
        return values
    }
    
    func sourceIndex<Index: ListIndex>(for listIndex: Index) -> Int {
        indices[sectioned ? listIndex.section : listIndex.item].index
    }
    
    func toSubsources(_ source: Source) -> ContiguousArray<Subsource> {
        subsourceHasSectioned = false
        var (id, offset, itemOffset) = (0, 0, 0)
        var itemSources = ContiguousArray<Subsource>(capacity: source.count)
        var subsources = ContiguousArray<Subsource>(capacity: source.count)
        
        func addItemSources() {
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: settingIndex(itemSources),
                update: .init(way: update.way)
            )
            let context = coordinator.context()
            itemSources.forEach {
                $0.context.isSectioned = false
                coordinator.addUpdate(to: $0.context)
            }
            addUpdate(to: context)
            let item = Subsource.Subelement.items(id: id) { coordinator.subsourcesArray }
            let count = context.numbersOfSections()
            subsources.append(.init(element: item, context: context, offset: offset, count: count))
            itemSources.removeAll()
            id += 1
            itemOffset = 0
            offset += count
        }
        
        for element in source {
            let coordinator = element.listCoordinator
            let context = coordinator.context(with: element.listContextSetups)
            if coordinator.sectioned {
                addUpdate(to: context)
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
        case (true, false):
            addItemSources()
        case (false, false):
            itemSources.forEach { addUpdate(to: $0.context) }
            subsources = itemSources
        default:
            break
        }
        
        return settingIndex(subsources)
    }
    
    func addUpdate(to context: ListCoordinatorContext<Source.Element.SourceBase>) {
        context.update = { [weak self] in self?.perform(subupdate: $1, at: $0) ?? [] }
    }
    
    func perform(
        subupdate: CoordinatorUpdate,
        at index: Int
    ) -> [(CoordinatorContext, CoordinatorUpdate)] {
        if let update = currentCoordinatorUpdate {
            update.add(subupdate: subupdate, at: index)
            return []
        }
        let update = SourcesCoordinatorUpdate<SourceBase, Source>(
            coordinator: self,
            update: .init(updateType: .batch(.init())),
            values: (subsources, subsources),
            sources: (source, source),
            indices: (indices, indices),
            keepSectionIfEmpty: (options.keepEmptySection, options.keepEmptySection),
            isSectioned: self.sectioned
        )
        update.add(subupdate: subupdate, at: index)
        currentCoordinatorUpdate = update
        return contextAndUpdates(update: update)
    }
    
    override func item(at indexPath: IndexPath) -> Item {
        let index = sourceIndex(for: indexPath), context = subsources[index]
        let indexPath = indexPath.offseted(-context.offset, isSection: sectioned)
        return context.coordinator.item(at: indexPath)
    }
    
    override func numbersOfSections() -> Int {
        sectioned ? indices.count : indices.isEmpty && !options.keepEmptySection ? 0 : 1
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
        let indicesAfterUpdate = subsourcesAfterUpdate.map(Self.toIndices)
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

extension SourcesCoordinator {
    static func toIndices(_ subsources: ContiguousArray<Subsource>) -> Indices {
        var indices = Indices(capacity: subsources.count)
        for (index, subsource) in subsources.enumerated() {
            subsource.context.index = index
            let count = subsource.count
            if count == 0 { continue }
            indices.append(repeatElement: (index, false), count: count)
        }
        return(indices)
    }
}

extension SourcesCoordinator where SourceBase.Source == Source {
    convenience init(sources sourceBase: SourceBase) {
        self.init(sourceBase, toSource: { $0 }, fromSource: { $0 })
    }
}
