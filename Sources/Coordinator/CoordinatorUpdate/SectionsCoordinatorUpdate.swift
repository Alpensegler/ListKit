//
//  SectionsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/15.
//

import Foundation

class SectionsCoordinatorUpdate<SourceBase>:
    CollectionCoordinatorUpdate<SourceBase, SourceBase.Source, ContiguousArray<SourceBase.Item>>
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
    
    weak var coordinator: SectionsCoordinator<SourceBase>?
    lazy var itemsUpdates = configItemsUpdates()
    var indices: Mapping<Indices>
    
    var updateType: ItemsUpdate.Type { ItemsUpdate.self }
    
    override var sourceCount: Int { indices.source.count }
    override var targetCount: Int { indices.target.count }
    override var sourceIsEmpty: Bool { indices.source.isEmpty }
    override var targetIsEmpty: Bool { indices.target.isEmpty }
    
    required init(
        coordinator: SectionsCoordinator<SourceBase>,
        update: Update<SourceBase>,
        values: Values,
        sources: Sources,
        indices: Mapping<Indices>,
        keepSectionIfEmpty: Mapping<Bool>
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, values: values, sources: sources)
        self.keepSectionIfEmpty = keepSectionIfEmpty
        isSectioned = true
    }
    
    func toSource(values: ContiguousArray<ItemsUpdate>, id: ObjectIdentifier?) -> Source {
        fatalError()
    }
    
    override func finalUpdate(_ hasBatchUpdate: Bool) {
        super.finalUpdate(hasBatchUpdate)
        coordinator?.sections = hasBatchUpdate ? updatedValues : values.target
        coordinator?.indices = indices.target
    }
    
    override func inferringMoves(context: Context) {
        itemsUpdates.forEach { $0.inferringMoves(context: context) }
    }
    
    override func generateListUpdates() -> BatchUpdates? {
        if !sourceIsEmpty || !targetIsEmpty { inferringMoves(context: generateContext()) }
        return super.generateListUpdates()
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> (count: Int, update: BatchUpdates.ListSource?) {
        var (count, update) = (0, BatchUpdates.ListSource())
        for itemUpdate in itemsUpdates {
            let (subsectionCount, subupdate) = itemUpdate.generateSourceSectionUpdate(
                order: order,
                context: toContext(context) { $0 + count }
            )
            count += subsectionCount
            subupdate.map { update.add($0) }
        }
        if order == .first {
            let needUpdate = itemsUpdates.reduce(false) { $0 || $1.needExtraUpdate[context?.id] }
            needExtraUpdate[context?.id] = needUpdate
        }
        return (count, update)
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Mapping<Int>>? = nil
    ) -> (count: Int, update: BatchUpdates.ListTarget?, change: (() -> Void)?) {
        var (count, update) = (0, BatchUpdates.ListTarget())
        var indices = ContiguousArray<Int>(capacity: itemsUpdates.count)
        for (i, itemUpdate) in itemsUpdates.enumerated() {
            let (subsectionCount, subupdate, _) = itemUpdate.generateTargetSectionUpdate(
                order: order,
                context: toContext(context) { ($0.source + count, $0.target + count) }
            )
            count += subsectionCount
            if subsectionCount != 0 { indices.append(i) }
            subupdate.map { update.add($0) }
        }
        let change: (() -> Void)?
        switch order {
        case .first:
            change = { [unowned self] in self.coordinator?.indices = indices }
        case .second:
            if needExtraUpdate[context?.id] {
                let source = toSource(values: itemsUpdates, id: context?.id)
                change = { [unowned self] in
                    self.coordinator?.source = source
                    self.coordinator?.indices = indices
                }
            } else {
                change = finalChange + { [unowned self] in self.coordinator?.indices = indices }
            }
        case .third:
            change = finalChange
        }
        
        return (count, update, change)
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
    override var rangeReplacable: Bool { true }
    
    override var updateType: ItemsUpdate.Type {
        RangeReplacableItemsCoordinatorUpdate<ListKit.Sources<Element, Item>>.self
    }
    
    override func toSource(values: ContiguousArray<ItemsUpdate>, id: ObjectIdentifier?) -> Source {
        .init(values.compactMap { $0.extraSources[id] ?? $0.sources.target ?? .init() })
    }
}
