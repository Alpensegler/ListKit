//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

class SectionsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Source.Element: Collection,
    SourceBase.Source.Element.Element == SourceBase.Item
{
    var sections = [[DiffableValue<Item, ItemRelatedCache>]]()
    var _source: SourceBase.Source
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        _source = sourceBase.source(storage: storage)
        
        super.init(storage: storage)
        defaultUpdate = sourceBase.listUpdate
    }
    
    override var multiType: SourceMultipleType { .multiple }
    override var source: SourceBase.Source { _source }
    
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

extension SectionsCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
