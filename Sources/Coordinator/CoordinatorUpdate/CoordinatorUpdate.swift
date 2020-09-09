//
//  CoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

class CoordinatorUpdate {
    enum Order: Int {
        case first, second, third
    }

    enum ChangeType: Equatable {
        case insert(itemsOnly: Bool = true), remove(itemsOnly: Bool = false)
        case reload, batchUpdates, none
        
        var shouldGetSubupdate: Bool { self != .reload && self != .none }
    }
    
    struct Cache<Value> {
        var dict = [ObjectIdentifier: Value]()
        var value: Value
    }
    
    class Change<Value> {
        struct Unowned {
            unowned let change: Change<Value>
        }
        
        enum State: Equatable {
            case change(moveAndRelod: Bool?)
            case reload
        }
        
        let value: Value
        let index: Int
        var state: State
        
        var offsets = Cache(value: (section: 0, item: 0))
        var associated = Cache(value: nil as Unowned?)
        
        required init(_ value: Value, _ index: Int, moveAndReloadable: Bool = true) {
            self.value = value
            self.index = index
            self.state = .change(moveAndRelod: moveAndReloadable ? nil : false)
        }
    }
    
    final class Context {
        var dicts: Mapping<[AnyHashable: Any?]> = ([:], [:])
    }
    
    typealias ContextAndID = (context: Context, id: ObjectIdentifier)
    
    typealias Indices = ContiguousArray<(index: Int, isFake: Bool)>
    typealias Offset<Offset> = (index: Int, offset: Mapping<Offset>)
    typealias UpdateContext<Offset> = (offset: Offset, isMoved: Bool, id: ObjectIdentifier)
    typealias UpdateSource<Update> = (count: Int, update: Update?)
    typealias UpdateTarget<Update> = (indices: Indices, update: Update?, change: (() -> Void)?)
    
    var isRemove = false
    var isSectioned = false
    var isItems = false
    var preferNoAnimation: Bool { false }
    
    lazy var maxOrder = configMaxOrder()
    lazy var count = configCount()
    
    lazy var listUpdates = generateListUpdates()
    lazy var changeType = configChangeType()
    lazy var defaultContext: ContextAndID = {
        let value = Context()
        return (value, ObjectIdentifier(value))
    }()
    
    func inferringMoves(context: ContextAndID? = nil) { }
    
    func configMaxOrder() -> Cache<Order> {
        switch (isSectioned, changeType) {
        case (false, _): return .init(value: Order.second)
        case (true, .remove(itemsOnly: false)): return .init(value: Order.third)
        case (true, .insert(itemsOnly: false)): return .init(value: Order.second)
        case (true, _): return .init(value: isItems ? Order.second : Order.first)
        }
    }
    
    func prepareData() { }
    func configCount() -> Mapping<Int> { notImplemented() }
    func configChangeType() -> ChangeType { .none }
    func generateListUpdates() -> BatchUpdates? {
        prepareData()
        inferringMoves()
        if isItems { return generateListUpdatesForItems() }
        return isSectioned ? generateListUpdatesForSections() : generateListUpdatesForItems()
    }
    
    func add(subupdate: CoordinatorUpdate, at index: Int) { }
    
    func updateData(_ isSource: Bool) { }
    func hasSectionIfEmpty(isSource: Bool) -> Bool { true }
    
    func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        (0, nil)
    }
    
    func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        ([], nil, nil)
    }
    
    func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        (0, nil)
    }
    
    func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        ([], nil, nil)
    }
}

extension CoordinatorUpdate {
    var sourceIsEmpty: Bool { count.source == 0 }
    var targetIsEmpty: Bool { count.target == 0 }
    
    var sourceHasSection: Bool { !sourceIsEmpty || hasSectionIfEmpty(isSource: true) }
    var targetHasSection: Bool { !targetIsEmpty || hasSectionIfEmpty(isSource: false) }
    
    var sourceSectionCount: Int { isSectioned && !isItems ? count.source : sourceHasSection ? 1 : 0 }
    var targetSectionCount: Int { isSectioned && !isItems ? count.target : targetHasSection ? 1 : 0 }
    
    var firstChange: (() -> Void)? { { [unowned self] in self.updateData(true) } }
    var finalChange: (() -> Void)? { { [unowned self] in self.updateData(false) } }
    
