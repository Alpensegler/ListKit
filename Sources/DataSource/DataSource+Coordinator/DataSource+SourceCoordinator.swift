//
//  DataSource+SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

import Foundation

public extension DataSource
where SourceBase.Source: DataSource, SourceBase.Source.Model == Model {
    var listCoordinator: ListCoordinator<SourceBase> {
        WrapperCoordinator(wrapper: sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: DataSource,
    SourceBase.Source.Model == Model
{
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: WrapperCoordinator(wrapper: sourceBase))
    }
}

public extension UpdatableDataSource
where
    SourceBase.Source: DataSource,
    SourceBase.Source.SourceBase == AnySources,
    SourceBase.Model == Any
{
    func modelContext<List: ListView>(for listView: List, at index: IndexPath) -> [ListModelContext<List>] {
        _modelContext(for: listView, at: index)
    }
}
