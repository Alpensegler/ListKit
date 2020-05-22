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
    var items = [(value: Item, related: ItemRelatedCache)]()
    
    override var multiType: SourceMultipleType {
        sourceType == .section ? .single : .multiple
    }
    
    override var isEmpty: Bool { sourceType == .cell && items.isEmpty }
    
    func difference(
        to isTo: Bool,
        items: [(value: Item, related: ItemRelatedCache)],
        source: SourceBase.Source,
        differ: Differ<Item>
    ) -> ItemsCoordinatorDifference<Item> {
        let mapping = isTo
            ? (source: self.items, target: items)
            : (source: items, target: self.items)
        let source: Mapping = isTo ? (self.source, source) : (source, self.source)
        let diff = ItemsCoordinatorDifference(mapping: mapping, differ: differ)
        diff.coordinatorChange = {
            self.items = mapping.target
            self.source = source.target
        }
        if !isTo {
            self.items = items
            self.source = source.source
        }
        return diff
    }
    
    override func item(at path: IndexPath) -> Item { items[path.item].value }
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache {
        items[path.item].related
    }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { items.count }
    
    override func setup() {
        sourceType = selectorSets.hasIndex ? .section : .cell
        items = source.map { ($0, .init()) }
    }
    
    override func updateTo(_ source: SourceBase.Source) {
        self.source = source
        items = source.map { ($0, .init()) }
    }
    
    override func difference<Value>(
        from: Coordinator,
        differ: Differ<Value>?
    ) -> CoordinatorDifference? {
        let coordinator = from as! ItemsCoordinator<SourceBase>
        let items = coordinator.items
        guard let differ = (differ.map { .init($0) }) ?? defaultUpdate.diff else { return nil }
        return difference(to: false, items: items, source: coordinator.source, differ: differ)
    }
    
    override func difference(
        to source: SourceBase.Source,
        differ: Differ<Item>
    ) -> CoordinatorDifference {
        difference(to: true, items: source.map { ($0, .init()) }, source: source, differ: differ)
    }
}

final class RangeReplacableItemsCoordinator<SourceBase: DataSource>: ItemsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == SourceBase.Item
{
    override func difference(
        to isTo: Bool,
        items: [(value: Item, related: ItemRelatedCache)],
        source: SourceBase.Source,
        differ: Differ<Item>
    ) -> ItemsCoordinatorDifference<Item> {
        let diff = super.difference(to: isTo, items: items, source: source, differ: differ)
        diff.rangeRelplacable = true
        diff.internalCoordinatorChange = { items in
            self.items = items
            self.source = .init(items.lazy.map { $0.value })
        }
        return diff
    }
}


