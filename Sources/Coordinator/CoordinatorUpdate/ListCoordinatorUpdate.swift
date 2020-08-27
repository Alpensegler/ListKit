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
    
    var differ: ListDiffer<SourceBase.Item>! { update?.diff ?? defaultUpdate?.diff }
    var diffable: Bool { differ?.isNone == false }
    var moveAndReloadable: Bool { false }
    
    var isMoreUpdate: Bool {
        update?.way.isMoreUpdate == true
    }
    
    init(
        coordinator: ListCoordinator<SourceBase>?,
        update: ListUpdate<SourceBase>,
        sources: Mapping<SourceBase.Source?>,
        _ keepSectionIfEmpty: Mapping<Bool>
    ) {
        self.listCoordinator = coordinator
        self.sources = sources
        self.defaultUpdate = coordinator?.update
        super.init()
        self.keepSectionIfEmpty = keepSectionIfEmpty
        switch update.updateType {
        case let .whole(whole):
            self.update = whole
            switch whole.way {
            case .insert:
                self.keepSectionIfEmpty.source = false
            case .remove:
                self.keepSectionIfEmpty.target = false
                isRemove = true
            default:
                break
            }
        case let .batch(batch):
            batch.operations.forEach { $0(self) }
            hasBatchUpdate = true
        }
    }
    
    override func updateData(_ isSource: Bool) {
        listCoordinator?.source = isSource ? sources.source : sources.target
    }
    
    override func configChangeType() -> ChangeType {
        switch (update?.way, sourceIsEmpty, targetIsEmpty) {
        case (.reload, _, _): return .reload
        case (.insert, _, true), (.remove, true, _), (_, true, true): return .none
        case (.remove, _, _), (_, false, true): return .remove(itemsOnly: itemsOnly(true))
        case (.insert, _, _), (_, true, false): return .insert(itemsOnly: itemsOnly(false))
        default: return isMoreUpdate || hasBatchUpdate || diffable ? .batchUpdates : .reload
        }
    }
    
    override func generateSourceUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> UpdateSource<BatchUpdates.ListSource> {
        switch (order, changeType) {
        case (_, .none):
            return (sourceSectionCount, nil)
        case (.first, _):
            guard let (offset, isMoved, _) = context, isMoved, sourceHasSection else {
                return (sourceSectionCount, nil)
            }
            return (1, .init(section: .init(move: offset)))
        case (.second, _),
            (.third, _) where !isEmptyUpdate(order, context, isSectioned: false):
            guard case let (_, itemUpdate?) = generateSourceItemUpdate(
                order: order,
                context: toContext(context) { IndexPath(section: $0) }
            ) else { return (1, nil) }
            return (1, .init(item: itemUpdate))
        case (.third, .remove(false)):
            return (1, .init(section: .init(\.deletes, context?.offset ?? 0)))
        case (.third, _):
            return (targetSectionCount, nil)
        }
    }
    
    override func generateTargetUpdate(
        order: Order,
        context: UpdateContext<Offset<Int>>? = nil
    ) -> UpdateTarget<BatchUpdates.ListTarget> {
        func count(_ count: Int, isFake: Bool = false) -> Indices {
            .init(repeatElement: (context?.offset.index ?? 0, isFake), count: count)
        }
        switch (order, changeType) {
        case (_, .none):
            return (count(sourceSectionCount), nil, nil)
        case (.first, .insert(false)):
            let indices = count(1, isFake: true), section = context?.offset.offset.target ?? 0
            return (indices, .init(section: .init(\.inserts, section)), firstChange)
        case (.first, _):
            guard let ((_, (source, target)), moved, _) = context, moved, sourceHasSection else {
                return (count(sourceSectionCount), nil, firstChange)
            }
            return (count(1), .init(section: .init(move: source, to: target)), firstChange)
        case (.second, _),
             (.third, _) where !isEmptyUpdate(order, context, isSectioned: false):
            let isFake = changeType == .remove(itemsOnly: false)
            guard case let (_, itemUpdate?, change) = generateTargetItemUpdate(
                order: order,
                context: toContext(context) {
                    (0, (.init(section: $0.offset.source), .init(section: $0.offset.target)))
                }
            ) else { return (count(1, isFake: isFake), nil, nil) }
            let changes = hasNext(order, context) ? change : (change + finalChange)
            return (count(1, isFake: isFake), .init(item: itemUpdate), changes)
        case (.third, .remove(itemsOnly: false)):
            return (count(0), nil, finalChange)
        case (.third, _):
            return (count(targetSectionCount), nil, finalChange)
        }
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> UpdateSource<BatchUpdates.ItemSource> {
        let diff = sourceCount - targetCount
        guard isMoreUpdate, order == .second, diff > 0 else { return (sourceCount, nil) }
        var start = context?.offset ?? .zero
        if update?.way.isAppend == true { start = start.offseted(targetCount) }
        return (sourceCount, .init(\.deletes, start, start.offseted(diff)))
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Offset<IndexPath>>? = nil
    ) -> UpdateTarget<BatchUpdates.ItemTarget> {
        let diff = targetCount - sourceCount
        guard isMoreUpdate, order == .second, diff > 0 else {
            return (toIndices(targetCount, context), nil, nil)
        }
        var start = context?.offset.offset.target ?? .zero
        if update?.way.isAppend == true { start = start.offseted(sourceCount) }
        let update = BatchUpdates.ItemTarget(\.inserts, start, start.offseted(diff))
        return (toIndices(targetCount, context), update, finalChange)
    }
}

