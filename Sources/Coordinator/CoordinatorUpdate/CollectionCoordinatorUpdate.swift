//
//  CollectionCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/5.
//

import Foundation

class CollectionCoordinatorUpdate<SourceBase, Source, Value, Change, DifferenceChange>:
    ListCoordinatorUpdate<SourceBase>
where
    SourceBase: DataSource,
    SourceBase.SourceBase == SourceBase,
    Source: Collection,
    Change: CoordinatorUpdate.Change<Value>
{
    typealias Element = Source.Element
    typealias Values = Mapping<ContiguousArray<Value>>
    typealias Differences = Mapping<ContiguousArray<Difference>>
    typealias CoordinatorChanges = Mapping<ContiguousArray<Change>>
    
    enum Difference {
        case change(DifferenceChange)
        case unchanged(from: Mapping<Int>, to: Mapping<Int>)
    }
    
    var values: Values
    var keepSectionIfEmpty = (source: false, target: false)
    
    var changeIndices: Mapping<IndexSet> = (.init(), .init())
    var changeDict: Mapping<[Int: Change]> = ([:], [:])
    var updateDict = [Int: (change: Change, value: Value)]()
    
    lazy var changes = hasBatchUpdate ? configChangesForBatchUpdates() : configChangesForDiff()
    lazy var sourceCount = getSourceCount()
    lazy var targetCount = getTargetCount()
    lazy var sourceValuesCount = values.source.count
    lazy var targetValuesCount = values.target.count
    
    var differ: Differ<SourceBase.Item>! { update?.diff ?? defaultUpdate?.diff }
    var diffable: Bool { differ?.isNone == false }
    var rangeReplacable: Bool { false }
    
    init(
        _ coordinator: ListCoordinator<SourceBase>? = nil,
        update: ListUpdate<SourceBase>,
        _ values: Values,
        _ sources: Sources,
        _ keepSectionIfEmpty: Mapping<Bool>
    ) {
        self.values = values
        super.init(coordinator: coordinator, update: update, sources: sources)
        self.keepSectionIfEmpty = keepSectionIfEmpty
        guard case let .whole(whole, _) = update else { return }
        switch whole.way {
        case .insert:
            self.keepSectionIfEmpty.source = false
        case .remove:
            self.keepSectionIfEmpty.target = false
        default: break
        }
    }
    
    func getSourceCount() -> Int { values.source.count }
    func getTargetCount() -> Int { values.target.count }
    
    func toCount(_ value: Value) -> Int { 1 }
    func toValue(_ element: Element) -> Value { fatalError("should be implemented by subclass") }
    func updateSource(with changes: Differences) { fatalError("should be implemented by subclass") }
    func configChangesForDiff() -> Differences { fatalError("should be implemented by subclass") }
    
    func toChange(_ change: Change, _ isSource: Bool) -> DifferenceChange {
        fatalError("should be implemented by subclass")
    }
    
    func append(change: Change, isSource: Bool, to changes: inout Differences) {
        changes[keyPath: path(isSource)].append(.change(toChange(change, isSource)))
    }
    
    override func configChangeType() -> ChangeType {
        switch (update?.way, sourceIsEmpty, targetIsEmpty) {
        case (.insert, _, true), (.remove, true, _), (_, true, true): return .none
        case (.remove, _, _), (_, false, true): return .remove(itemsOnly: itemsOnly(true))
        case (.insert, _, _), (_, true, false): return .insert(itemsOnly: itemsOnly(false))
        case (_, false, false): return diffable || hasBatchUpdate ? .batchUpdates : .reload
        }
    }
    
    override func generateListUpdates() -> BatchUpdates? {
        if !sourceIsEmpty || !targetIsEmpty { inferringMoves() }
        return isSectioned ? generateListUpdatesForSections() : generateListUpdatesForItems()
    }
}

extension CollectionCoordinatorUpdate {
    var sourceIsEmpty: Bool { sourceCount == 0 }
    var targetIsEmpty: Bool { targetCount == 0 }
    
    var sourceHasSection: Bool { !sourceIsEmpty || keepSectionIfEmpty.source }
    var targetHasSection: Bool { !targetIsEmpty || keepSectionIfEmpty.target }
    
    var sourceSectionCount: Int { isSectioned ? sourceCount : sourceHasSection ? 1 : 0 }
    var targetSectionCount: Int { isSectioned ? targetCount : targetHasSection ? 1 : 0 }
    
    func itemsOnly(_ isSource: Bool) -> Bool {
        isSectioned && (isSource ? keepSectionIfEmpty.source : keepSectionIfEmpty.target)
    }
    
