//
//  CoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

enum Order: Int, CaseIterable, Comparable {
    case first, second, third
    
    var next: Order? {
        Order(rawValue: rawValue + 1)
    }
    
    static func < (lhs: Order, rhs: Order) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum UpdateChangeType: Equatable {
    case insert(itemsOnly: Bool = true), remove(itemsOnly: Bool = false)
    case reload, batchUpdates, none
}

final class CoordinatorUpdateContext {
    var dicts: Mapping<[AnyHashable: Any?]> = ([:], [:])
}

class CoordinatorUpdate<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Sources = Mapping<SourceBase.Source?>
    typealias Context = (context: CoordinatorUpdateContext, id: ObjectIdentifier)
    typealias Indices = ContiguousArray<(index: Int, isFake: Bool)>
    
    typealias Offset<Offset> = (index: Int, offset: Mapping<Offset>)
    typealias UpdateContext<Offset> = (offset: Offset, isMoved: Bool, id: ObjectIdentifier)
    typealias UpdateSource<Update> = (count: Int, update: Update?)
    typealias UpdateTarget<Update> = (indices: Indices, update: Update?, change: (() -> Void)?)
    
    weak var listCoordinator: ListCoordinator<SourceBase>?
    var hasBatchUpdate = false
    var isSectioned = false
    var defaultUpdate: ListUpdate<SourceBase>.Whole?
    var update: ListUpdate<SourceBase>.Whole?
    var sources: Mapping<SourceBase.Source?>
    
    lazy var itemMaxOrder = UpdateContextCache(value: Order.second)
    lazy var sectionMaxOrder = UpdateContextCache(
        value: changeType == .remove(itemsOnly: false) ? Order.third : Order.first
    )
    
    lazy var defaultContext = generateDefaultContext()
    lazy var listUpdates = generateListUpdates()
    lazy var changeType = configChangeType()
    
    init(
        coordinator: ListCoordinator<SourceBase>?,
        update: ListUpdate<SourceBase>,
        sources: Mapping<SourceBase.Source?>
    ) {
        self.listCoordinator = coordinator
        self.sources = sources
        self.defaultUpdate = coordinator?.update
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
    
    func inferringMoves(context: Context? = nil) { }
    
    func configChangeType() -> UpdateChangeType { fatalError("should be implement by subclass") }
    func generateListUpdates() -> BatchUpdates? { fatalError("should be implement by subclass") }
    
    func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        fatalError("should be implement by subclass")
    }
    
    func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        fatalError("should be implement by subclass")
    }
    
    func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        fatalError("should be implement by subclass")
    }
    
    func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        fatalError("should be implement by subclass")
    }
}

extension CoordinatorUpdate {
    var finalChange: (() -> Void)? { { [unowned self] in self.updateData(isSource: false) } }
    var firstChange: (() -> Void)? { { [unowned self] in self.updateData(isSource: true) } }
    
    func generateDefaultContext() -> Context {
        let value = CoordinatorUpdateContext()
        return (value, ObjectIdentifier(value))
    }
    
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

// Order
extension CoordinatorUpdate {
    func isMain(_ order: Order) -> Bool {
        return isSectioned && order == .first || !isSectioned && order == .second
    }
    
    func isExtra(_ order: Order) -> Bool {
        return isSectioned && order == .second || !isSectioned && order == .third
    }
    
    func notUpdate<O>(_ order: Order, _ context: UpdateContext<O>?) -> Bool {
        isEmptyUpdate(order, context, isSectioned: isSectioned)
    }
    
    func isEmptyUpdate<O>(_ order: Order, _ context: UpdateContext<O>?, isSectioned: Bool) -> Bool {
        guard isSectioned else { return order > maxOrder(context, false) }
        return order > max(maxOrder(context, true), maxOrder(context, false))
    }
    
    func maxOrder<O>(_ context: UpdateContext<O>?, _ isSectioned: Bool) -> Order {
        isSectioned ? sectionMaxOrder[context?.id] : itemMaxOrder[context?.id]
    }
    
    func hasNext<O>(_ order: Order, _ context: UpdateContext<O>?, _ isSectioned: Bool) -> Bool {
        maxOrder(context, isSectioned) > order
    }
    
    func hasNext<O>(_ order: Order, _ context: UpdateContext<O>?) -> Bool {
        maxOrder(context, true) > order || maxOrder(context, false) > order
    }
    
    func updateMaxIfNeeded<O>(_ order: Order, _ context: UpdateContext<O>?, _ isSectioned: Bool) {
        guard maxOrder(context, isSectioned) < order else { return }
        isSectioned ? (sectionMaxOrder[context?.id] = order) : (itemMaxOrder[context?.id] = order)
    }
    
    func updateMaxIfNeeded<O, SourceBase: DataSource>(
        _ subupdate: CoordinatorUpdate<SourceBase>,
        _ context: UpdateContext<O>?,
        _ subcontext: UpdateContext<O>?
    ) {
        if isSectioned { updateMaxIfNeeded(subupdate.maxOrder(subcontext, true), context, true) }
        updateMaxIfNeeded(subupdate.maxOrder(subcontext, false), context, false)
    }
}
