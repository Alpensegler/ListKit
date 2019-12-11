//
//  DataSource+Coordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public extension DataSource where SourceBase.Source == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemCoordinator(sourceBase: sourceBase)
    }
}

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

public extension DataSource
where
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SectionsCoordinator(sourceBase: sourceBase)
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(sourceBase: sourceBase)
    }
}

public extension DataSource
where SourceBase.Source: DataSource, SourceBase.Source.Item == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourceCoordinator(sourceBase: sourceBase)
    }
}

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

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: DataSource,
    SourceBase.Source.Element.SourceBase.Item == Item,
    Item == Any
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        AnySourcesCoordinator(sourceBase: sourceBase)
    }
}
