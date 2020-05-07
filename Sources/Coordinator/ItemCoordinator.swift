//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

import Foundation

final class ItemCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    lazy var item = DiffableValue<SourceBase.Item, ItemRelatedCache>(
        differ: defaultUpdate.diff,
        value: source,
        cache: .init()
    )
    
    override var multiType: SourceMultipleType { .single }
    
    override func item(at path: IndexPath) -> Item { item.value }
    override func itemRelatedCache(at path: IndexPath) -> ItemRelatedCache { item.cache }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { 1 }
    
    override func setup() {
        sourceType = selectorSets.hasIndex ? .section : .cell
    }
}
