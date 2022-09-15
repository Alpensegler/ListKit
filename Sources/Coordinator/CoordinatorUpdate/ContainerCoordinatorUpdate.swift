//
//  ContainerCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/21.
//

// swiftlint:disable shorthand_operator opening_brace

//import Foundation
//
//class ContainerCoordinatorUpdate<SourceBase, Source, Value>: CollectionCoordinatorUpdate<
//    SourceBase,
//    Source,
//    Value,
//    CoordinatorUpdate.SourcesChange<Source.Element, Value>,
//    CoordinatorUpdate.DifferenceChange<Source.Element, Value>
//>
//where
//    SourceBase: DataSource,
//    SourceBase.SourceBase == SourceBase,
//    Source: Collection,
//    Source.Element: DataSource,
//    Source.Element.SourceBase.Model == SourceBase.Model
//{
//    typealias Subupdate = ListCoordinatorUpdate<Source.Element.SourceBase>
//    typealias Change = SourcesChange<Source.Element, Value>
//
//    let sourceIndices: Indices
//
//    lazy var targetIndices = toIndices(targetValues)
//    lazy var subupdates = [Int: Subupdate]()
//    lazy var offsetForOrder = Cache(value: [Order: [ObjectIdentifier: Int]]())
//    lazy var defaultContext = Context()
//
//    override var shouldConsiderUpdate: Bool {
//        !isBatchUpdate || super.shouldConsiderUpdate || !subupdates.isEmpty
//    }
//
//    init(
//        _ coordinator: ListCoordinator<SourceBase>,
//        _ update: ListUpdate<SourceBase>?,
//        _ values: Mapping<Values>,
//        _ sources: Sources,
//        _ indices: Mapping<Indices>,
//        _ options: Options
//    ) {
//        self.sourceIndices = indices.source
//        super.init(coordinator, update: update, values: values, sources: sources, options: options)
//        if !isBatchUpdate { self.targetIndices = indices.target }
//    }
//
//    func withOffset(_ value: Value, offset: Int, count: Int? = nil) -> Value { value }
//    func toIdentifier(_ value: Value) -> ObjectIdentifier { notImplemented() }
//    func toIndices(_ values: Values) -> Indices { notImplemented() }
//    func subupdate(from value: Mapping<Value>) -> Subupdate { notImplemented() }
//    func changeWhenHasNext(values: Values, source: SourceBase.Source?, indices: Indices) { }
//
//    override func add(change: Change, isSource: Bool, to differences: inout Differences) {
//        differences[keyPath: path(isSource)].append(.change(.change(change, isSource: isSource)))
//        guard change.associated[[]] == nil else { return }
//        differences[keyPath: path(!isSource)].append(.change(.change(change, isSource: isSource)))
//    }
//
//    override func canConfig(at index: Mapping<Int>) -> Bool {
//        isBatchUpdate ? super.canConfig(at: index) || subupdates[index.source] != nil : true
//    }
//
//    override func configUpdate(at index: Mapping<Int>, into differences: inout Differences) {
//        if isBatchUpdate {
//            if let update = subupdates[index.source] {
//                let source = sourceValues[index.source], target = targetValues[index.target]
//                differences.source.append(.change(.update(index, (source, target), update)))
//                differences.target.append(.change(.update(index, (source, target), update)))
//            } else {
//                super.configUpdate(at: index, into: &differences)
//            }
//        } else {
//            let source = sourceValues[index.source], target = targetValues[index.target]
//            let update = subupdate(from: (source, target))
//            differences.source.append(.change(.update(index, (source, target), update)))
//            differences.target.append(.change(.update(index, (source, target), update)))
//        }
//    }
//
//    override func configSourceCount() -> Int { sourceIndices.count }
//    override func configTargetCount() -> Int { targetIndices.count }
//
//    override func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) {
//        if isBatchUpdate { return }
//        let context = context ?? defaultContext
//        enumerateDifferences(ids: ids) { (subupdate, ids) in
//            let identifier = ObjectIdentifier(subupdate)
//            if context.inferredContext.contains(identifier) { return }
//            subupdate.inferringMoves(context: context, ids: ids)
//            context.inferredContext.insert(identifier)
//        }
//    }
//
//    override func configMaxOrderForContext(_ ids: [AnyHashable]) -> Order? {
//        guard changeType == .batch else { return super.configMaxOrderForContext(ids) }
//        var order: Order?
//        enumerateDifferences(ids: ids) { (update, ids) in
//            let suborder = update.maxOrder(ids)
//            if suborder > order { order = suborder }
//        }
//        return order
//    }
//
//    override func customUpdateWay() -> UpdateWay? {
//        diffable || isBatchUpdate ? .batch : .other(.reload)
//    }
//
//    override func generateSourceUpdate(
//        order: Order,
//        context: UpdateContext<Int> = (nil, false, [])
//    ) -> UpdateSource<BatchUpdates.ListSource> {
//        if sourceType.isModels { return super.generateSourceUpdate(order: order, context: context) }
//        return sourceUpdate(order, in: context, \.section, Subupdate.generateContianerSourceUpdate)
//    }
//
//    override func generateTargetUpdate(
//        order: Order,
//        context: UpdateContext<Offset<Int>> = (nil, false, [])
//    ) -> UpdateTarget<BatchUpdates.ListTarget> {
//        if sourceType.isModels { return super.generateTargetUpdate(order: order, context: context) }
//        return targetUpdate(order, in: context, \.section, Subupdate.generateContianerTargetUpdate)
//    }
//
//    override func generateSourceItemUpdate(
//        order: Order,
//        context: UpdateContext<IndexPath> = (nil, false, [])
//    ) -> UpdateSource<BatchUpdates.ItemSource> {
//        sourceUpdate(order, in: context, \.self, Subupdate.generateSourceItemUpdateForContianer)
//    }
//
//    override func generateTargetItemUpdate(
//        order: Order,
//        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
//    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
//        targetUpdate(order, in: context, \.self, Subupdate.generateTargetItemUpdateForContianer)
//    }
//}
//
//// swiftlint:disable function_body_length
//extension ContainerCoordinatorUpdate {
//    func enumerateDifferences(ids: [AnyHashable], closure: (Subupdate, [AnyHashable]) -> Void) {
//        for source in differences.source {
//            switch source {
//            case let .change(.change(change, isSource: isSource)):
//                let value = isSource ? (change[ids]?.change.value ?? change.value) : change.value
//                let ids = ids + [toIdentifier(value)]
//                closure(change.update(isSource, ids), ids)
//            case let .change(.update(_, (_, value), update)):
//                closure(update, ids + [toIdentifier(value)])
//            default:
//                break
//            }
//        }
//    }
//
//    func sourceUpdate<Collection: UpdateIndexCollection, Result: BatchUpdate, O>(
//        _ order: Order,
//        in context: UpdateContext<O>,
//        _ keyPath: WritableKeyPath<Result, BatchUpdates.Source<Collection>>,
//        _ toSubUpdate: (Subupdate) -> (Order, UpdateContext<O>) -> UpdateSource<Result>
//    ) -> UpdateSource<Result> where Collection.Element == O {
//        var count = 0, offsets = [ObjectIdentifier: Int](), result = Result()
//        var offset: O { .init(context.offset, offset: count) }
//
//        defer { offsetForOrder[context][order] = offsets }
//
//        func move(value: Value) {
//            let count = toCount(value)
//            if count == 0 { return }
//            result[keyPath: keyPath].move(offset, offset.offseted(count))
//        }
//
//        func add(value: Value, targetCount: Int? = nil) {
//            if toCount(value) == 0 { return }
//            count += targetCount ?? toCount(value)
//        }
//
//        func add(value: Value, _ update: Subupdate, isMoved: Bool) {
//            let id = toIdentifier(value)
//            offsets[id] = count
//            let subcontext = toContext(context, isMoved, id: id, or: .zero) { $0.offseted(count) }
//            if update.notUpdate(order, subcontext) {
//                add(value: value, targetCount: update.targetCountForContainer)
//                Log.log("\(value) \(type(of: update)) notupdate")
//                if isMoved, isMain(order) { move(value: value) }
//                return
//            }
//            let (subcount, subupdate) = toSubUpdate(update)(order, subcontext)
//            count += subcount
//            subupdate.map { result.add($0) }
//            Log.log("\(value) \(type(of: update)) \(subupdate.isEmpty ? "none " : " : ")")
//            Log.log(subupdate.isEmpty ? nil : subupdate?.description)
//        }
//
//        func reload(from value: Value, to other: Value) {
//            let (diff, minValue) = (toCount(value) - toCount(other), min(toCount(value), toCount(other)))
//            defer { count += toCount(value) }
//            if minValue > 0 {
//                result[keyPath: keyPath].add(\.reloads, offset, offset.offseted(minValue))
//            }
//            if diff > 0 {
//                let upper = offset.offseted(toCount(value))
//                result[keyPath: keyPath].add(\.deletes, upper.offseted(-diff), upper)
//            }
//        }
//
//        func configChange(_ change: Change) {
//            configCoordinatorChange(
//                change,
//                context: context,
//                enumrateChange: { change in
//                    context.offset.map { change.offsets[context.ids] = ($0.section, $0.item) }
//                },
//                deleteOrInsert: { change in
//                    add(value: change.value, change.update(true, context), isMoved: false)
//                },
//                reload: { (change, associated) in
//                    if isMain(order) {
//                        reload(from: change.value, to: associated.change.value)
//                    } else {
//                        add(value: associated.change.value)
//                    }
//                },
//                move: { change, associated, isReload in
//                    guard isReload else {
//                        let moved = isMain(order), update = change.update(true, context)
//                        add(value: associated.change.value, update, isMoved: moved)
//                        return
//                    }
//                    if isMain(order) {
//                        offsets[toIdentifier(associated.change.value)] = count
//                        move(value: change.value)
//                        add(value: change.value)
//                    } else if isExtra(order) {
//                        reload(from: change.value, to: associated.change.value)
//                    } else {
//                        add(value: associated.change.value)
//                    }
//                }
//            )
//        }
//
//        func config(value: Difference) {
//            switch value {
//            case let .change(.change(change, isSource: isSource)):
//                if isSource {
//                    configChange(change)
//                } else {
//                    add(value: change.value, change.update(false, context), isMoved: false)
//                }
//            case let .change(.update(_, value, update)):
//                add(value: value.target, update, isMoved: false)
//            case let .unchanged(from: from, to: to):
//                guard !context.isMoved else { fatalError("TODO") }
//                (from.source..<to.source).forEach { add(value: sourceValues[$0]) }
//            }
//        }
//
//        if isMain(order) {
//            differences.source.forEach(config(value:))
//        } else {
//            differences.target.forEach(config(value:))
//        }
//
//        return (count, result)
//    }
//
//    func targetUpdate<Collection: UpdateIndexCollection, Result: BatchUpdate, O>(
//        _ order: Order,
//        in context: UpdateContext<Offset<O>>,
//        _ keyPath: WritableKeyPath<Result, BatchUpdates.Target<Collection>>,
//        _ toSubresult: (Subupdate) -> (Order, UpdateContext<Offset<O>>) -> UpdateTarget<Result>
//    ) -> UpdateTarget<Result> where Collection.Element == O {
//        var values = ContiguousArray<Value>(capacity: targetValues.count)
//        var indices = Indices(capacity: self.sourceIndices.count)
//        var result = Result(), change: (() -> Void)?
//        var target: O { .init(context.offset?.offset.target, offset: indices.count) }
//        var index: Int { values.count }
//        let offsets = offsetForOrder[context][order]!
//
//        func move(value: Value) {
//            let count = toCount(value)
//            guard count != 0, let offset = offsets[toIdentifier(value)] else { return }
//            let source = O(context.offset?.offset.source, offset: offset)
//            result[keyPath: keyPath].move(
//                (source, target),
//                (source.offseted(count), target.offseted(count))
//            )
//        }
//
//        func add(value: Value, targetCount: Int? = nil) {
//            let count = indices.count
//            indices.append(repeatElement: (index, false), count: targetCount ?? toCount(value))
//            values.append(withOffset(value, offset: count))
//        }
//
//        func add(value: Value, update: Subupdate, isMoved: Bool) {
//            let id = toIdentifier(value)
//            guard let offset = offsets[id] else { return }
//            let subcontext = toContext(context, isMoved, id: id, or: (0, (.zero, .zero))) {
//                (index, ($0.offset.source.offseted(offset), $0.offset.target.offseted(indices.count)))
//            }
//            if update.notUpdate(order, subcontext) {
//                if isMoved, isMain(order) { move(value: value) }
//                add(value: value, targetCount: update.targetCountForContainer)
//                Log.log("\(value) \(type(of: update)) notupdate")
//                return
//            }
//            let (subindices, subupdate, subchange) = toSubresult(update)(order, subcontext)
//            subupdate.map { result.add($0) }
//            change = change + subchange
//            Log.log("\(value) \(type(of: update)) \(subupdate.isEmpty ? "none" : ":")")
//            Log.log(subupdate.isEmpty ? nil : subupdate?.description)
//            let count = indices.count
//            indices.append(contentsOf: subindices)
//            values.append(withOffset(value, offset: count, count: subindices.count))
//        }
//
//        func reload(from other: Value, to value: Value) {
//            let diff = toCount(value) - toCount(other), minValue = min(toCount(other), toCount(value))
//            if minValue != 0 {
//                result[keyPath: keyPath].reload(target, target.offseted(minValue))
//            }
//            if diff > 0 {
//                let upper = target.offseted(toCount(value))
//                result[keyPath: keyPath].add(\.inserts, upper.offseted(-diff), upper)
//            }
//            let count = indices.count
//            indices.append(repeatElement: (index, false), count: toCount(value))
//            values.append(withOffset(value, offset: count))
//        }
//
//        func configChange(_ change: Change) {
//            configCoordinatorChange(
//                change,
//                context: context,
//                enumrateChange: { change in
//                    guard let target = context.offset?.offset.target else { return }
//                    change.offsets[context.ids] = (target.section, target.item)
//                },
//                deleteOrInsert: { change in
//                    add(value: change.value, update: change.update(false, context), isMoved: false)
//                },
//                reload: { change, associated in
//                    if isMain(order) {
//                        reload(from: associated.change.value, to: change.value)
//                    } else {
//                        add(value: change.value)
//                    }
//                },
//                move: { change, associated, isReload in
//                    guard isReload else {
//                        let moved = isMain(order), update = change.update(false, context)
//                        add(value: change.value, update: update, isMoved: moved)
//                        return
//                    }
//                    if isMain(order) {
//                        move(value: associated.change.value)
//                        add(value: associated.change.value)
//                    } else if isExtra(order) {
//                        reload(from: associated.change.value, to: change.value)
//                    } else {
//                        add(value: change.value)
//                    }
//                }
//            )
//        }
//
//        for value in differences.target {
//            switch value {
//            case let .change(.change(change, isSource: isSource)):
//                if !isSource {
//                    configChange(change)
//                } else {
//                    add(value: change.value, update: change.update(false, context), isMoved: false)
//                }
//            case let .change(.update(_, value, update)):
//                add(value: value.target, update: update, isMoved: false)
//            case let .unchanged(from: from, to: to):
//                guard !context.isMoved else { fatalError("TODO") }
//                (from.target..<to.target).forEach { add(value: targetValues[$0]) }
//            }
//        }
//
//        if hasNext(order, context) {
//            let source = toSource(values)
//            change = change + { [unowned self] in
//                self.changeWhenHasNext(values: values, source: source, indices: indices)
//            }
//        } else {
//            change = change + finalChange()
//        }
//        return (toIndices(indices, context), result, change)
//    }
//}
//// swiftlint:enable function_body_length
//
//extension ContainerCoordinatorUpdate {
//    func add(subupdate: Subupdate, at index: Int) {
//        subupdate.isRemove ? removeElement(at: index) : (subupdates[index] = subupdate)
//    }
//
//    func isMain(_ order: Order) -> Bool { sourceType.isModels ? order == .second : order == .first }
//    func isExtra(_ order: Order) -> Bool { sourceType.isModels ? order == .third : order == .second }
//
//    func toContext<Offset, OtherOffset>(
//        _ context: UpdateContext<Offset>,
//        _ isMoved: Bool = false,
//        id: ObjectIdentifier,
//        or offset: Offset,
//        add: (Offset) -> OtherOffset
//    ) -> UpdateContext<OtherOffset> {
//        (add(context.offset ?? offset), isMoved || context.isMoved, context.ids + [id])
//    }
//}