extension ListCoordinatorUpdate {
    func itemsOnly(_ isSource: Bool) -> Bool {
        !isSectioned && hasSectionIfEmpty(isSource: isSource)
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
    
    func toIndices<O>(_ count: Int, _ context: UpdateContext<Offset<O>>?) -> Indices {
        .init(repeatElement: (context?.offset.index ?? 0, false), count: count)
    }
}

extension ListCoordinatorUpdate {
    func add<T>(_ change: T, id: AnyHashable, to dict: inout [AnyHashable: T?]) {
        if case .none = dict[id] {
            dict[id] = .some(change)
        } else {
            dict[id] = .some(.none)
        }
    }
    
    @discardableResult
    func config<T, Value, Change: CoordinatorUpdate.Change<Value>>(
        for change: Change,
        _ key: AnyHashable,
        _ context: ContextAndID?,
        _ dict: inout Mapping<[AnyHashable: T?]>,
        _ isEqual: ((Value, Value) -> Bool)?,
        _ toChange: (T) -> Change? = { $0 as? Change }
    ) -> Mapping<Change>? {
        let sourceChange = dict.source[key]?.map(toChange)
        let targetChange = dict.target[key]?.map(toChange)
        guard case let (source??, target??) = (sourceChange, targetChange) else { return nil }
        defer { (dict.source[key], dict.target[key]) = (nil, nil) }
        switch (context, source.state, target.state) {
        case let (_, .change, .change(moveAndRelod)):
            if isEqual?(source.value, target.value) != false { break }
            if moveAndRelod == false { return nil }
            target.state = .change(moveAndRelod: true)
            source.state = .change(moveAndRelod: true)
        default:
            return nil
        }
        (source[context?.id], target[context?.id]) = (target, source)
        return (source, target)
    }
    
    func configCoordinatorChange<Offset, Value, Change: CoordinatorUpdate.Change<Value>>(
        _ change: Change,
        context: UpdateContext<Offset>? = nil,
        enumrateChange: (Change) -> Void,
        deleteOrInsert: (Change) -> Void,
        reload: (Change, CoordinatorUpdate.Change<Value>) -> Void,
        move: (Change, CoordinatorUpdate.Change<Value>, Bool) -> Void
    ) {
        enumrateChange(change)
        switch (change.state, change[context?.id]) {
        case let (.reload, associaed?):
            switch (context?.isMoved, moveAndReloadable) {
            case (true, false):
                deleteOrInsert(change)
            case (true, true):
                move(change, associaed, true)
            default:
                reload(change, associaed)
            }
        case let (.change(moveAndRelod), associaed?):
            move(change, associaed, moveAndRelod == true)
        default:
            deleteOrInsert(change)
        }
    }
    
    func configCoordinatorChange<Offset: ListIndex, Value, Change: CoordinatorUpdate.Change<Value>>(
        _ change: Change,
        context: UpdateContext<Offset>? = nil,
        into update: inout BatchUpdates.ItemSource
    ) {
        configCoordinatorChange(
            change,
            context: context,
            enumrateChange: { change in
                guard let (offset, _, id) = context else { return }
                change.offsets[id] = (offset.section, offset.item)
            },
            deleteOrInsert: { change in
                update.add(\.deletes, change.indexPath(context?.id))
            },
            reload: { change, _ in
                update.add(\.reloads, change.indexPath(context?.id))
            },
            move: { change, associated, isReload in
                update.move(change.indexPath(context?.id))
            }
        )
    }
    
    func configCoordinatorChange<O: ListIndex, Value, Change: CoordinatorUpdate.Change<Value>>(
        _ change: Change,
        context: UpdateContext<Offset<O>>? = nil,
        into update: inout BatchUpdates.ItemTarget,
        configExtraValue: (Change, Change) -> Void
    ) {
        configCoordinatorChange(
            change,
            context: context,
            enumrateChange: { change in
                guard let ((_, offset), _, id) = context else { return }
                change.offsets[id] = (offset.target.section, offset.target.item)
            }, deleteOrInsert: { change in
                update.add(\.inserts, change.indexPath(context?.id))
            }, reload: { change, _  in
                update.reload(change.indexPath(context?.id))
            }, move: { change, associated, isReload in
                let sourcePath = associated.indexPath(context?.id)
                let targetPath = change.indexPath(context?.id)
                update.move(sourcePath, to: targetPath)
                guard isReload else { return }
                itemMaxOrder[context?.id] = .third
                configExtraValue(change, Change(associated.value, change.index))
            }
        )
    }
}
