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

class SourcesCoordinator<SourceBase: DataSource, Source>: ListCoordinator<SourceBase>
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
    var id = 0
    
    lazy var indices = Self.toIndices(subsources)
    lazy var subsourcesAndSubsectioned = toSubsources(subsourceType.from!(source), sectioned: nil)
    
    var subsources: ContiguousArray<Subsource> {
        get { subsourcesAndSubsectioned.subsources }
        set { subsourcesAndSubsectioned.subsources = newValue }
    }
    
    var notItems: Bool { subsourcesAndSubsectioned.sectioned }
    
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
    
    var updateType: SourcesCoordinatorUpdate<SourceBase, Source>.Type {
        SourcesCoordinatorUpdate<SourceBase, Source>.self
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
        super.init(source: nil, update: update, options: .removeEmptySection)
        subsourcesAndSubsectioned = (elements, false)
        sourceType = .sectionItems
    }
    
    func settingIndex(_ values: ContiguousArray<Subsource>) -> ContiguousArray<Subsource> {
        values.enumerated().forEach { $0.element.context.index = $0.offset }
        return values
    }
    
    func sourceIndex<Index: ListIndex>(for listIndex: Index) -> Int {
        indices[notItems ? listIndex.section : listIndex.item].index
    }
    
    func toSubsources(
        _ source: Source,
        sectioned: Bool? = nil
    ) -> (subsources: ContiguousArray<Subsource>, sectioned: Bool) {
        var sectioned = sectioned ?? super.isSectioned
        var (id, offset, itemOffset) = (0, 0, 0)
        var itemSources = ContiguousArray<Subsource>(capacity: source.count)
        var subsources = ContiguousArray<Subsource>(capacity: source.count)
        
        func addItemSources() {
            let coordinator = SourcesCoordinator<Source.Element.SourceBase, [Source.Element]>(
                elements: settingIndex(itemSources),
                update: .init(way: update.way)
            )
            let context = ListCoordinatorContext(coordinator)
            itemSources.forEach {
                $0.context.isSectioned = false
                coordinator.addContext(to: $0.context)
            }
            addContext(to: context)
            let item = Subsource.Subelement.items(id: id) { coordinator.subsourcesArray }
            let count = context.numbersOfSections()
            subsources.append(.init(element: item, context: context, offset: offset, count: count))
            itemSources.removeAll()
            id += 1
            self.id = id + 1
            itemOffset = 0
            offset += count
        }
        
        for element in source {
            let context = element.listCoordinatorContext, coordinator = context.listCoordinator
            if coordinator.sourceType.isSection {
                addContext(to: context)
                if !itemSources.isEmpty { addItemSources() }
                let count = context.numbersOfSections()
                let element = Subsource.Subelement.element(element)
                subsources.append(.init(element: element, context: context, offset: offset, count: count))
                sectioned = true
                offset += count
            } else {
                let count = context.numbersOfItems(in: 0)
                itemSources.append(.init(element: .element(element), context: context, offset: itemOffset, count: count))
                itemOffset += count
            }
        }
        
        switch (sectioned, itemSources.isEmpty) {
        case (true, false):
            addItemSources()
        case (false, false):
            itemSources.forEach { addContext(to: $0.context) }
            subsources = itemSources
        default:
            break
        }
        
        return (settingIndex(subsources), sectioned)
    }
    
    func addContext(to context: ListCoordinatorContext<Source.Element.SourceBase>) {
        context.update = { [weak self] (index, subupdate) in
            guard let self = self else { return nil }
            let subupdate = subupdate as! ListCoordinatorUpdate<Source.Element.SourceBase>
            if let update = self.currentCoordinatorUpdate as? SourcesCoordinatorUpdate<SourceBase, Source> {
                update.add(subupdate: subupdate, at: index)
                return []
            }
            let update = self.updateType.init(
                coordinator: self,
                update: .init(updateType: .batch(.init())),
                values: (self.subsources, self.subsources),
                sources: (self.source, self.source),
                indices: (self.indices, self.indices),
                options: (self.options, self.options)
            )
            update.add(subupdate: subupdate, at: index)
            return self.contextAndUpdates(update: update)
        }
        
        context.contextAtIndex = { [weak self] (index, offset, listView) in
            guard let self = self else { return [] }
            let offset = offset.offseted(self.subsources[index].offset, isSection: self.notItems)
            return self.offsetAndRoot(offset: offset, list: listView)
        }
    }
    
    func subContextIndex(at indexPath: IndexPath) -> (SourceElement<Source.Element>, IndexPath) {
        let index = sourceIndex(for: indexPath), context = subsources[index]
        return (context, indexPath.offseted(-context.offset, isSection: notItems))
    }
    
    override func numbersOfSections() -> Int {
        notItems ? indices.count : indices.isEmpty && options.removeEmptySection ? 0 : 1
    }
    
    override func numbersOfItems(in section: Int) -> Int {
        guard notItems else { return indices.count }
        let index = indices[section]
        if index.isFake { return 0 }
        let context = subsources[index.index]
        let count = context.coordinator.numbersOfItems(in: section - context.offset)
        return count
    }
    
    override func item(at indexPath: IndexPath) -> Item {
        let (context, indexPath) = subContextIndex(at: indexPath)
        return context.coordinator.item(at: indexPath)
    }
    
    override func cache<ItemCache>(
        for cached: inout Any?,
        at indexPath: IndexPath,
        in delegate: ListDelegate
    ) -> ItemCache {
        guard delegate.getCache == nil else { return super.cache(for: &cached, at: indexPath, in: delegate) }
        let (context, indexPath) = subContextIndex(at: indexPath)
        return context.coordinator.cache(for: &cached, at: indexPath, in: context.context.listDelegate)
    }
    
    override func configSourceType() -> SourceType {
        subsourcesAndSubsectioned.sectioned ? .section : .items
    }
    
    // Selectors
    override func configExtraSelector(delegate: ListDelegate) -> Set<Selector>? {
        guard delegate.extraSelectors.isEmpty else { return nil }
        var results = Set<Selector>()
        for subsource in subsources {
            let subdelegate = subsource.context.listDelegate
            subdelegate.functions.keys.forEach { results.insert($0) }
            if let selectors = subsource.coordinator.configExtraSelector(delegate: subdelegate) {
                results.formUnion(selectors)
            }
        }
        return results
    }
    
    override func apply<Object: AnyObject, Target, Input, Output, Closure>(
        _ function: ListDelegate.Function<Object, Delegate, Target, Input, Output, Closure>,
        for context: Context,
        root: CoordinatorContext,
        object: Object,
        with input: Input
    ) -> Output? {
        guard context.extraSelectors.contains(function.selector) else {
            return super.apply(function, for: context, root: root, object: object, with: input)
        }
        if function.noOutput {
            let output = subsources.compactMap { (element) in
                element.coordinator.apply(function, for: element.context, root: root, object: object, with: input)
            }.first
            return super.apply(function, for: context, root: root, object: object, with: input) ?? output
        } else {
            let output = subsources.lazy.compactMap { (element) in
                element.coordinator.apply(function, for: element.context, root: root, object: object, with: input)
            }.first
            return output ?? super.apply(function, for: context, root: root, object: object, with: input)
        }
    }
    
    override func apply<Object: AnyObject, Target, Input, Output, Closure, Index: ListIndex>(
        _ function: ListDelegate.IndexFunction<Object, Delegate, Target, Input, Output, Closure, Index>,
        for context: Context,
        root: CoordinatorContext,
        object: Object,
        with input: Input,
        _ offset: Index
    ) -> Output? {
        guard context.extraSelectors.contains(function.selector) else {
            return super.apply(function, for: context, root: root, object: object, with: input, offset)
        }
        let path = function.indexForInput(input)
        let index = sourceIndex(for: path.offseted(offset, plus: false))
        let subsource = subsources[index], subcontext = subsource.context, subcoordinator = subsource.coordinator
        let offset = offset.offseted(subsource.offset, isSection: sourceType == .section)
        let output = subcoordinator.apply(function, for: subcontext, root: root, object: object, with: input, offset)
        if function.noOutput {
            return super.apply(function, for: context, root: root, object: object, with: input, offset) ?? output
        } else {
            return output ?? super.apply(function, for: context, root: root, object: object, with: input, offset)
        }
    }
    
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! SourcesCoordinator<SourceBase, Source>
        return updateType.init(
            coordinator: self,
            update: ListUpdate(updateWay),
            values: (coordinator.subsources, subsources),
            sources: (coordinator.source, source),
            indices: (coordinator.indices, indices),
            options: (coordinator.options, options)
        )
    }
    
    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        let subsourcesAfter = update.source.flatMap { value in
            subsourceType.from.map { toSubsources($0(value), sectioned: notItems).subsources }
        }
        return updateType.init(
            coordinator: self,
            update: update,
            values: (subsources, subsourcesAfter ?? subsources),
            sources: (source, update.source ?? source),
            indices: (indices, subsourcesAfter.map(Self.toIndices) ?? indices),
            options: (self.options, options ?? self.options)
        )
    }
}

final class DataSourcesCoordinator<SourceBase: DataSource>:
    SourcesCoordinator<SourceBase, SourceBase.Source>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.Item == SourceBase.Item
{
    override var updateType: SourcesCoordinatorUpdate<SourceBase, SourceBase.Source>.Type {
        DataSourcesCoordinatorUpdate<SourceBase>.self
    }
    
    init(sources sourceBase: SourceBase) {
        super.init(sourceBase, toSource: { $0 }, fromSource: { $0 })
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
