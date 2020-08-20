//
//  DiffableCoordinatgorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/26.
//

import Foundation

class DiffableCoordinatgorUpdate<SourceBase: DataSource, Source, Value, Change, DifferenceChange>:
    CollectionCoordinatorUpdate<SourceBase, Source, Value, Change, DifferenceChange>
where
    SourceBase.SourceBase == SourceBase,
    Source: Collection,
    Change: CoordinatorUpdate.Change<Value>
{
    lazy var dict: Mapping<[AnyHashable: Change?]> = ([:], [:])
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
    
    func configChangeAssociated(for mapping: Mapping<Change>, context: ContextAndID?) { }
    
    func diffAppend(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Differences) {
        append(from: from, to: to, to: &changes)
    }
    
    override func configChangesForDiff() -> Differences {
        func mappingTo(isSource: Bool) -> Differences {
            var index = 0, differences: Differences = (.init(), .init())
            values[keyPath: path(isSource)].forEach {
                defer { index += 1 }
                let change = toChange($0, index: index, isSource: isSource)
                append(change: change, isSource: isSource, to: &differences)
            }
            return differences
        }
        
        switch changeType {
        case .none, .reload: return ([], [])
        case .remove: return mappingTo(isSource: true)
        case .insert: return mappingTo(isSource: false)
        case .batchUpdates: break
        }
        var changes: Changes = ([], [])
        let diffs = CollectionDifference(from: values.source, to: values.target, by: isDiffEqual)
        changes.source = diffs.removals.mapContiguous { toChange($0, isSource: true) }
        changes.target = diffs.insertions.mapContiguous { toChange($0, isSource: false) }
        
        if identifiable { apply(changes, context: nil, dict: &dict) { $0 } }
        
        var result: Differences = (.init(), .init())
        
        enumerateChangesWithOffset(changes: changes, body: { (isSource, change) in
            append(change: change, isSource: isSource, to: &result)
        }, offset: { (from, to) in
            diffAppend(from: from, to: to, to: &result)
        })
        
        return result
    }
    
    override func inferringMoves(context: ContextAndID? = nil) {
        guard let context = context else { return }
        let mapping = uniqueMapping
        let value = context.context
        mapping.source.forEach { add($0, id: identifier(for: $0.value), to: &value.dicts.source) }
        mapping.target.forEach { add($0, id: identifier(for: $0.value), to: &value.dicts.target) }
        apply(mapping, context: context, dict: &value.dicts) { $0 as? Change }
    }
}

extension DiffableCoordinatgorUpdate {
    func toChange(_ change: CollectionDifference<Value>.Change, isSource: Bool) -> Change {
        toChange(change._element, index: change._offset, isSource: isSource)
    }
    
    func toChange(_ element: Value, index: Int, isSource: Bool) -> Change {
        let change = Change(element, index, moveAndReloadable: moveAndReloadable)
        guard identifiable else { return change }
        let key = identifier(for: change.value)
        isSource ? add(change, id: key, to: &dict.source) : add(change, id: key, to: &dict.target)
        return change
    }
    
    func apply<T, C: Collection>(
        _ changes: Mapping<C>,
        context: ContextAndID?,
        dict: inout Mapping<[AnyHashable: T?]>,
        toChange: (T) -> Change?
    ) where C.Element == Change {
        func configAssociated(for change: Change) {
            let key = identifier(for: change.value)
            let euqal = equaltable ? isEqual : nil
            guard let mapping = config(for: change, key, context, &dict, euqal, toChange) else {
                return
            }
            if mapping.source.state != .change(moveAndRelod: true) {
                configChangeAssociated(for: mapping, context: context)
            }
        }
        
        changes.source.forEach { configAssociated(for: $0) }
        changes.target.forEach { configAssociated(for: $0) }
    }
}

