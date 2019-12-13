//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

class SectionsCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    var sections = [[Item]]()
    
    override func item<Path: PathConvertible>(at path: Path) -> Item { sections[path] }
    
    override func setup() {
        sections = source.map { $0.map { $0 } }
        sourceType = .section
        configSourceIndices()
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


class RangeReplacableSectionsCoordinator<SourceBase: DataSource>: SectionsCoordinator<SourceBase>
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    override func setup() {
        super.setup()
        rangeReplacable = true
    }
    
    override func anySectionApplyMultiSection(changes: ValueChanges<[Any], Int>) {
        _source.apply(changes, indexTransform: { $0 }, valueTransform: { .init($0 as! [Item]) })
        sections.apply(changes, indexTransform: { $0 }, valueTransform: { $0 as! [Item] })
        configSourceIndices()
    }
    
    override func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) {
        for (offset, change) in changes.enumerated() where !change.isEmpty {
            sections[offset].apply(change, indexTransform: { $0 }, valueTransform: { $0 as! Item })
        }
        _source = .init(sections.map { .init($0) })
        configSourceIndices()
    }
    
    override func sectionApplyMultiSection(changes: ValueChanges<[Item], Int>) {
        _source.apply(changes, indexTransform: { $0 }, valueTransform: { .init($0) })
        sections.apply(changes, indexTransform: { $0 }, valueTransform: { $0 })
        configSourceIndices()
    }
    
    override func sectionApplyItem(changes: [ValueChanges<Item, Int>]) {
        for (offset, change) in changes.enumerated() where !change.isEmpty {
            sections[offset].apply(change, indexTransform: { $0 }, valueTransform: { $0 })
        }
        _source = .init(sections.map { .init($0) })
        configSourceIndices()
    }
}
