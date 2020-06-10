//
//  DataSource+ItemsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

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
