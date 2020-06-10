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
    lazy var caches: [[ItemRelatedCache]] = {
        source.indices.map { Array(repeating: .init(), count: source[$0]) }
    }()
    
    override var multiType: SourceMultipleType { .noneDiffable }
    
    override func item(at section: Int, _ item: Int) -> Item {
        sourceBase.item(at: section, item)
    }
    override func itemRelatedCache(at section: Int, _ item: Int) -> ItemRelatedCache {
        caches[section][item]
    }
    
    override func numbersOfItems(in section: Int) -> Int { source[safe: section] ?? 0 }
    override func numbersOfSections() -> Int { source.count }
    
    override func configureIsSectioned() -> Bool {
        preferSection || selectorsHasSection || source.count > 1
    }
    
    override init(_ sourceBase: SourceBase, id: AnyHashable = ObjectIdentifier(SourceBase.self)) {
        self.sourceBase = sourceBase
        super.init(sourceBase, id: id)
    }
}
