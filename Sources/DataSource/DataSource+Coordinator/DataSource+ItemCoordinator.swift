//
//  DataSource+ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource where SourceBase.Source == Item {
    var listCoordinator: ListCoordinator<SourceBase> {
        ItemCoordinator(sourceBase)
    }
}

public extension DataSource where SourceBase.Source == Item, SourceBase: UpdatableDataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: ItemCoordinator(sourceBase))
    }
}
