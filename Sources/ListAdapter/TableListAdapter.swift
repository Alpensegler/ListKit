//
//  TableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

public protocol TableListAdapter: ScrollListAdapter {
    var tableList: TableList<SourceBase> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct TableList<Source: DataSource>: TableListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    let storage: ListAdapterStorage<Source>
    let erasedGetter: (Self) -> TableList<AnySources>
    
    public var sourceBase: Source { source }
    public var source: Source {
        get { storage.source }
        nonmutating set { storage.source = newValue }
    }
    
    public var listUpdate: ListUpdate<SourceBase>.Whole { source.listUpdate }
    public var listDiffer: ListDiffer<Source> { source.listDiffer }
    public var listOptions: ListOptions<Source> { source.listOptions }
    
    public var listCoordinator: ListCoordinator<Source> { storage.listCoordinator }
    public let listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void]
    
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    
    public var tableList: TableList<Source> { self }
    
    public var wrappedValue: Source {
        get { source }
        nonmutating set { source = newValue }
    }
    
    public var projectedValue: TableList<Source> {
        get { self }
        set { self = newValue }
    }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    public subscript<Value>(dynamicMember path: WritableKeyPath<Source, Value>) -> Value {
        get { source[keyPath: path] }
        set { source[keyPath: path] = newValue }
    }
    
    init(
        listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void],
        source: Source,
        erasedGetter: @escaping (Self) -> TableList<AnySources> = Self.defaultErasedGetter
    ) {
        self.listContextSetups = listContextSetups
        self.erasedGetter = erasedGetter
        self.storage = .init(source: source)
        storage.makeListCoordinator = { source.listCoordinator }
    }
}

public extension TableListAdapter {
    @discardableResult
    func apply(
        by tableView: TableView,
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        tableView.listDelegate.setCoordinator(
            coordinator: tableList.storage.listCoordinator,
            setups: listContextSetups,
            update: update,
            animated: animated,
            completion: completion
        )
        return tableList
    }
    
    @discardableResult
    func apply(
        by tableView: TableView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<SourceBase> {
        apply(by: tableView, update: listUpdate, animated: animated, completion: completion)
    }
}

extension TableList: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "TableList(\(source))" }
    public var debugDescription: String { "TableList(\(source))" }
}

extension TableList: ListAdapter {
    typealias View = TableView
    
    static var defaultErasedGetter: (Self) -> TableList<AnySources> {
        { .init(AnySources($0)) { $0 } }
    }
}

#if os(iOS) || os(tvOS)

import UIKit

extension TableList {
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, UITableListDelegate> {
        \.tableListDelegate
    }
}

#endif
