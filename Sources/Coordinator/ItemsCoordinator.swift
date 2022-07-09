//
//  SectionCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

// swiftlint:disable opening_brace

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
    override func configSourceType() -> SourceType { isSectioned ? .sectionItems : .items }

    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Item>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! ItemsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: ListUpdate(updateWay),
            values: (coordinator.items, items),
            sources: (coordinator.source, source),
            options: (coordinator.options, options)
        )
    }

    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        updateType.init(
            coordinator: self,
            update: update,
            values: (items, update.source.map(toItems) ?? items),
            sources: (source, update.source ?? source),
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
