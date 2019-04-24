//
//  Difference.swift
//  Difference
//
//  Created by Frain on 2019/3/17.
//  Copyright © 2019 Frain. All rights reserved.
//

public struct CollectionDifference<ChangeElement> {
    /// A type that represents a single change to a collection.
    ///
    /// The `offset` of each `insert` refers to the offset of its `element` in
    /// the final state after the difference is fully applied. The `offset` of
    /// each `remove` refers to the offset of its `element` in the original
    /// state. Non-`nil` values of `associatedWith` refer to the offset of the
    /// complementary change.
    public enum Change {
        case insert(offset: Int, element: ChangeElement, associatedWith: Int?)
        case remove(offset: Int, element: ChangeElement, associatedWith: Int?)
        
        // Internal common field accessors
        internal var _offset: Int {
            get {
                switch self {
                case .insert(offset: let o, element: _, associatedWith: _):
                    return o
                case .remove(offset: let o, element: _, associatedWith: _):
                    return o
                }
            }
        }
        internal var _element: ChangeElement {
            get {
                switch self {
                case .insert(offset: _, element: let e, associatedWith: _):
                    return e
                case .remove(offset: _, element: let e, associatedWith: _):
                    return e
                }
            }
        }
        internal var _associatedOffset: Int? {
            get {
                switch self {
                case .insert(offset: _, element: _, associatedWith: let o):
                    return o
                case .remove(offset: _, element: _, associatedWith: let o):
                    return o
                }
            }
        }
    }
    
    /// The `.insert` changes contained by this difference, from lowest offset to highest
    public let insertions: [Change]
    
    /// The `.remove` changes contained by this difference, from lowest offset to highest
    public let removals: [Change]
    
    /// The public initializer calls this function to ensure that its parameter
    /// meets the conditions set in its documentation.
    ///
    /// - Parameter changes: a collection of `CollectionDifference.Change`
    ///   instances intended to represent a valid state transition for
    ///   `CollectionDifference`.
    ///
    /// - Returns: whether the parameter meets the following criteria:
    ///
    ///   1. All insertion offsets are unique
    ///   2. All removal offsets are unique
    ///   3. All associations between insertions and removals are symmetric
    ///
    /// Complexity: O(`changes.count`)
    private static func _validateChanges<Changes: Collection>(
        _ changes : Changes
        ) -> Bool where Changes.Element == Change {
        if changes.count == 0 { return true }
        
        var insertAssocToOffset = Dictionary<Int,Int>()
        var removeOffsetToAssoc = Dictionary<Int,Int>()
        var insertOffset = Set<Int>()
        var removeOffset = Set<Int>()
        
        for change in changes {
            let offset = change._offset
            if offset < 0 { return false }
            
            switch change {
            case .remove(_, _, _):
                if removeOffset.contains(offset) { return false }
                removeOffset.insert(offset)
            case .insert(_, _, _):
                if insertOffset.contains(offset) { return false }
                insertOffset.insert(offset)
            }
            
            if let assoc = change._associatedOffset {
                if assoc < 0 { return false }
                switch change {
                case .remove(_, _, _):
                    if removeOffsetToAssoc[offset] != nil { return false }
                    removeOffsetToAssoc[offset] = assoc
                case .insert(_, _, _):
                    if insertAssocToOffset[assoc] != nil { return false }
                    insertAssocToOffset[assoc] = offset
                }
            }
        }
        
        return removeOffsetToAssoc == insertAssocToOffset
    }
    
    /// Creates an instance from a collection of changes.
    ///
    /// For clients interested in the difference between two collections, see
    /// `BidirectionalCollection.difference(from:)`.
    ///
    /// To guarantee that instances are unambiguous and safe for compatible base
    /// states, this initializer will fail unless its parameter meets to the
    /// following requirements:
    ///
    /// 1. All insertion offsets are unique
    /// 2. All removal offsets are unique
    /// 3. All associations between insertions and removals are symmetric
    ///
    /// - Parameter c: A collection of changes that represent a transition
    ///   between two states.
    ///
    /// - Complexity: O(*n* * log(*n*)), where *n* is the length of the
    ///   parameter.
    public init?<Changes: Collection>(
        _ changes: Changes
        ) where Changes.Element == Change {
        guard CollectionDifference<ChangeElement>._validateChanges(changes) else {
            return nil
        }
        
        self.init(_validatedChanges: changes)
    }
    
    /// Internal initializer for use by algorithms that cannot produce invalid
    /// collections of changes. These include the Myers' diff algorithm and
    /// the move inferencer.
    ///
    /// If parameter validity cannot be guaranteed by the caller then
    /// `CollectionDifference.init?(_:)` should be used instead.
    ///
    /// - Parameter c: A valid collection of changes that represent a transition
    ///   between two states.
    ///
    /// - Complexity: O(*n* * log(*n*)), where *n* is the length of the
    ///   parameter.
    internal init<Changes: Collection>(
        _validatedChanges changes: Changes
        ) where Changes.Element == Change {
        let sortedChanges = changes.sorted { (a, b) -> Bool in
            switch (a, b) {
            case (.remove(_, _, _), .insert(_, _, _)):
                return true
            case (.insert(_, _, _), .remove(_, _, _)):
                return false
            default:
                return a._offset < b._offset
            }
        }
        
        // Find first insertion via binary search
        let firstInsertIndex: Int
        if sortedChanges.count == 0 {
            firstInsertIndex = 0
        } else {
            var range = 0...sortedChanges.count
            while range.lowerBound != range.upperBound {
                let i = (range.lowerBound + range.upperBound) / 2
                switch sortedChanges[i] {
                case .insert(_, _, _):
                    range = range.lowerBound...i
                case .remove(_, _, _):
                    range = (i + 1)...range.upperBound
                }
            }
            firstInsertIndex = range.lowerBound
        }
        
        removals = Array(sortedChanges[0..<firstInsertIndex])
        insertions = Array(sortedChanges[firstInsertIndex..<sortedChanges.count])
    }
}

