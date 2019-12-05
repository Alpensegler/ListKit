//
//  TableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

public protocol TableListAdapter: ListAdapter {
    var collectionList: TableList<SourceBase> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct TableList<Source: DataSource>: TableListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    
    public var source: Source
    public var updater: Updater<Source>
    public var coordinatorStorage: CoordinatorStorage<Source>
    
    public var sourceBase: Source { source }
    public var wrappedValue: Source { source }
    public var collectionList: TableList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator<Source> { source.makeListCoordinator() }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(source: Source) {
        self.source = source
        self.updater = source.updater
        self.coordinatorStorage = CoordinatorStorage()
        coordinatorStorage.coordinator = source.listCoordinator
    }
}

extension TableListAdapter {
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableContext<SourceBase>, Input)) -> Output
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return self
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableContext<SourceBase>, Input)) -> Void
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return self
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableIndexContext<SourceBase>, Input)) -> Output
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableIndexContext<SourceBase>, Input)) -> Void
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<TableView, Input, Output>>,
        _ closure: @escaping ((TableIndexPathContext<SourceBase>, Input)) -> Output
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<TableView, Input, Void>>,
        _ closure: @escaping ((TableIndexPathContext<SourceBase>, Input)) -> Void
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
}
