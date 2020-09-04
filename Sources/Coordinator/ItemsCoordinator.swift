//
//  SectionCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

import Foundation

class ItemsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    lazy var items = toItems(source)
    
    var updateType: ItemsCoordinatorUpdate<SourceBase>.Type {
        ItemsCoordinatorUpdate<SourceBase>.self
    }
    
    func toItems(_ source: SourceBase.Source) -> ContiguousArray<Item> {
        source.mapContiguous { $0 }
    }
    
    override func numbersOfItems(in section: Int) -> Int { items.count }
    override func numbersOfSections() -> Int { items.isEmpty && options.removeEmptySection ? 0 : 1 }

    override func item(at indexPath: IndexPath) -> Item { items[indexPath.item] }

    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> CoordinatorUpdate {
        let coordinator = coordinator as! ItemsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: .init(updateWay, or: update),
            values: (coordinator.items, items),
            sources: (coordinator.source, source),
            options: (coordinator.options, options)
        )
    }

    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> CoordinatorUpdate {
        let sourcesAfterUpdate = update.source
        let itemsAfterUpdate = sourcesAfterUpdate.map(toItems)
        return updateType.init(
            coordinator: self,
            update: update,
            values: (items, itemsAfterUpdate ?? items),
            sources: (source, sourcesAfterUpdate ?? source),
            options: (self.options, options ?? self.options)
        )
    }
}

final class RangeReplacableItemsCoordinator<SourceBase: DataSource>: ItemsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == SourceBase.Item
{
    override var updateType: ItemsCoordinatorUpdate<SourceBase>.Type {
        RangeReplacableItemsCoordinatorUpdate<SourceBase>.self
    }
}


