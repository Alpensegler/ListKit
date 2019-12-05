//
//  Change.swift
//  ListKit
//
//  Created by Frain on 2019/11/15.
//

struct Change<Index> {
    struct IndexChange {
        var associatedIndex: Index? = nil
        var isReload = false
    }
    
    var at: Index
    var change: IndexChange
}

struct Changes<Index> {
    var insertions = [Change<Index>]()
    var removals = [Change<Index>]()
}

typealias ItemChanges = Changes<Path>
typealias SectionChanges = Changes<Int>

struct ListChanges {
    var items = ItemChanges()
    var sections = SectionChanges()
}

struct ValueChange<Value, Index> {
    var value: Value
    var index: Change<Index>
}

struct ValueChanges<Value, Index> {
    var insertions = [ValueChange<Value, Index>]()
    var removals = [ValueChange<Value, Index>]()
    
    var isEmpty: Bool {
        insertions.isEmpty && removals.isEmpty
    }
}

extension ValueChange {
    init(value: Value, index: Index, associatedIndex: Index?, isReload: Bool = false) {
        let change = Change.IndexChange(associatedIndex: associatedIndex, isReload: isReload)
        self.init(value: value, index: .init(at: index, change: change))
    }
}

extension ValueChanges {
    fileprivate func _fastEnumeratedApply(
        indexTransform: (Index) -> Int,
        _ consume: (Bool, ValueChange<Value, Index>) -> Void
    ) {
        let totalRemoves = removals.count
        let totalInserts = insertions.count
        var enumeratedRemoves = 0
        var enumeratedInserts = 0

        while enumeratedRemoves < totalRemoves || enumeratedInserts < totalInserts {
            let (isInsert, change): (Bool, ValueChange<Value, Index>)
            if enumeratedRemoves < removals.count && enumeratedInserts < insertions.count {
                let removeOffset = removals[enumeratedRemoves].index.at
                let insertOffset = insertions[enumeratedInserts].index.at
                if indexTransform(removeOffset) - enumeratedRemoves <= indexTransform(insertOffset) - enumeratedInserts {
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

extension RangeReplaceableCollection {
    mutating func apply<Value, Index>(
        _ changes: ValueChanges<Value, Index>,
        indexTransform: (Index) -> Int,
        valueTransform: (Value) -> Element
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
        
        changes._fastEnumeratedApply(indexTransform: indexTransform) { (isInsert, change) in
            if isInsert {
                let origCount = (indexTransform(change.index.at) + enumeratedRemoves - enumeratedInserts) - enumeratedOriginals
                append(into: &result, contentsOf: self, from: &currentIndex, count: origCount)
                result.append(valueTransform(change.value))
                enumeratedOriginals += origCount
                enumeratedInserts += 1
            } else {
                let origCount = indexTransform(change.index.at) - enumeratedOriginals
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

extension Array where Element: Hashable {
    func changes<Index>(
        from: Self,
        movable: Bool,
        reloadable: Bool,
        areEquivalent: ((Element, Element) -> Bool)?,
        indexTransform: (Int) -> Index
    ) -> (first: ValueChanges<Element, Index>, second: ValueChanges<Element, Index>) {
        var first = ValueChanges<Element, Index>()
        var second = ValueChanges<Element, Index>()
        var difference = diff(from: from)
        if movable { difference = difference.inferringMoves() }
        func append(
            toFirst: Bool,
            toInsert: Bool,
            _ value: Element,
            _ index: Int,
            _ associatedIndex: Int?,
            _ isReload: Bool = false) {
            let change = ValueChange(
                value: value,
                index: indexTransform(index),
                associatedIndex: associatedIndex.map(indexTransform),
                isReload: isReload
            )
            switch (toFirst, toInsert) {
            case (true, true): first.insertions.append(change)
            case (true, false): first.removals.append(change)
            case (false, true): second.insertions.append(change)
            case (false, false): second.removals.append(change)
            }
        }
        for case let .insert(offset, value, associated) in difference.insertions {
            if let associated = associated {
                let fromValue = from[associated]
                if offset == associated {
                    append(toFirst: true, toInsert: true, value, offset, associated, true)
                } else if reloadable, areEquivalent?(fromValue, value) == false {
                    append(toFirst: true, toInsert: true, fromValue, offset, associated)
                    append(toFirst: false, toInsert: true, value, offset, associated, true)
                } else {
                    append(toFirst: true, toInsert: true, fromValue, offset, associated)
                }
            } else {
                append(toFirst: true, toInsert: true, value, offset, nil)
            }
        }
        for case let .remove(offset, value, associated) in difference.removals {
            if let associated = associated {
                let toValue = self[associated]
                if offset == associated {
                    append(toFirst: true, toInsert: false, value, offset, associated, true)
                } else if reloadable, areEquivalent?(value, toValue) == false {
                    append(toFirst: true, toInsert: false, value, offset, associated)
                    append(toFirst: false, toInsert: false, value, offset, associated, true)
                } else {
                    append(toFirst: true, toInsert: false, value, offset, associated)
                }
            } else {
                append(toFirst: true, toInsert: false, value, offset, associated)
            }
        }
        return (first, second)
    }
}
