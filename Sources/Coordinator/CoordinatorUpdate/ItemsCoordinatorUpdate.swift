//
//  ItemsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

class ItemsCoordinatorUpdate<SourceBase: DataSource>:
    DiffableCoordinatgorUpdate<SourceBase, SourceBase.Source, SourceBase.Item, CoordinatorChange<SourceBase.Item>>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    typealias Source = SourceBase.Source
    
    weak var coordinator: ItemsCoordinator<SourceBase>?
    
    lazy var unchangedDict = configUnchangedDict { ($1, $0) }
    lazy var extraSources = UpdateContextCache(value: nil as Source?)
    lazy var extraValues = UpdateContextCache(value: ContiguousArray<Item>())
    lazy var extraValuesIndex = UpdateContextCache(value: [IndexPath]())
    
    override var equaltable: Bool { differ.areEquivalent != nil }
    override var identifiable: Bool { differ.identifier != nil }
    override var rangeReplacable: Bool { false }
    
    required init(
        coordinator: ItemsCoordinator<SourceBase>? = nil,
        update: Update<SourceBase>,
        values: Values,
        sources: Sources,
        keepSectionIfEmpty: Mapping<Bool>
    ) {
        self.coordinator = coordinator
        super.init(coordinator, update: update, values: values, sources: sources)
        self.keepSectionIfEmpty = keepSectionIfEmpty
    }
    
    func toSource(_ items: ContiguousArray<Item>) -> Source { fatalError() }
    
    override func toValue(_ element: Element) -> Item { element }
    
    override func isEqual(lhs: Item, rhs: Item) -> Bool { differ.equal(lhs: lhs, rhs: rhs) }
    override func identifier(for value: Item) -> AnyHashable { differ.identifier!(value) }
    override func isDiffEqual(lhs: Item, rhs: Item) -> Bool { differ.diffEqual(lhs, rhs) }
    
    override func finalUpdate(_ hasBatchUpdate: Bool) {
        super.finalUpdate(hasBatchUpdate)
        coordinator?.items = hasBatchUpdate ? updatedValues : values.target
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> (count: Int, update: BatchUpdates.ItemSource?) {
        switch order {
        case .first:
            return (values.source.count, nil)
        case .second:
            var update = BatchUpdates.ItemSource()
            configChange(
                context: context,
                changes: changes.source,
                values: values.source,
                enumrateChange: { change in
                    guard let (offset, _, id) = context else { return }
                    change.offsets[id] = (offset.section, offset.item)
                },
                configValue: { _, _, _ in },
                deleteOrInsert: { change in
                    update.add(\.deletes, change.indexPath(context?.id))
                },
                reload: { change, _ in
                    update.moveOrReload(change.indexPath(context?.id))
                },
                move: { change, associated, isReload in
                    if isReload { needExtraUpdate[context?.id] = true }
                    update.moveOrReload(change.indexPath(context?.id))
                }
            )
            return (values.target.count, update)
        case .third:
            return (values.target.count, nil)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Mapping<IndexPath>>? = nil
    ) -> (count: Int, update: BatchUpdates.ItemTarget?, change: (() -> Void)?) {
        switch order {
        case .first:
            return (values.source.count, nil, nil)
        case .second:
            var update = BatchUpdates.ItemTarget()
            configChange(
                context: context,
                changes: changes.target,
                values: values.target,
                enumrateChange: { change in
                    guard let (offset, _, id) = context else { return }
                    change.offsets[id] = (offset.target.section, offset.target.item)
                },
                configValue: { index, value, isMove in
                    guard let context = context,
                          let sourceIndex = unchangedDict.target[index]
                    else { return }
                    let source = context.offset.source
                    let target = context.offset.target
                    update.move(
                        IndexPath(section: source.section, item: source.item + sourceIndex),
                        to: IndexPath(section: target.section, item: target.item + index)
                    )
                },
                deleteOrInsert: { change in
                    update.add(\.inserts, change.indexPath(context?.id))
                },
                reload: { change, _  in
                    update.add(\.reloads, change.indexPath(context?.id))
                },
                move: { change, associated, isReload in
                    let source = associated.indexPath(context?.id)
                    let target = change.indexPath(context?.id)
                    update.move(source, to: target)
                    if isReload {
                        if extraValues[context?.id].isEmpty {
                            extraValues[context?.id] = values.target
                        }
                        extraValues[context?.id][change.index] = associated.value
                        extraValuesIndex[context?.id].append(change.indexPath(context?.id))
                    }
                }
            )
            
            let change: (() -> Void)?
            if needExtraUpdate[context?.id] {
                if extraValues[context?.id].isEmpty {
                    change = { [unowned self] in self.finalUpdate(false) }
                } else {
                    let values = extraValues[context?.id]
                    let source = toSource(values)
                    extraSources[context?.id] = source
                    change = { [unowned self] in
                        self.coordinator?.source = source
                        self.coordinator?.items = values
                    }
                }
            } else {
                change = finalChange
            }
            return (values.target.count, update, change)
        case .third:
            guard needExtraUpdate[context?.id] else { return (values.target.count, nil, nil) }
            let update = BatchUpdates.ItemTarget(\.reloads, extraValuesIndex[context?.id])
            return (values.target.count, update, finalChange)
        }
    }
}

final class RangeReplacableItemsCoordinatorUpdate<SourceBase>:
    ItemsCoordinatorUpdate<SourceBase>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Item == SourceBase.Source.Element
{
    override var rangeReplacable: Bool { true }
    override func toSource(_ items: ContiguousArray<Item>) -> Source { .init(items) }
}
