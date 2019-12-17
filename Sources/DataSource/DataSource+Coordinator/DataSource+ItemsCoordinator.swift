//
//  DataSource+ItemsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where SourceBase.Source: Collection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemsCoordinator(sourceBase: sourceBase)
    }
}

public extension DataSource
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableItemsCoordinator(sourceBase: sourceBase)
    }
}

public extension UpdatableDataSource
where SourceBase.Source: Collection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(ItemsCoordinator(sourceBase: sourceBase))
    }
}

public extension UpdatableDataSource
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(RangeReplacableItemsCoordinator(sourceBase: sourceBase))
    }
}
