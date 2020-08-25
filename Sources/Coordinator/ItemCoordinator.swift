//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

import Foundation

final class ItemCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { 1 }
    
    override func item(at indexPath: IndexPath) -> Item { source }
    
    override func isSectioned() -> Bool { options.preferSection || super.isSectioned() }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        let coordinator = coordinator as! ItemCoordinator<SourceBase>
        return ItemCoordinatorUpdate(
            coordinator: self,
            update: .init(updateWay, or: update),
            sources: (coordinator.source, source)
        )
    }
    
    override func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate {
        let sourcesAfterUpdate = update.source
        return ItemCoordinatorUpdate(
            coordinator: self,
            update: update,
            sources: (source, sourcesAfterUpdate ?? source)
        )
    }
}
