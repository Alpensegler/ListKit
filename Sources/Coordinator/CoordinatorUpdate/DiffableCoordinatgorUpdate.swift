//
//  DiffableCoordinatgorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/26.
//

import Foundation

class DiffableCoordinatgorUpdate<SourceBase: DataSource, Source, Value, Change>:
    CollectionCoordinatorUpdate<SourceBase, Source, Value>
where SourceBase.SourceBase == SourceBase, Source: Collection, Change: CoordinatorChange<Value> {
    typealias Changes = Mapping<ContiguousArray<Change>>
    typealias Dicts<T> = Mapping<[AnyHashable: T?]>
    
    lazy var changes = configChanges()
    lazy var dict: Dicts<Change> = ([:], [:])
    lazy var unchangedIndices = configUnchangedIndices()
    lazy var uniqueMapping: Changes = {
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
        for mapping: Mapping<Change>,
        context: (context: CoordinatorUpdateContext, id: ObjectIdentifier)?
    ) {
        
    }
    
    func inferringSubmoves(context: Context) { }
    
    override func inferringMoves(context: Context) {
        let mapping = uniqueMapping
        let value = context.context
        mapping.source.forEach { add($0, id: identifier(for: $0.value), to: &value.dicts.source) }
        mapping.target.forEach { add($0, id: identifier(for: $0.value), to: &value.dicts.target) }
        apply(mapping, context: context, dict: &value.dicts) { $0 as? Change }
        inferringSubmoves(context: context)
    }
    
    override func generateSourceSectionUpdate(
        order: Order,
        context: UpdateContext<Int>? = nil
    ) -> (count: Int, update: BatchUpdates.ListSource?) {
        switch (order, changeType) {
        case (_, .none), (.first, _), (.second, .remove(.section)), (.second, .insert(.section)):
            return (sourceSectionCount, nil)
        case (.second, _):
            guard case let (_, itemUpdate?) = generateSourceItemUpdate(
                order: .second,
                context: toContext(context) { IndexPath(section: $0) }
            ) else { return (1, nil) }
            return (1, .init(item: itemUpdate))
        case let (.third, .remove(content)) where content.hasSection:
            return (1, .init(section: .init(\.deletes, context?.offset ?? 0)))
        case (.third, _):
            return (targetSectionCount, nil)
        }
    }
    
    override func generateTargetSectionUpdate(
        order: Order,
        context: UpdateContext<Mapping<Int>>? = nil
    ) -> (count: Int, update: BatchUpdates.ListTarget?, change: (() -> Void)?) {
        switch (order, changeType) {
        case (_, .none):
            return (sourceSectionCount, nil, nil)
        case let (.first, .insert(content)) where content.hasSection:
            return (1, .init(section: .init(\.inserts, context?.offset.target ?? 0)), nil)
        case (.first, _):
            guard let context = context, context.isMoved, sourceHasSection else {
                return (sourceSectionCount, nil, nil)
            }
            return (1, .init(section: .init(moves: [context.offset])), nil)
        case let (.second, .insert(content)) where !content.hasItem,
             let (.second, .remove(content)) where !content.hasItem:
            return (sourceSectionCount, nil, nil)
        case (.second, _),
             (.third, _) where needExtraUpdate[context?.id]:
            guard case let (_, itemUpdate?, change) = generateTargetItemUpdate(
                order: order,
                context: toContext(context) { (.init(section: $0.source), .init(section: $0.target)) }
            ) else { return (1, nil, nil) }
            return (1, .init(item: itemUpdate), change)
        case (.third, _):
            return (targetSectionCount, nil, nil)
        }
    }
}

extension DiffableCoordinatgorUpdate {
    func configChanges() -> Changes {
        func mappingTo(isSource: Bool) -> ContiguousArray<Change> {
            var index = 0
            return values[keyPath: path(isSource)].mapContiguous {
                defer { index += 1 }
                return toChange($0, index: index, isSource: isSource)
            }
        }
        
        switch changeType {
        case .none, .reload: return ([], [])
        case .remove: return (mappingTo(isSource: true), [])
        case .insert: return ([], mappingTo(isSource: false))
        case .batchUpdates: break
        }
        
        var changes: Changes = ([], [])
        let diffs = values.target.diff(from: values.source, by: isDiffEqual)
        changes.source = diffs.removals.mapContiguous { toChange($0, isSource: true) }
        changes.target = diffs.insertions.mapContiguous { toChange($0, isSource: false) }
        
        if diffable { apply(changes, context: nil, dict: &dict) { $0 } }
        return changes
    }
    
