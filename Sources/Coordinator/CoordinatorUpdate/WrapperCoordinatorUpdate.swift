//
//  WrapperCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/25.
//

import Foundation

final class WrapperCoordinatorUpdate<SourceBase, Other>: ListCoordinatorUpdate<SourceBase>
where SourceBase: DataSource, SourceBase.SourceBase == SourceBase, Other: DataSource {
    typealias Wrapped = WrapperCoordinator<SourceBase, Other>.Wrapped
    
    var wrappeds: Mapping<Wrapped?>
    var subupdate: CoordinatorUpdate?
    var coordinator: WrapperCoordinator<SourceBase, Other>
    
    var shouldHandle: Bool { sourceType == .sectionItems }
    
    init(
        coordinator: WrapperCoordinator<SourceBase, Other>,
        update: ListUpdate<SourceBase>,
        wrappeds: Mapping<Wrapped?>,
        sources: Sources,
        subupdate: CoordinatorUpdate?,
        options: Options
    ) {
        self.wrappeds = wrappeds
        self.coordinator = coordinator
        self.subupdate = subupdate
        super.init(coordinator, update: update, sources: sources, options: options)
    }
    
    override func inferringMoves(context: CoordinatorUpdate.ContextAndID? = nil) {
        subupdate?.inferringMoves(context: context)
    }
    
    override func prepareData() {
        subupdate?.prepareData()
    }
    
    override func configMaxOrder() -> Cache<Order> {
        if shouldHandle { return super.configMaxOrder() }
        return subupdate?.maxOrder ?? super.configMaxOrder()
    }
    
    override func configCount() -> Mapping<Int> { subupdate?.count ?? (0, 0) }
    
    override func configChangeType() -> ChangeType {
        guard shouldHandle else { return subupdate?.changeType ?? .none }
        switch (update?.way, count.source == 0, count.target == 0) {
        case (.insert, _, true), (.remove, true, _), (_, true, true): return .none
        case (.remove, _, _), (_, false, true): return .remove
        case (.insert, _, _), (_, true, false): return .insert
        default: return subupdate?.changeType ?? .none
        }
    }
    
    override func updateData(_ isSource: Bool) {
        subupdate?.updateData(isSource)
        super.updateData(isSource)
        coordinator.wrapped = wrappeds.target
        if !isSource { coordinator.resetDelegates() }
    }
    
    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        if shouldHandle { return super.generateSourceUpdate(order: order, context: context) }
        guard let subupdate = subupdate else { return (0, nil) }
        return subupdate.generateSourceUpdate(order: order, context: context)
    }
    
    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        if shouldHandle { return super.generateTargetUpdate(order: order, context: context) }
        guard let subupdate = subupdate else { return ([], nil, nil) }
        var update = subupdate.generateTargetUpdate(order: order, context: context)
        updateMaxIfNeeded(subupdate, context, context)
        if hasNext(order, context) {
            update.change = update.change + { [weak self] in self?.coordinator.resetDelegates() }
        } else {
            update.change = update.change + finalChange
        }
        return update
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        guard let subupdate = subupdate else { return (0, nil) }
        return subupdate.generateSourceItemUpdate(order: order, context: context)
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        guard let subupdate = subupdate else { return ([], nil, nil) }
        var update = subupdate.generateTargetItemUpdate(order: order, context: context)
        updateMaxIfNeeded(subupdate, context, context)
        if hasNext(order, context) {
            update.change = update.change + { [weak self] in self?.coordinator.resetDelegates() }
        } else {
            update.change = update.change + finalChange
        }
        return update
    }
}
