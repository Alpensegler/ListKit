//
//  ListAdapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/30.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol TableListAdapter: ListAdapter, TableListDelegate, ListUpdatable { }
public protocol CollectionListAdapter: ListAdapter, CollectionListDelegate, ListUpdatable { }


public protocol TableSectionAdapter: SectionAdapter, TableListDelegate, ListUpdatable { }
public protocol CollectionSectionAdapter: SectionAdapter, CollectionListDelegate, ListUpdatable { }
