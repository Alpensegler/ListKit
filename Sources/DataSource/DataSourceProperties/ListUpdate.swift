//
//  ListUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/7.
//

enum UpdateWay {
    case reload
    case remove
    case insert
    case appendOrRemoveLast
    case prependOrRemoveFirst
}

enum ListUpdateWay<Item> {
    case diff(ListDiffer<Item>)
    case other(UpdateWay)
    case subupdate
    
    var differ: ListDiffer<Item>? {
        guard case let .diff(differ) = self else { return nil }
        return differ
    }
    
    init<OtherItem>(_ way: ListUpdateWay<OtherItem>, cast: @escaping (Item) -> (OtherItem)) {
        switch way {
        case .diff(let differ): self = .diff(.init(differ, cast: cast))
        case .other(let other): self = .other(other)
        case .subupdate: self = .subupdate
        }
    }
}

public struct ListUpdate<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    public struct Whole {
        let way: ListUpdateWay<SourceBase.Item>
    }
    
    public struct Batch {
        var operations = [(ListCoordinatorUpdate<SourceBase>) -> Void]()
        var needSource = false
    }
    
    enum UpdateType {
        case whole(Whole)
        case batch(Batch)
    }
    
    var updateType: UpdateType
    var source: SourceBase.Source!
    
    var isEmpty: Bool {
        guard case let .batch(batch) = updateType else { return false }
        return batch.operations.isEmpty
    }
    
    var needSource: Bool {
        switch updateType {
        case let .batch(batch):
            return batch.needSource
        case let .whole(whole):
            if case .other(.remove) = whole.way { return false }
            return true
        }
    }
}

extension ListUpdate.Whole: DiffInitializableUpdate {
    var diff: ListDiffer<SourceBase.Item>? { way.differ }
    
    init(id: ((Value) -> AnyHashable)? = nil, by areEquivalent: ((Value, Value) -> Bool)? = nil) {
        self.init(diff: ListDiffer(identifier: id, areEquivalent: areEquivalent))
    }
    
    init(diff: ListDiffer<Value>) {
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
    static var insert: Self { .init(.init(way: .other(.insert))) }
    
    init(_ whole: ListUpdate<SourceBase>.Whole, _ source: Source) {
        self.updateType = .whole(whole)
        self.source = source
    }
    init?(_ way: ListUpdateWay<SourceBase.Item>?) {
        guard let way = way else { return nil }
        self.updateType = .whole(.init(way: way))
    }
}

public extension ListUpdate {
    typealias Value = SourceBase.Item
    
    static var remove: Self { .init(.init(way: .other(.remove))) }
    static func reload(to source: Source) -> Self { .init(.init(way: .other(.reload)), source) }
    
    var batch: Batch? {
        guard case let .batch(batch) = updateType else { return nil }
        return batch
    }
    
    init(_ whole: ListUpdate<SourceBase>.Whole) { updateType = .whole(whole) }
    init(_ batch: Batch) { updateType = .batch(batch) }
    init() { updateType = .batch(.init(operations: [])) }
}

public extension ListUpdate where Source: Collection {
    static func appendOrRemoveLast(to source: Source) -> Self {
        .init(.init(way: .other(.appendOrRemoveLast)), source)
    }
    
    static func prependOrRemoveFirst(to source: Source) -> Self {
        .init(.init(way: .other(.prependOrRemoveFirst)), source)
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

//Subupdate
public extension DiffInitializableUpdate where SourceBase.Source: DataSource {
    static var subupdate: Self { .init(.init(way: .subupdate)) }
}

public extension DiffInitializableUpdate
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item
{
    static var subupdate: Self { .init(.init(way: .subupdate)) }
}
