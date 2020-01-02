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
        SourcesCoordinator(sourceBase: sourceBase)
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourcesCoordinator(sourceBase: sourceBase, storage: coordinatorStorage)
    }
}
