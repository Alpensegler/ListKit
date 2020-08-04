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
    
    var isSectioned = false
    
    lazy var itemMaxOrder = Cache(value: Order.second)
    lazy var sectionMaxOrder = Cache(
        value: changeType == .remove(itemsOnly: false) ? Order.third : Order.first
    )
    
    lazy var listUpdates = generateListUpdates()
    lazy var changeType = configChangeType()
    lazy var defaultContext: ContextAndID = {
        let value = Context()
        return (value, ObjectIdentifier(value))
    }()
    
    func inferringMoves(context: ContextAndID? = nil) { }
    
    func configChangeType() -> ChangeType { .none }
    func generateListUpdates() -> BatchUpdates? { nil }
    
    func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        (0, nil)
    }
    
    func generateTargetSectionUpdate(
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

// Order
extension CoordinatorUpdate {
    func isMain(_ order: Order) -> Bool {
        isSectioned && order == .first || !isSectioned && order == .second
    }
    
    func isExtra(_ order: Order) -> Bool {
        isSectioned && order == .second || !isSectioned && order == .third
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
    
    func updateMaxIfNeeded<O>(
        _ subupdate: CoordinatorUpdate,
        _ context: UpdateContext<O>?,
        _ subcontext: UpdateContext<O>?
    ) {
        if isSectioned { updateMaxIfNeeded(subupdate.maxOrder(subcontext, true), context, true) }
        updateMaxIfNeeded(subupdate.maxOrder(subcontext, false), context, false)
    }
}

extension CoordinatorUpdate.Cache {
    subscript(id: ObjectIdentifier?) -> Value {
        get {
            id.flatMap { dict[$0] } ?? value
        }
        set {
            if let id = id {
                dict[id] = newValue
            } else {
                value = newValue
            }
        }
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
