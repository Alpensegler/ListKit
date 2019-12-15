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
    
    var contextSetups = [(ListContext<Source>) -> Void]()
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var tableList: TableList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator<Source> {
        addToStorage(source.listCoordinator)
    }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
}

extension DataSource {
    func toTableList() -> TableList<SourceBase> {
        let tableList = TableList(source: sourceBase)
        tableList.coordinatorStorage.coordinator = listCoordinator
        return tableList
    }
}

#if os(iOS) || os(tvOS)
import UIKit

extension TableListAdapter {
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<UITableViewDelegates, Delegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableContext<SourceBase>, Input)) -> Output
    ) -> TableList<SourceBase> {
        var tableList = self.tableList
        tableList.contextSetups.append {
            let rootPath = \Delegates.tableViewDelegates
            $0.set(rootPath.appending(path: keyPath)) { closure((.init($1, $0), $2)) }
        }
        return tableList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<UITableViewDelegates, Delegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableContext<SourceBase>, Input)) -> Void
    ) -> TableList<SourceBase> {
        var tableList = self.tableList
        tableList.contextSetups.append {
            let rootPath = \Delegates.tableViewDelegates
            $0.set(rootPath.appending(path: keyPath)) { closure((.init($1, $0), $2)) }
        }
        return tableList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<UITableViewDelegates, Delegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableSectionContext<SourceBase>, Input)) -> Output
    ) -> TableList<SourceBase> {
        var tableList = self.tableList
        tableList.contextSetups.append {
            let rootPath = \Delegates.tableViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, section: $2[keyPath: path]), $2)) }
        }
        return tableList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<UITableViewDelegates, Delegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableSectionContext<SourceBase>, Input)) -> Void
    ) -> TableList<SourceBase> {
        var tableList = self.tableList
        tableList.contextSetups.append {
            let rootPath = \Delegates.tableViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, section: $2[keyPath: path]), $2)) }
        }
        return tableList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<UITableViewDelegates, Delegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableItemContext<SourceBase>, Input)) -> Output
    ) -> TableList<SourceBase> {
        var tableList = self.tableList
        tableList.contextSetups.append {
            let rootPath = \Delegates.tableViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return tableList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<UITableViewDelegates, Delegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableItemContext<SourceBase>, Input)) -> Void
    ) -> TableList<SourceBase> {
        var tableList = self.tableList
        tableList.contextSetups.append {
            let rootPath = \Delegates.tableViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return tableList
    }
}

#endif
