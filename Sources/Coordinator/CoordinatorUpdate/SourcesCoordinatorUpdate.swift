//
//  SourcesCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/12.
//

import Foundation

final class SourcesCoordinatorChange<SourceBase: DataSource, Source: RangeReplaceableCollection>:
    CoordinatorChange<SourcesCoordinator<SourceBase, Source>.Subsource>
where
    SourceBase.SourceBase == SourceBase,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    var update = UpdateContextCache(value: nil as CoordinatorUpdate<Source.Element.SourceBase>?)
}

final class SourcesCoordinatorUpdate<SourceBase: DataSource, Source: RangeReplaceableCollection>:
    DiffableCoordinatgorUpdate<SourceBase, Source, SourcesCoordinator<SourceBase, Source>.Subsource, SourcesCoordinatorChange<SourceBase, Source>>
where
    SourceBase.SourceBase == SourceBase,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == SourceBase.Item
{
    typealias Coordinator = SourcesCoordinator<SourceBase, Source>
    typealias Change = SourcesCoordinatorChange<SourceBase, Source>
    typealias Subsource = Coordinator.Subsource
    typealias Subupdate = CoordinatorUpdate<Element.SourceBase>
    typealias Subcoordinator = ListCoordinator<Element.SourceBase>
    
    weak var coordinator: Coordinator?
    
    var indices: Mapping<Indices>
    var movedUpdate = UpdateContextCache(value: ContiguousArray<Subupdate>())
    var offsetForOrder = UpdateContextCache(value: [Order: [Int]]())
    var subsourceUpdate = [() -> Void]()
    lazy var subupdates = configSubupdates()
    
    override var sourceCount: Int { indices.source.count }
    override var targetCount: Int { indices.target.count }
    override var sourceIsEmpty: Bool { indices.source.isEmpty }
    override var targetIsEmpty: Bool { indices.target.isEmpty }
    
    override var diffable: Bool { true }
    override var equaltable: Bool { true }
    override var identifiable: Bool { true }
    override var rangeReplacable: Bool { true }
    
    init(
        coordinator: Coordinator,
        update: Update<SourceBase>,
        values: Values,
        sources: Sources,
        indices: Mapping<Indices>,
        keepSectionIfEmpty: Mapping<Bool>,
        isSectioned: Bool
    ) {
        self.coordinator = coordinator
        self.indices = indices
        super.init(coordinator, update: update, values: values, sources: sources)
        self.keepSectionIfEmpty = keepSectionIfEmpty
        self.isSectioned = isSectioned
    }
    
    override func inferringSubmoves(context: Context) {
        unchangedIndices.source.forEach { subupdates.source[$0]?.update.inferringMoves(context: context) }
        movedUpdate[context.id].forEach { $0.inferringMoves(context: context) }
    }
    
    override func generateListUpdates() -> BatchUpdates? {
        if !sourceIsEmpty || !targetIsEmpty { inferringSubmoves(context: generateContext()) }
        return super.generateListUpdates()
    }
    
    override func finalUpdate(_ hasBatchUpdate: Bool) {
        super.finalUpdate(hasBatchUpdate)
        coordinator?.subsources = hasBatchUpdate ? updatedValues : values.target
        coordinator?.indices = indices.target
    }
    
    override func isEqual(lhs: Subsource, rhs: Subsource) -> Bool {
        let related = lhs.related
        switch (lhs.value, rhs.value) {
        case let (.element(lhs), .element(rhs)):
            return related.coordinator.equal(lhs: lhs.sourceBase, rhs: rhs.sourceBase)
        case let (.items(lhs, _), .items(rhs, _)):
            return lhs == rhs
        default:
            return false
        }
    }
    
    override func identifier(for value: Subsource) -> AnyHashable {
        switch value.value {
        case .element(let element):
            return HashCombiner(0, value.related.coordinator.identifier(for: element.sourceBase))
        case .items(let id, _):
            return HashCombiner(1, id)
        }
    }
    override func isDiffEqual(lhs: Subsource, rhs: Subsource) -> Bool {
        guard identifier(for: lhs) == identifier(for: rhs) else { return false }
        return isEqual(lhs: lhs, rhs: rhs)
    }
    
    override func configChangeAssociated(
        for mapping: Mapping<Change>,
        context: (context: CoordinatorUpdateContext, id: ObjectIdentifier)?
    ) {
        let source = mapping.source.value.related.coordinator
        let target = mapping.target.value.related.coordinator
        let update = target.update(from: source, differ: differ)
        mapping.source.update[context?.id] = update
        mapping.target.update[context?.id] = update
        movedUpdate[context?.id].append(update)
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> (count: Int, update: BatchUpdates.ListSource?) {
        guard isSectioned else {
            return super.generateSourceSectionUpdate(order: order, context: context)
        }
        
        return sourceUpdate(
            order: order,
            updatesToBeConfig: nil,
            indexReloadCoordinator: nil,
            context: context,
            path: \.section,
            add: { $0 ?? 0 + $1 },
            toOffset: { ($0, 0) },
            toCount: { $0.numbersOfSections() },
            toSubUpdate: Subupdate.generateSourceSectionUpdate
        )
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Mapping<Int>>? = nil
    ) -> (count: Int, update: BatchUpdates.ListTarget?, change: (() -> Void)?) {
        guard isSectioned else {
            return super.generateTargetSectionUpdate(order: order, context: context)
        }
        
        return targetUpdate(
            order: order,
            updatesToBeConfig: nil,
            indexReloadCoordinator: nil,
            context: context,
            path: \.section,
            add: { $0 ?? 0 + $1 },
            toOffset: { ($0, 0) },
            toCount: { $0.numbersOfSections() },
            toSubUpdate: Subupdate.generateTargetSectionUpdate
        )
    }
    
    override func generateSourceItemUpdate(
        order: Order,
        context: UpdateContext<IndexPath>? = nil
    ) -> (count: Int, update: BatchUpdates.ItemSource?) {
        sourceUpdate(
            order: order,
            updatesToBeConfig: nil,
            indexReloadCoordinator: nil,
            context: context,
            path: \.self,
            add: { IndexPath(section: $0?.section ?? 0, item: $0?.item ?? 0 + $1) },
            toOffset: { ($0.section, $0.item) },
            toCount: { $0.numbersOfSections() },
            toSubUpdate: Subupdate.generateSourceItemUpdate
        )
    }
    
    override func generateTargetItemUpdate(
        order: Order,
        context: UpdateContext<Mapping<IndexPath>>? = nil
    ) -> (count: Int, update: BatchUpdates.ItemTarget?, change: (() -> Void)?) {
        targetUpdate(
            order: order,
            updatesToBeConfig: nil,
            indexReloadCoordinator: nil,
            context: context,
            path: \.self,
            add: { .init(section: $0?.section ?? 0, item: $0?.item ?? 0 + $1) },
            toOffset: { ($0.section, $0.item) },
            toCount: { $0.numbersOfSections() },
            toSubUpdate: Subupdate.generateTargetItemUpdate
        )
    }
}

extension SourcesCoordinatorUpdate {
    func subsource<Subsource: UpdatableDataSource>(
        _ source: Subsource,
        update: Update<Subsource.SourceBase>,
        animated: Bool? = nil,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        subsourceUpdate.append {
            source.perform(update, animated: animated, completion: completion)
        }
    }
    
    func configSubupdates() -> Mapping<[Int: (related: Int, update: Subupdate)]> {
        configUnchangedDict {
            let source = values.source[$0].related, target = values.target[$1].related
            let update = target.coordinator.update(from: source.coordinator, differ: differ)
            return (($1, update), ($0, update))
        }
    }
    
    func sourceUpdate<Collection: UpdateIndexCollection, Result: BatchUpdate, Offset>(
        order: Order,
        updatesToBeConfig: ContiguousArray<Subupdate>?,
        indexReloadCoordinator: ((Int) -> (Subcoordinator, Subcoordinator))?,
        context: UpdateContext<Offset>?,
        path: WritableKeyPath<Result, BatchUpdates.Source<Collection>>,
        add: (Offset?, Int) -> Offset,
        toOffset: (Offset) -> (Int, Int),
        toCount: (Subcoordinator) -> Int,
        toSubUpdate: (Subupdate) -> (Order, UpdateContext<Offset>?) -> (Int, Result?)
    ) -> (count: Int, update: Result?) where Collection.Element == Offset {
        var count = 0, offsets = [Int](), result = Result()
        var offset: Offset { add(context?.offset, count) }
        
        defer { offsetForOrder[context?.id][order] = offsets }
        
        func addToUpdate(_ subupdate: Subupdate, isMoved: Bool) {
            let context = toContext(context, isMoved) { add($0, count) }
            let (subcount, subupdate) = toSubUpdate(subupdate)(order, context)
            offsets.append(count)
            count += subcount
            subupdate.map { result.add($0) }
        }
        
        func reload(from coordinator: Subcoordinator, to other: Subcoordinator) {
            let (from, to) = (toCount(coordinator), toCount(other))
            let (diff, minValue) = (from - to, min(from, to))
            offsets.append(count)
            count += from
            if minValue > 0 {
                result[keyPath: path].moveOrReload(offset, add(offset, minValue))
            }
            if diff > 0 {
                result[keyPath: path].add(\.deletes, add(offset, from - diff), add(offset, from))
            }
        }
        
        if let updates = updatesToBeConfig {
            for (index, update) in updates.enumerated() {
                if let (from, to) = indexReloadCoordinator?(index) {
                    reload(from: from, to: to)
                } else {
                    addToUpdate(update, isMoved: false)
                }
            }
            return (count, result)
        }
        
        configChange(
            context: context,
            changes: changes.source,
            values: values.source,
            alwaysEnumrate: true,
            enumrateChange: { change in
                guard let context = context else { return }
                change.offsets[context.id] = toOffset(offset)
            },
            configValue: { index, value, isMove in
                addToUpdate(subupdates.source[index]!.update, isMoved: isMove)
            },
            deleteOrInsert: { change in
                let subcount = toCount(change.value.related.coordinator)
                guard subcount != 0 else { return }
                result[keyPath: path].add(\.deletes, add(offset, 0), add(offset, subcount))
                offsets.append(count)
                count += subcount
            },
            reload: { (change, associated) in
                let target = associated.value.related.coordinator
                reload(from: change.value.related.coordinator, to: target)
            },
            move: { change, associated, isReload in
                if isReload {
                    needExtraUpdate[context?.id] = true
                    let subcount = toCount(change.value.related.coordinator)
                    if subcount == 0 { return }
                    offsets.append(count)
                    count += subcount
                    result[keyPath: path].moveOrReload(add(offset, 0), add(offset, subcount))
                } else {
                    addToUpdate(change.update[context?.id]!, isMoved: true)
                }
            }
        )
        
        offsetForOrder[context?.id][order] = offsets
        
        return (count, result)
    }
    
    func targetUpdate<Collection: UpdateIndexCollection, Result: BatchUpdate, Offset>(
        order: Order,
        updatesToBeConfig: ContiguousArray<Subupdate>?,
        indexReloadCoordinator: ((Int) -> (Subcoordinator, Subcoordinator))?,
        context: UpdateContext<Mapping<Offset>>?,
        path: WritableKeyPath<Result, BatchUpdates.Target<Collection>>,
        add: (Offset?, Int) -> Offset,
        toOffset: (Offset) -> (Int, Int),
        toCount: (Subcoordinator) -> Int,
        toSubUpdate: (Subupdate) -> (Order, UpdateContext<Mapping<Offset>>?) -> (Int, Result?, (() -> Void)?)
    ) -> (count: Int, update: Result?, change: (() -> Void)?) where Collection.Element == Offset {
        var subsources = ContiguousArray<Subsource>(capacity: values.target.count)
        var indices = ContiguousArray<Int>(capacity: self.indices.source.count)
        var result = Result(), change: (() -> Void)?
        var offset: Offset { add(context?.offset.target, indices.count) }
        let soureceOffset = offsetForOrder[context?.id][order]
        
        func addUpdate(_ value: Subsource, subupdate: Subupdate, index: Int, related: Int, isMoved: Bool) {
            guard let offset = soureceOffset?[related] else { return }
            let context = toContext(context, isMoved) { (add($0, offset), add($1, indices.count)) }
            let (subcount, subupdate, subchange) = toSubUpdate(subupdate)(order, context)
            subsources.append((value.value, value.related, indices.count))
            subupdate.map { result.add($0) }
            change = change + subchange
            if subcount == 0 { return }
            indices.append(contentsOf: repeatElement(index, count: subcount))
        }
        
        func reload(index: Int, from other: Subsource, to value: Subsource) {
            let from = toCount(other.related.coordinator), to = toCount(value.related.coordinator)
            let diff = to - from, minValue = min(from, to)
            subsources.append((value.value, value.related, indices.count))
            indices.append(contentsOf: repeatElement(index, count: to))
            if minValue != 0 {
                result[keyPath: path].add(\.reloads, add(offset, 0), add(offset, minValue))
            }
            if diff > 0 {
                result[keyPath: path].add(\.inserts, add(offset, to - diff), add(offset, to))
            }
        }

        configChange(
            context: context,
            changes: changes.target,
            values: values.target,
            alwaysEnumrate: true,
            enumrateChange: { change in
                context.map { change.offsets[$0.id] = toOffset($0.offset.target) }
            },
            configValue: {
                guard let (related, update) = subupdates.target[$0] else { return }
                addUpdate($1, subupdate: update, index: $0, related: related, isMoved: $2)
            },
            deleteOrInsert: {
                let count = toCount($0.value.related.coordinator)
                subsources.append(($0.value.value, $0.value.related, indices.count))
                if count == 0 { return }
                indices.append(contentsOf: repeatElement($0.index, count: count))
                result[keyPath: path].add(\.inserts, add(offset, 0), add(offset, count))
            },
            reload: { change, associated in
                reload(index: change.index, from: associated.value, to: change.value)
            },
            move: { change, associated, isReload in
                if isReload {
                    guard let sourceOffset = soureceOffset?[associated.index] else { return }
                    let value = associated.value, count = toCount(value.related.coordinator)
                    subsources.append((value.value, value.related, indices.count))
                    if count == 0 { return }
                    indices.append(contentsOf: repeatElement(change.index, count: count))
                    let lower = add(context?.offset.source, sourceOffset)
                    result[keyPath: path].move(
                        from: (lower, add(lower, count)),
                        to: (add(offset, indices.count), add(offset, indices.count + count))
                    )
                } else {
                    addUpdate(
                        associated.value,
                        subupdate: change.update[context?.id]!,
                        index: change.index,
                        related: associated.index,
                        isMoved: true
                    )
                }
            }
        )
        
        change = change + { [unowned self] in
            self.coordinator?.set(values: subsources, indices: indices)
        }
        
        return (indices.count, result, change)
    }
}