    func appendBoth(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Differences) {
        changes.source.append(.unchanged(from: from, to: to))
        changes.target.append(.unchanged(from: from, to: to))
    }
    
    func enumerate(
        from: Mapping<Int>,
        to: Mapping<Int>,
        changes: Differences,
        consume: (Mapping<Int>, inout Differences) -> Bool
    ) -> Differences {
        var changes = changes
        var lastSource = from.source, lastTarget = from.target
        for (s, t) in zip(from.source..<to.source, from.target..<to.target) {
            guard consume((s, t), &changes), s > lastSource else { continue }
            appendBoth(from: (lastSource, s), to: (lastTarget, t), to: &changes)
            (lastSource, lastTarget) = (s + 1, t + 1)
        }
        guard lastSource < to.source else { return changes }
        appendBoth(from: (lastSource, to.source), to: (lastTarget, to.target), to: &changes)
        return changes
    }
    
    func configChangesForBatchUpdates() -> Mapping<ContiguousArray<Difference>> {
        var changes: CoordinatorChanges = ([], [])
        changeIndices.source.forEach { changeDict.source[$0].map { changes.source.append($0) } }
        changeIndices.target.forEach { changeDict.target[$0].map { changes.target.append($0) } }
        var result: Mapping<ContiguousArray<Difference>> = (.init(), .init())
        enumerateChangesWithOffset(changes: changes, body: { (isSource, change) in
            append(change: change, isSource: isSource, to: &result)
        }, offset: { (from, to) in
            if updateDict.isEmpty {
                appendBoth(from: from, to: to, to: &result)
            } else {
                result = enumerate(from: from, to: to, changes: result) { (i, changes) -> Bool in
                    guard let (source, value) = updateDict[i.source] else { return false }
                    let target = Change(value, i.target)
                    (source[nil], target[nil]) = (target, source)
                    (source.state, target.state) = (.reload, .reload)
                    
                    append(change: source, isSource: true, to: &changes)
                    append(change: target, isSource: false, to: &changes)
                    return true
                }
            }
        })
        updateSource(with: result)
        return result
    }
    
    func generateListUpdatesForItems() -> BatchUpdates? {
        switch changeType {
        case .insert(false):
            return .init(target: BatchUpdates.SectionTarget(\.inserts, 0), finalChange)
        case .insert(true):
            let indices = [IndexPath](IndexPath(item: 0), IndexPath(item: targetCount))
            return .init(target: BatchUpdates.ItemTarget(\.inserts, indices), finalChange)
        case .remove(false):
            return .init(source: BatchUpdates.SectionSource(\.deletes, 0), finalChange)
        case .remove(true):
            let indices = [IndexPath](IndexPath(item: 0), IndexPath(item: sourceCount))
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
            return .init(target: BatchUpdates.SectionTarget(\.inserts, 0, targetCount), finalChange)
        case .remove:
            return .init(source: BatchUpdates.SectionSource(\.deletes, 0, sourceCount), finalChange)
        case .batchUpdates:
            return listUpdatesForSections()
        case .reload:
            return .reload(change: finalChange)
        case .none:
            return .none
        }
    }
}

extension CollectionCoordinatorUpdate {
    func enumerateChanges(changes: CoordinatorChanges, _ body: (Bool, Change) -> Void) {
        let total: Mapping = (changes.source.count, changes.target.count)
        var enumerated: Mapping = (0, 0)
        
        while enumerated.source < total.source || enumerated.target < total.target {
            let change: Change, isSoure: Bool
            if enumerated.source < total.source && enumerated.target < total.target {
                let removeOffset = changes.source[enumerated.source].index
                let insertOffset = changes.target[enumerated.target].index
                if removeOffset - enumerated.source <= insertOffset - enumerated.target {
                    (isSoure, change) = (true, changes.source[enumerated.source])
                } else {
                    (isSoure, change) = (false, changes.target[enumerated.target])
                }
            } else if enumerated.source < total.source {
                (isSoure, change) = (true, changes.source[enumerated.source])
            } else if enumerated.target < total.target {
                (isSoure, change) = (false, changes.target[enumerated.target])
            } else {
                // Not reached, loop should have exited.
                preconditionFailure()
            }
            
            body(isSoure, change)
            
            isSoure ? (enumerated.source += 1) : (enumerated.target += 1)
        }
    }
    