    func generateListUpdatesForItems() -> BatchUpdates? {
        switch changeType {
        case .insert(false):
            return .init(target: BatchUpdates.SectionTarget(\.inserts, 0), finalChange)
        case .insert(true):
            let indices = [IndexPath](IndexPath(item: 0), IndexPath(item: count.target))
            return .init(target: BatchUpdates.ItemTarget(\.inserts, indices), finalChange)
        case .remove(false):
            return .init(source: BatchUpdates.SectionSource(\.deletes, 0), finalChange)
        case .remove(true):
            let indices = [IndexPath](IndexPath(item: 0), IndexPath(item: count.source))
            return .init(source: BatchUpdates.ItemSource(\.deletes, indices), finalChange)
        case .batchUpdates:
            return listUpdatesForItems()
        case .reload:
            return .reload(change: finalChange)
        case .none:
            return .none
        }
    }
    
    func generateListUpdatesForSections() -> BatchUpdates? {
        switch changeType {
        case .insert:
            let update = BatchUpdates.SectionTarget(\.inserts, 0, count.target)
            return .init(target: update, finalChange)
        case .remove:
            let update = BatchUpdates.SectionSource(\.deletes, 0, count.source)
            return .init(source: update, finalChange)
        case .batchUpdates:
            return listUpdatesForSections()
        case .reload:
            return .reload(change: finalChange)
        case .none:
            return .none
        }
    }
    
    func listUpdatesForSections() -> BatchUpdates {
        .batch(Order.allCases.compactMapContiguous { order in
            Log.log("---\(order)---")
            Log.log("-source-")
            let source = generateSourceUpdate(order: order)
            Log.log("-target-")
            let target = generateTargetUpdate(order: order)
            guard !source.update.isEmpty || !target.update.isEmpty else { return nil }
            return .init(update: (source.update, target.update), change: target.change)
        })
    }
    
    func listUpdatesForItems() -> BatchUpdates {
        .batch([Order.second, Order.third].compactMapContiguous { order in
            Log.log("---\(order)---")
            Log.log("-source-")
            let source = generateSourceItemUpdate(order: order)
            Log.log("-target-")
            let target = generateTargetItemUpdate(order: order)
            guard !source.update.isEmpty || !target.update.isEmpty else { return nil }
            return .init(update: (source.update, target.update), change: target.change)
        })
    }
}

// Order
extension CoordinatorUpdate {
    func isMain(_ order: Order) -> Bool {
        isSectioned && order == .first || !isSectioned && order == .second
    }
    
    func isExtra(_ order: Order) -> Bool {
        isSectioned && order == .second || !isSectioned && order == .third
    }
    
    func notUpdate<O>(_ order: Order, _ context: UpdateContext<O>?) -> Bool {
        order > maxOrder(context)
    }
    
    func maxOrder<O>(_ context: UpdateContext<O>?) -> Order {
        maxOrder[context?.id]
    }
    
    func hasNext<O>(_ order: Order, _ context: UpdateContext<O>?) -> Bool {
        maxOrder(context) > order
    }
    
    func updateMaxIfNeeded<O>(_ order: Order, _ context: UpdateContext<O>?) {
        guard maxOrder(context) < order else { return }
        maxOrder[context?.id] = order
    }
    
    func updateMaxIfNeeded<O>(
        _ subupdate: CoordinatorUpdate,
        _ context: UpdateContext<O>?,
        _ subcontext: UpdateContext<O>?
    ) {
        updateMaxIfNeeded(subupdate.maxOrder(subcontext), context)
    }
}

extension CoordinatorUpdate.Cache {
    subscript(id: ObjectIdentifier?) -> Value {
        get { id.flatMap { dict[$0] } ?? value }
        set { id.map { dict[$0] = newValue } ?? (value = newValue) }
    }
}

extension CoordinatorUpdate.Order: CaseIterable, Comparable {
    var next: CoordinatorUpdate.Order? {
        CoordinatorUpdate.Order(rawValue: rawValue + 1)
    }
    
    static func < (lhs: CoordinatorUpdate.Order, rhs: CoordinatorUpdate.Order) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension CoordinatorUpdate.Change: CustomStringConvertible, CustomDebugStringConvertible {
    subscript(id: ObjectIdentifier?) -> CoordinatorUpdate.Change<Value>? {
        get { associated.value?.change ?? associated[id]?.change }
        set { associated[id] = newValue.map(Unowned.init(change:)) }
    }
    
    func indexPath(_ id: ObjectIdentifier?) -> IndexPath {
        let (section, item) = offsets[id]
        return IndexPath(section: section, item: item + index)
    }
    
    func index(_ id: ObjectIdentifier?) -> Int {
        offsets[id].section + index
    }
    
    var description: String {
        "\(value), \(index), \(state)"
    }
    
    var debugDescription: String {
        (associated.value?.change).map { "\(description), \($0.index)" } ?? description
    }
}
