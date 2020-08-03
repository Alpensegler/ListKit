//
//  DiffableCoordinatgorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/26.
//

import Foundation

class DiffableCoordinatgorUpdate<SourceBase: DataSource, Source, Value, CoordinatorChange, Change>:
    CollectionCoordinatorUpdate<SourceBase, Source, Value, CoordinatorChange, Change>
where
    SourceBase.SourceBase == SourceBase,
    Source: Collection,
    CoordinatorChange: CoordinatorUpdate.Change<Value>
{
    typealias Dicts<T> = Mapping<[AnyHashable: T?]>
    
    lazy var dict: Dicts<CoordinatorChange> = ([:], [:])
    lazy var uniqueMapping: CoordinatorChanges = {
        _ = changes
        let source = dict.source.values.compactMapContiguous { $0 }
        let target = dict.target.values.compactMapContiguous { $0 }
        return (source, target)
    }()
    
    var equaltable: Bool { false }
    var identifiable: Bool { false }
    
    func isEqual(lhs: Value, rhs: Value) -> Bool { false }
    func identifier(for value: Value) -> AnyHashable { false }
    func isDiffEqual(lhs: Value, rhs: Value) -> Bool { false }
    
    func configChangeAssociated(
        for mapping: Mapping<CoordinatorChange>,
        context: ContextAndID?
    ) {
        
    }
    
    func append(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Differences) {
        appendBoth(from: from, to: to, to: &changes)
    }
    
    override func configChangesForDiff() -> Differences {
        func mappingTo(isSource: Bool) -> ContiguousArray<Difference> {
            var index = 0
            return values[keyPath: path(isSource)].mapContiguous {
                defer { index += 1 }
                return .change(toChange(toChange($0, index: index, isSource: isSource), isSource))
            }
        }
        
        switch changeType {
        case .none, .reload: return ([], [])
        case .remove: return (mappingTo(isSource: true), [])
        case .insert: return ([], mappingTo(isSource: false))
        case .batchUpdates: break
        }
        var changes: CoordinatorChanges = ([], [])
        let diffs = values.target.diff(from: values.source, by: isDiffEqual)
        changes.source = diffs.removals.mapContiguous { toChange($0, isSource: true) }
        changes.target = diffs.insertions.mapContiguous { toChange($0, isSource: false) }
        
        if identifiable { apply(changes, context: nil, dict: &dict) { $0 } }
        
        var result: Differences = (.init(), .init())
        
        enumerateChangesWithOffset(changes: changes, body: { (isSource, change) in
            append(change: change, isSource: isSource, to: &result)
        }, offset: { (from, to) in
            append(from: from, to: to, to: &result)
        })
        
        return result
    }
    
    override func inferringMoves(context: ContextAndID? = nil) {
        guard let context = context else { return }
        let mapping = uniqueMapping
        let value = context.context
        mapping.source.forEach { add($0, id: identifier(for: $0.value), to: &value.dicts.source) }
        mapping.target.forEach { add($0, id: identifier(for: $0.value), to: &value.dicts.target) }
        apply(mapping, context: context, dict: &value.dicts) { $0 as? CoordinatorChange }
    }
    
    override func generateSourceSectionUpdate(
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
    
    override func generateTargetSectionUpdate(
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
            return (count(1, isFake: isFake), .init(item: itemUpdate), change)
        case (.third, _):
            return (count(targetSectionCount), nil, nil)
        }
    }
}

extension DiffableCoordinatgorUpdate {
    func toChange(_ change: CollectionDifference<Value>.Change, isSource: Bool) -> CoordinatorChange {
        toChange(change._element, index: change._offset, isSource: isSource)
    }
    
    func toChange(_ element: Value, index: Int, isSource: Bool) -> CoordinatorChange {
        let change = CoordinatorChange(element, index, moveAndReloadable: rangeReplacable)
        guard identifiable else { return change }
        let key = identifier(for: change.value)
        isSource ? add(change, id: key, to: &dict.source) : add(change, id: key, to: &dict.target)
        return change
    }
    
    func add<T>(_ change: T, id: AnyHashable, to dict: inout [AnyHashable: T?]) {
        if case .none = dict[id] {
            dict[id] = .some(change)
        } else {
            dict[id] = .some(.none)
        }
    }
    
    func apply<T, C: Collection>(
        _ changes: Mapping<C>,
        context: ContextAndID?,
        dict: inout Dicts<T>,
        toChange: (T) -> CoordinatorChange?
    ) where C.Element == CoordinatorChange {
        func configAssociated(for change: CoordinatorChange, isSource: Bool) {
            let key = identifier(for: change.value)
            let sourceChange = dict.source[key]?.map(toChange)
            let targetChange = dict.target[key]?.map(toChange)
            guard case let (source??, target??) = (sourceChange, targetChange) else { return }
            defer { (dict.source[key], dict.target[key]) = (nil, nil) }
            switch (context, source.state, target.state) {
            case let (_, .change, .change(moveAndRelod)):
                if !equaltable || isEqual(lhs: source.value, rhs: target.value) { break }
                if moveAndRelod == false { return }
                target.state = .change(moveAndRelod: true)
                source.state = .change(moveAndRelod: true)
            default:
                return
            }
            (source[context?.id], target[context?.id]) = (target, source)
            if source.state != .change(moveAndRelod: true) {
                configChangeAssociated(for: (source, target), context: context)
            }
        }
        
        changes.source.forEach { configAssociated(for: $0, isSource: true) }
        changes.target.forEach { configAssociated(for: $0, isSource: false) }
    }
    
    func configCoordinatorChange<Offset>(
        _ change: CoordinatorChange,
        context: UpdateContext<Offset>? = nil,
        enumrateChange: (CoordinatorChange) -> Void,
        deleteOrInsert: (CoordinatorChange) -> Void,
        reload: (CoordinatorChange, CoordinatorUpdate.Change<Value>) -> Void,
        move: (CoordinatorChange, CoordinatorUpdate.Change<Value>, Bool) -> Void
    ) {
        enumrateChange(change)
        switch (change.state, change[context?.id]) {
        case let (.reload, associaed?):
            switch (context?.isMoved, rangeReplacable) {
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
}

