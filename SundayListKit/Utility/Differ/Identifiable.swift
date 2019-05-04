//
//  Identifiable.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/23.
//  Copyright © 2019 Frain. All rights reserved.
//

/// A type that can be compared for identity equality.
public protocol Identifiable {
    
    /// A type of unique identifier that can be compared for equality.
    associatedtype ID: Hashable
    
    /// A unique identifier that can be compared for equality.
    var id: Self.ID { get }
    
    /// The type of value identified by `id`.
    associatedtype IdentifiedValue = Self
    
    /// The value identified by `id`.
    ///
    /// By default this returns `self`.
    var identifiedValue: Self.IdentifiedValue { get }
}

extension Identifiable where Self == Self.IdentifiedValue {
    
    @inlinable public var identifiedValue: Self {
        return self
    }
}

extension Identifiable where Self: AnyObject {
    
    @inlinable public var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

/// An identifier and value that is uniquely identified by it.
public struct IdentifierValuePair<ID, Value>: Identifiable where ID: Hashable {
    
    /// The type of value identified by `id`.
    public typealias IdentifiedValue = Value
    
    /// A unique identifier that can be compared for equality.
    public let id: ID
    
    /// A value identified by `id`.
    public let value: Value
    
    /// The value identified by `id`.
    ///
    /// By default this returns `self`.
    @inlinable public var identifiedValue: Value {
        return value
    }
    
    /// Creates an instance.
    @inlinable public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }
}

/// A collection of identifier-value pairs computed on demand by calling
///// `getID`.
//public struct IdentifierValuePairs<Base, ID>: Collection where Base: Collection, ID: Hashable {
//
//    /// A type that represents a position in the collection.
//    ///
//    /// Valid indices consist of the position of every element and a
//    /// "past the end" position that's not valid for use as a subscript
//    /// argument.
//    public typealias Index = Base.Index
//
//    /// A type representing the sequence's elements.
//    public typealias Element = IdentifierValuePair<ID, Base.Element>
//
//    /// The position of the first element in a nonempty collection.
//    ///
//    /// If the collection is empty, `startIndex` is equal to `endIndex`.
//    @inlinable public var startIndex: Base.Index {
//
//    }
//
//    /// The collection's "past the end" position---that is, the position one
//    /// greater than the last valid subscript argument.
//    ///
//    /// When you need a range that includes the last element of a collection, use
//    /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
//    /// creates a range that doesn't include the upper bound, so it's always
//    /// safe to use with `endIndex`. For example:
//    ///
//    ///     let numbers = [10, 20, 30, 40, 50]
//    ///     if let index = numbers.firstIndex(of: 30) {
//    ///         print(numbers[index ..< numbers.endIndex])
//    ///     }
//    ///     // Prints "[30, 40, 50]"
//    ///
//    /// If the collection is empty, `endIndex` is equal to `startIndex`.
//    @inlinable public var endIndex: Base.Index { get }
//
//    /// Returns the position immediately after the given index.
//    ///
//    /// The successor of an index must be well defined. For an index `i` into a
//    /// collection `c`, calling `c.index(after: i)` returns the same index every
//    /// time.
//    ///
//    /// - Parameter i: A valid index of the collection. `i` must be less than
//    ///   `endIndex`.
//    /// - Returns: The index value immediately after `i`.
//    @inlinable public func index(after i: IdentifierValuePairs<Base, ID>.Index) -> IdentifierValuePairs<Base, ID>.Index
//
//    /// Replaces the given index with its successor.
//    ///
//    /// - Parameter i: A valid index of the collection. `i` must be less than
//    ///   `endIndex`.
//    @inlinable public func formIndex(after i: inout IdentifierValuePairs<Base, ID>.Index)
//
//    /// Accesses the element at the specified position.
//    ///
//    /// The following example accesses an element of an array through its
//    /// subscript to print its value:
//    ///
//    ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
//    ///     print(streets[1])
//    ///     // Prints "Bryant"
//    ///
//    /// You can subscript a collection with any valid index other than the
//    /// collection's end index. The end index refers to the position one past
//    /// the last element of a collection, so it doesn't correspond with an
//    /// element.
//    ///
//    /// - Parameter position: The position of the element to access. `position`
//    ///   must be a valid index of the collection that is not equal to the
//    ///   `endIndex` property.
//    ///
//    /// - Complexity: O(1)
//    @inlinable public subscript(position: IdentifierValuePairs<Base, ID>.Index) -> IdentifierValuePairs<Base, ID>.Element { get }
//
//    /// A type that provides the collection's iteration interface and
//    /// encapsulates its iteration state.
//    ///
//    /// By default, a collection conforms to the `Sequence` protocol by
//    /// supplying `IndexingIterator` as its associated `Iterator`
//    /// type.
//    public typealias Iterator = IndexingIterator<IdentifierValuePairs<Base, ID>>
//
//    /// A sequence that represents a contiguous subrange of the collection's
//    /// elements.
//    ///
//    /// This associated type appears as a requirement in the `Sequence`
//    /// protocol, but it is restated here with stricter constraints. In a
//    /// collection, the subsequence should also conform to `Collection`.
//    public typealias SubSequence = Slice<IdentifierValuePairs<Base, ID>>
//
//    /// A type that represents the indices that are valid for subscripting the
//    /// collection, in ascending order.
//    public typealias Indices = DefaultIndices<IdentifierValuePairs<Base, ID>>
//}
//
//extension IdentifierValuePairs: BidirectionalCollection where Base: BidirectionalCollection {
//
//    /// Returns the position immediately before the given index.
//    ///
//    /// - Parameter i: A valid index of the collection. `i` must be greater than
//    ///   `startIndex`.
//    /// - Returns: The index value immediately before `i`.
//    @inlinable public func index(before i: IdentifierValuePairs<Base, ID>.Index) -> IdentifierValuePairs<Base, ID>.Index
//
//    /// Replaces the given index with its predecessor.
//    ///
//    /// - Parameter i: A valid index of the collection. `i` must be greater than
//    ///   `startIndex`.
//    @inlinable public func formIndex(before i: inout IdentifierValuePairs<Base, ID>.Index)
//}
//
//extension IdentifierValuePairs: RandomAccessCollection where Base: RandomAccessCollection {
//}
