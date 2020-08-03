//
//  NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

import Foundation

final class NSCoordinator<SourceBase: NSDataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    unowned let sourceBase: SourceBase
    
    override var multiType: SourceMultipleType { .other }
    override var isEmpty: Bool { numbersOfSections() == 0 }
    
    override func numbersOfItems(in section: Int) -> Int { source[safe: section] ?? 0 }
    override func numbersOfSections() -> Int { source.count }
    
    override func item(at section: Int, _ item: Int) -> Item { sourceBase.item(at: section, item) }
    
    override func isSectioned() -> Bool {
        options.preferSection || super.isSectioned() || source.count > 1
    }
    
    override init(_ sourceBase: SourceBase) {
        self.sourceBase = sourceBase
        super.init(sourceBase)
    }
}