/// A CollectionDifference is itself a Collection.
///
/// The enumeration order of `Change` elements is:
///
/// 1. `.remove`s, from highest `offset` to lowest
/// 2. `.insert`s, from lowest `offset` to highest
///
/// This guarantees that applicators on compatible base states are safe when
/// written in the form:
///
/// ```
/// for c in diff {
///   switch c {
///   case .remove(offset: let o, element: _, associatedWith: _):
///     arr.remove(at: o)
///   case .insert(offset: let o, element: let e, associatedWith: _):
///     arr.insert(e, at: o)
///   }
/// }
/// ```
extension CollectionDifference: Collection {
    public typealias Element = Change
    
    public struct Index {
        // Opaque index type is isomorphic to Int
        @usableFromInline
        internal let _offset: Int
        
        internal init(_offset offset: Int) {
            _offset = offset
        }
    }
    
    public var startIndex: Index {
        return Index(_offset: 0)
    }
    
    public var endIndex: Index {
        return Index(_offset: removals.count + insertions.count)
    }
    
    public func index(after index: Index) -> Index {
        return Index(_offset: index._offset + 1)
    }
    
    public subscript(position: Index) -> Element {
        if position._offset < removals.count {
            return removals[removals.count - (position._offset + 1)]
        }
        return insertions[position._offset - removals.count]
    }
    
    public func index(before index: Index) -> Index {
        return Index(_offset: index._offset - 1)
    }
    
    public func formIndex(_ index: inout Index, offsetBy distance: Int) {
        index = Index(_offset: index._offset + distance)
    }
    
    public func distance(from start: Index, to end: Index) -> Int {
        return end._offset - start._offset
    }
}

extension CollectionDifference.Index: Equatable {
    @inlinable
    public static func == (
        lhs: CollectionDifference.Index,
        rhs: CollectionDifference.Index
        ) -> Bool {
        return lhs._offset == rhs._offset
    }
}

extension CollectionDifference.Index: Comparable {
    @inlinable
    public static func < (
        lhs: CollectionDifference.Index,
        rhs: CollectionDifference.Index
        ) -> Bool {
        return lhs._offset < rhs._offset
    }
}

extension CollectionDifference.Index: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_offset)
    }
}

extension CollectionDifference.Change: Equatable where ChangeElement: Equatable {}

extension CollectionDifference: Equatable where ChangeElement: Equatable {}

extension CollectionDifference.Change: Hashable where ChangeElement: Hashable {}

extension CollectionDifference: Hashable where ChangeElement: Hashable {}

extension CollectionDifference where ChangeElement: Hashable {
    /// Infers which `ChangeElement`s have been both inserted and removed only
    /// once and returns a new difference with those associations.
    ///
    /// - Returns: an instance with all possible moves inferred.
    ///
    /// - Complexity: O(*n*) where *n* is `self.count`
    public func inferringMoves() -> CollectionDifference<ChangeElement> {
        let uniqueRemovals: [ChangeElement:Int?] = {
            var result = [ChangeElement:Int?](minimumCapacity: Swift.min(removals.count, insertions.count))
            for removal in removals {
                let element = removal._element
                if result[element] != .none {
                    result[element] = .some(.none)
                } else {
                    result[element] = .some(removal._offset)
                }
            }
            return result.filter { (_, v) -> Bool in v != .none }
        }()
        
        let uniqueInsertions: [ChangeElement:Int?] = {
            var result = [ChangeElement:Int?](minimumCapacity: Swift.min(removals.count, insertions.count))
            for insertion in insertions {
                let element = insertion._element
                if result[element] != .none {
                    result[element] = .some(.none)
                } else {
                    result[element] = .some(insertion._offset)
                }
            }
            return result.filter { (_, v) -> Bool in v != .none }
        }()
        
        return CollectionDifference(_validatedChanges: map({ (change: Change) -> Change in
            switch change {
            case .remove(offset: let offset, element: let element, associatedWith: _):
                if uniqueRemovals[element] == nil {
                    return change
                }
                if let assoc = uniqueInsertions[element] {
                    return .remove(offset: offset, element: element, associatedWith: assoc)
                }
            case .insert(offset: let offset, element: let element, associatedWith: _):
                if uniqueInsertions[element] == nil {
                    return change
                }
                if let assoc = uniqueRemovals[element] {
                    return .insert(offset: offset, element: element, associatedWith: assoc)
                }
            }
            return change
        }))
    }
}
