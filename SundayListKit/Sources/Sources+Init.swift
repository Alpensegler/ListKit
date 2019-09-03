//
//  Sources+Init.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/7.
//  Copyright © 2019 Frain. All rights reserved.
//

//MARK: - List

public typealias ListSources<Item> = Sources<[AnySources<Item>], Item, Never>
public typealias TableListSources = TableSources<[AnyTableSources], Any>
public typealias CollectionListSources = CollectionSources<[AnyCollectionSources], Any>

public extension Sources
where
    SubSource: Collection,
    SubSource.Element: SourcesTypeEraser,
    SubSource.Element: Diffable,
    SubSource.Element.Item == Item,
    UIViewType == Never
{
    init(id: AnyHashable = UUID(), sources: SubSource) {
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        
        sourceClosure = nil
        _sourceStored = sources
        
        diffable = AnyDiffable(id)
    }
}

public extension Sources
where
    SubSource == [AnySources<Item>],
    UIViewType == Never
{
    private init(id: AnyHashable, _ sources: [SubSource.Element]) {
        var _sources = SubSource()
        _sources.append(contentsOf: sources)
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        diffable = .init(id)
        
        sourceClosure = nil
        _sourceStored = _sources
    }
    
    init<Value: Source>(id: AnyHashable = UUID(), source: Value?...) where Value.Item == Item {
        self.init(id: id, source.compactMap { $0?.eraseToAnySources() })
    }
    
    init<S0: Source, S1: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?) where S0.Item == Item, S1.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?) where S0.Item == Item, S1.Item == Item, S2.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S6.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S7.Item == Item, S6.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source, S8: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?, _ s8: S8?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S7.Item == Item, S6.Item == Item, S8.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
            s8.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source, S8: Source, S9: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?, _ s8: S8?, _ s9: S9?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S7.Item == Item, S6.Item == Item, S8.Item == Item, S9.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
            s8.map(SubSource.Element.init),
            s9.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
}

//MARK: - Sources + CollectionDataSources

