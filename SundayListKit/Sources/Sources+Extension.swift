//
//  Sources+Extension.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Sources: CustomStringConvertible {
    public var description: String {
        return "\(source)" // "Sources<\(SubSource.self), \(Item.self), \(SourceSnapshot.self), \(UIViewType.self)> \(source)"
    }
}

extension Sources: Identifiable {
    public typealias ID = AnyHashable
    
    public var id: ID {
        return diffable.id
    }
}

extension Sources: Equatable {
    public static func == (lhs: Sources<SubSource, Item, SourceSnapshot, UIViewType>, rhs: Sources<SubSource, Item, SourceSnapshot, UIViewType>) -> Bool {
        return lhs.diffable == rhs.diffable
    }
}

extension Sources: Sequence where SubSource: Sequence {
    public typealias Element = SubSource.Element
    public typealias Iterator = SubSource.Iterator
    public var underestimatedCount: Int { return source.underestimatedCount }
    
    public func makeIterator() -> SubSource.Iterator {
        return source.makeIterator()
    }
    
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        return try source.withContiguousStorageIfAvailable(body)
    }
}

extension Sources: Collection where SubSource: Collection {
    public typealias Index = SubSource.Index
    public typealias Indices = SubSource.Indices
    public typealias SubSequence = SubSource.SubSequence
    
    public var startIndex: Index { return source.startIndex }
    public var endIndex: Index { return source.endIndex }
    public var indices: Indices { return source.indices }
    public var isEmpty: Bool { return source.isEmpty }
    public var count: Int { return source.count }
    
    public subscript(position: Index) -> Element {
        get { return source[position] }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        return source[bounds]
    }
    
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        return source.index(i, offsetBy: distance)
    }
    
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        return source.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    public func distance(from start: Index, to end: Index) -> Int {
        return source.distance(from: start, to: end)
    }
    
    public func index(after i: Index) -> Index {
        return source.index(after: i)
    }
    
    public func formIndex(after i: inout Index) {
        return source.formIndex(after: &i)
    }
}

struct AnyDiffable: Identifiable, Equatable {
    static func == (lhs: AnyDiffable, rhs: AnyDiffable) -> Bool {
        guard let l = lhs.base, let r = rhs.base else { return false }
        return l.isContentEqual(to: r)
    }
    
    let _id: () -> AnyHashable
    let _base: (() -> AnyEquatableBox)?
    
    var id: AnyHashable { return _id() }
    var base: AnyEquatableBox? { return _base?() }
    
    init() {
        let uuid = UUID()
        _id = { uuid }
        _base = nil
    }
    
    init(_ id: AnyHashable) {
        _id = { id }
        _base = { EquatableBox(id) }
    }
    
    init<T: Identifiable>(_ identifiable: @escaping () -> T) {
        self._id = { identifiable().id }
        self._base = { EquatableBox(identifiable().id) }
    }
    
    init<T: Identifiable & Equatable>(_ identifiable: @escaping () -> T) {
        self._id = { identifiable().id }
        self._base = { EquatableBox(identifiable()) }
    }
}

protocol AnyEquatableBox {
    var base: Any { get }
    
    func isContentEqual(to source: AnyEquatableBox) -> Bool
}

struct EquatableBox<Base: Equatable>: AnyEquatableBox {
    private let baseComponent: Base
    
    var base: Any {
        return baseComponent
    }
    
    init(_ base: Base) {
        baseComponent = base
    }
    
    func isContentEqual(to source: AnyEquatableBox) -> Bool {
        guard let sourceBase = source.base as? Base else {
            return false
        }
        return baseComponent == sourceBase
    }
}

