//
//  ItemsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

class ItemsCoordinatorUpdate<SourceBase: DataSource>:
    DiffableCoordinatgorUpdate<SourceBase, SourceBase.Source, SourceBase.Item, CoordinatorChange<SourceBase.Item>, CoordinatorChange<SourceBase.Item>>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    typealias Source = SourceBase.Source
    typealias Change = CoordinatorChange<SourceBase.Item>
    
    weak var coordinator: ItemsCoordinator<SourceBase>?
    
    lazy var extraSources = UpdateContextCache(value: nil as Source?)
    lazy var extraValues = UpdateContextCache(value: ContiguousArray<Item>())
    lazy var extraChanges = UpdateContextCache(value: ([], []) as Mapping<ContiguousArray<Change>>)
    
    override var equaltable: Bool { differ?.areEquivalent != nil }
    override var identifiable: Bool { differ?.identifier != nil }
    override var rangeReplacable: Bool { false }
    
    required init(
        coordinator: ItemsCoordinator<SourceBase>? = nil,
        update: ListUpdate<SourceBase>,
        values: Values,
        sources: Sources,
        keepSectionIfEmpty: Mapping<Bool>
    ) {
        self.coordinator = coordinator
        super.init(coordinator, update: update, values, sources, keepSectionIfEmpty)
    }
    
    func toSource(_ items: ContiguousArray<Item>) -> Source { fatalError() }
    
    override func isEqual(lhs: Item, rhs: Item) -> Bool { differ.equal(lhs: lhs, rhs: rhs) }
    override func identifier(for value: Item) -> AnyHashable { differ.identifier!(value) }
    override func isDiffEqual(lhs: Item, rhs: Item) -> Bool {
        switch (differ.identifier, differ.areEquivalent) {
        case let (id?, areEquivalent?): return id(lhs) == id(rhs) && areEquivalent(lhs, rhs)
        case let (id?, _): return id(lhs) == id(rhs)
        case let (_, areEquivalent?): return areEquivalent(lhs, rhs)
        default: return false
        }
    }
    
    override func toValue(_ element: Element) -> Item { element }
    override func toChange(_ change: Change, _ isSource: Bool) -> Change { change }
    
    override func updateData(isSource: Bool) {
        super.updateData(isSource: isSource)
        coordinator?.items = isSource ? values.source : values.target
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        if notUpdate(order, context) { return (targetCount, nil) }
        var update = BatchUpdates.ItemSource()
        func configChange(_ change: Change) {
            configCoordinatorChange(
                change,
                context: context,
                enumrateChange: { change in
                    guard let (offset, _, id) = context else { return }
                    change.offsets[id] = (offset.section, offset.item)
                },
                deleteOrInsert: { change in
                    update.add(\.deletes, change.indexPath(context?.id))
                },
                reload: { change, _ in
                    update.add(\.reloads, change.indexPath(context?.id))
                },
                move: { change, associated, isReload in
                    update.move(change.indexPath(context?.id))
                }
            )
        }
        if order == .third {
            extraChanges[context?.id].source.forEach {
                update.add(\.reloads, $0.indexPath(context?.id))
            }
            return (targetCount, update)
        } else {
            for value in changes.source {
                switch value {
                case let .change(change):
                    configChange(change)
                case let .unchanged(from, to):
                    guard context?.isMoved == true else { continue }
                    let offset = context?.offset ?? .zero
                    update.move(offset.offseted(from.source), offset.offseted(to.source))
                }
            }
            return (targetCount, update)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        func indices(_ count: Int) -> Indices {
            .init(repeatElement: (context?.offset.index ?? 0, false), count: count)
        }
        
        if notUpdate(order, context) { return (indices(targetCount), nil, nil) }
        var update = BatchUpdates.ItemTarget()
        
        func configChange(_ change: Change) {
            configCoordinatorChange(
                change,
                context: context,
                enumrateChange: { change in
                    guard let ((_, offset), _, id) = context else { return }
                    change.offsets[id] = (offset.target.section, offset.target.item)
                }, deleteOrInsert: { change in
                    update.add(\.inserts, change.indexPath(context?.id))
                }, reload: { change, _  in
                    update.reload(change.indexPath(context?.id))
                }, move: { change, associated, isReload in
                    guard order == .second else {
                        update.reload(change.indexPath(context?.id))
                        return
                    }
                    let sourcePath = associated.indexPath(context?.id)
                    let targetPath = change.indexPath(context?.id)
                    update.move(sourcePath, to: targetPath)
                    guard isReload else { return }
                    itemMaxOrder[context?.id] = .third
                    if extraValues[context?.id].isEmpty {
                        extraValues[context?.id] = values.target
                    }
                    extraValues[context?.id][change.index] = associated.value
                    let newChange = Change(associated.value, change.index)
                    extraChanges[context?.id].target.append(change)
                    extraChanges[context?.id].source.append(newChange)
                }
            )
        }
        if order == .third {
            extraChanges[context?.id].target.forEach {  update.reload($0.indexPath(context?.id)) }
            return (indices(targetCount), update, finalChange)
        } else {
            for value in changes.target {
                switch value {
                case let .change(change):
                    configChange(change)
                case let .unchanged(from, to):
                    guard context?.isMoved == true else { continue }
                    let source = context?.offset.offset.source ?? .zero
                    let target = context?.offset.offset.target ?? .zero
                    update.move(
                        (source.offseted(from.source), target.offseted(from.target)),
                        (source.offseted(to.source), target.offseted(to.target))
                    )
                }
            }
            
            let change: (() -> Void)?
            if hasNext(order, context, false) {
                let values = extraValues[context?.id], source = toSource(values)
                extraSources[context?.id] = source
                change = { [unowned self] in
                    self.coordinator?.source = source
                    self.coordinator?.items = values
                }
            } else {
                change = finalChange
            }
            return (indices(targetCount), update, change)
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