    func configUnchangedIndices() -> Mapping<IndexSet> {
        var subindices: Mapping<IndexSet> = ([], [])
        enumerateValue(values: values.source, with: changes.source) { i, value in
            subindices.source.insert(i)
        }
        enumerateValue(values: values.target, with: changes.target) { i, value in
            subindices.target.insert(i)
        }
        return subindices
    }
    
    func configUnchangedDict<T>(_ mapping: (Int, Int) -> Mapping<T>) -> Mapping<[Int: T]> {
        var dict: Mapping<[Int: T]> = ([:], [:])
        dict.source.reserveCapacity(unchangedIndices.source.count)
        dict.target.reserveCapacity(unchangedIndices.target.count)
        zip(unchangedIndices.source, unchangedIndices.target).forEach {
            let (source, target) = mapping($0, $1)
            (dict.source[$0], dict.target[$1]) = (source, target)
        }
        return dict
    }
    
    func toChange(_ change: CollectionDifference<Value>.Change, isSource: Bool) -> Change {
        toChange(change._element, index: change._offset, isSource: isSource)
    }
    
    func toChange(_ element: Value, index: Int, isSource: Bool) -> Change {
        let change = Change(element, index, moveAndReloadable: rangeReplacable)
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
        context: (context: CoordinatorUpdateContext, id: ObjectIdentifier)?,
        dict: inout Dicts<T>,
        toChange: (T) -> Change?
    ) where C.Element == Change {
        func configAssociated(for change: Change, isSource: Bool) {
            let key = identifier(for: change.value)
            let sourceChange = dict.source[key]?.map(toChange)
            let targetChange = dict.target[key]?.map(toChange)
            guard case let (source??, target??) = (sourceChange, targetChange) else { return }
            defer { (dict.source[key], dict.target[key]) = (nil, nil) }
            let equal = equaltable ? nil : isEqual(lhs: source.value, rhs: target.value)
            switch (context, source.state, target.state) {
            case (nil, _, _) where equal == false && source.index == target.index:
                (source.state, target.state) = (.reload, .reload)
            case let (_, .change, .change(moveAndRelod)):
                if equal != false { break }
                guard moveAndRelod != false else { return }
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
    
    func configChange<Offset>(
        context: UpdateContext<Offset>?,
        changes: ContiguousArray<Change>,
        values: ContiguousArray<Value>,
        alwaysEnumrate: Bool = false,
        enumrateChange: (Change) -> Void,
        configValue: (Int, Value, Bool) -> Void,
        deleteOrInsert: (Change) -> Void,
        reload: (Change, CoordinatorChange<Value>) -> Void,
        move: (Change, CoordinatorChange<Value>, Bool) -> Void
    ) {
        let isMove = context?.isMoved ?? false
        func configChange(_ change: Change) {
            enumrateChange(change)
            switch (change.state, change[context?.id]) {
            case let (.reload, associaed?):
                switch (isMove, rangeReplacable) {
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
        
        guard alwaysEnumrate || isMove else {
            changes.forEach(configChange(_:))
            return
        }
        
        enumerateValue(values: values, with: changes, configChange: configChange(_:)) {
            configValue($0, $1, isMove)
        }
    }
    
    func enumerateValue(
        values: ContiguousArray<Value>,
        with changes: ContiguousArray<Change>,
        configChange: (Change) -> Void = { _ in },
        enumrateValue: (Int, Value) -> Void
    ) {
        if changes.isEmpty {
            values.enumerated().forEach { enumrateValue($0.offset, $0.element) }
            return
        }
        var enumratedCount = 0
        for i in values.indices {
            if enumratedCount < changes.count, i == changes[enumratedCount].index {
                configChange(changes[enumratedCount])
                enumratedCount += 1
            } else {
                enumrateValue(i, values[i])
            }
        }
    }
}

