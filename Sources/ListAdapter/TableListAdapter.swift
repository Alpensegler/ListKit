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
    let coordinatorSetups: [(ListCoordinator<Source>) -> Void]
    let storage = ListAdapterStorage<Source>()
    let erasedGetter: (Self) -> TableList<AnySources>
    
    public let source: Source
    public var sourceBase: Source { source }
    public var differ: Differ<Source> { source.differ }
    public var listUpdate: ListUpdate<Item> { source.listUpdate }
    public var tableList: TableList<Source> { self }
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    public func makeListCoordinator() -> ListCoordinator<Source> { storage.listCoordinator }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(
        coordinatorSetups: [(ListCoordinator<Source>) -> Void],
        source: Source,
        erasedGetter: @escaping (Self) -> TableList<AnySources> = Self.defaultErasedGetter
    ) {
        self.coordinatorSetups = coordinatorSetups
        self.source = source
        self.erasedGetter = erasedGetter
        storage.makeListCoordinator = makeCoordinator(for: source, setups: coordinatorSetups)
    }
}

public extension TableListAdapter {
    @discardableResult
    func apply(
        by tableView: TableView,
        update: ListUpdate<Item>?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        tableView.listDelegate.setCoordinator(
            coordinator: tableList.storage.listCoordinator,
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

extension TableList: ListAdapter {
    static var defaultErasedGetter: (Self) -> TableList<AnySources> {
        { .init(AnySources($0)) { $0 } }
    }
}

#if os(iOS) || os(tvOS)

import UIKit

extension TableList {
    static var rootKeyPath: ReferenceWritableKeyPath<Coordinator, UITableListDelegate> {
        \.tableListDelegate
    }
    
    static func toContext(
        _ view: TableView,
        _ coordinator: ListCoordinator<Source>
    ) -> TableContext<Source> {
        .init(listView: view, coordinator: coordinator)
    }
    
    static func toSectionContext(
        _ view: TableView,
        _ coordinator: ListCoordinator<Source>,
        _ section: Int,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> TableSectionContext<Source> {
        .init(
            listView: view,
            coordinator: coordinator,
            section: section - sectionOffset,
            sectionOffset: sectionOffset
        )
    }
    
    
    static func toItemContext(
        _ view: TableView,
        _ coordinator: ListCoordinator<Source>,
        _ path: IndexPath,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> TableItemContext<Source> {
        .init(
            listView: view,
            coordinator: coordinator,
            section: path.section - sectionOffset,
            sectionOffset: sectionOffset,
            item: path.item - itemOffset,
            itemOffset: itemOffset
        )
    }
}

#endif
