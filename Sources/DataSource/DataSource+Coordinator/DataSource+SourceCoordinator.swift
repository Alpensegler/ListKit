//
//  DataSource+SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension DataSource
where SourceBase.Source: DataSource, SourceBase.Source.Item == Item {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        WrapperCoordinator(sourceBase)
    }
}

public extension DataSource
where
    SourceBase: UpdatableDataSource,
    SourceBase.Source: DataSource,
    SourceBase.Source.Item == Item
{
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        WrapperCoordinator(updatable: sourceBase)
    }
}
