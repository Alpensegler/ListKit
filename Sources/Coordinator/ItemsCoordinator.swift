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
    typealias Value = ValueRelated<Item, ItemRelatedCache>
    
    lazy var items = toItems(source)
    var updatingSectionCount: Int?
    
    override var multiType: SourceMultipleType { isSectioned ? .single : .multiple }
    
    override var isEmpty: Bool { items.isEmpty }
    
    func difference(
        to isTo: Bool,
        _ items: ContiguousArray<Value>,
        _ source: SourceBase.Source!,
        _ keepSectionIfEmpty: Mapping<Bool>,
        _ differ: Differ<Item>?
    ) -> ItemsCoordinatorDifference<Item> {
        let mapping = isTo
            ? (source: self.items, target: items)
            : (source: items, target: self.items)
        let source: Mapping = isTo ? (self.source, source) : (source, self.source)
        let diff = ItemsCoordinatorDifference(mapping: mapping, differ: differ)
        diff.isSectioned = false
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
    
    func toItems(_ source: SourceBase.Source) -> ContiguousArray<Value> {
        source.mapContiguous { .init($0, related: .init()) }
    }
    
    override func item(at section: Int, _ item: Int) -> Item { items[item].value }
    override func itemRelatedCache(at section: Int, _ item: Int) -> ItemRelatedCache {
        items[item].related
    }
    
    override func numbersOfItems(in section: Int) -> Int { items.count }
    override func numbersOfSections() -> Int {
        updatingSectionCount ?? (isEmpty && !keepSection ? 0 : 1)
    }
    
    override func configureIsSectioned() -> Bool { preferSection || selectorsHasSection }
    
    override func updateTo(_ source: SourceBase.Source) {
        self.source = source
        items = toItems(source)
    }
    
    // Diffs:
    override func difference(
        from coordinator: ListCoordinator<SourceBase>,
        differ: Differ<Item>?
    ) -> CoordinatorDifference {
        let coordinator = coordinator as! ItemsCoordinator<SourceBase>
        let (source, items) = (coordinator.source, coordinator.items)
        let mapping = (coordinator.keepSection, keepSection)
        return difference(to: false, items, source, mapping, differ ?? update.diff)
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
        _ items: ContiguousArray<Value>,
        _ source: SourceBase.Source!,
        _ keepSectionIfEmpty: Mapping<Bool>,
        _ differ: Differ<Item>?
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


