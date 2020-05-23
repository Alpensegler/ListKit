//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

import Foundation

class SectionsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    var sections = [[Diffable<Item, ItemRelatedCache>]]()
    
    override var multiType: SourceMultipleType { .multiple }
    
    func toSections(_ source: SourceBase.Source) -> [[Diffable<Item, ItemRelatedCache>]] {
        source.map { $0.map { ($0, related: .init()) } }
    }
    
    func difference(
        to isTo: Bool,
        sections: [[Diffable<Item, ItemRelatedCache>]],
        source: SourceBase.Source,
        differ: Differ<Item>
    ) -> SectionsCoordinatorDifference<Item> {
        let mapping = isTo
            ? (source: self.sections, target: sections)
            : (source: sections, target: self.sections)
        let source: Mapping = isTo ? (self.source, source) : (source, self.source)
        let diff = SectionsCoordinatorDifference(mapping: mapping, differ: differ)
        diff.coordinatorChange = {
            self.sections = mapping.target
            self.source = source.target
        }
        if !isTo {
            self.sections = mapping.source
            self.source = source.source
        }
        return diff
    }
    
    override func item(at path: IndexPath) -> Item { sections[path].value }
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache { sections[path].related }
    
    override func numbersOfSections() -> Int { sections.count }
    override func numbersOfItems(in section: Int) -> Int { sections[section].count }
    
    override var isEmpty: Bool { sections.isEmpty }
    
    override func setup() {
        sections = toSections(source)
        sourceType = .section
    }
    
    override func updateTo(_ source: SourceBase.Source) {
        self.source = source
        sections = toSections(source)
    }
    
    override func difference<Value>(
        from: Coordinator,
        differ: Differ<Value>?
    ) -> CoordinatorDifference? {
        let coordinator = from as! SectionsCoordinator<SourceBase>
        let sections = coordinator.sections
        guard let differ = (differ.map { .init($0) }) ?? defaultUpdate.diff else { return nil }
        return difference(to: false, sections: sections, source: coordinator.source, differ: differ)
    }
    
    override func difference(
        to source: SourceBase.Source,
        differ: Differ<Item>
    ) -> CoordinatorDifference {
        difference(to: true, sections: toSections(source), source: source, differ: differ)
    }
}


final class RangeReplacableSectionsCoordinator<SourceBase: DataSource>: SectionsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    override func difference(
        to isTo: Bool,
        sections: [[Diffable<Item, ItemRelatedCache>]],
        source: SourceBase.Source,
        differ: Differ<Item>
    ) -> SectionsCoordinatorDifference<Item> {
        let diff = super.difference(to: isTo, sections: sections, source: source, differ: differ)
        diff.rangeRelplacable = true
        diff.internalCoordinatorChange = { sections in
            self.sections = sections
            self.source = .init(sections.map { .init($0.lazy.map { $0.value }) })
        }
        return diff
    }
}
