//
//  ListCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/3.
//

// swiftlint:disable shorthand_operator

import Foundation

class ListCoordinatorUpdate<SourceBase: DataSource>: CoordinatorUpdate
where SourceBase.SourceBase == SourceBase {
    typealias Item = SourceBase.Item
    typealias Sources = Mapping<SourceBase.Source?>
    typealias Options = Mapping<ListOptions>

    weak var listCoordinator: ListCoordinator<SourceBase>?
    let source: SourceBase.Source?
    let sourceType: SourceType
    var updateWay: ListUpdateWay<SourceBase.Item>
    var differ: ListDiffer<SourceBase.Item>!
    var isBatchUpdate = false

    lazy var target = configTarget()
    lazy var suboperations = [() -> Void]()
    lazy var sourceCount = configSourceCount()
    lazy var targetCount = configTargetCount()

    lazy var changeType = configUpdateWay()
    lazy var cachedMaxOrder = Cache(value: nil as Order??)

    var diffable: Bool { differ?.isNone == false }
    var moveAndReloadable: Bool { false }
    var isRemove: Bool {
        guard case .other(.remove) = updateWay else { return false }
        return true
    }

    var noneDiffUpdate: Bool {
        if isBatchUpdate { return false }
        switch changeType {
        case .other(.remove), .other(.insert): return false
        default: return true
        }
    }

    var isInsert: Bool {
        guard case .other(.insert) = updateWay else { return false }
        return true
    }

    // swiftlint:disable unused_setter_value
    var section: ChangeSets<IndexSet> {
        get { fatalError() }
        set { }
    }

    var item: ChangeSets<IndexPathSet> {
        get { fatalError() }
        set { }
    }
    // swiftlint:enable unused_setter_value

    init(
        _ coordinator: ListCoordinator<SourceBase>,
        update: ListUpdate<SourceBase>?,
        sources: Sources,
        options: Options
    ) {
        self.listCoordinator = coordinator
        self.source = sources.source
        self.sourceType = coordinator.sourceType
        self.updateWay = coordinator.update.way
        self.differ = updateWay.differ
        super.init()
        self.options = options
        coordinator.currentCoordinatorUpdate = self
        switch update?.updateType {
        case .whole(let whole):
            self.target = sources.target
            self.updateWay = whole.way
            switch whole.way {
            case .other(.insert):
                self.options.source.insert(.removeEmptySection)
                sourceCount = 0
            case .other(.remove):
                self.options.target.insert(.removeEmptySection)
                targetCount = 0
            case .diff(let differ):
                self.differ = differ
            default:
                break
            }
        case .batch(let batch):
            self.isBatchUpdate = true
            batch.operations.forEach { $0(self) }
            suboperations.forEach { $0() }
        default:
            break
        }
    }

    func configTarget() -> SourceBase.Source? { source }
    func configSourceCount() -> Int { notImplemented() }
    func configTargetCount() -> Int { notImplemented() }
    func inferringMoves(context: Context? = nil, ids: [AnyHashable] = []) { }

    func configMaxOrderForContext(_ ids: [AnyHashable]) -> Order? {
        switch (sourceType, changeType) {
        case (.sectionItems, _) where targetHasSection != sourceHasSection: break
        case (.sectionItems, .other(.reload)): return .first
        case (_, .none): return nil
        case (.section, .batch) where moveType(ids) == .moveAndReload: return .second
        case (.section, _): return .first
        case (_, .batch) where moveType(ids) == .moveAndReload: return .third
        case (_, _): return .second
        }

        switch (targetHasSection && !sourceHasSection, moveType(ids)) {
        case (_, .none): return .first
        case (true, .some): return .second
        case (false, .some): return .third
        }
    }

    func customUpdateWay() -> UpdateWay? { notImplemented() }
    func configUpdateWay() -> UpdateWay? {
        switch (updateWay, sourceCount == 0, targetCount == 0) {
        case (.other(.reload), _, _): return .other(.reload)
        case (.other(.appendOrRemoveLast), _, _) where sourceCount == targetCount: fallthrough
        case (.other(.prependOrRemoveFirst), _, _) where sourceCount == targetCount: fallthrough
        case (.other(.insert), _, true), (.other(.remove), true, _), (_, true, true): return .none
        case (.other(.remove), _, _), (_, false, true): return .other(.remove)
        case (.other(.insert), _, _), (_, true, false): return .other(.insert)
        case let (.other(other), _, _): return .other(other)
        default: return customUpdateWay()
        }
    }

    func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ListSource> {
        if order == .first {
            guard context.isMoved, let offset = context.offset, sourceHasSection else {
                return (sourceCountForContainer, nil)
            }
            return (1, .init(section: .init(move: offset)))
        } else {
            guard case let (_, itemUpdate?) = generateSourceItemUpdate(
                order: order,
                context: toContext(context) { IndexPath(section: $0) }
            ) else { return (sourceCountForContainer, nil) }
            return (sourceCountForContainer, .init(item: itemUpdate))
        }
    }

    func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        if order == .first {
            let indices = toIndices(sourceCountForContainer, context)
            guard context.isMoved, let offset = context.offset, sourceHasSection else {
                return (indices, nil, firstChange(true))
            }
            let (source, target) = offset.offset
            return (indices, .init(section: .init(move: source, to: target)), firstChange(true))
        } else {
            let indices = toIndices(targetCountForContainer, context)
            guard case let (_, itemUpdate?, change) = generateTargetItemUpdate(
                order: order,
                context: toContext(context) {
                    (0, (.init(section: $0.offset.source), .init(section: $0.offset.target)))
                }
            ) else { return (indices, nil, nil) }
            return (indices, .init(item: itemUpdate), change)
        }
    }

    func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        notImplemented()
    }

    func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        notImplemented()
    }

    // element batch update
    func insert(_ element: SourceBase.Source.Element, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection { }

    func insert<C: Collection>(contentsOf elements: C, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection, C.Element == SourceBase.Source.Element { }

    func append(_ element: SourceBase.Source.Element)
    where SourceBase.Source: RangeReplaceableCollection { }

    func append<S: Sequence>(contentsOf elements: S)
    where SourceBase.Source: RangeReplaceableCollection, S.Element == SourceBase.Source.Element { }

    func remove(at index: Int)
    where SourceBase.Source: RangeReplaceableCollection { }

    func remove(at indexSet: IndexSet)
    where SourceBase.Source: RangeReplaceableCollection { }

    func update(_ element: SourceBase.Source.Element, at index: Int)
    where SourceBase.Source: RangeReplaceableCollection { }

    func move(at index: Int, to newIndex: Int)
    where SourceBase.Source: RangeReplaceableCollection { }

    override func generateListUpdates() -> BatchUpdates? {
        sourceType.isItems ? generateListUpdatesForItems() : generateListUpdatesForSections()
    }

    override func updateData(_ isSource: Bool, containsSubupdate: Bool) {
        listCoordinator?.source = isSource ? source : target
        listCoordinator?.options = isSource ? options.source : options.target
    }
}

extension ListCoordinatorUpdate {
    func generateContianerSourceUpdate(
        order: Order,
        context: UpdateContext<Int> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ListSource> {
        let update: BatchUpdates.ListSource
        if isSectionItems, targetHasSection != sourceHasSection {
            switch (order, targetHasSection && !sourceHasSection) {
            case (.first, false) where !hasNext(order, context):
                update = .init(section: sourceUpdate(.remove, context, true))
                return (sourceCountForContainer, update)
            case (.first, true) where !hasNext(order, context):
                return (sourceCountForContainer, nil)
            case (.third, false):
                return (1, .init(section: .init(\.deletes, context.offset ?? 0)))
            default:
                break
            }

            var subupdate = generateSourceUpdate(order: order, context: context)
            if order == .second, targetHasSection && !sourceHasSection { subupdate.count = 1 }
            return subupdate
        }

        switch changeType {
        case .none: return (sourceCountForContainer, nil)
        case .other(let way) where way == .remove && moveType(context) != nil: fallthrough
        case .other(let way) where way != .reload && isSectionItems: fallthrough
        case .batch: return generateSourceUpdate(order: order, context: context)
        case .other(.insert): return (sourceCountForContainer, nil)
        case .other(let way): update = .init(section: sourceUpdate(way, context, isSectionItems))
        }
        return (sourceCountForContainer, update)
    }

    func generateContianerTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        let update: BatchUpdates.ListTarget
        if isSectionItems, targetHasSection != sourceHasSection {
            func count(_ count: Int, isFake: Bool = false) -> Indices {
                self.toIndices(count, context, isFake: isFake)
            }
            switch (order, targetHasSection && !sourceHasSection) {
            case (.first, false) where !hasNext(order, context):
                return (count(targetCountForContainer), nil, finalChange(true))
            case (.first, true) where !hasNext(order, context):
                update = .init(section: targetUpdate(.insert, context, true))
                return (count(targetCountForContainer), update, finalChange(true))
            case (.first, true):
                let indices = count(1, isFake: true), section = context.offset?.offset.target ?? 0
                return (indices, .init(section: .init(\.inserts, section)), firstChange(true))
            case (.third, _):
                return (count(targetCountForContainer), nil, finalChange(true))
            default:
                break
            }

            var subupdate = generateTargetUpdate(order: order, context: context)
            switch order {
            case .first:
                subupdate.change = subupdate.change + firstChange(true)
            case .second where !targetHasSection && sourceHasSection:
                subupdate.indices = [(context.offset?.index ?? 0, true)]
                subupdate.change = subupdate.change + finalChange(true)
            default:
                break
            }
            return subupdate
        }

        var change: () -> Void { hasNext(order, context) ? firstChange(true) : finalChange(true) }
        switch changeType {
        case .none: return (toIndices(targetCountForContainer, context), nil, nil)
        case .other(let way) where way == .insert && moveType(context) != nil: fallthrough
        case .other(let way) where way != .reload && isSectionItems: fallthrough
        case .batch: return generateTargetUpdate(order: order, context: context)
        case .other(.remove): return (toIndices(targetCountForContainer, context), nil, change)
        case .other(let way): update = .init(section: targetUpdate(way, context, isSectionItems))
        }
        return (toIndices(targetCountForContainer, context), update, finalChange(true))
    }

    func generateSourceItemUpdateForContianer(
        order: Order,
        context: UpdateContext<IndexPath> = (nil, false, [])
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        switch changeType {
        case .none, .other(.insert): return (sourceCount, nil)
        case .other(.remove) where moveType(context) != nil: fallthrough
        case .batch: return generateSourceItemUpdate(order: order, context: context)
        case .other(let way): return (sourceCount, sourceUpdate(way, context))
        }
    }

    func generateTargetItemUpdateForContianer(
        order: Order,
        context: UpdateContext<Offset<IndexPath>> = (nil, false, [])
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        let update: BatchUpdates.ItemTarget?
        switch changeType {
        case .none: return (toIndices(targetCount, context), nil, nil)
        case .other(.remove): return (toIndices(targetCount, context), nil, finalChange(true))
        case .other(.insert) where moveType(context) != nil: fallthrough
        case .batch: return generateTargetItemUpdate(order: order, context: context)
        case .other(let way): update = targetUpdate(way, context)
        }
        return (toIndices(targetCount, context), update, finalChange(true))
    }
}

extension ListCoordinatorUpdate {
    func sourceUpdate<C: UpdateIndexCollection>(
        _ way: ListKit.UpdateWay,
        _ context: UpdateContext<C.Element> = (nil, false, []),
        _ forContainer: Bool = false
    ) -> BatchUpdates.Source<C>? {
        let offset = context.offset ?? .zero
        let source = forContainer ? sourceCountForContainer : sourceCount
        let target = forContainer ? targetCountForContainer : targetCount
        switch way {
        case .remove:
            return .init(\.deletes, offset, offset.offseted(source))
        case .appendOrRemoveLast where sourceCount > targetCount:
            return .init(\.deletes, offset.offseted(target), offset.offseted(source))
        case .prependOrRemoveFirst where sourceCount > targetCount:
            return .init(\.deletes, offset, offset.offseted(source - target))
        case .reload:
            var update = BatchUpdates.Source<C>()
            let diff = source - target, minValue = min(source, target)
            if minValue != 0 { update.add(\.reloads, offset, offset.offseted(minValue)) }
            if diff > 0 { update.add(\.deletes, offset.offseted(minValue), offset.offseted(source)) }
            return update
        case .appendOrRemoveLast, .prependOrRemoveFirst, .insert:
            return nil
        }
    }

    func targetUpdate<C: UpdateIndexCollection>(
        _ way: ListKit.UpdateWay,
        _ context: UpdateContext<Offset<C.Element>> = (nil, false, []),
        _ forContainer: Bool = false
    ) -> BatchUpdates.Target<C>? {
        let offset = context.offset?.offset.target ?? .zero
        let source = forContainer ? sourceCountForContainer : sourceCount
        let target = forContainer ? targetCountForContainer : targetCount
        switch way {
        case .insert:
            return .init(\.inserts, offset, offset.offseted(target))
        case .appendOrRemoveLast where targetCount > sourceCount:
            return .init(\.inserts, offset.offseted(source), offset.offseted(target))
        case .prependOrRemoveFirst where targetCount > sourceCount:
            return .init(\.inserts, offset, offset.offseted(target - source))
        case .reload:
            var update = BatchUpdates.Target<C>()
            let diff = target - source, minValue = min(source, target)
            if minValue != 0 { update.reload(offset, offset.offseted(minValue)) }
            if diff > 0 { update.add(\.inserts, offset.offseted(minValue), offset.offseted(target)) }
            return update
        case .appendOrRemoveLast, .prependOrRemoveFirst, .remove:
            return nil
        }
    }

    func batchChangeFor<C: UpdateIndexCollection>(
        way: ListKit.UpdateWay,
        _ indexType: C.Type
    ) -> BatchUpdates {
        switch way {
        case .reload:
            return .reload(change: finalChange(true))
        case .appendOrRemoveLast, .prependOrRemoveFirst, .remove, .insert:
            let source: BatchUpdates.Source<C>? = sourceUpdate(way)
            let target: BatchUpdates.Target<C>? = targetUpdate(way)
            return .init(source: source, target: target, finalChange(true))
        }
    }
}

extension ListCoordinatorUpdate {
    var isSectionItems: Bool { sourceType == .sectionItems }

    var sourceHasSection: Bool { sourceCount != 0 || !options.source.removeEmptySection }
    var targetHasSection: Bool { targetCount != 0 || !options.target.removeEmptySection }

    var sourceCountForContainer: Int { isSectionItems ? (sourceHasSection ? 1 : 0) : sourceCount }
    var targetCountForContainer: Int { isSectionItems ? (targetHasSection ? 1 : 0) : targetCount }

    func generateListUpdatesForItems() -> BatchUpdates? {
        if targetHasSection && !sourceHasSection {
            return .init(target: BatchUpdates.SectionTarget(\.inserts, 0), finalChange(true))
        }
        if !targetHasSection && sourceHasSection {
            return .init(source: BatchUpdates.SectionSource(\.deletes, 0), finalChange(true))
        }
        switch changeType {
        case .other(let way): return batchChangeFor(way: way, IndexPathSet.self)
        case .batch: return listUpdatesForItems()
        case .none: return .none
        }
    }

    func generateListUpdatesForSections() -> BatchUpdates? {
        switch changeType {
        case .other(let way): return batchChangeFor(way: way, IndexSet.self)
        case .batch: return listUpdatesForSections()
        default: return .none
        }
    }

    func listUpdatesForSections() -> BatchUpdates {
        inferringMoves()
        return .batch(Order.allCases.compactMapContiguous { order in
            if order > maxOrder() { return nil }
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
        inferringMoves()
        return .batch([Order.second, Order.third].compactMapContiguous { order in
            if order > maxOrder() { return nil }
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
extension ListCoordinatorUpdate {
    func toIndices<O>(_ indices: Indices, _ context: UpdateContext<Offset<O>>) -> Indices {
        guard let index = context.offset?.index else { return indices }
        return indices.mapContiguous { (index, $0.isFake) }
    }

    func toIndices<O>(_ count: Int, _ context: UpdateContext<Offset<O>>, isFake: Bool = false) -> Indices {
        .init(repeatElement: (context.offset?.index ?? 0, isFake), count: count)
    }

    func toContext<Offset, OtherOffset>(
        _ context: UpdateContext<Offset>,
        add: (Offset) -> OtherOffset
    ) -> UpdateContext<OtherOffset> {
        return (context.offset.map(add), context.isMoved, context.ids)
    }

    func notUpdate<O>(_ order: Order, _ context: UpdateContext<O>) -> Bool {
        order > maxOrder(context.ids)
    }

    func hasNext<O>(_ order: Order, _ context: UpdateContext<O>) -> Bool {
        maxOrder(context.ids) > order
    }

    func maxOrder(_ ids: [AnyHashable] = []) -> Order? {
        cachedMaxOrder.value ?? cachedMaxOrder[ids] ?? {
            let maxOrder = configMaxOrderForContext(ids)
            cachedMaxOrder[ids] = maxOrder
            return maxOrder
        }()
    }

    func moveType<O>(_ context: UpdateContext<O>) -> MoveType? { moveType(context.ids) }
    func moveType(_ ids: [AnyHashable]) -> MoveType? { moveType.value ?? moveType[ids] }
}

extension ListCoordinatorUpdate {
    func subsource<Subsource: UpdatableDataSource>(
        _ source: Subsource,
        update: ListUpdate<Subsource.SourceBase>,
        animated: Bool? = nil,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        suboperations.append { source.perform(update, animated: animated, completion: completion) }
    }
}

extension ListCoordinatorUpdate {
    func add<T>(
        _ change: T,
        id: AnyHashable,
        ids: [AnyHashable] = [],
        to dict: inout Uniques<T>
    ) {
        if case .none = dict[id] {
            dict[id] = .some((ids, change))
        } else {
            dict[id] = .some(.none)
        }
    }

    func config<T, Value, Change: CoordinatorUpdate.Change<Value>>(
        for change: Change,
        _ key: AnyHashable,
        _ dict: inout Mapping<Uniques<T>>,
        _ isEqual: ((Value, Value) -> Bool)?,
        _ associate: ((Mapping<Change>, Mapping<[AnyHashable]>) -> Void)? = nil,
        _ toChange: (T) -> Change? = { $0 as? Change }
    ) {
        func convert(_ change: (ids: [AnyHashable], change: T)??) -> ([AnyHashable], Change)? {
            change?.flatMap { change in toChange(change.change).map { (change.ids, $0) } }
        }
        guard let (sourceID, source) = convert(dict.source[key]),
              let (targetID, target) = convert(dict.target[key]) else { return }
        defer { (dict.source[key], dict.target[key]) = (nil, nil) }
        var moveType = MoveType.move
        switch (source.state, target.state) {
        case (.change, .change):
            if isEqual?(source.value, target.value) != false { break }
            if !target.moveAndReloadable { return }
            moveType = .moveAndReload
        default:
            return
        }
        source[sourceID] = .init(change: target, ids: targetID)
        target[targetID] = .init(change: source, ids: sourceID)
        (target.state, source.state) = (.change(moveType), .change(moveType))
        source.coordinatorUpdate?.moveType[sourceID] = moveType
        target.coordinatorUpdate?.moveType[targetID] = moveType
        if moveType != .moveAndReload {
            associate?((source, target), (sourceID, targetID))
        }
    }

    // swiftlint:disable function_parameter_count
    func configCoordinatorChange<Offset, Value, Change: CoordinatorUpdate.Change<Value>>(
        _ change: Change,
        context: UpdateContext<Offset>,
        enumrateChange: (Change) -> Void,
        deleteOrInsert: (Change) -> Void,
        reload: (Change, CoordinatorUpdate.Change<Value>.Associated) -> Void,
        move: (Change, CoordinatorUpdate.Change<Value>.Associated, Bool) -> Void
    ) {
        enumrateChange(change)
        switch (change.state, change[context.ids]) {
        case let (.reload, associaed?):
            switch (context.isMoved, moveAndReloadable) {
            case (true, false):
                deleteOrInsert(change)
            case (true, true):
                move(change, associaed, true)
            case (false, _):
                reload(change, associaed)
            }
        case let (.change(moveType), associaed?):
            move(change, associaed, moveType == .moveAndReload)
        default:
            deleteOrInsert(change)
        }
    }
    // swiftlint:enable function_parameter_count

    func configCoordinatorChange<Offset: ListIndex, Value>(
        _ change: Change<Value>,
        context: UpdateContext<Offset>,
        into update: inout BatchUpdates.ItemSource
    ) {
        configCoordinatorChange(
            change,
            context: context,
            enumrateChange: { change in
                guard let offset = context.offset else { return }
                change.offsets[context.ids] = (offset.section, offset.item)
            },
            deleteOrInsert: { change in
                update.add(\.deletes, change.indexPath(context.ids))
            },
            reload: { change, _ in
                update.add(\.reloads, change.indexPath(context.ids))
            },
            move: { change, _, _ in
                update.move(change.indexPath(context.ids))
            }
        )
    }

    func configCoordinatorChange<O: ListIndex, Value>(
        _ change: Change<Value>,
        context: UpdateContext<Offset<O>>,
        into update: inout BatchUpdates.ItemTarget,
        configExtraValue: (Change<Value>, Change<Value>) -> Void
    ) {
        configCoordinatorChange(
            change,
            context: context,
            enumrateChange: { change in
                guard let offset = context.offset?.offset else { return }
                change.offsets[context.ids] = (offset.target.section, offset.target.item)
            }, deleteOrInsert: { change in
                update.add(\.inserts, change.indexPath(context.ids))
            }, reload: { change, _  in
                update.reload(change.indexPath(context.ids))
            }, move: { change, associated, isReload in
                let sourcePath = associated.change.indexPath(current: context.ids, associated.ids)
                let targetPath = change.indexPath(context.ids)
                update.move(sourcePath, to: targetPath)
                guard isReload else { return }
                configExtraValue(change, .init(value: associated.change.value, index: change.index))
            }
        )
    }
}
