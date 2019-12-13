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

extension TableListAdapter {
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableContext<SourceBase>, Input)) -> Output
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        let coordinator = tableList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return tableList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableContext<SourceBase>, Input)) -> Void
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        let coordinator = tableList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return tableList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableSectionContext<SourceBase>, Input)) -> Output
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        let coordinator = tableList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return tableList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableSectionContext<SourceBase>, Input)) -> Void
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        let coordinator = tableList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return tableList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableItemContext<SourceBase>, Input)) -> Output
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        let coordinator = tableList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return tableList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, Delegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableItemContext<SourceBase>, Input)) -> Void
    ) -> TableList<SourceBase> {
        let tableList = self.tableList
        let coordinator = tableList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return tableList
    }
}
