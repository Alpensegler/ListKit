//
//  ValueWrapper.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/5.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ValueWrapper {
    associatedtype WrappedValue
    var wrappedValue: WrappedValue { get set }
}

extension ValueWrapper
where
    Self: Sequence,
    WrappedValue: Sequence,
    Element == WrappedValue.Element,
    Iterator == WrappedValue.Iterator
{
    public __consuming func makeIterator() -> Iterator {
        return wrappedValue.makeIterator()
    }
    
    public var underestimatedCount: Int {
        return wrappedValue.underestimatedCount
    }
    
    @discardableResult
    public __consuming func _copyContents(initializing buf: UnsafeMutableBufferPointer<Element>) -> (Iterator, UnsafeMutableBufferPointer<Element>.Index) {
        return wrappedValue._copyContents(initializing: buf)
    }
    
    public func _customContainsEquatableElement(_ element: Element) -> Bool? {
        return wrappedValue._customContainsEquatableElement(element)
    }
    
    public __consuming func _copyToContiguousArray() -> ContiguousArray<Element> {
        return wrappedValue._copyToContiguousArray()
    }
}

extension ValueWrapper
where
    Self: Collection,
    WrappedValue: Collection,
    Element == WrappedValue.Element,
    Iterator == WrappedValue.Iterator,
    Index == WrappedValue.Index,
    Indices == WrappedValue.Indices,
    SubSequence == WrappedValue.SubSequence
{
    public var startIndex: Index { return wrappedValue.startIndex }
    public var endIndex: Index { return wrappedValue.endIndex }
    public var indices: Indices { return wrappedValue.indices }
    public var isEmpty: Bool { return wrappedValue.isEmpty }
    public var count: Int { return wrappedValue.count }
    
    public func index(after i: Index) -> Index {
        return wrappedValue.index(after: i)
    }
    
    public subscript(position: Index) -> Element {
        return wrappedValue[position]
    }
    
    public func _customIndexOfEquatableElement(_ element: Element) -> Index?? {
        return wrappedValue._customIndexOfEquatableElement(element)
    }
    
    public func _customLastIndexOfEquatableElement(_ element: Element) -> Index?? {
        return wrappedValue._customLastIndexOfEquatableElement(element)
    }
    
    public func index(_ i: Index, offsetBy n: Int) -> Index {
        return wrappedValue.index(i, offsetBy: n)
    }
}


extension ValueWrapper
where
    Self: BidirectionalCollection,
    WrappedValue: BidirectionalCollection,
    Element == WrappedValue.Element,
    Iterator == WrappedValue.Iterator,
    Index == WrappedValue.Index,
    Indices == WrappedValue.Indices,
    SubSequence == WrappedValue.SubSequence
{
    public func index(before i: Index) -> Index {
        return wrappedValue.index(before: i)
    }
    
    public func distance(from start: Index, to end: Index) -> Int {
        return wrappedValue.distance(from:start, to: end)
    }
    
    public func index(_ i: Self.Index, offsetBy distance: Int) -> Self.Index {
        return wrappedValue.index(i, offsetBy: distance)
    }
    
    public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index) -> Bool {
        return wrappedValue.formIndex(&i, offsetBy: distance, limitedBy: limit)
    }
    
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
        return wrappedValue.formIndex(&i, offsetBy: distance)
    }
}

extension ValueWrapper
where
    Self: RangeReplaceableCollection,
    WrappedValue: RangeReplaceableCollection,
    Element == WrappedValue.Element,
    Iterator == WrappedValue.Iterator,
    Index == WrappedValue.Index,
    Indices == WrappedValue.Indices,
    SubSequence == WrappedValue.SubSequence
{
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        wrappedValue.replaceSubrange(subrange, with: newElements)
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        wrappedValue.reserveCapacity(n)
    }
    
    public mutating func append(_ newElement: __owned Element) {
        wrappedValue.append(newElement)
    }
    
    public mutating func insert(_ newElement: __owned Element, at i: Index) {
        wrappedValue.insert(newElement, at: i)
    }
    
    public mutating func insert<C>(contentsOf newElements: __owned C, at i: Index) where C : Collection, Element == C.Element {
        wrappedValue.insert(contentsOf: newElements, at: i)
    }
    
    public mutating func remove(at position: Index) -> Element {
        return wrappedValue.remove(at: position)
    }
    
    public mutating func removeSubrange(_ bounds: Range<Index>) {
        wrappedValue.removeSubrange(bounds)
    }
    
    public mutating func removeFirst() -> Element {
        return wrappedValue.removeFirst()
    }
    
    public mutating func removeFirst(_ k: Int) {
        wrappedValue.removeFirst()
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        wrappedValue.removeAll(keepingCapacity: keepCapacity)
    }
    
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try wrappedValue.removeAll(where: shouldBeRemoved)
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        return wrappedValue[bounds]
    }
}

