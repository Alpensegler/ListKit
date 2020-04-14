//
//  ItemCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

final class ItemCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase  {
    var item: DiffableValue<SourceBase.Item, ItemRelatedCache>
    
    override var source: SourceBase.Item { item.value }
    override var multiType: SourceMultipleType { .single }
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        let update = sourceBase.listUpdate
        item = .init(
            differ: update.diff,
            value: sourceBase.source(storage: storage),
            cache: .init()
        )
        
        super.init(storage: storage)
        defaultUpdate = update
    }
    
    override func item(at path: PathConvertible) -> Item { item.value }
    override func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache { item.cache }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { 1 }
    
    override func setup() {
        super.setup()
        sourceType = selectorSets.hasIndex ? .section : .cell
    }
}

extension ItemCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
