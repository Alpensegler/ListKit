//
//  DataSource+SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

import Foundation

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        DataSourcesCoordinator(sources: sourceBase)
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
        sourceBase.coordinator(with: DataSourcesCoordinator(sources: sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func itemContext<List: ListView>(for listView: List, at index: IndexPath) -> [ListItemContext<List>] {
        _itemContext(for: listView, at: index)
    }
}
