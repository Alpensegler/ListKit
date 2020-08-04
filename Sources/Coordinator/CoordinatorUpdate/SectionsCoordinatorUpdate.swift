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
        keepSectionIfEmpty: Mapping<Bool>
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, values, sources, keepSectionIfEmpty)
        isSectioned = true
    }
    
    func toSource(values: ContiguousArray<ItemsUpdate>, id: ObjectIdentifier?) -> Source {
        fatalError()
    }
    
    override func getSourceCount() -> Int { indices.source.count }
    override func getTargetCount() -> Int { indices.target.count }
    
    override func updateData(isSource: Bool) {
        super.updateData(isSource: isSource)
        coordinator?.sections = isSource ? values.source : values.target
        coordinator?.indices = isSource ? indices.source : indices.target
    }
    
    override func inferringMoves(context: ContextAndID? = nil) {
        itemsUpdates.forEach { $0.inferringMoves(context: context ?? defaultContext) }
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        if notUpdate(order, context) { return (targetCount, nil) }
        var (count, update) = (0, BatchUpdates.ListSource())
        for itemUpdate in itemsUpdates {
            let (subsectionCount, subupdate) = itemUpdate.generateSourceSectionUpdate(
                order: order,
                context: toContext(context, or: 0) { $0 + count }
            )
            count += subsectionCount
            subupdate.map { update.add($0) }
        }
        return (count, update)
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        if notUpdate(order, context) { return (toIndices(indices.target, context), nil, nil) }
        var (indices, update) = (Indices(capacity: itemsUpdates.count), BatchUpdates.ListTarget())
        for (i, itemUpdate) in itemsUpdates.enumerated() {
            let subcontext = toContext(context, or: (0, (0, 0))) {
                (i, ($0.offset.source + indices.count, $0.offset.target + indices.count))
            }
            let (subsectionCount, subupdate, _) = itemUpdate.generateTargetSectionUpdate(
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
        case .second where hasNext(order, context, true):
            let noItems = !hasNext(order, context, false)
            let source = noItems ? sources.target : toSource(values: itemsUpdates, id: context?.id)
            let sections = noItems ? values.target : itemsUpdates.mapContiguous {
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
            let source = i < sourceCount ? values.source[i] : []
            let target = i < targetCount ? values.target[i] : []
            return updateType.init(
                update: (update?.way).map { .init(.init(way: $0)) } ?? .init(),
                values: (source, target),
                sources: (nil, elements?[safe: i]),
                keepSectionIfEmpty: keepSectionIfEmpty
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
