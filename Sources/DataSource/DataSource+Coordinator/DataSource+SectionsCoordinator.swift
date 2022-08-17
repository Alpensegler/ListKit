//
//  DataSource+SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

public extension DataSource
where
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        SectionsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        RangeReplacableSectionsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: SectionsCoordinator(sourceBase))
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: RangeReplacableSectionsCoordinator(sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == Model,
    Self: ListAdapter
{
    func modelContext(
        for listView: View,
        at section: Int,
        item: Int
    ) -> [ListModelContext] {
        _modelContext(for: listView, at: .init(section: section, item: item))
    }
}