public extension Sources
where
    Item == Any,
    SubSource == [AnyCollectionSources],
    UIViewType == UICollectionView
{
    private init(id: AnyHashable, _ sources: [SubSource.Element]) {
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        diffable = .init(id)
        
        sourceClosure = nil
        _sourceStored = sources
        
        collectionCellForItem = { (context, _) in context.elementsCellForItem() }
        collectionSupplementaryView = { (context, kind, _) in context.elementsViewForSupplementaryElementOfKind(kind: kind) }
        
        collectionDidSelectItem = { (context, _) in context.elementDidSelectItem() }
        collectionDidDeselectItem = { (context, _) in context.elementDidDeselectItem() }
        collectionWillDisplayItem = { (context, cell, _) in context.elementWillDisplay(cell: cell) }
        
        collectionSizeForItem = { (context, layout, _) in context.elementsizeForItem(collectionViewLayout: layout) }
        collectionSizeForHeader = { (context, layout, _) in context.elementreferenceSizeForHeaderInSection(collectionViewLayout: layout) }
        collectionSizeForFooter = { (context, layout, _) in context.elementreferenceSizeForFooterInSection(collectionViewLayout: layout) }
    }
    
    init<Value: CollectionDataSource>(id: AnyHashable = UUID(), source: Value?...) {
        self.init(id: id, source.compactMap { $0.map { .init($0) } })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource, S4: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource, S4: CollectionDataSource, S5: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource, S4: CollectionDataSource, S5: CollectionDataSource, S6: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource, S4: CollectionDataSource, S5: CollectionDataSource, S6: CollectionDataSource, S7: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource, S4: CollectionDataSource, S5: CollectionDataSource, S6: CollectionDataSource, S7: CollectionDataSource, S8: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?, _ s8: S8?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
            s8.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: CollectionDataSource, S1: CollectionDataSource, S2: CollectionDataSource, S3: CollectionDataSource, S4: CollectionDataSource, S5: CollectionDataSource, S6: CollectionDataSource, S7: CollectionDataSource, S8: CollectionDataSource, S9: CollectionDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?, _ s8: S8?, _ s9: S9?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
            s8.map(SubSource.Element.init),
            s9.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
}

//MARK: - Sources + TableDataSources

public extension Sources
where
    Item == Any,
    SubSource == [AnyTableSources],
    UIViewType == UITableView
{
    private init(id: AnyHashable, _ sources: [SubSource.Element]) {
        var _sources = SubSource()
        _sources.append(contentsOf: sources)
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        diffable = .init(id)
        
        sourceClosure = nil
        _sourceStored = _sources
        
        tableCellForItem = { (context, _) in context.elementCellForItem() }
        tableTitleForHeader = { (context, _) in context.elementTitleForHeaderInSection() }
        tableTitleForFooter = { (context, _) in context.elementTitleForFooterInSection() }
        
        tableHeader = { (context, _) in context.elementViewForHeaderInSection() }
        tableFooter = { (context, _) in context.elementViewForFooterInSection() }
        tableWillDisplayHeaderView = { (context, view, _) in context.elementWillDisplayHeaderView(view: view) }
        tableWillDisplayFooterView = { (context, view, _) in context.elementWillDisplayFooterView(view: view) }
        tableDidSelectItem = { (context, _) in context.elementDidSelectItem() }
        tableDidDeselectItem = { (context, _) in context.elementDidDeselectItem() }
        tableWillDisplayItem = { (context, cell, _) in context.elementWillDisplay(cell: cell) }
        tableViewDidHighlightItem = { (context, _) in context.elementDidHighlightItem() }
        tableViewDidUnhighlightItem = { (context, _) in context.elementDidUnhighlightItem() }
        tableHeightForItem = { (context, _) in context.elementHeightForItem() }
        tableHeightForHeader = { (context, _) in context.elementHeightForHeader() }
        tableHeightForFooter = { (context, _) in context.elementHeightForFooter() }
    }
    
    init<Value: TableDataSource>(id: AnyHashable = UUID(), source: Value?...) {
        self.init(id: id, source.compactMap { $0.map { .init($0) } })
    }
    
    init<S0: TableDataSource, S1: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource, S4: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource, S4: TableDataSource, S5: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource, S4: TableDataSource, S5: TableDataSource, S6: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource, S4: TableDataSource, S5: TableDataSource, S6: TableDataSource, S7: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource, S4: TableDataSource, S5: TableDataSource, S6: TableDataSource, S7: TableDataSource, S8: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?, _ s8: S8?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
            s8.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: TableDataSource, S1: TableDataSource, S2: TableDataSource, S3: TableDataSource, S4: TableDataSource, S5: TableDataSource, S6: TableDataSource, S7: TableDataSource, S8: TableDataSource, S9: TableDataSource>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?, _ s8: S8?, _ s9: S9?) {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
            s8.map(SubSource.Element.init),
            s9.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
}


//MARK: - Section

public typealias SectionSources<Item> = Sources<[Item], Item, Never>

public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never
{
    private init(id: AnyHashable, _items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        itemFor = { $0.item(at: $1) }
        createSnapshotWith = { .init($0) }
        updateContext = customUpdate
        
        sourceClosure = nil
        _sourceStored = _items
        diffable = .init(id)
    }
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Equatable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Equatable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Equatable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Hashable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Hashable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Hashable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Identifiable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Diffable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Diffable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Diffable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Identifiable + Hashable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, items: .init(), customUpdate: customUpdate)
    }
}

//MARK: - Item

public typealias ItemSources<Item> = Sources<Item, Item, Never>

public extension Sources where SubSource == Item, UIViewType == Never {
    private init(id: AnyHashable, _item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        itemFor = { (snapshot, _) in snapshot.item }
        createSnapshotWith = { .init($0) }
        updateContext = customUpdate
        
        sourceClosure = nil
        _sourceStored = _item
        diffable = .init(id)
    }
    
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
    }
}

//MARK: Equatable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Equatable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
    }
}

//MARK: Hashable

public extension Sources where SubSource == Item, UIViewType == Never, Item: Hashable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}

//MARK: Identifiable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Identifiable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}

//MARK: Diffable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Diffable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}

//MARK: Identifiable + Hashable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Identifiable, Item: Hashable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}
