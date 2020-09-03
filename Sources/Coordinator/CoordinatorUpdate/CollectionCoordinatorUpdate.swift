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
    typealias Changes = Mapping<ContiguousArray<Change>>
    typealias Differences = Mapping<ContiguousArray<Difference>>
    
    enum Difference {
        case change(DifferenceChange)
        case unchanged(from: Mapping<Int>, to: Mapping<Int>)
    }
    
    var values: Values
    
    var changeIndices: Mapping<IndexSet> = (.init(), .init())
    var changeDict: Mapping<[Int: Change]> = ([:], [:])
    var updateDict = [Int: (change: Change, value: Value)]()
    
    lazy var changes = hasBatchUpdate ? configChangesForBatchUpdates() : configChangesForDiff()
    
    var shouldConsiderUpdate: Bool { !updateDict.isEmpty }
    
    override var sourceCount: Int { values.source.count }
    override var targetCount: Int { values.target.count }
    
    init(
        _ coordinator: ListCoordinator<SourceBase>? = nil,
        update: ListUpdate<SourceBase>,
        _ values: Values,
        _ sources: Sources,
        _ keepSectionIfEmpty: Mapping<Bool>,
        _ isSectioned: Bool
    ) {
        self.values = values
        super.init(coordinator, update: update, sources: sources, keepSectionIfEmpty, isSectioned)
    }
    
    func toValue(_ element: Element) -> Value { notImplemented() }
    func toSource(_ values: ContiguousArray<Value>) -> SourceBase.Source? { notImplemented() }
    func configChangesForDiff() -> Differences { notImplemented() }
    
    func append(change: Change, isSource: Bool, to changes: inout Differences) { notImplemented() }
    func append(change: DifferenceChange, into values: inout ContiguousArray<Value>) {
        notImplemented()
    }
    
    func canConfigUpdateAt(
        index: Mapping<Int>,
        last: Mapping<Int>,
        into changes: inout Differences
    ) -> Bool {
        guard let (source, value) = updateDict[index.source] else { return false }
        appendUnchanged(index: index, last: last, to: &changes)
        let target = Change(value, index.target)
        (source[nil], target[nil]) = (target, source)
        (source.state, target.state) = (.reload, .reload)
        
        append(change: source, isSource: true, to: &changes)
        append(change: target, isSource: false, to: &changes)
        return true
    }
    
    override func prepareData() {
        guard shouldPrepareData else { return }
        var valuesAfter = ContiguousArray<Value>(capacity: values.source.count)
        for update in changes.target {
            switch update {
            case let .change(differenceChange):
                append(change: differenceChange, into: &valuesAfter)
            case let .unchanged(from: from, to: to):
                valuesAfter.append(contentsOf: values.source[from.source..<to.source])
            }
        }
        (sources.target, values.target) = (toSource(valuesAfter), valuesAfter)
    }
}

extension CollectionCoordinatorUpdate {
    var shouldPrepareData: Bool {
        guard hasBatchUpdate else { return false }
        return !changes.source.isEmpty || !changes.target.isEmpty || shouldConsiderUpdate
    }
    
    func append(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Differences) {
        changes.source.append(.unchanged(from: from, to: to))
        changes.target.append(.unchanged(from: from, to: to))
    }
    
    func appendUnchanged(index: Mapping<Int>, last: Mapping<Int>, to changes: inout Differences) {
        if index.source > last.source { append(from: last, to: index, to: &changes) }
    }
    
    func enumerateUnchanged(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Differences) {
        var last = from
        for index in zip(from.source..<to.source, from.target..<to.target) {
            guard canConfigUpdateAt(index: index, last: last, into: &changes) else { continue }
            (last.source, last.target) = (index.0 + 1, index.1 + 1)
        }
        if last.source < to.source { append(from: last, to: to, to: &changes) }
    }
    
    func configChangesForBatchUpdates() -> Differences {
        var changes: Changes = (.init(), .init()), result: Differences = (.init(), .init())
        changeIndices.source.forEach { changeDict.source[$0].map { changes.source.append($0) } }
        changeIndices.target.forEach { changeDict.target[$0].map { changes.target.append($0) } }
        enumerateChangesWithOffset(changes: changes, body: { (isSource, change) in
            append(change: change, isSource: isSource, to: &result)
        }, offset: { (from, to) in
            if shouldConsiderUpdate {
                enumerateUnchanged(from: from, to: to, to: &result)
            } else {
                append(from: from, to: to, to: &result)
            }
        })
        return result
    }
}

extension CollectionCoordinatorUpdate {
    func enumerateChanges(changes: Changes, _ body: (Bool, Change) -> Void) {
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
        changes: Changes,
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
        
        let remaining = values.source.count - index.source
        guard remaining > 0 else { return }
        offset(index, (index.source + remaining, index.target + remaining))
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

extension CollectionCoordinatorUpdate {
    func append(_ element: Element) {
        let value = toValue(element)
        changeIndices.target.insert(targetCount)
        changeDict.target[targetCount] = .init(value, targetCount)
    }
    
    func append<S: Sequence>(contentsOf elements: S) where Element == S.Element {
        var upper = targetCount
        for element in elements {
            let value = toValue(element)
            changeDict.target[upper] = .init(value, upper)
            upper += 1
        }
        guard upper != targetCount else { return }
        changeIndices.target.insert(integersIn: targetCount..<upper)
    }
    
    func insert(_ element: Element, at index: Int) {
        let value = toValue(element)
        changeIndices.target.insert(index)
        changeDict.target[index] = .init(value, index)
    }
    
    func insert<C: Collection>(contentsOf elements: C, at index: Int) where Element == C.Element {
        guard !elements.isEmpty else { return }
        var upper = index
        for element in elements {
            let value = toValue(element)
            changeDict.target[upper] = .init(value, upper)
            upper += 1
        }
        changeIndices.target.insert(integersIn: index..<upper)
    }
    
    func remove(at index: Int) {
        changeIndices.source.insert(index)
        changeDict.source[index] = .init(values.source[index], index)
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
