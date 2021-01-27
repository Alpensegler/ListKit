//
//  CollectionListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/11/23.
//

public protocol CollectionListAdapter: ScrollListAdapter {
    var collectionList: CollectionList<AdapterBase> { get }
}

@dynamicMemberLookup
public final class CollectionList<Source: DataSource>: ScrollList<Source>, CollectionListAdapter
where Source.AdapterBase == Source {
    public var collectionList: CollectionList<Source> { self }
    public var projectedValue: CollectionList<Source> { self }
    public override var wrappedValue: Source {
        get { source }
        set { source = newValue }
    }
}

public extension CollectionListAdapter {
    @discardableResult
    func apply(
        by collectionView: CollectionView,
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> CollectionList<AdapterBase> {
        let collectionList = self.collectionList
        collectionView.listDelegate.setCoordinator(
            context: listCoordinatorContext,
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
    ) -> CollectionList<AdapterBase> {
        apply(by: collectionView, update: listUpdate, animated: animated, completion: completion)
    }
}

extension CollectionList: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "CollectionList(\(source)" }
    public var debugDescription: String { "CollectionList(\(source)" }
}

public extension CollectionList where Source: ItemCachedDataSource {
    var base: CollectionList<Source.SourceBase.AdapterBase> {
        .init(source.sourceBase.adapterBase, listDelegate: listDelegate)
    }
}
