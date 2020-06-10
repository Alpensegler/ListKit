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
    var listCoordinator: ListCoordinator<SourceBase> {
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
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: SourcesCoordinator(sources: sourceBase))
    }
}
