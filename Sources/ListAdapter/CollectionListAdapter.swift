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
    let storage: ListAdapterStorage<Source>
    let erasedGetter: (Self, ListOptions) -> CollectionList<AnySources>
    
    public var sourceBase: Source { source }
    public var source: Source {
        get { storage.source }
        nonmutating set { storage.source = newValue }
    }
    
    public var listUpdate: ListUpdate<SourceBase>.Whole { source.listUpdate }
    public var listDiffer: ListDiffer<Source> { source.listDiffer }
    public var listOptions: ListOptions { source.listOptions }
    
    public var listCoordinator: ListCoordinator<Source> { storage.listCoordinator }
    public let listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void]
    
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    
    public var collectionList: CollectionList<Source> { self }
    
    public var wrappedValue: Source {
        get { source }
        nonmutating set { source = newValue }
    }
    
    public var projectedValue: CollectionList<Source> {
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
        erasedGetter: @escaping (Self, ListOptions) -> CollectionList<AnySources> = Self.defaultErasedGetter
    ) {
        self.listContextSetups = listContextSetups
        self.erasedGetter = erasedGetter
        self.storage = .init(source: source)
        storage.makeListCoordinator = { source.listCoordinator }
    }
}

public extension CollectionListAdapter {
    @discardableResult
    func apply(
        by collectionView: CollectionView,
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        collectionView.listDelegate.setCoordinator(
            coordinator: collectionList.storage.listCoordinator,
            setups: listContextSetups,
            update: update,
            animated: animated,
            completion: completion
        )
        return collectionList
    }
    
    @discardableResult
    func apply(
        by collectionView: CollectionView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> CollectionList<SourceBase> {
        apply(by: collectionView, update: listUpdate, animated: animated, completion: completion)
    }
}

extension CollectionList: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "CollectionList(\(source)" }
    public var debugDescription: String { "CollectionList(\(source)" }
}

extension CollectionList: ListAdapter {
    typealias View = CollectionView
    typealias Erased = CollectionList<AnySources>
}

#if os(iOS) || os(tvOS)

import UIKit

extension CollectionList {
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, UICollectionListDelegate> {
        \.collectionListDelegate
    }
}

#endif
