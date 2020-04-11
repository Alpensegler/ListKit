//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

final class ItemCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    lazy var item: DiffableValue<SourceBase.Item, ItemRelatedCache> = .init(
        differ: defaultUpdate.diff,
        value: source,
        cache: .init()
    )
    
    override var multiType: SourceMultipleType { .single }
    
    override func item(at path: PathConvertible) -> Item { item.value }
    override func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache { item.cache }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { 1 }
    
    override func setup() {
        super.setup()
        sourceType = selectorSets.hasIndex ? .section : .cell
    }
}
