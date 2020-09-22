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
    override func configSourceType() -> SourceType { isSectioned ? .sectionItems : .items }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! ItemCoordinator<SourceBase>
        return ItemCoordinatorUpdate(
            self,
            update: ListUpdate(updateWay),
            sources: (coordinator.source, source),
            options: (coordinator.options, options)
        )
    }
    
    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        return ItemCoordinatorUpdate(
            self,
            update: update,
            sources: (source, update.source ?? source),
            options: (self.options, options ?? self.options)
        )
    }
}
