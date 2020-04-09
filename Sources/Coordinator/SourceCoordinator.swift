//
//  SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

final class SourceCoordinator<SourceBase: DataSource>: ItemTypedWrapperCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: DataSource,
    SourceBase.Source.Item == SourceBase.Item
{
    var storedSource: SourceBase.Source
    var coordinator: ListCoordinator<SourceBase.Source.SourceBase>
    override var source: SourceBase.Source { storedSource }
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var wrappedItemTypedCoodinator: ItemTypedCoorinator<Item> { coordinator }
    
    override init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        storedSource = sourceBase.source(storage: storage)
        coordinator = storedSource.makeListCoordinator()
        
        super.init(sourceBase, storage: storage)
    }
}

extension SourceCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
