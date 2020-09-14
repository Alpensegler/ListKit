//
//  ItemCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/3.
//

import Foundation

final class ItemCoordinatorUpdate<SourceBase: DataSource>: ListCoordinatorUpdate<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase {
    lazy var change = configChange()
    lazy var extraChange = Cache(value: (nil, nil) as Mapping<Change<Item>?>)
    
    override var moveAndReloadable: Bool { true }
    
    override func configCount() -> Mapping<Int> { (1, 1) }
    
    func configChange() -> Mapping<Change<Item>?> {
        guard let s = sources.source, let t = sources.target else { return (nil, nil) }
        switch changeType {
        case .insert: return (nil, Change(t, 0))
        case .remove: return (Change(s, 0), nil)
        default: break
        }
        guard diffable else { return (nil, nil) }
        let isEqual = differ.diffEqual(lhs: s, rhs: t)
        return isEqual ? (nil, nil) : (Change(s, 0), Change(t, 0))
    }
    
    override func inferringMoves(context: ContextAndID? = nil) {
        guard diffable,
              let id = differ.identifier,
              let context = context,
              let source = sources.source,
              let target = sources.target,
              let sourceChange = change.source,
              let targetChange = change.target
        else { return }
        let key: Mapping = (id(source), id(target))
        add(sourceChange, id: key.source, to: &context.context.dicts.source)
        add(targetChange, id: key.target, to: &context.context.dicts.target)
        config(for: sourceChange, key.source, context, &context.context.dicts, differ.areEquivalent)
        config(for: targetChange, key.target, context, &context.context.dicts, differ.areEquivalent)
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        if notUpdate(order, context) { return (1, nil) }
        var update = BatchUpdates.ItemSource()
        if order == .third {
            extraChange[context?.id].source.map { update.add(\.reloads, $0.indexPath(context?.id)) }
            return (1, update)
        } else {
            if let change = change.source {
                configCoordinatorChange(change, context: context, into: &update)
            } else if context?.isMoved == true {
                update.move(context?.offset ?? .zero)
            }
            return (1, update)
        }
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        var indices: Indices { [(context?.offset.index ?? 0, false)] }
        if notUpdate(order, context) { return (indices, nil, nil) }
        var update = BatchUpdates.ItemTarget()
        if order == .third {
            extraChange[context?.id].target.map { update.reload($0.indexPath(context?.id)) }
            return (indices, update, finalChange)
        } else {
            if let change = change.target {
                configCoordinatorChange(change, context: context, into: &update) {
                    extraChange[context?.id].target = $0
                    extraChange[context?.id].source = $1
                }
            } else if context?.isMoved == true {
                let source = context?.offset.offset.source ?? .zero
                let target = context?.offset.offset.target ?? .zero
                update.move(source, to: target)
            }
            
            let change: (() -> Void)?
            if hasNext(order, context) {
                let source = extraChange[context?.id].source?.value
                change = { [unowned self] in self.listCoordinator?.source = source }
            } else {
                change = finalChange
            }
            return (indices, update, change)
        }
    }
}
