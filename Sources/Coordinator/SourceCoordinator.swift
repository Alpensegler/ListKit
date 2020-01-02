//
//  SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

final class SourceCoordinator<SourceBase: DataSource>: ItemTypedWrapperCoordinator<SourceBase>
where SourceBase.Source: DataSource, SourceBase.Source.Item == SourceBase.Item {
    var storedSource: SourceBase.Source
    var coordinator: ListCoordinator<SourceBase.Source.SourceBase>
    override var source: SourceBase.Source { storedSource }
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var wrappedItemTypedCoodinator: ItemTypedCoorinator<Item> { coordinator }
    
    override init(sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        storedSource = storage?.source ?? sourceBase.source
        coordinator = storedSource.makeListCoordinator()
        
        super.init(sourceBase: sourceBase, storage: storage)
    }
}
