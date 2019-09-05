//
//  Sources+TypeErase.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias AnyListSources<Item, UIViewType> = Sources<Any, Item, UIViewType>
public typealias AnySources<Item> = Sources<Any, Item, Never>

extension Source {
    func eraseToAnySources() -> AnySources<Item> {
        return eraseToSources().eraseToAnySources()
    }
}

extension Sources {
    func eraseToAnySources() -> AnySources<Item> {
        return .init(sources: self)
    }
}

public protocol SourcesTypeEraser: Source where SubSource == Any {
    init<Value: Source>(_ source: Value) where Value.Item == Item
}

public protocol CollectionDataSourcesTypeEraser: Source where SubSource == Any, Item == Any {
    init<Value: CollectionDataSource>(_ source: Value)
}

public protocol TableDataSourcesTypeEraser: Source where SubSource == Any, Item == Any {
    init<Value: TableDataSource>(_ source: Value)
}

extension Sources: SourcesTypeEraser where SubSource == Any, UIViewType == Never {
    public init<Value: Source>(_ source: Value) where Item == Value.Item {
        self.init(sources: source.eraseToSources())
    }
}

extension Sources: CollectionDataSourcesTypeEraser where SubSource == Any, Item == Any, UIViewType == UICollectionView {
    public init<Value: CollectionDataSource>(_ source: Value) {
        self.init(sources: source.eraseToCollectionSources())
    }
}

extension Sources: TableDataSourcesTypeEraser where SubSource == Any, Item == Any, UIViewType == UITableView {
    public init<Value: TableDataSource>(_ source: Value) {
        self.init(sources: source.eraseToTableSources())
    }
}

extension Sources {
    init<OtherSource, OtherItem, View>(sources: Sources<OtherSource, OtherItem, View>) {
        listUpdater = sources.listUpdater.castSnapshotType(from: OtherSource.self, otherItem: OtherItem.self, to: SubSource.self, item: Item.self)
        diffable = sources.diffable
        
        sourceClosure = sources.sourceClosure.map { closure in { closure() as! SubSource } }

        //MARK: - Source
        createSnapshotWith = { sources.createSnapshot(with: $0 as! OtherSource).castType() }
        itemFor = { [itemFor = sources.itemFor] in itemFor($0.castType(), $1) as! Item }
        updateContext = { [updateContext = sources.updateContext] in updateContext($0.castSnapshotType()) }
        performUpdate = { [performUpdate = sources.performUpdate] in performUpdate(.init(sources: $0)) }

        //MARK: - collection adapter
        collectionView = sources.collectionView
        collectionViewWillUpdate = sources.collectionViewWillUpdate
        
        collectionCellForItem = sources.collectionCellForItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        collectionSupplementaryView = sources.collectionSupplementaryView.map { closure in { closure($0.castSnapshotType(), $1, $2 as! OtherItem) } }
        
        collectionDidSelectItem = sources.collectionDidSelectItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        collectionDidDeselectItem = sources.collectionDidDeselectItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        collectionWillDisplayItem = sources.collectionWillDisplayItem.map { closure in { closure($0.castSnapshotType(), $1, $2 as! OtherItem) } }
        
        collectionSizeForItem = sources.collectionSizeForItem.map { closure in { closure($0.castSnapshotType(), $1, $2 as! OtherItem) } }
        collectionSizeForHeader = sources.collectionSizeForHeader.map { closure in { closure($0.castSnapshotType(), $1, $2) } }
        collectionSizeForFooter = sources.collectionSizeForFooter.map { closure in { closure($0.castSnapshotType(), $1, $2) } }

        //MARK: - table adapter
        tableViewWillUpdate = sources.tableViewWillUpdate
        tableCellForItem = sources.tableCellForItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        tableTitleForHeader = sources.tableTitleForHeader.map { closure in { closure($0.castSnapshotType(), $1) } }
        tableTitleForFooter = sources.tableTitleForFooter.map { closure in { closure($0.castSnapshotType(), $1) } }
        
        tableHeader = sources.tableHeader.map { closure in { closure($0.castSnapshotType(), $1) } }
        tableFooter = sources.tableFooter.map { closure in { closure($0.castSnapshotType(), $1) } }
        
        tableWillDisplayHeaderView = sources.tableWillDisplayHeaderView.map { closure in { closure($0.castSnapshotType(), $1, $2) } }
        tableWillDisplayFooterView = sources.tableWillDisplayFooterView.map { closure in { closure($0.castSnapshotType(), $1, $2) } }
        
        tableDidSelectItem = sources.tableDidSelectItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        tableDidDeselectItem = sources.tableDidDeselectItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        tableWillDisplayItem = sources.tableWillDisplayItem.map { closure in { closure($0.castSnapshotType(), $1, $2 as! OtherItem) } }
        
        tableViewDidHighlightItem = sources.tableViewDidHighlightItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        tableViewDidUnhighlightItem = sources.tableViewDidUnhighlightItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        
        tableHeightForItem = sources.tableHeightForItem.map { closure in { closure($0.castSnapshotType(), $1 as! OtherItem) } }
        tableHeightForHeader = sources.tableHeightForHeader.map { closure in { closure($0.castSnapshotType(), $1) } }
        tableHeightForFooter = sources.tableHeightForFooter.map { closure in { closure($0.castSnapshotType(), $1) } }
    }
}
