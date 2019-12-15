//
//  CollectionListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/11/23.
//

public protocol CollectionListAdapter: ScrollListAdapter {
    var collectionList: CollectionList<SourceBase> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct CollectionList<Source: DataSource>: CollectionListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    
    var contextSetups = [(ListContext<Source>) -> Void]()
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var collectionList: CollectionList<Source> { self }
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
    func toCollectionList() -> CollectionList<SourceBase> {
        let collectionList = CollectionList(source: sourceBase)
        collectionList.coordinatorStorage.coordinator = listCoordinator
        return collectionList
    }
}

#if os(iOS) || os(tvOS)
import UIKit

extension CollectionListAdapter {
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<UICollectionViewDelegates, Delegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionContext<SourceBase>, Input)) -> Output
    ) -> CollectionList<SourceBase> {
        var collectionList = self.collectionList
        collectionList.contextSetups.append {
            let rootPath = \Delegates.collectionViewDelegates
            $0.set(rootPath.appending(path: keyPath)) { closure((.init($1, $0), $2)) }
        }
        return collectionList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<UICollectionViewDelegates, Delegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionContext<SourceBase>, Input)) -> Void
    ) -> CollectionList<SourceBase> {
        var collectionList = self.collectionList
        collectionList.contextSetups.append {
            let rootPath = \Delegates.collectionViewDelegates
            $0.set(rootPath.appending(path: keyPath)) { closure((.init($1, $0), $2)) }
        }
        return collectionList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<UICollectionViewDelegates, Delegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionSectionContext<SourceBase>, Input)) -> Output
    ) -> CollectionList<SourceBase> {
        var collectionList = self.collectionList
        collectionList.contextSetups.append {
            let rootPath = \Delegates.collectionViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, section: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<UICollectionViewDelegates, Delegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionSectionContext<SourceBase>, Input)) -> Void
    ) -> CollectionList<SourceBase> {
        var collectionList = self.collectionList
        collectionList.contextSetups.append {
            let rootPath = \Delegates.collectionViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .index(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, section: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }
    
    func set<Input, Output>(
        _ keyPath: ReferenceWritableKeyPath<UICollectionViewDelegates, Delegate<CollectionView, Input, Output>>,
        _ closure: @escaping ((CollectionItemContext<SourceBase>, Input)) -> Output
    ) -> CollectionList<SourceBase> {
        var collectionList = self.collectionList
        collectionList.contextSetups.append {
            let rootPath = \Delegates.collectionViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }
    
    func set<Input>(
        _ keyPath: ReferenceWritableKeyPath<UICollectionViewDelegates, Delegate<CollectionView, Input, Void>>,
        _ closure: @escaping ((CollectionItemContext<SourceBase>, Input)) -> Void
    ) -> CollectionList<SourceBase> {
        var collectionList = self.collectionList
        collectionList.contextSetups.append {
            let rootPath = \Delegates.collectionViewDelegates
            let keyPath = rootPath.appending(path: keyPath)
            guard case let .indexPath(path) = $0[keyPath: keyPath].index else { fatalError() }
            $0.set(keyPath) { closure((.init($1, $0, path: $2[keyPath: path]), $2)) }
        }
        return collectionList
    }
}

#endif
