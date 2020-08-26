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
    
    override var sourceCount: Int { subupdate?.sourceCount ?? 0 }
    override var targetCount: Int { subupdate?.targetCount ?? 0 }
    
    override var sourceSectionCount: Int { subupdate?.sourceSectionCount ?? 0 }
    override var targetSectionCount: Int { subupdate?.targetSectionCount ?? 0 }
    
    override var itemMaxOrder: Cache<Order> {
        get { subupdate?.itemMaxOrder ?? Cache(value: Order.first) }
        set { subupdate?.itemMaxOrder = newValue }
    }
    
    override var sectionMaxOrder: Cache<Order> {
        get { subupdate?.sectionMaxOrder ?? Cache(value: Order.first) }
        set { subupdate?.sectionMaxOrder = newValue }
    }
    
    init(
        coordinator: WrapperCoordinator<SourceBase, Other>,
        update: ListUpdate<SourceBase>,
        wrappeds: Mapping<Wrapped?>,
        sources: Sources,
        subupdate: CoordinatorUpdate?,
        isSectioned: Bool
    ) {
        self.wrappeds = wrappeds
        self.coordinator = coordinator
        self.subupdate = subupdate
        super.init(coordinator: coordinator, update: update, sources: sources)
        self.isSectioned = isSectioned
    }
    
    override func inferringMoves(context: CoordinatorUpdate.ContextAndID? = nil) {
        subupdate?.inferringMoves(context: context)
    }
    
    override func prepareData() {
        subupdate?.prepareData()
    }
    
    override func configChangeType() -> CoordinatorUpdate.ChangeType {
        subupdate?.changeType ?? .none
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
        guard let subupdate = subupdate else { return (0, nil) }
        return subupdate.generateSourceUpdate(order: order, context: context)
    }
    
    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        guard let subupdate = subupdate else { return ([], nil, nil) }
        var update = subupdate.generateTargetUpdate(order: order, context: context)
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
        if hasNext(order, context) {
            update.change = update.change + { [weak self] in self?.coordinator.resetDelegates() }
        } else {
            update.change = update.change + finalChange
        }
        return update
    }
}
