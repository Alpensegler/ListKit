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
    
    override var isEmpty: Bool { source.isEmpty }
    override var multiType: SourceMultipleType { sectioned ? .single : .multiple }
    
    func toItems(_ source: SourceBase.Source) -> ContiguousArray<Item> {
        source.mapContiguous { $0 }
    }
    
    override func numbersOfItems(in section: Int) -> Int { items.count }
    override func numbersOfSections() -> Int { isEmpty && !options.preferSection ? 0 : 1 }
    
    override func item(at section: Int, _ item: Int) -> Item { items[item] }
    
    override func isSectioned() -> Bool { options.preferSection || super.isSectioned() }
    
    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        differ: Differ<Item>?
    ) -> CoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! ItemsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: ListUpdate(differ, or: update),
            values: (coordinator.items, items),
            sources: (coordinator.source, source),
            keepSectionIfEmpty: (coordinator.options.keepEmptySection, options.keepEmptySection)
        )
    }
    
    override func update(_ update: ListUpdate<SourceBase>) -> CoordinatorUpdate<SourceBase> {
        let sourcesAfterUpdate = update.source
        let itemsAfterUpdate = sourcesAfterUpdate.map(toItems)
        defer {
            source = sourcesAfterUpdate ?? source
            items = itemsAfterUpdate ?? items
        }
        return updateType.init(
            coordinator: self,
            update: update,
            values: (items, itemsAfterUpdate ?? items),
            sources: (source, sourcesAfterUpdate ?? source),
            keepSectionIfEmpty: (options.keepEmptySection, options.keepEmptySection)
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


