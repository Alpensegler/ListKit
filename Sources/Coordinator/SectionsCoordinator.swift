//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

class SectionsCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    var sections = [[DiffableValue<Item, ItemRelatedCache>]]()
    
    override var multiType: SourceMultipleType { .multiple }
    
    override func item(at path: PathConvertible) -> Item { sections[path].value }
    override func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache {
        sections[path].cache
    }
    
    override func numbersOfSections() -> Int { sections.count }
    override func numbersOfItems(in section: Int) -> Int { sections[section].count }
    
    override var isEmpty: Bool { sections.isEmpty }
    
    override func setup() {
        super.setup()
        sections = source.map { $0.map { DiffableValue(differ: defaultUpdate.diff, value: $0, cache: .init()) } }
        sourceType = .section
    }
}


final class RangeReplacableSectionsCoordinator<SourceBase: DataSource>: SectionsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: RangeReplaceableCollection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    
    
}
