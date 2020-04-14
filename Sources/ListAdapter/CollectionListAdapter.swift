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
    let coordinatorSetups: [(ListCoordinator<Source>) -> Void]
    let storage = ListAdapterStorage<Source>()
    
    public let source: Source
    public var sourceBase: Source { source }
    public var differ: Differ<Source> { source.differ }
    public var listUpdate: Update<Item> { source.listUpdate }
    public var collectionList: CollectionList<Source> { self }
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    public func makeListCoordinator() -> ListCoordinator<Source> { storage.listCoordinator }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(coordinatorSetups: [(ListCoordinator<Source>) -> Void], source: Source) {
        self.coordinatorSetups = coordinatorSetups
        self.source = source
        storage.makeListCoordinator = makeCoordinator
    }
}

public extension CollectionListAdapter {
    @discardableResult
    func apply(
        by collectionView: CollectionView,
        update: Update<Item>,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        collectionView.listDelegate.setCoordinator(
            coordinator: collectionList.storage.listCoordinator,
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

#if os(iOS) || os(tvOS)

extension CollectionList: ListAdapter {
    static var rootKeyPath: ReferenceWritableKeyPath<Coordinator, UICollectionListDelegate> {
        \.collectionListDelegate
    }
    
    static func toContext(
        _ view: CollectionView,
        _ coordinator: ListCoordinator<Source>
    ) -> CollectionContext<Source> {
        .init(listView: view, coordinator: coordinator)
    }
    
    static func toSectionContext(
        _ view: CollectionView,
        _ coordinator: ListCoordinator<Source>,
        section: Int
    ) -> CollectionSectionContext<Source> {
        let (sectionOffset, _) = coordinator.offset(for: view)
        return .init(
            listView: view,
            coordinator: coordinator,
            section: section - sectionOffset,
            sectionOffset: sectionOffset
        )
    }
    
    static func toItemContext(
        _ view: CollectionView,
        _ coordinator: ListCoordinator<Source>,
        path: PathConvertible
    ) -> CollectionItemContext<Source> {
        let (sectionOffset, itemOffset) = coordinator.offset(for: view)
        return .init(
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
