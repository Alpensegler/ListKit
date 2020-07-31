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
    let erasedGetter: (Self) -> CollectionList<AnySources>
    
    public var sourceBase: Source { source }
    public var source: Source {
        get { storage.source }
        nonmutating set { storage.source = newValue }
    }
    
    public var listUpdate: ListUpdate<SourceBase>.Whole { source.listUpdate }
    public var listOptions: ListOptions<Source> { source.listOptions }
    
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
        erasedGetter: @escaping (Self) -> CollectionList<AnySources> = Self.defaultErasedGetter
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

extension CollectionList: ListAdapter {
    static var defaultErasedGetter: (Self) -> CollectionList<AnySources> {
        { .init(AnySources($0)) { $0 } }
    }
}

#if os(iOS) || os(tvOS)

import UIKit

extension CollectionList {
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, UICollectionListDelegate> {
        \.collectionListDelegate
    }
    
    static func toContext(
        _ view: CollectionView,
        _ context: ListCoordinatorContext<Source>
    ) -> CollectionContext<Source> {
        .init(listView: view, context: context)
    }
    
    static func toSectionContext(
        _ view: CollectionView,
        _ context: ListCoordinatorContext<Source>,
        _ section: Int,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> CollectionSectionContext<Source> {
        .init(
            listView: view,
            context: context,
            section: section - sectionOffset,
            sectionOffset: sectionOffset
        )
    }
    
    static func toItemContext(
        _ view: CollectionView,
        _ context: ListCoordinatorContext<Source>,
        _ path: IndexPath,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> CollectionItemContext<Source> {
        .init(
            listView: view,
            context: context,
            section: path.section - sectionOffset,
            sectionOffset: sectionOffset,
            item: path.item - itemOffset,
            itemOffset: itemOffset
        )
    }
}

#endif
