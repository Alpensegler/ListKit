//
//  NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

final class NSCoordinator<SourceBase: NSDataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    let itemClosure: (Int, Int) -> Item
    let configSourceIndices: (NSCoordinator<SourceBase>) -> Void
    var counts = [Int]()
    var caches = [[ItemRelatedCache]]()
    
    override var multiType: SourceMultipleType { .noneDiffable }
    
    override func item(at path: Path) -> Item {
        itemClosure(path.section, path.item)
    }
    override func itemRelatedCache(at path: Path) -> ItemRelatedCache {
        caches[path]
    }
    
    override func numbersOfSections() -> Int { counts.count }
    override func numbersOfItems(in section: Int) -> Int { counts[section] }
    
    init(_ sourceBase: SourceBase) {
        itemClosure = { [unowned sourceBase] in sourceBase.item(at: $0, item: $1) }
        configSourceIndices = { [unowned sourceBase] in
            $0.caches = (0..<sourceBase.numbersOfSections()).map {
                Array(repeating: .init(), count: sourceBase.numbersOfItem(in: $0))
            }
            $0.counts = (0..<sourceBase.numbersOfSections()).map {
                sourceBase.numbersOfItem(in: $0)
            }
        }
        
        super.init(source: (), storage: sourceBase.coordinatorStorage)
        configSourceIndices(self)
        sourceType = .section
    }
}
