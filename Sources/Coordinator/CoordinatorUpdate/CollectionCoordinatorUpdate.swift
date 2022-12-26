//
//  CollectionCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/5.
//

// swiftlint:disable opening_brace

import Foundation

//class CollectionCoordinatorUpdate<SourceBase, Source, Value, Change, DifferenceChange>: ListCoordinatorUpdate<SourceBase>
//where
//    SourceBase: DataSource,
//    SourceBase.SourceBase == SourceBase,
//    Source: Collection,
//    Change: CoordinatorUpdate.Change<Value>
//{
//    typealias Element = Source.Element
//    typealias Values = ContiguousArray<Value>
//    typealias Changes = Mapping<ContiguousArray<Change>>
//    typealias Difference = CoordinatorUpdate.Difference<DifferenceChange>
//    typealias Differences = Mapping<ContiguousArray<Difference>>
//
//    let sourceValues: Values
//
//    lazy var targetValues = configTargetValues()
//    lazy var differences = configDifferences()
//    lazy var diffs = configDiffs()
//    lazy var changes = configChanges()
//    lazy var uniqueMapping = configUniqueMapping()
//    lazy var uniqueDict = configUniqueDict()
//
//    lazy var appendValues = Values()
//    lazy var changeIndices: Mapping<IndexSet> = (.init(), .init())
//    lazy var changeDict: Mapping<[Int: Change]> = ([:], [:])
//    lazy var updateDict = [Int: (change: Change, value: Value)]()
//
//    var equatable: Bool { false }
//    var identifiable: Bool { false }
//    var shouldConsiderUpdate: Bool { !updateDict.isEmpty }
//
//    init(
//        _ coordinator: ListCoordinator<SourceBase>,
//        update: ListUpdate<SourceBase>?,
//        values: Mapping<Values>,
//        sources: Sources,
//        options: Options
//    ) {
//        self.sourceValues = values.source
//        super.init(coordinator, update: update, sources: sources, options: options)
//        if !isBatchUpdate { self.targetValues = values.target }
//    }
//
//    func isEqual(lhs: Value, rhs: Value) -> Bool { notImplemented() }
//    func identifier(for value: Value) -> AnyHashable { notImplemented() }
//    func isDiffEqual(lhs: Value, rhs: Value) -> Bool { notImplemented() }
//    func associateChange(_ mapping: Mapping<Change>, ids: Mapping<[AnyHashable]>) { }
//
//    func toValue(_ element: Element) -> Value { notImplemented() }
//    func toCount(_ value: Value) -> Int { 1 }
//    func toChange(_ value: Value, _ index: Int) -> Change { notImplemented() }
//    func toSource(_ values: ContiguousArray<Value>) -> SourceBase.Source? { notImplemented() }
//
//    func add(change: Change, isSource: Bool, to differences: inout Differences) { notImplemented() }
//
//    func canConfig(at index: Mapping<Int>) -> Bool { updateDict[index.source] != nil }
//    func configUpdate(at index: Mapping<Int>, into differences: inout Differences) {
//        guard let (source, value) = updateDict[index.source] else { fatalError() }
//        let target = toChange(value, index.target)
//        (source[[]], target[[]]) = (.init(change: target), .init(change: source))
//        (source.state, target.state) = (.reload, .reload)
//
//        add(change: source, isSource: true, to: &differences)
//        add(change: target, isSource: false, to: &differences)
//    }
//
//    func configTargetValues() -> Values {
//        enumerateChangesForTarget(offset: { (from, to, source, target) in
//            target.append(contentsOf: source[from..<to])
//        }, append: { $1.append($0) })
//    }
//
//    func configChangesForDiffs() -> Changes {
//        func convert(values: Values) -> ContiguousArray<Change> {
//            var index = 0
//            return values.mapContiguous {
//                defer { index += 1 }
//                return toChange($0, index)
//            }
//        }
//
//        if isRemove { return (convert(values: sourceValues), .init()) }
//        if isInsert { return (.init(), convert(values: targetValues)) }
//
//        switch changeType {
//        case .none, .other(.reload): return (.init(), .init())
//        case .other(.remove): return (convert(values: sourceValues), .init())
//        case .other(.insert): return (.init(), convert(values: targetValues))
//        default: break
//        }
//
//        let sourceChange = diffs.removals.mapContiguous { toChange($0._element, $0._offset) }
//        let targetChange = diffs.insertions.mapContiguous { toChange($0._element, $0._offset) }
//        return (sourceChange, targetChange)
//    }
//
//    override func configTarget() -> SourceBase.Source? { toSource(targetValues) }
//}
//
//extension CollectionCoordinatorUpdate {
//    func append(from: Mapping<Int>, to: Mapping<Int>, to changes: inout Differences) {
//        guard to.source > from.source else { return }
//        changes.source.append(.unchanged(from: from, to: to))
//        changes.target.append(.unchanged(from: from, to: to))
//    }
//
//    func enumerateUnchanged(from: Mapping<Int>, to: Mapping<Int>, to diffs: inout Differences) {
//        var last = from
//        for index in zip(from.source..<to.source, from.target..<to.target) where canConfig(at: index) {
//            append(from: last, to: index, to: &diffs)
//            configUpdate(at: index, into: &diffs)
//            (last.source, last.target) = (index.0 + 1, index.1 + 1)
//        }
//        append(from: last, to: to, to: &diffs)
//    }
//
//    func configChanges() -> Changes {
//        guard isBatchUpdate else { return configChangesForDiffs() }
//        let count: Mapping<Int> = (changeDict.source.count, changeDict.target.count)
//        var changes: Changes = (.init(capacity: count.source), .init(capacity: count.target))
//        changeIndices.source.forEach { changeDict.source[$0].map { changes.source.append($0) } }
//        changeIndices.target.forEach { changeDict.target[$0].map { changes.target.append($0) } }
//        var targetCount = sourceValues.count - changes.source.count + changes.target.count
//        for value in appendValues {
//            changes.target.append(toChange(value, targetCount))
//            targetCount += 1
//        }
//        return changes
//    }
//
//    func configUniqueDict() -> Mapping<Uniques<Change>> {
//        let source = Uniques<Change>(minimumCapacity: changes.source.count)
//        let target = Uniques<Change>(minimumCapacity: changes.target.count)
//        var result: Mapping<Uniques<Change>> = (source, target)
//        changes.source.forEach { add($0, id: identifier(for: $0.value), to: &result.source) }
//        changes.target.forEach { add($0, id: identifier(for: $0.value), to: &result.target) }
//        if identifiable { apply(changes, dict: &result) { $0 } }
//        return result
//    }
//
//    func configDiffs() -> CollectionDifference<Value> {
//        CollectionDifference(from: sourceValues, to: targetValues, by: isDiffEqual)
//    }
//
//    func configUniqueMapping() -> Changes {
//        let source = uniqueDict.source.values.compactMapContiguous { $0?.change }
//        let target = uniqueDict.target.values.compactMapContiguous { $0?.change }
//        return (source, target)
//    }
//
//    func configDifferences() -> Differences {
//        let capacity = sourceValues.count + targetValues.count
//        var result: Differences = (.init(capacity: capacity), .init(capacity: capacity))
//        enumerateChangesWithOffset(body: { (isSource, change) in
//            add(change: change, isSource: isSource, to: &result)
//        }, offset: { (from, to) in
//            if shouldConsiderUpdate {
//                enumerateUnchanged(from: from, to: to, to: &result)
//            } else {
//                append(from: from, to: to, to: &result)
//            }
//        })
//        return result
//    }
//
//    func apply<T, C: Collection>(
//        _ changes: Mapping<C>,
//        dict: inout Mapping<Uniques<T>>,
//        toChange: (T) -> Change?
//    ) where C.Element == Change {
//        func configAssociated(for change: Change) {
//            let key = identifier(for: change.value)
//            let euqal = equatable ? isEqual : nil
//            config(for: change, key, &dict, euqal, associateChange, toChange)
//        }
//
//        changes.source.forEach { configAssociated(for: $0) }
//        changes.target.forEach { configAssociated(for: $0) }
//    }
//}
//
//extension CollectionCoordinatorUpdate {
//    func enumerateChanges(changes: Changes, _ body: (Bool, Change) -> Void) {
//        let total: Mapping = (changes.source.count, changes.target.count)
//        var enumerated: Mapping = (0, 0)
//
//        while enumerated.source < total.source || enumerated.target < total.target {
//            let change: Change, isSoure: Bool
//            if enumerated.source < total.source && enumerated.target < total.target {
//                let removeOffset = changes.source[enumerated.source].index
//                let insertOffset = changes.target[enumerated.target].index
//                if removeOffset - enumerated.source <= insertOffset - enumerated.target {
//                    (isSoure, change) = (true, changes.source[enumerated.source])
//                } else {
//                    (isSoure, change) = (false, changes.target[enumerated.target])
//                }
//            } else if enumerated.source < total.source {
//                (isSoure, change) = (true, changes.source[enumerated.source])
//            } else if enumerated.target < total.target {
//                (isSoure, change) = (false, changes.target[enumerated.target])
//            } else {
//                // Not reached, loop should have exited.
//                preconditionFailure()
//            }
//
//            body(isSoure, change)
//
//            isSoure ? (enumerated.source += 1) : (enumerated.target += 1)
//        }
//    }
//
//    func enumerateChangesWithOffset(
//        body: (Bool, Change) -> Void,
//        offset: (Mapping<Int>, Mapping<Int>) -> Void
//    ) {
//        var enumeratedChanges: Mapping = (0, 0)
//        var enumeratedOriginals: Mapping = (0, 0)
//        var index: Mapping = (0, 0)
//
//        enumerateChanges(changes: changes) { (isSource, change) in
//            let current = enumerate(
//                change: change,
//                in: isSource ? sourceValues : targetValues,
//                index: &index[keyPath: path(isSource)],
//                enumeratedOriginals: &enumeratedOriginals[keyPath: path(!isSource)]
//            )
//            let other = enumerate(
//                change: change,
//                in: isSource ? targetValues : sourceValues,
//                index: &index[keyPath: path(!isSource)],
//                enumeratedOriginals: &enumeratedOriginals[keyPath: path(isSource)],
//                enumeratedCurrent: enumeratedChanges[keyPath: path(isSource)],
//                enumeratedOther: enumeratedChanges[keyPath: path(!isSource)]
//            )
//            enumeratedChanges[keyPath: path(isSource)] += 1
//            if current.end != current.start {
//                let from = isSource ? (current.start, other.start) : (other.start, current.start)
//                let to = isSource ? (current.end, other.end) : (other.end, current.end)
//                offset(from, to)
//            }
//            body(isSource, change)
//        }
//
//        let remaining = sourceValues.count - index.source
//        guard remaining > 0, targetValues.count > index.target else { return }
//        offset(index, (index.source + remaining, index.target + remaining))
//    }
//
//    func enumerateChangesForTarget(
//        offset: (Int, Int, Values, inout Values) -> Void,
//        append: (Value, inout Values) -> Void
//    ) -> Values {
//        var target = Values(capacity: sourceValues.count)
//        var enumeratedOriginals = 0, currentIndex = 0
//        var enumeratedChanges: Mapping = (0, 0)
//        enumerateChanges(changes: changes) { (isSource, change) in
//            if isSource {
//                let (from, to) = enumerate(
//                    change: change,
//                    in: sourceValues,
//                    index: &currentIndex,
//                    enumeratedOriginals: &enumeratedOriginals
//                )
//                if to > from { offset(from, to, sourceValues, &target) }
//                enumeratedChanges.source += 1
//            } else {
//                let (from, to) = enumerate(
//                    change: change,
//                    in: sourceValues,
//                    index: &currentIndex,
//                    enumeratedOriginals: &enumeratedOriginals,
//                    enumeratedCurrent: enumeratedChanges.target,
//                    enumeratedOther: enumeratedChanges.source
//                )
//                if to > from { offset(from, to, sourceValues, &target) }
//                append(change.value, &target)
//                enumeratedChanges.target += 1
//            }
//        }
//        if currentIndex < sourceValues.endIndex {
//            offset(currentIndex, sourceValues.endIndex, sourceValues, &target)
//        }
//
//        return target
//    }
//
//    func enumerate<Collection: RangeReplaceableCollection>(
//        change: Change,
//        in value: Collection,
//        index: inout Collection.Index,
//        enumeratedOriginals: inout Int
//    ) -> (start: Collection.Index, end: Collection.Index) {
//        let origCount = change.index - enumeratedOriginals
//        let start = index
//        value.formIndex(&index, offsetBy: origCount)
//        enumeratedOriginals += origCount + 1
//        defer { index = value.index(after: index) }
//        return (start, index)
//    }
//
//    // swiftlint:disable function_parameter_count
//    func enumerate<Collection: RangeReplaceableCollection>(
//        change: Change,
//        in value: Collection,
//        index: inout Collection.Index,
//        enumeratedOriginals: inout Int,
//        enumeratedCurrent: Int,
//        enumeratedOther: Int
//    ) -> (start: Collection.Index, end: Collection.Index) {
//        let origCount = (change.index + enumeratedOther - enumeratedCurrent) - enumeratedOriginals
//        let start = index
//        value.formIndex(&index, offsetBy: origCount)
//        enumeratedOriginals += origCount
//        return (start, index)
//    }
//    // swiftlint:enable function_parameter_count
//}
//
//extension CollectionCoordinatorUpdate {
//    func insertElement(_ element: Element, at index: Int) {
//        let value = toValue(element)
//        changeIndices.target.insert(index)
//        changeDict.target[index] = toChange(value, index)
//    }
//
//    func insertElements<C: Collection>(contentsOf elements: C, at index: Int) where Element == C.Element {
//        guard !elements.isEmpty else { return }
//        var upper = index
//        for element in elements {
//            let value = toValue(element)
//            changeDict.target[upper] = toChange(value, upper)
//            upper += 1
//        }
//        changeIndices.target.insert(integersIn: index..<upper)
//    }
//
//    func appendElement(_ element: Element) {
//        appendValues.append(toValue(element))
//    }
//
//    func appendElements<S: Sequence>(contentsOf elements: S) where Element == S.Element {
//        appendValues.append(contentsOf: elements.map(toValue))
//    }
//
//    func removeElement(at index: Int) {
//        changeIndices.source.insert(index)
//        changeDict.source[index] = toChange(sourceValues[index], index)
//    }
//
//    func removeElements(at indexSet: IndexSet) {
//        changeIndices.source.formUnion(indexSet)
//        indexSet.forEach { changeDict.source[$0] = toChange(sourceValues[$0], $0) }
//    }
//
//    func updateElement(_ element: Element, at index: Int) {
//        let sourceChange = toChange(sourceValues[index], index)
//        updateDict[index] = (sourceChange, toValue(element))
//    }
//
//    func moveElement(at index: Int, to newIndex: Int) {
//        changeIndices.source.insert(index)
//        changeIndices.target.insert(newIndex)
//        let source = toChange(sourceValues[index], index)
//        let target = toChange(sourceValues[index], newIndex)
//        (source[[]], target[[]]) = (.init(change: target), .init(change: source))
//        (changeDict.source[index], changeDict.target[newIndex]) = (source, target)
//    }
//}
