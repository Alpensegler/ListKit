//
//  DiffInitializableUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/7/7.
//

public protocol DiffInitializableUpdate: DiffInitializable where Value == SourceBase.Item {
    associatedtype SourceBase: DataSource where SourceBase.SourceBase == SourceBase
    
    init(_ listUpdate: ListUpdate<SourceBase>)
}

public extension DiffInitializableUpdate {
    static var reload: Self { .init(.init(way: .reload)) }
    
    static func diff(by areEquivalent: @escaping (Value, Value) -> Bool) -> Self {
        .init(.init(id: nil, by: areEquivalent))
    }
    
    static func diff<ID: Hashable>(id: @escaping (Value) -> ID) -> Self {
        .init(.init(id: id, by: nil))
    }
    
    static func diff<ID: Hashable>(
        id: @escaping (Value) -> ID,
        by areEquivalent: @escaping (Value, Value) -> Bool
    ) -> Self {
        .init(.init(id: id, by: areEquivalent))
    }
}

public extension DiffInitializableUpdate where SourceBase.Source: Collection {
    static var appendOrRemoveLast: Self { .init(.init(way: .appendOrRemoveLast)) }
    static var prependOrRemoveFirst: Self { .init(.init(way: .prependOrRemoveFirst)) }
}

public extension DiffInitializableUpdate where SourceBase: NSDataSource {
    static var appendOrRemoveLast: Self { .init(.init(way: .appendOrRemoveLast)) }
    static var prependOrRemoveFirst: Self { .init(.init(way: .prependOrRemoveFirst)) }
}
