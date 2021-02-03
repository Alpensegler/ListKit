//
//  ItemsCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

class ItemsCoordinatorUpdate<SourceBase: DataSource>:
    CollectionCoordinatorUpdate<
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
    
    lazy var extraValues = Cache(value: ContiguousArray<Item>())
    lazy var extraChanges = Cache(value: ([], []) as Changes)
    
    override var equatable: Bool { differ?.areEquivalent != nil }
    override var identifiable: Bool { differ?.identifier != nil }
    
    required init(
        coordinator: ItemsCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>?,
        values: Mapping<Values>,
        sources: Sources,
        options: Options
    ) {
        self.coordinator = coordinator
        super.init(coordinator, update: update, values: values, sources: sources, options: options)
    }
    
    override func isEqual(lhs: Item, rhs: Item) -> Bool { differ.equal(lhs: lhs, rhs: rhs) }
    override func identifier(for value: Item) -> AnyHashable { differ.identifier!(value) }
    override func isDiffEqual(lhs: Item, rhs: Item) -> Bool { differ.diffEqual(lhs: lhs, rhs: rhs) }
    
    override func toValue(_ element: Element) -> Item { element }
    
    override func toChange(_ value: Item, _ index: Int) -> Change {
        let change = Change(value: value, index: index, moveAndReloadable: moveAndReloadable)
        change.coordinatorUpdate = self
        return change
    }
    
    override func add(change: Change, isSource: Bool, to changes: inout Differences) {
        changes[keyPath: path(isSource)].append(.change(change))
    }
    
    override func configSourceCount() -> Int { sourceValues.count }
    override func configTargetCount() -> Int { targetValues.count }
    
    override func updateData(_ isSource: Bool, containsSubupdate: Bool) {
        super.updateData(isSource, containsSubupdate: containsSubupdate)
        coordinator?.items = isSource ? sourceValues : targetValues
    }
    
    override func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) {
        guard identifiable else { return }
        _ = uniqueDict
        guard let context = context else { return }
        let (source, target) = uniqueMapping
        source.forEach { add($0, id: identifier(for: $0.value), ids: ids, to: &context.dicts.source) }
        target.forEach { add($0, id: identifier(for: $0.value), ids: ids, to: &context.dicts.target) }
        apply(uniqueMapping, dict: &context.dicts) { $0 as? Change }
    }
    
    override func customUpdateWay() -> UpdateWay? {
        if isBatchUpdate { return .batch }
        guard diffable else { return .other(.reload) }
        return diffs.isEmpty ? nil : .batch
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        var update = BatchUpdates.ItemSource()
        if order == .third {
            extraChanges[context].source.forEach { update.add(\.reloads, $0.indexPath(context.ids)) }
            return (targetCount, update)
        } else {
            for value in differences.source {
                switch value {
                case let .change(change):
                    configCoordinatorChange(change, context: context, into: &update)
                case let .unchanged(from, to):
                    guard context.isMoved else { continue }
                    let offset = context.offset ?? .zero
                    update.move(offset.offseted(from.source), offset.offseted(to.source))
                }
            }
            return (sourceCount, update)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        var update = BatchUpdates.ItemTarget()
        if order == .third {
            extraChanges[context].target.forEach {  update.reload($0.indexPath(context.ids)) }
            return (toIndices(targetCount, context), update, finalChange())
        } else {
            for value in differences.target {
                switch value {
                case let .change(change):
                    configCoordinatorChange(change, context: context, into: &update) {
                        if extraValues[context].isEmpty {
                            extraValues[context] = targetValues
                        }
                        extraValues[context][$0.index] = $1.value
                        extraChanges[context].target.append($0)
                        extraChanges[context].source.append($1)
                    }
                case let .unchanged(from, to):
                    guard context.isMoved == true else { continue }
                    let source = context.offset?.offset.source ?? .zero
                    let target = context.offset?.offset.target ?? .zero
                    update.move(
                        (source.offseted(from.source), target.offseted(from.target)),
                        (source.offseted(to.source), target.offseted(to.target))
                    )
                }
            }
            
            let change: (() -> Void)?
            if hasNext(order, context) {
                let values = extraValues[context], source = toSource(values)
                change = { [unowned self] in
                    self.coordinator?.source = source
                    self.coordinator?.items = values
                }
            } else {
                change = finalChange()
            }
            return (toIndices(targetCount, context), update, change)
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
    override var moveAndReloadable: Bool { !noneDiffUpdate }
    override func toSource(_ items: ContiguousArray<Item>) -> SourceBase.Source? { .init(items) }
    
    override func insert(_ element: SourceBase.Source.Element, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        insertElement(element, at: index)
    }
        
    override func insert<C: Collection>(contentsOf elements: C, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection, C.Element == SourceBase.Source.Element {
        insertElements(contentsOf: elements, at: index)
    }
        
    override func append(_ element: SourceBase.Source.Element)
    where SourceBase.Source: RangeReplaceableCollection {
        appendElement(element)
    }
        
    override func append<S: Sequence>(contentsOf elements: S)
    where SourceBase.Source: RangeReplaceableCollection, S.Element == SourceBase.Source.Element {
        appendElements(contentsOf: elements)
    }
        
    override func remove(at index: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        removeElement(at: index)
    }
    
    override func remove(at indexSet: IndexSet)
    where SourceBase.Source: RangeReplaceableCollection {
        removeElements(at: indexSet)
    }
        
    override func update(_ element: SourceBase.Source.Element, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        updateElement(element, at: index)
    }
        
    override func move(at index: Int, to newIndex: Int)
    where SourceBase.Source: RangeReplaceableCollection {
        moveElement(at: index, to: newIndex)
    }
}
