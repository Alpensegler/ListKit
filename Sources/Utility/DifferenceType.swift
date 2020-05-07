//
//  DifferenceType.swift
//  ListKit
//
//  Created by Frain on 2020/2/28.
//

import Foundation

protocol DifferenceType { }

class Difference<Index: Equatable>: DifferenceType {
    var insertions: [Change<Index>] { fatalError() }
    var removals: [Change<Index>] { fatalError() }
    var isEmpty: Bool { true }
}

class CacheDifference<Cache, Index: Equatable>: Difference<Index> {
    var insertionsChange: [DiffChange<Cache, Index>] { fatalError() }
    var removalsChange: [DiffChange<Cache, Index>] { fatalError() }
    
    var source: [Diffable<Cache>] { fatalError() }
    var target: [Diffable<Cache>] { fatalError() }
    
    override var insertions: [Change<Index>] { insertionsChange }
    override var removals: [Change<Index>] { removalsChange }
    
    func addTo(
        uniqueRemovals: inout [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: inout [AnyHashable: DiffChange<Cache, Index>?]
    ) { }
    
    func applying(
        uniqueRemovals: [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: [AnyHashable: DiffChange<Cache, Index>?]
    ) { }
    
    func toItemDifference() -> Difference<IndexPath> { fatalError() }
}

class ValueDifference<Value, Cache, Index: Equatable>: CacheDifference<Cache, Index> {
    override var insertionsChange: [DiffChange<Cache, Index>] { insertionValues }
    override var removalsChange: [DiffChange<Cache, Index>] { removalValues }
    override var source: [Diffable<Cache>] { sourceValue }
    override var target: [Diffable<Cache>] { targetValue }
    
    var insertionValues: [ValueChange<Value, Cache, Index>]
    var removalValues: [ValueChange<Value, Cache, Index>]
    
    var sourceValue: [DiffableValue<Value, Cache>]
    var targetValue: [DiffableValue<Value, Cache>]
    var differ: Differ<Value>?
    
    var applying: ((ValueDifference<Value, Cache, Index>) -> Void)?
    var starting: (() -> Void)?
    var ending: (() -> Void)?
    var finish: (() -> Void)?
    
    override func addTo(
        uniqueRemovals: inout [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: inout [AnyHashable: DiffChange<Cache, Index>?]
    ) {
        guard applying != nil else { return }
        for removal in removalValues {
            if case .none = uniqueRemovals[removal.cache] {
                uniqueRemovals[removal.cache] = .some(removal)
            } else {
                uniqueRemovals[removal.cache] = .some(.none)
            }
        }
        
        for insertion in insertionValues {
            if case .none = uniqueRemovals[insertion.cache] {
                uniqueRemovals[insertion.cache] = .some(insertion)
            } else {
                uniqueRemovals[insertion.cache] = .some(.none)
            }
        }
    }
    
    override func applying(
        uniqueRemovals: [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: [AnyHashable: DiffChange<Cache, Index>?]
    ) {
        guard applying != nil else { return }
        for removal in removalValues {
            guard let assoc = associated(for: removal, uniqueRemovals, uniqueInsertions) else {
                continue
            }
            removal.valueAssociated = assoc
        }
        
        for insertion in insertionValues {
            guard let assoc = associated(for: insertion, uniqueInsertions, uniqueRemovals) else {
                continue
            }
            insertion.valueAssociated = assoc
        }
    }
    
    func associated(
        for change: ValueChange<Value, Cache, Index>,
        _ uniques: [AnyHashable: DiffChange<Cache, Index>?],
        _ assocUniques: [AnyHashable: DiffChange<Cache, Index>?]
    ) -> ValueChange<Value, Cache, Index>? {
        guard uniques[change.cache] != nil else { return nil }
        return assocUniques[change.cache] as? ValueChange<Value, Cache, Index>
    }

    init(
        source: [DiffableValue<Value, Cache>],
        target: [DiffableValue<Value, Cache>],
        insertionValues: [ValueChange<Value, Cache, Index>],
        removalValues: [ValueChange<Value, Cache, Index>],
        differ: Differ<Value>?
    ) {
        self.sourceValue = source
        self.targetValue = target
        self.insertionValues = insertionValues
        self.removalValues = removalValues
        self.differ = differ
        super.init()
    }
}

typealias ItemCacheDifference = CacheDifference<ItemRelatedCache, IndexPath>

class ItemValueDifference<Value>: ValueDifference<Value, ItemRelatedCache, IndexPath> {
    init(
        source: [DiffableValue<Value, ItemRelatedCache>],
        target: [DiffableValue<Value, ItemRelatedCache>],
        differ: Differ<Value>? = nil,
        insertOffset: IndexPath = .init(),
        deleteOffsey: IndexPath = .init()
    ) {
        let diffs = target.diff(from: source) { $0.isDiffEqual(with: $1, differ: differ) }
        super.init(
            source: source,
            target: target,
            insertionValues: diffs.map {
                .init($0._element, differ: differ, index: insertOffset.adding(item: $0._offset))
            },
            removalValues: diffs.map {
                .init($0._element, differ: differ, index: insertOffset.adding(item: $0._offset))
            },
            differ: differ
        )
    }
}

typealias DataSourceDifference = CacheDifference<Coordinator, [Int]>

enum Values {
    case value(Diffable<Coordinator>, DiffChange<Coordinator, [Int]>?? = nil)
    case values([Values], DiffChange<Coordinator, [Int]>? = nil)
    
    mutating func set(value newValue: Values, at indexPath: [Int]) {
        guard case .values(var values, let change) = self else { fatalError() }
        values.set(value: newValue, at: indexPath)
        self = .values(values, change)
    }
}

class DataSourceValueDifference<Value>: ValueDifference<Value, Coordinator, [Int]> {
    var sourceCoordinator: Coordinator
    var targetCoordinator: Coordinator
    
    init(
        sourceCoordinator: Coordinator,
        targetCoordinator: Coordinator,
        sourcePaths: [Int],
        targetPaths: [Int],
        source: [DiffableValue<Value, Coordinator>],
        target: [DiffableValue<Value, Coordinator>]
    ) {
        self.sourceCoordinator = sourceCoordinator
        self.targetCoordinator = targetCoordinator
        let diffs = target.diff(from: source) { $0.isDiffEqual(with: $1, differ: nil) }
        super.init(
            source: source,
            target: target,
            insertionValues: diffs.map {
                .init($0._element, differ: nil, index: targetPaths + [$0._offset])
            },
            removalValues: diffs.map {
                .init($0._element, differ: nil, index: sourcePaths + [$0._offset])
            },
            differ: nil
        )
    }
    
    func generateValues() -> ([Values], [Values]) {
        var uniqueRemovals = [AnyHashable: DiffChange<Coordinator, [Int]>?]()
        var uniqueInsertions = [AnyHashable: DiffChange<Coordinator, [Int]>?]()
        var (unhandledSource, unhandledTarget) = ([[Int]](), [[Int]]())
        var unhandledMoved = [AnyHashable: (DiffChange<Coordinator, [Int]>, DiffChange<Coordinator, [Int]>)]()
        
        addTo(uniqueRemovals: &uniqueRemovals, uniqueInsertions: &uniqueInsertions)
        applying(uniqueRemovals: uniqueRemovals, uniqueInsertions: uniqueInsertions)
        
        func values(difference: DataSourceDifference, index: [Int], isSource: Bool) -> [Values] {
            var enumerated = 0
            let values = isSource ? difference.removalsChange : difference.insertionsChange
            return (isSource ? difference.source : difference.target).enumerated().map { arg in
                if enumerated < values.count,
                arg.offset == values[enumerated].index.nonNilLast {
                    let change = values[enumerated]
                    let associated = change.diffAssociated
                    enumerated += 1
                    if let associated = associated {
                        unhandledMoved[change.cache] = isSource
                            ? (change, associated)
                            : (associated, change)
                    }
                    return .value(arg.element, .some(associated))
                } else {
                    if arg.element.cache.multiType == .sources {
                        isSource
                            ? unhandledSource.append(index + [arg.offset])
                            : unhandledTarget.append(index + [arg.offset])
                    }
                    return .value(arg.element)
                }
            }
        }
        
        var sourceValues = values(difference: self, index: [], isSource: true)
        var targetValues = values(difference: self, index: [], isSource: false)
        
        func handleSubdifferences() {
            let unhandled = zip(unhandledSource, unhandledTarget)
            var operations = [() -> Void]()
            unhandledSource.removeAll()
            unhandledTarget.removeAll()
            
            func handle(
                sourceIndex: [Int],
                targetIndex: [Int],
                sourceChange: DiffChange<Coordinator, [Int]>? = nil,
                targetChange: DiffChange<Coordinator, [Int]>? = nil
            ) {
                guard case let .value(sourceValue, nil)? = sourceValues[safe: sourceIndex],
                    case let .value(targetValue, nil)? = targetValues[safe: targetIndex]
                else {
                    fatalError()
                }
                let difference = targetValue.cache.sourceDifference(
                    sourceOffset: sourceCoordinator[sourceIndex],
                    targetOffset: targetCoordinator[targetIndex],
                    sourcePaths: sourceIndex,
                    targetPaths: targetIndex,
                    from: sourceValue.cache
                )
                
                difference.addTo(uniqueRemovals: &uniqueRemovals, uniqueInsertions: &uniqueInsertions)
                
                operations.append {
                    difference.applying(uniqueRemovals: uniqueRemovals, uniqueInsertions: uniqueInsertions)
                    let source = values(difference: difference, index: sourceIndex, isSource: true)
                    let target = values(difference: difference, index: targetIndex, isSource: false)
                    sourceValues.set(value: .values(source, sourceChange), at: sourceIndex)
                    targetValues.set(value: .values(target, targetChange), at: sourceIndex)
                }
            }
            
            for (sourceIndex, targetIndex) in unhandled {
                handle(sourceIndex: sourceIndex, targetIndex: targetIndex)
            }
            
            let moves = unhandledMoved
            unhandledMoved.removeAll()
            for ((sourceChange, targetChange)) in moves.values {
                handle(
                    sourceIndex: sourceChange.index,
                    targetIndex: targetChange.index,
                    sourceChange: sourceChange,
                    targetChange: targetChange
                )
            }
            
            operations.forEach { $0() }
        }
        
        while !unhandledSource.isEmpty || !unhandledTarget.isEmpty || !unhandledMoved.isEmpty {
            handleSubdifferences()
        }
        
        return (sourceValues, targetValues)
    }
}

extension RangeReplaceableCollection {
    mutating func apply<Cache, Value, Index>(
        _ difference: ValueDifference<Value, Cache, Index>,
        indexTransform: (Index) -> Int,
        valueTransform: (ValueChange<Value, Cache, Index>) -> Element
    ) {
        _apply(
            difference,
            insertion: \.insertionValues,
            removals: \.removalValues,
            indexTransform: indexTransform
        ) { valueTransform($0.valueAssociated ?? $0) }
    }
    
    mutating func apply<Cache, Index>(
        _ difference: CacheDifference<Cache, Index>,
        indexTransform: (Index) -> Int,
        valueTransform: (DiffChange<Cache, Index>) -> Element
    ) {
        _apply(
            difference,
            insertion: \.insertionsChange,
            removals: \.removalsChange,
            indexTransform: indexTransform
        ) { valueTransform($0.diffAssociated ?? $0) }
    }
}

fileprivate extension DifferenceType {
    func _fastEnumeratedApply<Cache, Index, Change: DiffChange<Cache, Index>>(
        insertion: KeyPath<Self, [Change]>,
        removals: KeyPath<Self, [Change]>,
        indexTransform: (Index) -> Int,
        _ consume: (Bool, Change) -> Void
    ) {
        let removals = self[keyPath: removals]
        let insertions = self[keyPath: insertion]
        
        let totalRemoves = removals.count
        let totalInserts = insertions.count
        var enumeratedRemoves = 0
        var enumeratedInserts = 0

        while enumeratedRemoves < totalRemoves || enumeratedInserts < totalInserts {
            let (isInsert, change): (Bool, Change)
            if enumeratedRemoves < removals.count && enumeratedInserts < insertions.count {
                let removeOffset = indexTransform(removals[enumeratedRemoves].index)
                let insertOffset = indexTransform(insertions[enumeratedInserts].index)
                if (removeOffset) - enumeratedRemoves <= insertOffset - enumeratedInserts {
                    (isInsert, change) = (false, removals[enumeratedRemoves])
                } else {
                    (isInsert, change) = (true, insertions[enumeratedInserts])
                }
            } else if enumeratedRemoves < totalRemoves {
                (isInsert, change) = (false, removals[enumeratedRemoves])
            } else if enumeratedInserts < totalInserts {
                (isInsert, change) = (true, insertions[enumeratedInserts])
            } else {
                // Not reached, loop should have exited.
                preconditionFailure()
            }

            consume(isInsert, change)
            
            if isInsert {
                enumeratedInserts += 1
            } else {
                enumeratedRemoves += 1
            }
        }
    }
}

fileprivate extension RangeReplaceableCollection {
    mutating func _apply<Cache, Index, Change: DiffChange<Cache, Index>, Difference: DifferenceType>(
        _ difference: Difference,
        insertion: KeyPath<Difference, [Change]>,
        removals: KeyPath<Difference, [Change]>,
        indexTransform: (Index) -> Int,
        valueTransform: (Change) -> Element
    ) {
        var result = Self()
        var enumeratedRemoves = 0
        var enumeratedInserts = 0
        var enumeratedOriginals = 0
        var currentIndex = self.startIndex
        
        func append(
            into target: inout Self,
            contentsOf source: Self,
            from index: inout Self.Index, count: Int
        ) {
            let start = index
            source.formIndex(&index, offsetBy: count)
            target.append(contentsOf: source[start..<index])
        }
        
        difference._fastEnumeratedApply(
            insertion: insertion,
            removals: removals,
            indexTransform: indexTransform
        ) { (isInsert, change) in
            if isInsert {
                let origCount = (indexTransform(change.index) + enumeratedRemoves - enumeratedInserts) - enumeratedOriginals
                append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
                result.append(valueTransform(change))
                enumeratedOriginals += origCount
                enumeratedInserts += 1
            } else {
                let origCount = indexTransform(change.index) - enumeratedOriginals
                append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
                enumeratedOriginals += origCount + 1 // Removal consumes an original element
                currentIndex = index(after: currentIndex)
                enumeratedRemoves += 1
            }
        }
        let origCount = count - enumeratedOriginals
        append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
        
        self = result
    }
}

fileprivate extension Array where Element == Values {
    subscript(safe indexPath: [Int]) -> Values? {
        var values = self
        for (offset, index) in indexPath.enumerated() {
            guard let value = values[safe: index] else { return nil }
            switch value {
            case .value where offset == indexPath.count - 1:
                return value
            case let .values(subvalues):
                values = subvalues.0
                continue
            default:
                return nil
            }
        }
        return nil
    }
    
    mutating func set(value newValue: Values, at indexPath: [Int]) {
        var indexPath = indexPath
        let index = indexPath.remove(at: 0)
        if indexPath.isEmpty {
            self[index] = newValue
        }
        self[index].set(value: newValue, at: indexPath)
    }
}

fileprivate extension Coordinator {
    subscript(indexPath: [Int]) -> IndexPath {
        var coordinator: Coordinator = self
        for (offset, index) in indexPath.enumerated() {
            if offset == indexPath.count - 1 { return coordinator.subsourceOffset(at: index) }
            coordinator = coordinator.subsource(at: index)
        }
        return coordinator.subsourceOffset(at: indexPath.nonNilLast)
    }
}
