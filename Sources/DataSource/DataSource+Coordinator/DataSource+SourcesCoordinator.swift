//
//  DataSource+SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(sources: sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(updatableSources: sourceBase)
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(sources: sourceBase) { $0.tableList.makeListCoordinator() }
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(sources: sourceBase) { $0.collectionList.makeListCoordinator() }
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(updatableSources: sourceBase) { $0.tableList.makeListCoordinator() }
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(updatableSources: sourceBase) { $0.collectionList.makeListCoordinator() }
    }
}
