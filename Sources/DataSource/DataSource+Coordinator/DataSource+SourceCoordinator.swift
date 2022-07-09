//
//  DataSource+SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

import Foundation

public extension DataSource
where SourceBase.Source: DataSource, SourceBase.Source.Item == Item {
    var listCoordinator: ListCoordinator<SourceBase> {
        WrapperCoordinator(wrapper: sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: DataSource,
    SourceBase.Source.Item == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: WrapperCoordinator(wrapper: sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: DataSource,
    SourceBase.Source.SourceBase == AnySources,
    SourceBase.Item == Any
{
    func itemContext<List: ListView>(for listView: List, at index: IndexPath) -> [ListItemContext<List>] {
        _itemContext(for: listView, at: index)
    }
}
