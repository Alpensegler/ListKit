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
    var items = [Diffable<Item, ItemRelatedCache>]()
    var updatingSectionCount: Int?
    lazy var keepSection = options.contains(.keepSectionIfEmpty)
    lazy var preferSection = options.contains(.preferSection)
    
    override var multiType: SourceMultipleType {
        sourceType == .section ? .single : .multiple
    }
    
    override var isEmpty: Bool { items.isEmpty }
    
    func difference(
        to isTo: Bool,
        _ items: [Diffable<Item, ItemRelatedCache>],
        _ source: SourceBase.Source!,
        _ keepSectionIfEmpty: Mapping<Bool>,
        _ differ: Differ<Item>
    ) -> ItemsCoordinatorDifference<Item> {
        let mapping = isTo
            ? (source: self.items, target: items)
            : (source: items, target: self.items)
        let source: Mapping = isTo ? (self.source, source) : (source, self.source)
        let diff = ItemsCoordinatorDifference(mapping: mapping, differ: differ)
        diff.keepSectionIfEmpty = keepSectionIfEmpty
        diff.coordinatorChange = {
            self.items = mapping.target
            self.source = source.target
        }
        diff.updateSectionCount = { self.updatingSectionCount = $0 }
        if !isTo {
            self.items = items
            self.source = source.source
        }
        return diff
    }
    
    func toItems(_ source: SourceBase.Source) -> [Diffable<Item, ItemRelatedCache>] {
        source.map { ($0, .init()) }
    }
    
    override func item(at path: IndexPath) -> Item { items[path.item].value }
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache {
        items[path.item].related
    }
    
    override func numbersOfItems(in section: Int) -> Int { items.count }
    override func numbersOfSections() -> Int {
        updatingSectionCount ?? (isEmpty && !keepSection ? 0 : 1)
    }
    
    override func setup() {
        sourceType = preferSection || selectorSets.hasIndex ? .section : .cell
        items = toItems(source)
    }
    
    override func updateTo(_ source: SourceBase.Source) {
        self.source = source
        items = toItems(source)
    }
    
    override func difference<Value>(
        from: Coordinator,
        differ: Differ<Value>?
    ) -> CoordinatorDifference? {
        let coordinator = from as! ItemsCoordinator<SourceBase>
        let (source, items) = (coordinator.source, coordinator.items)
        let mapping = (coordinator.keepSection, keepSection)
        guard let differ = (differ.map { .init($0) }) ?? defaultUpdate.diff else { return nil }
        return difference(to: false, items, source, mapping, differ)
    }
    
    override func difference(
        to source: SourceBase.Source,
        differ: Differ<Item>
    ) -> CoordinatorDifference {
        difference(to: true, toItems(source), source, (keepSection, keepSection), differ)
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
        _ items: [Diffable<Item, ItemRelatedCache>],
        _ source: SourceBase.Source!,
        _ keepSectionIfEmpty: Mapping<Bool>,
        _ differ: Differ<Item>
    ) -> ItemsCoordinatorDifference<Item> {
        let diff = super.difference(to: isTo, items, source, keepSectionIfEmpty, differ)
        diff.rangeRelplacable = true
        diff.extraCoordinatorChange = { items in
            self.items = items
            self.source = .init(items.lazy.map { $0.value })
        }
        return diff
    }
}


