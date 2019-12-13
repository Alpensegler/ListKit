//
//  SectionCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

class ItemsCoordinator<SourceBase: DataSource>: SourceStoredListCoordinator<SourceBase>
where SourceBase.Source: Collection, SourceBase.Item == SourceBase.Source.Element {
    var items = [Item]()
    override var sourceType: SourceType {
        get { selectorSets.hasIndex ? .section : .cell }
        set { fatalError() }
    }
    
    override var isEmpty: Bool { sourceType == .cell && items.isEmpty }
    
    override func item<Path: PathConvertible>(at path: Path) -> Item { items[path.item] }
    
    override func setup() {
        items = source.map { $0 }
        configSourceIndices()
    }
    
    override func anyItemSources<Source: DataSource>(source: Source) -> AnyItemSources {
        .multiple(.init(source: source, coordinator: self) { self.items })
    }
    
    override func anySectionSources<Source: DataSource>(source: Source) -> AnySectionSources {
        sourceType == .section
            ? .other(Other(type: .cellContainer) { [.init(source: source, coordinator: self) { self.items }] })
            : .single(.init(source: source, coordinator: self) { self.items })
    }
    
    override func itemSources<Source: DataSource>(source: Source) -> ItemSource {
        .multiple(.init(source: source, coordinator: self) { self.items })
    }
    
    override func sectionSources<Source: DataSource>(source: Source) -> SectionSource {
        sourceType == .section
            ? .other(Other(type: .cellContainer) { [.init(source: source, coordinator: self) { self.items }] })
            : .single(.init(source: source, coordinator: self) { self.items })
    }
    
    func configSourceIndices() {
        sourceIndices = sourceType == .section
            ? [.section(index: 0, count: items.count)]
            : [.cell(indices: items.map { _ in 0 })]
    }
}

class RangeReplacableItemsCoordinator<SourceBase: DataSource>: ItemsCoordinator<SourceBase>
where SourceBase.Source: RangeReplaceableCollection, SourceBase.Source.Element == SourceBase.Item {
    override func setup() {
        super.setup()
        rangeReplacable = true
    }
    
    override func anyItemApplyMultiItem(changes: ValueChanges<Any, Int>) {
        _source.apply(changes, indexTransform: { $0 }, valueTransform: { $0 as! Item })
        items.apply(changes, indexTransform: { $0 }, valueTransform: { $0 as! Item })
        configSourceIndices()
    }
    
    override func anySectionApplyItem(changes: [ValueChanges<Any, Int>]) {
        _source.apply(changes[0], indexTransform: { $0 }, valueTransform: { $0 as! Item })
        items.apply(changes[0], indexTransform: { $0 }, valueTransform: { $0 as! Item })
        configSourceIndices()
    }
    
    override func itemApplyMultiItem(changes: ValueChanges<Item, Int>) {
        _source.apply(changes, indexTransform: { $0 }, valueTransform: { $0 })
        items.apply(changes, indexTransform: { $0 }, valueTransform: { $0 })
        configSourceIndices()
    }
    
    override func sectionApplyItem(changes: [ValueChanges<Item, Int>]) {
        _source.apply(changes[0], indexTransform: { $0 }, valueTransform: { $0 })
        items.apply(changes[0], indexTransform: { $0 }, valueTransform: { $0 })
        configSourceIndices()
    }
}


