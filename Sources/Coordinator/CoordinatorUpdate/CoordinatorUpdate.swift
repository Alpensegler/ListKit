//
//  CoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

enum Order: CaseIterable {
    case first, second, third
}

enum UpdateChangeType: Equatable {
    enum Content {
        case itemsAndSection
        case section
        case items
        
        var hasSection: Bool { self == .itemsAndSection || self == .section }
        var hasItem: Bool { self == .itemsAndSection || self == .items }
    }
    
    case insert(Content = .section), remove(Content = .section)
    case reload, batchUpdates, none
}

final class CoordinatorUpdateContext {
    var dicts: Mapping<[AnyHashable: Any?]> = ([:], [:])
}

typealias UpdateContext<Offset> = (offset: Offset, isMoved: Bool, id: ObjectIdentifier)

func toContext<Offset, OtherOffset>(
    _ context: UpdateContext<Offset>?,
    _ isMoved: Bool = false,
    addOffset: (Offset) -> OtherOffset
) -> UpdateContext<OtherOffset>? {
    guard let context = context else { return nil }
    return (addOffset(context.offset), isMoved || context.isMoved, context.id)
}

class CoordinatorUpdate<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Sources = Mapping<SourceBase.Source?>
    typealias Context = (context: CoordinatorUpdateContext, id: ObjectIdentifier)
    
    weak var listCoordinator: ListCoordinator<SourceBase>?
    var hasBatchUpdate = false
    var update: ListUpdate<SourceBase>?
    var sources: Mapping<SourceBase.Source?>
    var context: Context?
    var finalChange: (() -> Void)? { { [unowned self] in self.finalUpdate(self.hasBatchUpdate) } }
    
    lazy var listUpdates = generateListUpdates()
    lazy var changeType = configChangeType()
    lazy var updatedSource: SourceBase.Source? = {
        let target = sources.target
        hasBatchUpdate = true
        return target
    }()
    
    init(
        coordinator: ListCoordinator<SourceBase>?,
        update: Update<SourceBase>,
        sources: Mapping<SourceBase.Source?>
    ) {
        self.listCoordinator = coordinator
        self.update = update.listUpdate
        self.sources = sources
        update.operations.forEach { $0(self) }
    }
    
    func finalUpdate(_ hasBatchUpdate: Bool) {
        listCoordinator?.source = hasBatchUpdate ? updatedSource : sources.target
    }
    
    func inferringMoves(context: Context) { }
    
    func configChangeType() -> UpdateChangeType { fatalError("should be implement by subclass") }
    func generateListUpdates() -> BatchUpdates? { fatalError("should be implement by subclass") }
    
    func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> (count: Int, update: BatchUpdates.ListSource?) {
        fatalError("should be implement by subclass")
    }
    
    func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Mapping<Int>>? = nil
    ) -> (count: Int, update: BatchUpdates.ListTarget?, change: (() -> Void)?) {
        fatalError("should be implement by subclass")
    }
    
    func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> (count: Int, update: BatchUpdates.ItemSource?) {
        fatalError("should be implement by subclass")
    }
    
    func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Mapping<IndexPath>>? = nil
    ) -> (count: Int, update: BatchUpdates.ItemTarget?, change: (() -> Void)?) {
        fatalError("should be implement by subclass")
    }
}

extension CoordinatorUpdate {
    func generateContext() -> Context {
        let value = CoordinatorUpdateContext()
        let context = (value, ObjectIdentifier(value))
        self.context = context
        return context
    }
    
    func context<T>(_ offset: T, isMoved: Bool = false) -> UpdateContext<T>? {
        context.map { (offset, isMoved, $0.id) }
    }
    
    func listUpdatesForSections() -> BatchUpdates {
        .batch(Order.allCases.compactMapContiguous { order in
            let source = generateSourceSectionUpdate(order: order, context: context(0))
            let target = generateTargetSectionUpdate(order: order, context: context((0, 0)))
            guard !source.update.isEmpty || !target.update.isEmpty else { return nil }
            return .init(update: (source.update, target.update), change: target.change)
        })
    }
    
    func listUpdatesForItems() -> BatchUpdates {
        .batch(Order.allCases.compactMapContiguous { order in
            let source = generateSourceItemUpdate(order: order, context: context(.zero))
            let target = generateTargetItemUpdate(order: order, context: context((.zero, .zero)))
            guard !source.update.isEmpty || !target.update.isEmpty else { return nil }
            return .init(update: (source.update, target.update), change: target.change)
        })
    }
}
