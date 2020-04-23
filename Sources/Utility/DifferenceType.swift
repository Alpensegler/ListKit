//
//  DifferenceType.swift
//  ListKit
//
//  Created by Frain on 2020/2/28.
//

protocol DifferenceType { }

class Difference<Index: Equatable>: DifferenceType {
    var insertions: [Change<Index>] { fatalError() }
    var removals: [Change<Index>] { fatalError() }
    var isEmpty: Bool { true }
}

class CacheDifference<Cache, Index: Equatable>: Difference<Index> {
    var insertionsChange: [DiffChange<Cache, Index>] { fatalError() }
    var removalsChange: [DiffChange<Cache, Index>] { fatalError() }
    
    override var insertions: [Change<Index>] { insertionsChange }
    override var removals: [Change<Index>] { removalsChange }
    
    func add(to
        uniqueRemovals: inout [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: inout [AnyHashable: DiffChange<Cache, Index>?]
    ) { }
    
    func applying(
        uniqueRemovals: [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: [AnyHashable: DiffChange<Cache, Index>?]
    ) { }
    
    func toItemDifference() -> Difference<Path> { fatalError() }
}

class ValueDifference<Value, Cache, Index: Equatable>: CacheDifference<Cache, Index> {
    override var insertionsChange: [DiffChange<Cache, Index>] { insertionValues }
    override var removalsChange: [DiffChange<Cache, Index>] { removalValues }

    var insertionValues: [ValueChange<Value, Cache, Index>]
    var removalValues: [ValueChange<Value, Cache, Index>]
    
    var source: [DiffableValue<Value, Cache>]
    var target: [DiffableValue<Value, Cache>]
    var differ: Differ<Value>?
    
    var applying: ((ValueDifference<Value, Cache, Index>) -> Void)?
    var starting: (() -> Void)?
    var ending: (() -> Void)?
    var finish: (() -> Void)?
    
    override func add(to
        uniqueRemovals: inout [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: inout [AnyHashable: DiffChange<Cache, Index>?]
    ) {
        for removal in removalValues {
            guard let id = removal.value.id else { continue }
            if case .none = uniqueRemovals[id] {
                uniqueRemovals[id] = .some(removal)
            } else {
                uniqueRemovals[id] = .some(.none)
            }
        }
        
        for insertion in insertionValues {
            guard let id = insertion.value.id else { continue }
            if case .none = uniqueRemovals[id] {
                uniqueRemovals[id] = .some(insertion)
            } else {
                uniqueRemovals[id] = .some(.none)
            }
        }
    }
    
    override func applying(
        uniqueRemovals: [AnyHashable: DiffChange<Cache, Index>?],
        uniqueInsertions: [AnyHashable: DiffChange<Cache, Index>?]
    ) {
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
        guard let id = change.value.id, uniques[id] != nil else { return nil }
        return assocUniques[id] as? ValueChange<Value, Cache, Index>
    }

    init(
        source: [DiffableValue<Value, Cache>],
        target: [DiffableValue<Value, Cache>],
        insertionValues: [ValueChange<Value, Cache, Index>],
        removalValues: [ValueChange<Value, Cache, Index>],
        differ: Differ<Value>?
    ) {
        self.source = source
        self.target = target
        self.insertionValues = insertionValues
        self.removalValues = removalValues
        self.differ = differ
        super.init()
    }
}

typealias ItemCacheDifference = CacheDifference<ItemRelatedCache, Path>

class ItemValueDifference<Value>: ValueDifference<Value, ItemRelatedCache, Path> {
    init(
        source: [DiffableValue<Value, ItemRelatedCache>],
        target: [DiffableValue<Value, ItemRelatedCache>],
        differ: Differ<Value>? = nil,
        insertOffset: Path = .init(),
        deleteOffsey: Path = .init()
    ) {
        let diffs = target.diff(from: source) { $0.isDiffEqual(with: $1, differ: differ) }
        super.init(
            source: source,
            target: target,
            insertionValues: diffs.map {
                .init($0._element, differ: differ, index: insertOffset.adding($0._offset))
            },
            removalValues: diffs.map {
                .init($0._element, differ: differ, index: insertOffset.adding($0._offset))
            },
            differ: differ
        )
    }
}

extension ValueDifference where Index == Int {
    convenience init(
        source: [DiffableValue<Value, Cache>],
        target: [DiffableValue<Value, Cache>],
        differ: Differ<Value>? = nil
    ) {
        let diffs = target.diff(from: source) { $0.isDiffEqual(with: $1, differ: differ) }
        self.init(
            source: source,
            target: target,
            insertionValues: diffs.map { .init($0._element, differ: differ, index: $0._offset) },
            removalValues: diffs.map { .init($0._element, differ: differ, index: $0._offset)  },
            differ: differ
        )
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
