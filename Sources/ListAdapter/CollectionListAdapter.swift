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
    var coordinatorSetups = [(ListCoordinator<Source>) -> Void]()
    var cacheFromItem: ((Item) -> Any)? = nil
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var collectionList: CollectionList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator<Source> { makeCoordinator() }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(coordinatorSetups: [(ListCoordinator<Source>) -> Void], source: Source) {
        self.coordinatorSetups = coordinatorSetups
        self.source = source
    }
}

public extension CollectionListAdapter {
    @discardableResult
    func apply(by collectionView: CollectionView) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        let coordinator = makeListCoordinator()
        coordinator.setup(
            listView: collectionView,
            objectIdentifier: ObjectIdentifier(collectionView)
        )
        _ = collectionView.listDelegate(for: coordinator)
        collectionView.reloadSynchronously()
        return collectionList
    }
}

#if os(iOS) || os(tvOS)

extension CollectionList: ListAdapter {
    static var rootKeyPath: ReferenceWritableKeyPath<BaseCoordinator, UICollectionListDelegate> {
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
