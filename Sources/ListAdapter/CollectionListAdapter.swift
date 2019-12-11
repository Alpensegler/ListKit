//
//  CollectionListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/11/23.
//

public protocol CollectionListAdapter: ListAdapter {
    var collectionList: CollectionList<SourceBase> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct CollectionList<Source: DataSource>: CollectionListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    
    public var source: Source
    public var updater: Updater<Source>
    public var coordinatorStorage: CoordinatorStorage<Source>
    
    public var sourceBase: Source { source }
    public var collectionList: CollectionList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator<Source> { source.makeListCoordinator() }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
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

extension CollectionListAdapter {
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionContext<SourceBase>, Input)) -> Output
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return self
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionContext<SourceBase>, Input)) -> Void
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator), $0.1))
        }
        return self
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionIndexContext<SourceBase>, Input)) -> Output
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionIndexContext<SourceBase>, Input)) -> Void
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .index(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, section: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionIndexPathContext<SourceBase>, Input)) -> Output
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<BaseCoordinator, ClosureDelegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionIndexPathContext<SourceBase>, Input)) -> Void
    ) -> Self {
        let coordinator = collectionList.listCoordinator
        guard case let .indexPath(path) = coordinator[keyPath: keyPath].index else { fatalError() }
        coordinator.set(keyPath) { [unowned coordinator] in
            closure((.init($0.0, coordinator, path: $0.1[keyPath: path]), $0.1))
        }
        return self
    }
}
