//
//  DataSource+ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

// swiftlint:disable opening_brace

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

public extension DataSource where Self: ModelCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: modelCached.listDelegate)
    }
}

public extension DataSource where Self: TableListAdapter, Self: ModelCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: tableList.listDelegate)
            .context(with: modelCached.listDelegate)
    }
}

public extension DataSource where Self: CollectionListAdapter, Self: ModelCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: collectionList.listDelegate)
            .context(with: modelCached.listDelegate)
    }
}

public extension DataSource
where Self: TableListAdapter, Self: CollectionListAdapter, Self: ModelCachedDataSource {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: scrollList.listDelegate)
            .context(with: tableList.listDelegate)
            .context(with: collectionList.listDelegate)
            .context(with: modelCached.listDelegate)
    }
}

// MARK: - DataSource + nested Table Adapter
public extension DataSource
where
    SourceBase.Source: TableListAdapter,
    SourceBase.Source.SourceBase.Model == Model
{
    func tableListBySubsource() -> TableList<AdapterBase> { .init(adapterBase) }
}

public extension TableListAdapter
where
    SourceBase.Source: TableListAdapter,
    SourceBase.Source.SourceBase.Model == Model
{
    var tableList: TableList<AdapterBase> { tableListBySubsource() }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Model == Model
{
    func tableListBySubsource() -> TableList<AdapterBase> { .init(adapterBase) }
}

public extension TableListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Model == Model
{
    var tableList: TableList<AdapterBase> { tableListBySubsource() }
}

// MARK: - DataSource + nested Collection Adapter
public extension DataSource
where
    SourceBase.Source: CollectionListAdapter,
    SourceBase.Source.SourceBase.Model == Model
{
    func collectionListBySubsource() -> CollectionList<AdapterBase> { .init(adapterBase) }
}

public extension CollectionListAdapter
where
    SourceBase.Source: CollectionListAdapter,
    SourceBase.Source.SourceBase.Model == Model
{
    var collectionList: CollectionList<AdapterBase> { collectionListBySubsource() }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Model == Model
{
    func collectionListBySubsource() -> CollectionList<AdapterBase> { .init(adapterBase) }
}

public extension CollectionListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Model == Model
{
    var collectionList: CollectionList<AdapterBase> { collectionListBySubsource() }
}
