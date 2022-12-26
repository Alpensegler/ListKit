//
//  CoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

class CoordinatorUpdate {
//    enum Order: Int {
//        case first, second, third
//    }
//
    enum UpdateWay: Hashable {
        case other(ListKit.UpdateWay)
//        case batch
    }
//
//    enum MoveType {
//        case move, moveAndReload
//    }
//
//    enum Difference<DifferenceChange> {
//        case change(DifferenceChange)
//        case unchanged(from: Mapping<Int>, to: Mapping<Int>)
//    }
//
//    enum DifferenceChange<Element: DataSource, Value> {
//        case update(Mapping<Int>, Mapping<Value>, ListCoordinatorUpdate<Element.SourceBase>)
//        case change(SourcesChange<Element, Value>, isSource: Bool)
//    }
//
//    struct Cache<Value> {
//        var dict = [[AnyHashable]: Value]()
//    }
//
//    class Change<Value> {
//        struct Associated {
//            unowned let change: Change<Value>
//            var ids: [AnyHashable] = []
//        }
//
//        enum State: Equatable {
//            case change(MoveType? = nil)
//            case reload
//        }
//
//        let value: Value
//        let index: Int
//        let moveAndReloadable: Bool
//        var state: State
//
//        var offsets = Cache(value: (section: 0, item: 0))
//        var associated = Cache(value: nil as Associated?)
//        weak var coordinatorUpdate: CoordinatorUpdate?
//
//        init(value: Value, index: Int, moveAndReloadable: Bool = true) {
//            self.value = value
//            self.index = index
//            self.state = .change()
//            self.moveAndReloadable = moveAndReloadable
//        }
//    }
//
//    final class SourcesChange<Element: DataSource, Value>: Change<Value> {
//        typealias Coordinator = ListCoordinator<Element.SourceBase>
//        typealias CoordinatorUpdate = ListCoordinatorUpdate<Element.SourceBase>
//
//        lazy var update = Cache(value: nil as CoordinatorUpdate?)
//        let coordinator: Coordinator
//
//        init(value: Value, index: Int, _ coordinator: Coordinator, _ moveAndReloadable: Bool) {
//            self.coordinator = coordinator
//            super.init(value: value, index: index, moveAndReloadable: moveAndReloadable)
//        }
//
//        func update(_ isSource: Bool, _ ids: [AnyHashable]) -> CoordinatorUpdate {
//            self.update[ids] ?? {
//                let update = coordinator.update(update: isSource ? .remove : .insert)
//                self.update.value = update
//                return update
//            }()
//        }
//
//        func update<O>(_ isSource: Bool, _ context: UpdateContext<O>) -> CoordinatorUpdate {
//            update(isSource, context.ids)
//        }
//    }
//
//    final class Context {
//        var dicts: Mapping<Uniques<Any>> = ([:], [:])
//        var inferredContext = Set<ObjectIdentifier>()
//    }

//    typealias Uniques<T> = [AnyHashable: (ids: [AnyHashable], change: T)?]
//    typealias ContextAndID = (context: Context, id: [AnyHashable])
    typealias Options = Mapping<ListOptions>

    typealias Indices = ContiguousArray<(index: Int, isFake: Bool)>
    typealias Offset<Offset> = (index: Int, offset: Mapping<Offset>)
    typealias UpdateContext<Offset> = (offset: Offset?, isMoved: Bool, ids: [AnyHashable])
    typealias UpdateSource<Update> = (count: Int, update: Update?)
    typealias UpdateTarget<Update> = (indices: Indices, update: Update?, change: (() -> Void)?)

    var options: Options = (.init(), .init())

//    lazy var moveType = Cache(value: nil as MoveType?)
    lazy var listUpdates = generateListUpdates()

    func generateListUpdates() -> BatchUpdates? { notImplemented() }
    func updateData(_ isSource: Bool, containsSubupdate: Bool) { }
}

extension CoordinatorUpdate {
    func firstChange(_ containsSubupdate: Bool = false) -> () -> Void {
        { [unowned self] in self.updateData(true, containsSubupdate: containsSubupdate) }
    }

    func finalChange(_ containsSubupdate: Bool = false) -> () -> Void {
        { [unowned self] in self.updateData(false, containsSubupdate: containsSubupdate) }
    }
}
//
//extension CoordinatorUpdate.Cache {
//    var value: Value {
//        get { dict[[]]! }
//        set { dict[[]] = newValue }
//    }
//
//    init(value: Value) {
//        dict = [[]: value]
//    }
//
//    subscript(ids: [AnyHashable]) -> Value {
//        get { dict[ids] ?? value }
//        set { dict[ids] = newValue }
//    }
//
//    subscript<O>(context: CoordinatorUpdate.UpdateContext<O>) -> Value {
//        get { self[context.ids] }
//        set { self[context.ids] = newValue }
//    }
//}
//
//extension CoordinatorUpdate.Order: CaseIterable {
//    var next: CoordinatorUpdate.Order? { CoordinatorUpdate.Order(rawValue: rawValue + 1) }
//}
//
//extension Optional where Wrapped == CoordinatorUpdate.Order {
//    static func > (lhs: CoordinatorUpdate.Order?, rhs: CoordinatorUpdate.Order?) -> Bool {
//        guard let lhs = lhs else { return false }
//        guard let rhs = rhs else { return true }
//        return lhs.rawValue > rhs.rawValue
//    }
//}
//
//extension CoordinatorUpdate.Change: CustomStringConvertible, CustomDebugStringConvertible {
//    subscript(ids: [AnyHashable]) -> CoordinatorUpdate.Change<Value>.Associated? {
//        get { associated.value ?? associated[ids] }
//        set { associated[ids] = newValue }
//    }
//
//    func indexPath(current: [AnyHashable]? = nil, _ ids: [AnyHashable]) -> IndexPath {
//        let (section, item) = current.flatMap { offsets.dict[$0] } ?? offsets[ids]
//        return IndexPath(section: section, item: item + index)
//    }
//
//    func index(_ ids: [AnyHashable]) -> Int {
//        offsets[ids].section + index
//    }
//
//    var description: String {
//        "\(value), \(index), \(state)"
//    }
//
//    var debugDescription: String {
//        (associated.value?.change).map { "\(description), \($0.index)" } ?? description
//    }
//}
