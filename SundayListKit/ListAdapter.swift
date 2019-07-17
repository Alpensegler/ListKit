//
//  ListAdapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/30.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol TableListDataSource: TableDataSource, ListUpdatable { }
public protocol CollectionListDataSource: CollectionDataSource, ListUpdatable { }

public protocol TableListAdapter: TableAdapter, ListUpdatable { }
public protocol CollectionListAdapter: CollectionAdapter, ListUpdatable { }
