//
//  ListUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/7.
//

import Foundation

enum ListUpdateWay<Item> {
    case diff(Differ<Item>)
    case reload
    case remove
    case insert
    case appendOrRemoveLast
    case prependOrRemoveFirst
}

public enum ListUpdate<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    public struct Whole {
        let way: ListUpdateWay<SourceBase.Item>
    }
    
    public struct Batch {
        var operations = [(CoordinatorUpdate<SourceBase>) -> Void]()
    }
    
    case whole(Whole, Source? = nil)
    case batch(Batch)
    
    var source: Source? {
        guard case let .whole(_, source) = self else { return nil }
        return source
    }
    
    var isEmpty: Bool {
        guard case let .batch(batch) = self else { return false }
        return batch.operations.isEmpty
    }
}

extension ListUpdate.Whole: DiffInitializableUpdate {
    var diff: Differ<SourceBase.Item>? {
        guard case let .diff(differ) = way else { return nil }
        return differ
    }
    
    init(id: ((Value) -> AnyHashable)? = nil, by areEquivalent: ((Value, Value) -> Bool)? = nil) {
        self.init(diff: Differ(identifier: id, areEquivalent: areEquivalent))
    }
    
    init(diff: Differ<Value>) {
        way = .diff(diff)
    }
}

public extension ListUpdate.Whole {
    typealias Value = SourceBase.Item
    
    init(_ whole: ListUpdate<SourceBase>.Whole) {
        self = whole
    }
}

extension ListUpdate.Batch: BatchInitializable { }

public extension ListUpdate.Batch {
    var batch: ListUpdate<SourceBase>.Batch? { self }
    init(_ batch: ListUpdate<SourceBase>.Batch) { self = batch }
}

extension ListUpdate: BatchInitializable, DiffInitializableUpdate {
    static var insert: Self { .init(.init(way: .insert)) }
    
    init(_ whole: ListUpdate<SourceBase>.Whole, _ source: Source) { self = .whole(whole, source) }
    init(_ differ: Differ<SourceBase.Item>?, or update: ListUpdate<SourceBase>.Whole) {
        self = .whole(differ.map { .init(diff: $0) } ?? update)
    }
}

public extension ListUpdate {
    typealias Value = SourceBase.Item
    
    static var remove: Self { .init(.init(way: .remove)) }
    static func reload(to source: Source) -> Self { .init(.init(way: .reload), source) }
    
    var batch: Batch? {
        guard case let .batch(batch) = self else { return nil }
        return batch
    }
    
    init(_ whole: ListUpdate<SourceBase>.Whole) { self = .whole(whole) }
    init(_ batch: Batch) { self = .batch(batch) }
    init() { self = .batch(.init(operations: [])) }
}

public extension ListUpdate where Source: Collection {
    static func appendOrRemoveLast(to source: Source) -> Self {
        .init(.init(way: .appendOrRemoveLast), source)
    }
    
    static func prependOrRemoveFirst(to source: Source) -> Self {
        .init(.init(way: .prependOrRemoveFirst), source)
    }
}

//Value Equatable
public extension ListUpdate where Value: Equatable {
    static func diff(to source: Source) -> Self { .init(.diff(by: ==), source) }
    static func diff<ID: Hashable>(to source: Source, id: @escaping (Value) -> ID) -> Self {
        .init(.diff(id: id, by: ==), source)
    }
}

//Value Hashable
public extension ListUpdate where Value: Hashable {
    static func diff(to source: Source) -> Self { .init(.diff(id: { $0 }), source) }
}

//Value Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension ListUpdate where Value: Identifiable {
    static func diff(to source: Source) -> Self { .init(.diff(id: \.id), source) }
    static func diff(
        to source: Source,
        by areEquivalent: @escaping (Value, Value) -> Bool
    ) -> Self {
        .init(.diff(id: \.id, by: areEquivalent), source)
    }
}

//Value Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension ListUpdate where Value: Identifiable, Value: Equatable {
    static func diff(to source: Source) -> Self { .init(.diff(id: \.id, by: ==), source) }
}

//Value Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension ListUpdate where Value: Identifiable, Value: Hashable {
    static func diff(to source: Source) -> Self { .init(.diff(id: \.id, by: ==), source) }
}