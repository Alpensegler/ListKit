//
//  DataSource+SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SectionsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SectionsCoordinator(updatable: sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(updatable: sourceBase)
    }
}
