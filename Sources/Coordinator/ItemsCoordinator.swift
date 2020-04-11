//
//  SectionCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

class ItemsCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    var items = [DiffableValue<Item, ItemRelatedCache>]()
    
    override var multiType: SourceMultipleType {
        sourceType == .section ? .single : .multiple
    }
    
    override var isEmpty: Bool { sourceType == .cell && items.isEmpty }
    
    override func item(at path: PathConvertible) -> Item { items[path.item].value }
    override func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache {
        items[path.item].cache
    }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { items.count }
    
    override func setup() {
        super.setup()
        sourceType = selectorSets.hasIndex ? .section : .cell
        items = source.map { DiffableValue(differ: defaultUpdate.diff, value: $0, cache: .init()) }
    }
    
    override func itemDifference(
        from coordinator: BaseCoordinator,
        differ: Differ<Item>
    ) -> [Difference<ItemRelatedCache>] {
        return [diff(from: coordinator as! ItemsCoordinator<SourceBase>, differ: differ)]
    }
    
    func diff(
        from coordinator: ItemsCoordinator<SourceBase>,
        differ: Differ<Item>
    ) -> ValueDifference<Item, ItemRelatedCache> {
        let diff = ValueDifference(source: coordinator.items, target: items, differ: differ)
        diff.starting = {
//            if coordinator.needUpdateCaches {
//                self.needUpdateCaches = true
//                self.configNestedNotNewIfNeeded()
//            }
            self.items = coordinator.items
            self._source = coordinator._source
        }
        diff.ending = { [items, _source] in
            self.items = items
            self._source = _source
        }
        diff.finish = configNestedIfNeeded
        return diff
    }
}

final class RangeReplacableItemsCoordinator<SourceBase: DataSource>: ItemsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == SourceBase.Item
{
    override func diff(
        from coordinator: ItemsCoordinator<SourceBase>,
        differ: Differ<Item>
    ) -> ValueDifference<Item, ItemRelatedCache> {
        let diff = super.diff(from: coordinator, differ: differ)
        diff.applying = {
            self.items.apply($0) { $0.value }
            self._source.apply($0) { $0.value.value }
        }
        return diff
    }
}