    func enumerateChangesWithOffset(
        changes: CoordinatorChanges,
        body: (Bool, Change) -> Void,
        offset: (Mapping<Int>, Mapping<Int>) -> Void
    ) {
        var enumerated: Mapping = (0, 0)
        var enumeratedOriginals: Mapping = (0, 0)
        var index: Mapping = (0, 0)
        
        enumerateChanges(changes: changes) { (isSource, change) in
            let current = enumerate(
                change: change,
                in: values[keyPath: path(isSource)],
                index: &index[keyPath: path(isSource)],
                enumeratedOriginals: &enumeratedOriginals[keyPath: path(!isSource)]
            )
            let other = enumerate(
                change: change,
                in: values[keyPath: path(!isSource)],
                index: &index[keyPath: path(!isSource)],
                enumeratedOriginals: &enumeratedOriginals[keyPath: path(isSource)],
                enumeratedCurrent: enumerated[keyPath: path(isSource)],
                enumeratedOther: enumerated[keyPath: path(!isSource)]
            )
            enumerated[keyPath: path(isSource)] += 1
            if current.end != current.start {
                let from = isSource ? (current.start, other.start) : (other.start, current.start)
                let to = isSource ? (current.end, other.end) : (other.end, current.end)
                offset(from, to)
            }
            body(isSource, change)
        }
        
        if index.source < sourceValuesCount {
            offset(index, (sourceValuesCount, targetValuesCount))
        }
    }
    
    func enumerate<Collection: RangeReplaceableCollection>(
        change: Change,
        in value: Collection,
        index: inout Collection.Index,
        enumeratedOriginals: inout Int
    ) -> (start: Collection.Index, end: Collection.Index) {
        let origCount = change.index - enumeratedOriginals
        let start = index
        value.formIndex(&index, offsetBy: origCount)
        enumeratedOriginals += origCount + 1
        defer { index = value.index(after: index) }
        return (start, index)
    }
    
    func enumerate<Collection: RangeReplaceableCollection>(
        change: Change,
        in value: Collection,
        index: inout Collection.Index,
        enumeratedOriginals: inout Int,
        enumeratedCurrent: Int,
        enumeratedOther: Int
    ) -> (start: Collection.Index, end: Collection.Index) {
        let origCount = (change.index + enumeratedOther - enumeratedCurrent) - enumeratedOriginals
        let start = index
        value.formIndex(&index, offsetBy: origCount)
        enumeratedOriginals += origCount
        return (start, index)
    }
}

extension CollectionCoordinatorUpdate
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source == Source {
    func append(_ element: Element) {
        let value = toValue(element)
        changeIndices.target.insert(targetCount)
        changeDict.target[targetCount] = .init(value, targetCount)
        targetValuesCount += 1
        targetCount += toCount(value)
    }
    
    func append<S: Sequence>(contentsOf elements: S) where Element == S.Element {
        var upper = targetCount
        for element in elements {
            let value = toValue(element)
            changeDict.target[upper] = .init(value, upper)
            upper += 1
            targetCount += toCount(value)
        }
        guard upper != targetCount else { return }
        changeIndices.target.insert(integersIn: targetCount..<upper)
        targetValuesCount = upper
    }
    
    func insert(_ element: Element, at index: Int) {
        let value = toValue(element)
        changeIndices.target.insert(index)
        changeDict.target[index] = .init(value, index)
        targetValuesCount += 1
        targetCount += toCount(value)
    }
    
    func insert<C: Collection>(contentsOf elements: C, at index: Int) where Element == C.Element {
        guard !elements.isEmpty else { return }
        var upper = index
        for element in elements {
            let value = toValue(element)
            changeDict.target[upper] = .init(value, upper)
            upper += 1
            targetCount += toCount(value)
        }
        changeIndices.target.insert(integersIn: index..<upper)
        targetValuesCount = upper
    }
    
    func remove(at index: Int) {
        changeIndices.source.insert(index)
        changeDict.source[index] = .init(values.source[index], index)
        targetValuesCount -= 1
        targetCount -= toCount(values.source[index])
    }
    
    func update(_ element: Element, at index: Int) {
        let sourceChange = Change(values.source[index], index)
        updateDict[index] = (sourceChange, toValue(element))
    }
    
    func move(at index: Int, to newIndex: Int) {
        changeIndices.source.insert(index)
        changeIndices.target.insert(newIndex)
        let sourceChange = Change(values.source[index], index)
        let targetChange = Change(values.source[index], newIndex)
        (sourceChange[nil], targetChange[nil]) = (targetChange, sourceChange)
        (changeDict.source[index], changeDict.target[newIndex]) = (sourceChange, targetChange)
    }
}
