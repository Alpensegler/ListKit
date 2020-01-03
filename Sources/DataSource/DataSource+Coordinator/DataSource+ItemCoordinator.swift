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

public extension UpdatableDataSource where SourceBase.Source == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        ItemCoordinator(sourceBase, storage: coordinatorStorage)
    }
}
