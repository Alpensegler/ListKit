//
//  DataSource+ItemsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

public extension DataSource
where SourceBase.Source: Collection, SourceBase.Source.Element == Item {
    var listCoordinator: ListCoordinator<SourceBase> {
        ItemsCoordinator(sourceBase)
    }
}

public extension DataSource
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == Item {
    var listCoordinator: ListCoordinator<SourceBase> {
        RangeReplacableItemsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: Collection,
    SourceBase.Source.Element == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: ItemsCoordinator(sourceBase))
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == Item
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: RangeReplacableItemsCoordinator(sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: Collection,
    SourceBase.Source.Element == Item
{
    func itemContext<List: ListView>(for listView: List, at index: Int) -> [ListItemContext<List>] {
        _itemContext(for: listView, at: .init(item: index))
    }
}
