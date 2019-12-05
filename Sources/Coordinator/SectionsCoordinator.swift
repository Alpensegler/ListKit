//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

class SectionsCoordinator<Source: DataSource>: SourceListCoordinator<Source>
where
    Source.Source: Collection,
    Source.Source.Element: Collection,
    Source.Source.Element.Element == Source.Item
{
    var sections = [[Item]]()
    
    override func item(at path: Path) -> Item { sections[path] }
    
    override func setup() {
        sections = source.map { $0.map { $0 } }
        sourceType = .section
    }
    
    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
        .multiple(.init(source: source, coordinator: self) { self.sections })
    }
    
    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
        .multiple(.init(source: source, coordinator: self) { self.sections })
    }
    
    func configSourceIndices() {
        sourceIndices = sections.map { .section(index: 0, count: $0.count) }
    }
}


class RangeReplacableSectionsCoordinator<Source: DataSource>: SectionsCoordinator<Source>
where
    Source.Source: RangeReplaceableCollection,
    Source.Source.Element: RangeReplaceableCollection,
    Source.Source.Element.Element == Source.Item
{
    override func setup() {
        super.setup()
        rangeReplacable = true
    }
    
    override func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) {
        source.apply(changes, indexTransform: { $0 }, valueTransform: { .init($0 as! [Item]) })
        sections.apply(changes, indexTransform: { $0 }, valueTransform: { $0 as! [Item] })
        configSourceIndices()
    }
    
    override func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) {
        for (offset, change) in changes.enumerated() where !change.isEmpty {
            sections[offset].apply(change, indexTransform: { $0 }, valueTransform: { $0 as! Item })
        }
        source = .init(sections.map { .init($0) })
        configSourceIndices()
    }
    
    override func sectionApplyMultiSection(changes: ValueChanges<[Item], Int>) {
        source.apply(changes, indexTransform: { $0 }, valueTransform: { .init($0) })
        sections.apply(changes, indexTransform: { $0 }, valueTransform: { $0 })
        configSourceIndices()
    }
    
    override func sectionApplyItem(changes: [ValueChanges<Item, Int>]) {
        for (offset, change) in changes.enumerated() where !change.isEmpty {
            sections[offset].apply(change, indexTransform: { $0 }, valueTransform: { $0 })
        }
        source = .init(sections.map { .init($0) })
        configSourceIndices()
    }
}
