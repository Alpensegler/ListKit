//
//  DataSource+ModelsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

public extension DataSource
where SourceBase.Source: Collection, SourceBase.Source.Element == Model {
    var listCoordinator: ListCoordinator<SourceBase> {
        ModelsCoordinator(sourceBase)
    }
}

public extension DataSource
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == Model {
    var listCoordinator: ListCoordinator<SourceBase> {
        RangeReplacableModelsCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: Collection,
    SourceBase.Source.Element == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: ModelsCoordinator(sourceBase))
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: RangeReplacableModelsCoordinator(sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: Collection,
    SourceBase.Source.Element == Model
{
    func modelContext<List: ListView>(for listView: List, at index: Int) -> [ListModelContext<List>] {
        _modelContext(for: listView, at: .init(item: index))
    }
}
