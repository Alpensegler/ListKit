//
//  ItemCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/3.
//

import Foundation

final class ItemCoordinatorUpdate<SourceBase: DataSource>: ListCoordinatorUpdate<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase {
    lazy var changes = configChanges()
    lazy var extraChange = Cache(value: (nil, nil) as Mapping<Change<Item>?>)
    
    override var moveAndReloadable: Bool { !noneDiffUpdate }
    
    override func configSourceCount() -> Int { 1 }
    override func configTargetCount() -> Int { 1 }
    
    override func customUpdateWay() -> UpdateWay? {
        diffable && (changes.source != nil || changes.target != nil) ? .batch : nil
    }
    
    func toChange(_ value: Item, _ index: Int) -> Change<Item> {
        let change = Change(value: value, index: index, moveAndReloadable: true)
        change.coordinatorUpdate = self
        return change
    }
    
    func configChanges() -> Mapping<Change<Item>?> {
        guard let s = source, let t = target else { return (nil, nil) }
        switch updateWay {
        case .other(.insert): return (nil, toChange(t, 0))
        case .other(.remove): return (toChange(s, 0), nil)
        default: break
        }
        guard diffable else { return (nil, nil) }
        let isEqual = differ.diffEqual(lhs: s, rhs: t)
        return isEqual ? (nil, nil) : (toChange(s, 0), toChange(t, 0))
    }
    
    override func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) {
        guard diffable,
              let id = differ.identifier,
              let context = context,
              let source = source,
              let target = target,
              changes.source != nil || changes.target != nil
        else { return }
        let key: Mapping = (id(source), id(target))
        changes.source.map { add($0, id: key.source, ids: ids, to: &context.dicts.source) }
        changes.target.map { add($0, id: key.target, ids: ids, to: &context.dicts.target) }
        changes.source.map { config(for: $0, key.source, &context.dicts, differ.areEquivalent) }
        changes.target.map { config(for: $0, key.target, &context.dicts, differ.areEquivalent) }
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        var update = BatchUpdates.ItemSource()
        if order == .third {
            extraChange[context].source.map { update.add(\.reloads, $0.indexPath(context.ids)) }
            return (1, update)
        } else {
            if let change = changes.source {
                configCoordinatorChange(change, context: context, into: &update)
            } else if context.isMoved {
                update.move(context.offset ?? .zero)
            }
            return (1, update)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        var indices: Indices { targetCount == 0 ? [] : [(context.offset?.index ?? 0, false)] }
        var update = BatchUpdates.ItemTarget()
        if order == .third {
            extraChange[context].target.map { update.reload($0.indexPath(context.ids)) }
            return (indices, update, finalChange())
        } else {
            if let change = changes.target {
                configCoordinatorChange(change, context: context, into: &update) {
                    extraChange[context].target = $0
                    extraChange[context].source = $1
                }
            } else if context.isMoved {
                let source = context.offset?.offset.source ?? .zero
                let target = context.offset?.offset.target ?? .zero
                update.move(source, to: target)
            }
            
            let change: (() -> Void)?
            if hasNext(order, context) {
                let source = extraChange[context].source?.value
                change = { [unowned self] in self.listCoordinator?.source = source }
            } else {
                change = finalChange()
            }
            return (indices, update, change)
        }
    }
}
