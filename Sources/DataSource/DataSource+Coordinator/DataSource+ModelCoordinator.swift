//
//  DataSource+ModelCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource where SourceBase.Source == Model {
    var listCoordinator: ListCoordinator<SourceBase> {
        ModelCoordinator(sourceBase)
    }
}

public extension DataSource where SourceBase.Source == Model, SourceBase: UpdatableDataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: ModelCoordinator(sourceBase))
    }
}

public extension UpdatableDataSource where SourceBase.Source == Model {
    func modelContext<List: ListView>(for listView: List) -> [ListModelContext<List>] {
        _modelContext(for: listView, at: .init(item: 0))
    }
}
