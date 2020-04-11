//
//  SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

final class SourceCoordinator<SourceBase: DataSource>: WrapperCoordinator<SourceBase, SourceBase.Source>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: DataSource,
    SourceBase.Source.Item == SourceBase.Item
{
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        super.init(
            source: sourceBase.source(storage: storage),
            wrappedCoodinator: sourceBase.source.makeListCoordinator()
        ) { $0 }
    }
}

extension SourceCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
