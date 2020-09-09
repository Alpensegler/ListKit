//
//  SectionsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/15.
//

import Foundation

class SectionsCoordinatorUpdate<SourceBase>:
    CollectionCoordinatorUpdate<
        SourceBase,
        SourceBase.Source,
        ContiguousArray<SourceBase.Item>,
        CoordinatorUpdate.Change<ContiguousArray<SourceBase.Item>>,
        CoordinatorUpdate.Change<ContiguousArray<SourceBase.Item>>
    >
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    typealias Subsource = ListKit.Sources<Element, Item>
    typealias ItemsUpdate = ItemsCoordinatorUpdate<Subsource>
    typealias Source = SourceBase.Source
    typealias Sections = ContiguousArray<ContiguousArray<Item>>
    
    weak var coordinator: SectionsCoordinator<SourceBase>?
    lazy var itemsUpdates = configItemsUpdates()
    var indices: Mapping<Indices>
    
    var updateType: ItemsUpdate.Type { ItemsUpdate.self }
    
    required init(
        coordinator: SectionsCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>,
        values: Values,
        sources: Sources,
        indices: Mapping<Indices>,
        options: Options
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, values: values, sources: sources, options: options)
    }
    
    func toSource(values: ContiguousArray<ItemsUpdate>, id: ObjectIdentifier?) -> Source {
        fatalError()
    }
    
    override func configCount() -> Mapping<Int> { (indices.source.count, indices.target.count) }
    
    override func updateData(_ isSource: Bool) {
        super.updateData(isSource)
        coordinator?.sections = isSource ? values.source : values.target
        coordinator?.indices = isSource ? indices.source : indices.target
    }
    
    override func inferringMoves(context: ContextAndID? = nil) {
        itemsUpdates.forEach { $0.inferringMoves(context: context ?? defaultContext) }
    }
    
    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        if notUpdate(order, context) { return (count.target, nil) }
        var (count, update) = (0, BatchUpdates.ListSource())
        for itemUpdate in itemsUpdates {
            let (subsectionCount, subupdate) = itemUpdate.generateSourceUpdate(
                order: order,
                context: toContext(context, or: 0) { $0 + count }
            )
            count += subsectionCount
            subupdate.map { update.add($0) }
        }
        return (count, update)
    }
    
    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        if notUpdate(order, context) { return (toIndices(indices.target, context), nil, nil) }
        var (indices, update) = (Indices(capacity: itemsUpdates.count), BatchUpdates.ListTarget())
        for (i, itemUpdate) in itemsUpdates.enumerated() {
            let subcontext = toContext(context, or: (0, (0, 0))) {
                (i, ($0.offset.source + indices.count, $0.offset.target + indices.count))
            }
            let (subsectionCount, subupdate, _) = itemUpdate.generateTargetUpdate(
                order: order,
                context: subcontext
            )
            indices.append(contentsOf: subsectionCount)
            subupdate.map { update.add($0) }
            updateMaxIfNeeded(itemUpdate, context, subcontext)
        }
        let change: (() -> Void)?
        switch order {
        case .first:
            change = { [unowned self] in
                self.coordinator?.source = self.sources.source
                self.coordinator?.sections = self.values.source
                self.coordinator?.indices = indices
            }
        case .second where hasNext(order, context):
            let source = toSource(values: itemsUpdates, id: context?.id)
            let sections = itemsUpdates.mapContiguous {
                $0.hasNext(.second, context) ? $0.extraValues[context?.id] : $0.values.target
            }
            change = { [unowned self] in
                self.coordinator?.source = source
                self.coordinator?.indices = indices
                self.coordinator?.sections = sections
            }
        default:
            change = finalChange
        }
        
        return (toIndices(indices, context), update, change)
    }
}

extension SectionsCoordinatorUpdate {
    func configItemsUpdates() -> ContiguousArray<ItemsUpdate> {
        let (sourceCount, targetCount) = (values.source.count, values.target.count)
        let maxCount = max(sourceCount, targetCount)
        if maxCount == 0 { return [] }
        let elements = sources.target?.mapContiguous { $0 }
        return (0..<maxCount).mapContiguous { i in
            var (sourceOption, targetOption) = options
            let source = i < sourceCount ? values.source[i] : []
            let target = i < targetCount ? values.target[i] : []
            if i >= targetCount { sourceOption.insert(.removeEmptySection) }
            if i >= sourceCount { targetOption.insert(.removeEmptySection) }
            return updateType.init(
                update: (update?.way).map { .init(.init(way: $0)) } ?? .init(),
                values: (source, target),
                sources: (nil, elements?[safe: i]),
                options: (sourceOption, targetOption)
            )
        }
    }
}

final class RangeReplacableSectionsCoordinatorUpdate<SourceBase>:
    SectionsCoordinatorUpdate<SourceBase>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    override var moveAndReloadable: Bool { true }
    
    override var updateType: ItemsUpdate.Type {
        RangeReplacableItemsCoordinatorUpdate<ListKit.Sources<Element, Item>>.self
    }
    
    override func toSource(values: ContiguousArray<ItemsUpdate>, id: ObjectIdentifier?) -> Source {
        .init(values.compactMap { $0.extraSources[id] ?? $0.sources.target ?? .init() })
    }
}
