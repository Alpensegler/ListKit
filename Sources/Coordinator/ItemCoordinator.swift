//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

import Foundation

final class ItemCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    typealias Value = ValueRelated<Item, ItemRelatedCache>
    
    lazy var value = Value(source, related: ItemRelatedCache())
    
    override var multiType: SourceMultipleType { .single }
    
    override func item(at section: Int, _ item: Int) -> Item { value.value }
    override func itemRelatedCache(at section: Int, _ item: Int) -> ItemRelatedCache {
        value.related
    }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { 1 }
    
    override func configureIsSectioned() -> Bool { selectorsHasSection }
}
