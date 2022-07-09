//
//  WrapperCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/25.
//

// swiftlint:disable shorthand_operator

import Foundation

final class WrapperCoordinatorUpdate<SourceBase, Other>: ListCoordinatorUpdate<SourceBase>
where SourceBase: DataSource, SourceBase.SourceBase == SourceBase, Other: DataSource {
    typealias Wrapped = WrapperCoordinator<SourceBase, Other>.Wrapped

    var wrappeds: Mapping<Wrapped?>
    var subupdate: ListCoordinatorUpdate<Other.SourceBase>?
    var coordinator: WrapperCoordinator<SourceBase, Other>

    init(
        coordinator: WrapperCoordinator<SourceBase, Other>,
        update: ListUpdate<SourceBase>?,
        wrappeds: Mapping<Wrapped?>,
        sources: Sources,
        subupdate: ListCoordinatorUpdate<Other.SourceBase>?,
        options: Options
    ) {
        self.wrappeds = wrappeds
        self.coordinator = coordinator
        self.subupdate = subupdate
        super.init(coordinator, update: update, sources: sources, options: options)
        if isBatchUpdate { self.target = source }
    }

    override func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) {
        subupdate?.inferringMoves(context: context, ids: ids)
    }

    override func configMaxOrderForContext(_ ids: [AnyHashable]) -> Order? {
        guard isSectionItems && targetHasSection != sourceHasSection else {
            return subupdate?.maxOrder(ids)
        }

        switch (targetHasSection && !sourceHasSection, subupdate?.moveType(ids)) {
        case (_, .none): return .first
        case (true, .some): return .second
        case (false, .some): return .third
        }
    }

    override func configSourceCount() -> Int { subupdate?.sourceCount ?? 0 }
    override func configTargetCount() -> Int { subupdate?.targetCount ?? 0 }

    override func customUpdateWay() -> UpdateWay? { subupdate?.changeType }
    override func configUpdateWay() -> UpdateWay? {
        isSectionItems ? super.configUpdateWay() : subupdate?.changeType
    }

    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ListSource> {
        if isSectionItems { return super.generateSourceUpdate(order: order, context: context) }
        guard let subupdate = subupdate else { return (0, nil) }
        return subupdate.generateSourceUpdate(order: order, context: context)
    }

    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        if isSectionItems { return super.generateTargetUpdate(order: order, context: context) }
        guard let subupdate = subupdate else { return ([], nil, nil) }
        var update = subupdate.generateTargetUpdate(order: order, context: context)
        if subupdate.hasNext(order, context) {
            update.change = update.change + firstChange()
        } else {
            update.change = update.change + finalChange()
        }
        return update
    }

    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        guard let subupdate = subupdate else { return (0, nil) }
        return subupdate.generateSourceItemUpdate(order: order, context: context)
    }

    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        guard let subupdate = subupdate else { return ([], nil, nil) }
        var update = subupdate.generateTargetItemUpdate(order: order, context: context)
        if subupdate.hasNext(order, context) {
            update.change = update.change + firstChange()
        } else {
            update.change = update.change + finalChange()
        }
        return update
    }

    override func updateData(_ isSource: Bool, containsSubupdate: Bool) {
        if containsSubupdate { subupdate?.updateData(isSource, containsSubupdate: true) }
        super.updateData(isSource, containsSubupdate: containsSubupdate)
        coordinator.wrapped = wrappeds.target
        coordinator.resetDelegates()
    }
}
