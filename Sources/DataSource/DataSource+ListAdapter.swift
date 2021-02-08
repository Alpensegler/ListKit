//
//  DataSource+ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

public extension DataSource where Self: TableListAdapter {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: tableList.listDelegate)
    }
}

public extension DataSource where Self: CollectionListAdapter {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: collectionList.listDelegate)
    }
}

public extension DataSource where Self: TableListAdapter, Self: CollectionListAdapter {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: tableList.listDelegate)
            .context(with: collectionList.listDelegate)
    }
}

public extension DataSource where Self: ItemCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: itemCached.listDelegate)
    }
}

public extension DataSource where Self: TableListAdapter, Self: ItemCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: tableList.listDelegate)
            .context(with: itemCached.listDelegate)
    }
}

public extension DataSource where Self: CollectionListAdapter, Self: ItemCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: collectionList.listDelegate)
            .context(with: itemCached.listDelegate)
    }
}

public extension DataSource
where Self: TableListAdapter, Self: CollectionListAdapter, Self: ItemCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: tableList.listDelegate)
            .context(with: collectionList.listDelegate)
            .context(with: itemCached.listDelegate)
    }
}

// MARK: - DataSource + nested Table Adapter
public extension DataSource
where
    SourceBase.Source: TableListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    func tableListBySubsource() -> TableList<AdapterBase> { .init(adapterBase) }
}

public extension TableListAdapter
where
    SourceBase.Source: TableListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    var tableList: TableList<AdapterBase> { tableListBySubsource() }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func tableListBySubsource() -> TableList<AdapterBase> { .init(adapterBase) }
}

public extension TableListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    var tableList: TableList<AdapterBase> { tableListBySubsource() }
}

// MARK: - DataSource + nested Collection Adapter

public extension DataSource
where
    SourceBase.Source: CollectionListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    func collectionListBySubsource() -> CollectionList<AdapterBase> { .init(adapterBase) }
}

public extension CollectionListAdapter
where
    SourceBase.Source: CollectionListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    var collectionList: CollectionList<AdapterBase> { collectionListBySubsource() }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func collectionListBySubsource() -> CollectionList<AdapterBase> { .init(adapterBase) }
}

public extension CollectionListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    var collectionList: CollectionList<AdapterBase> { collectionListBySubsource() }
}
