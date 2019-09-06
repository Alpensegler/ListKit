//
//  ListAdapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/30.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol TableListDataSource: TableDataSource, ListUpdatable {
    @discardableResult
    func setTableView(_ tableView: UITableView, withReload: Bool) -> Self
    func makeTableCoordinator() -> TableCoordinator
}

public protocol CollectionListDataSource: CollectionDataSource, ListUpdatable {
    @discardableResult
    func setCollectionView(_ collectionView: UICollectionView, withReload: Bool) -> Self
    func makeCollectionCoordinator() -> CollectionCoordinator
}

public protocol TableListAdapter: TableAdapter, TableListDataSource { }
public protocol CollectionListAdapter: CollectionAdapter, CollectionListDataSource { }

public typealias CollectionSectionSources<Item> = CollectionSources<[Item], Item>
public typealias TableSectionSources<Item> = TableSources<[Item], Item>

public typealias CollectionItemSources<Item> = CollectionSources<Item, Item>
public typealias TableItemSources<Item> = TableSources<Item, Item>
