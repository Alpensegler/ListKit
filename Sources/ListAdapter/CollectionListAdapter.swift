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
    public var wrappedValue: Source { source }
    public var collectionList: CollectionList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator { source.makeListCoordinator() }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(source: Source) {
        self.source = source
        self.updater = source.updater
        self.coordinatorStorage = CoordinatorStorage()
    }
}

#if os(iOS) || os(tvOS)
import UIKit

public extension ListAdapter  {
    func provideCollectionCell(
        _ provider: @escaping (CollectionIndexContext<SourceBase>, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        fatalError()
    }
}

extension CollectionListAdapter where Self: UpdatableDataSource {
    @discardableResult
    func apply(by collectionView: UICollectionView) -> Self { self }
}

#endif
