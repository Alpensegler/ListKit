//
//  DataSource+ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource where SourceBase.Source == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemCoordinator(sourceBase)
    }
}

public extension DataSource where SourceBase.Source == Item, SourceBase: UpdatableDataSource {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemCoordinator(updatable: sourceBase)
    }
}
