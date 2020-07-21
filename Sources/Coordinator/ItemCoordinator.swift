//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

import Foundation

final class ItemCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    override var multiType: SourceMultipleType { .single }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { 1 }
    
    override func item(at section: Int, _ item: Int) -> Item { source }
    
    override func isSectioned() -> Bool { options.preferSection || super.isSectioned() }
}
