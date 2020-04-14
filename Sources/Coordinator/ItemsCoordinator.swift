//
//  SectionCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

class ItemsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Item == SourceBase.Source.Element
{
    var items = [DiffableValue<Item, ItemRelatedCache>]()
    var _source: SourceBase.Source
    
    override var source: SourceBase.Source { _source }
    
    override var multiType: SourceMultipleType {
        sourceType == .section ? .single : .multiple
    }
    
    override var isEmpty: Bool { sourceType == .cell && items.isEmpty }
    
    func difference(
        to isTo: Bool,
        items: [DiffableValue<Item, ItemRelatedCache>],
        source: SourceBase.Source,
        differ: Differ<Item>?
    ) -> ValueDifference<Item, ItemRelatedCache> {
        let (sourceItems, tagetItems) = isTo ? (items, self.items) : (self.items, items)
        let targetSource = isTo ? source : self.source
        let diff = ValueDifference(source: sourceItems, target: tagetItems, differ: differ)
        diff.starting = {
            self.configNestedNotNewIfNeeded()
            if isTo { return }
            self.items = items
            self._source = source
        }
        diff.ending = {
            self.items = sourceItems
            self._source = targetSource
        }
        diff.finish = configNestedIfNeeded
        return diff
    }
    
    init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        _source = sourceBase.source(storage: storage)
        
        super.init(storage: storage)
        defaultUpdate = sourceBase.listUpdate
    }
    
    override func item(at path: PathConvertible) -> Item { items[path.item].value }
    override func itemRelatedCache(at path: PathConvertible) -> ItemRelatedCache {
        items[path.item].cache
    }
    
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfItems(in section: Int) -> Int { items.count }
    
    override func setup() {
        super.setup()
        sourceType = selectorSets.hasIndex ? .section : .cell
        items = source.map { DiffableValue(differ: defaultUpdate.diff, value: $0, cache: .init()) }
    }
    
    override func itemDifference(
        from coordinator: BaseCoordinator,
        differ: Differ<Item>
    ) -> [Difference<ItemRelatedCache>] {
        let coordinator = coordinator as! ItemsCoordinator<SourceBase>
        let (items, source) = (coordinator.items, coordinator.source)
        return [difference(to: false, items: items, source: source, differ: differ)]
    }
}

final class RangeReplacableItemsCoordinator<SourceBase: DataSource>: ItemsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == SourceBase.Item
{
    override func difference(
        to isTo: Bool,
        items: [DiffableValue<Item, ItemRelatedCache>],
        source: SourceBase.Source,
        differ: Differ<Item>?
    ) -> ValueDifference<Item, ItemRelatedCache> {
        let diff = super.difference(to: isTo, items: items, source: source, differ: differ)
        diff.applying = {
            self.items.apply($0) { $0.value }
            self._source.apply($0) { $0.value.value }
        }
        return diff
    }
}

extension ItemsCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}


