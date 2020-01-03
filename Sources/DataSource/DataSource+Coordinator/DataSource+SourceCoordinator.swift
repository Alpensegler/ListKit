//
//  DataSource+SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where SourceBase.Source: DataSource, SourceBase.Source.Item == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourceCoordinator(sourceBase)
    }
}

public extension UpdatableDataSource
where SourceBase.Source: DataSource, SourceBase.Source.Item == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        SourceCoordinator(sourceBase, storage: coordinatorStorage)
    }
}
