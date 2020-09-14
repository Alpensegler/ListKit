//
//  ItemsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

class ItemsCoordinatorUpdate<SourceBase: DataSource>:
    DiffableCoordinatgorUpdate<
        SourceBase,
        SourceBase.Source,
        SourceBase.Item,
        CoordinatorUpdate.Change<SourceBase.Item>,
        CoordinatorUpdate.Change<SourceBase.Item>
    >
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    typealias Source = SourceBase.Source
    typealias Change = CoordinatorUpdate.Change<SourceBase.Item>
    
    weak var coordinator: ItemsCoordinator<SourceBase>?
    
    lazy var extraSources = Cache(value: nil as Source?)
    lazy var extraValues = Cache(value: ContiguousArray<Item>())
    lazy var extraChanges = Cache(value: ([], []) as Mapping<ContiguousArray<Change>>)
    
    override var equaltable: Bool { differ?.areEquivalent != nil }
    override var identifiable: Bool { differ?.identifier != nil }
    
    required init(
        coordinator: ItemsCoordinator<SourceBase>? = nil,
        update: ListUpdate<SourceBase>,
        values: Values,
        sources: Sources,
        options: Options
    ) {
        self.coordinator = coordinator
        super.init(coordinator, update: update, values: values, sources: sources, options: options)
    }
    
    // override from DiffableCoordinatgorUpdate
    
    override func isEqual(lhs: Item, rhs: Item) -> Bool { differ.equal(lhs: lhs, rhs: rhs) }
    override func identifier(for value: Item) -> AnyHashable { differ.identifier!(value) }
    override func isDiffEqual(lhs: Item, rhs: Item) -> Bool { differ.diffEqual(lhs: lhs, rhs: rhs) }
    
    // override from CoordinatorUpdate
    
    override func toValue(_ element: Element) -> Item { element }
    
    override func append(change: Change, isSource: Bool, to changes: inout Differences) {
        changes[keyPath: path(isSource)].append(.change(change))
    }
    
    override func append(change: Change, into values: inout ContiguousArray<Item>) {
        values.append(change.value)
    }
    
    override func updateData(_ isSource: Bool) {
        super.updateData(isSource)
        coordinator?.items = isSource ? values.source : values.target
    }
    
    // override from CoordinatorUpdate
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        if isMoreUpdate { return super.generateSourceItemUpdate(order: order, context: context) }
        if notUpdate(order, context) { return (count.target, nil) }
        var update = BatchUpdates.ItemSource()
        if order == .third {
            extraChanges[context?.id].source.forEach {
                update.add(\.reloads, $0.indexPath(context?.id))
            }
            return (count.target, update)
        } else {
            for value in changes.source {
                switch value {
                case let .change(change):
                    configCoordinatorChange(change, context: context, into: &update)
                case let .unchanged(from, to):
                    guard context?.isMoved == true else { continue }
                    let offset = context?.offset ?? .zero
                    update.move(offset.offseted(from.source), offset.offseted(to.source))
                }
            }
            return (count.source, update)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        if isMoreUpdate { return super.generateTargetItemUpdate(order: order, context: context) }
        if notUpdate(order, context) { return (toIndices(count.target, context), nil, nil) }
        var update = BatchUpdates.ItemTarget()
        if order == .third {
            extraChanges[context?.id].target.forEach {  update.reload($0.indexPath(context?.id)) }
            return (toIndices(count.target, context), update, finalChange)
        } else {
            for value in changes.target {
                switch value {
                case let .change(change):
                    configCoordinatorChange(change, context: context, into: &update) {
                        if extraValues[context?.id].isEmpty {
                            extraValues[context?.id] = values.target
                        }
                        extraValues[context?.id][$0.index] = $1.value
                        extraChanges[context?.id].target.append($0)
                        extraChanges[context?.id].source.append($1)
                    }
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
            if hasNext(order, context) {
                let values = extraValues[context?.id], source = toSource(values)
                extraSources[context?.id] = source
                change = { [unowned self] in
                    self.coordinator?.source = source
                    self.coordinator?.items = values
                }
            } else {
                change = finalChange
            }
            return (toIndices(count.target, context), update, change)
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
    override var moveAndReloadable: Bool { true }
    override func toSource(_ items: ContiguousArray<Item>) -> SourceBase.Source? { .init(items) }
}
