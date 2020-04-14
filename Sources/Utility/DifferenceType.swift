//
//  DifferenceType.swift
//  ListKit
//
//  Created by Frain on 2020/2/28.
//

protocol DifferenceType { }

class Difference<Cache>: DifferenceType {
    var insertions: [DiffChange<Cache>] { fatalError() }
    var removals: [DiffChange<Cache>] { fatalError() }
    
    func add(to
        uniqueRemovals: inout [AnyHashable: DiffChange<Cache>?],
        uniqueInsertions: inout [AnyHashable: DiffChange<Cache>?]
    ) { }
    
    func applying(
        uniqueRemovals: [AnyHashable: DiffChange<Cache>?],
        uniqueInsertions: [AnyHashable: DiffChange<Cache>?]
    ) { }
}

final class SimpleDifference<Cache>: Difference<Cache> {
    override var insertions: [DiffChange<Cache>] { insertionValues }
    override var removals: [DiffChange<Cache>] { removalValues }
    
    var insertionValues: [DiffChange<Cache>]
    var removalValues: [DiffChange<Cache>]
    
    init(insertionValues: [DiffChange<Cache>], removalValues: [DiffChange<Cache>]) {
        self.insertionValues = insertionValues
        self.removalValues = removalValues
    }
    
}

final class ValueDifference<Value, Cache>: Difference<Cache> {
    override var insertions: [DiffChange<Cache>] { insertionValues }
    override var removals: [DiffChange<Cache>] { removalValues }

    var insertionValues: [ValueChangeClass<Value, Cache>]
    var removalValues: [ValueChangeClass<Value, Cache>]
    
    var source: [DiffableValue<Value, Cache>]
    var target: [DiffableValue<Value, Cache>]
    
    var applying: ((ValueDifference<Value, Cache>) -> Void)?
    var starting: (() -> Void)?
    var ending: (() -> Void)?
    var finish: (() -> Void)?
    
    override func add(to
        uniqueRemovals: inout [AnyHashable: DiffChange<Cache>?],
        uniqueInsertions: inout [AnyHashable: DiffChange<Cache>?]
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
        uniqueRemovals: [AnyHashable: DiffChange<Cache>?],
        uniqueInsertions: [AnyHashable: DiffChange<Cache>?]
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
        for change: ValueChangeClass<Value, Cache>,
        _ uniques: [AnyHashable: DiffChange<Cache>?],
        _ assocUniques: [AnyHashable: DiffChange<Cache>?]
    ) -> ValueChangeClass<Value, Cache>? {
        guard let id = change.value.id, uniques[id] != nil else { return nil }
        return assocUniques[id] as? ValueChangeClass<Value, Cache>
    }

    init(
        source: [DiffableValue<Value, Cache>],
        target: [DiffableValue<Value, Cache>],
        insertionValues: [ValueChangeClass<Value, Cache>] = [],
        removalValues: [ValueChangeClass<Value, Cache>] = []
    ) {
        self.source = source
        self.target = target
        self.insertionValues = insertionValues
        self.removalValues = removalValues
        super.init()
    }
}

extension ValueDifference {
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
            removalValues: diffs.map { .init($0._element, differ: differ, index: $0._offset)  }
        )
    }
}

extension RangeReplaceableCollection {
    mutating func apply<Cache, Value>(
        _ difference: ValueDifference<Value, Cache>,
        valueTransform: (ValueChangeClass<Value, Cache>) -> Element
    ) {
        _apply(
            difference,
            insertion: \.insertionValues,
            removals: \.removalValues
        ) { valueTransform($0) }
    }
    
    mutating func apply<Cache>(
        _ difference: Difference<Cache>,
        valueTransform: (DiffChange<Cache>) -> Element
    ) {
        _apply(
            difference,
            insertion: \.insertions,
            removals: \.removals
        ) { valueTransform($0) }
    }
}

fileprivate extension DifferenceType {
    func _fastEnumeratedApply<Cache, Change: DiffChange<Cache>>(
        insertion: KeyPath<Self, [Change]>,
        removals: KeyPath<Self, [Change]>,
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
                let removeOffset = removals[enumeratedRemoves].index
                let insertOffset = insertions[enumeratedInserts].index
                if removeOffset - enumeratedRemoves <= insertOffset - enumeratedInserts {
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
    mutating func _apply<Cache, Change: DiffChange<Cache>, Difference: ListKit.Difference<Cache>>(
        _ difference: Difference,
        insertion: KeyPath<Difference, [Change]>,
        removals: KeyPath<Difference, [Change]>,
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
            removals: removals) { (isInsert, change) in
            if isInsert {
                let origCount = (change.index + enumeratedRemoves - enumeratedInserts) - enumeratedOriginals
                append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
                result.append(valueTransform(change))
                enumeratedOriginals += origCount
                enumeratedInserts += 1
            } else {
                let origCount = change.index - enumeratedOriginals
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
