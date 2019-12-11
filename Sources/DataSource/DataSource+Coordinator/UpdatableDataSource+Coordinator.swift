//
//  UpdatableDataSource+Coordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

extension UpdatableDataSource {
    func addToStorage(_ coordinator: ListCoordinator<SourceBase>) -> ListCoordinator<SourceBase> {
        coordinatorStorage.coordinator = coordinator
        return coordinator
    }
}

public extension UpdatableDataSource where SourceBase.Source == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(ItemCoordinator(sourceBase: sourceBase))
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

public extension UpdatableDataSource
where
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(SectionsCoordinator(sourceBase: sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(RangeReplacableSectionsCoordinator(sourceBase: sourceBase))
    }
}

public extension UpdatableDataSource
where SourceBase.Source: DataSource, SourceBase.Source.Item == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(SourceCoordinator(sourceBase: sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(SourcesCoordinator(sourceBase: sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item,
    Item == Any
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(AnySourcesCoordinator(sourceBase: sourceBase))
    }
}

public extension NSDataSource where SourceBase: NSDataSource {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        addToStorage(NSCoordinator(sourceBase: sourceBase))
    }
}



