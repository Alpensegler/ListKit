//
//  ListCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/3.
//

import Foundation

class ListCoordinatorUpdate<SourceBase: DataSource>: CoordinatorUpdate
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Sources = Mapping<SourceBase.Source?>
    
    weak var listCoordinator: ListCoordinator<SourceBase>?
    var hasBatchUpdate = false
    var defaultUpdate: ListUpdate<SourceBase>.Whole?
    var update: ListUpdate<SourceBase>.Whole?
    var sources: Mapping<SourceBase.Source?>
    
    init(
        coordinator: ListCoordinator<SourceBase>?,
        update: ListUpdate<SourceBase>,
        sources: Mapping<SourceBase.Source?>
    ) {
        self.listCoordinator = coordinator
        self.sources = sources
        self.defaultUpdate = coordinator?.update
        super.init()
        switch update {
        case let .whole(whole, _):
            self.update = whole
        case let .batch(batch):
            batch.operations.forEach { $0(self) }
            hasBatchUpdate = true
        }
    }
    
    func updateData(isSource: Bool) {
        listCoordinator?.source = isSource ? sources.source : sources.target
    }
}

extension ListCoordinatorUpdate {
    var finalChange: (() -> Void)? { { [unowned self] in self.updateData(isSource: false) } }
    var firstChange: (() -> Void)? { { [unowned self] in self.updateData(isSource: true) } }
    
    func listUpdatesForSections() -> BatchUpdates {
        .batch(Order.allCases.compactMapContiguous { order in
            let source = generateSourceSectionUpdate(order: order)
            let target = generateTargetSectionUpdate(order: order)
            guard !source.update.isEmpty || !target.update.isEmpty else { return nil }
            return .init(update: (source.update, target.update), change: target.change)
        })
    }
    
    func listUpdatesForItems() -> BatchUpdates {
        .batch([Order.second, Order.third].compactMapContiguous { order in
            let source = generateSourceItemUpdate(order: order)
            let target = generateTargetItemUpdate(order: order)
            guard !source.update.isEmpty || !target.update.isEmpty else { return nil }
            return .init(update: (source.update, target.update), change: target.change)
        })
    }
    
    func toContext<Offset, OtherOffset>(
        _ context: UpdateContext<Offset>?,
        _ isMoved: Bool = false,
        or offset: Offset? = nil,
        add: (Offset) -> OtherOffset
    ) -> UpdateContext<OtherOffset>? {
        let isMoved = isMoved || context?.isMoved == true
        if let context = context { return (add(context.offset), isMoved, context.id) }
        return offset.map { (add($0), isMoved, defaultContext.id) }
    }
    
    func toIndices<O>(_ indices: Indices, _ context: UpdateContext<Offset<O>>?) -> Indices {
        guard let index = context?.offset.index else { return indices }
        return indices.mapContiguous { (index, $0.isFake) }
    }
}
