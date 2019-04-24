//
//  ListAdapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/30.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
public protocol ListAdapter: class, ListViewConfigurable, ListViewModel {
    associatedtype Item = Model
    
    func cellForItem<List: ListView>(for listContext: ListContext<List>, item: Item) -> List.Cell
    func sizeForItem<List: ListView>(for listContext: ListContext<List>, item: Item) -> ListSize
    
    func update<List: ListView>(listView: List, animation: List.Animation, completion: ((Bool) -> Void)?)
    func update(completion: ((Bool) -> Void)?)
}

public extension ListAdapter {
    func cellForItem<List: ListView>(for listContext: ListContext<List>) -> List.Cell {
        return cellForItem(for: listContext, item: item(for: listContext))
    }
    
    func sizeForItem<List: ListView>(for listContext: ListContext<List>, item: Item) -> ListSize {
        return listContext.listView.defaultItemSize
    }
    
    func sizeForItem<List: ListView>(for listContext: ListContext<List>) -> ListSize {
        return sizeForItem(for: listContext, item: item(for: listContext))
    }
    
    func update<List: ListView>(listView: List, animation: List.Animation, completion: ((Bool) -> Void)? = nil) {
        let oldListViewData = self[listView]
        let listViewData = ListData(for: listView, container: listModels(for: listView))
        update(from: oldListViewData.models as! [Model], to: listViewData.models as! [Model], in: ListUpdateContext(updating: true))
        self[listView] = listViewData
    }
}

public extension ListAdapter where Model: ListViewConfigurable {
    func cellForItem<List: ListView>(for listContext: ListContext<List>, item: Item) -> List.Cell {
        return (listContext.model() as Model).cellForItem(for: listContext)
    }
}

public extension ListAdapter where Model == ListViewConfigurable {
    func cellForItem<List: ListView>(for listContext: ListContext<List>, item: Item) -> List.Cell {
        return (listContext.model() as Model).cellForItem(for: listContext)
    }
}

public protocol TableListAdapter: ListAdapter, TableListDelegate { }
public protocol CollectionListAdapter: ListAdapter, CollectionListDelegate { }

public extension ListAdapter where Self: TableListDelegate {
    func update(completion: ((Bool) -> Void)? = nil) {
        for tableView in allTableViews {
            update(listView: tableView, animation: tableView.defaultAnimation, completion: completion)
        }
    }
}

public extension ListAdapter where Self: CollectionListDelegate {
    func update(completion: ((Bool) -> Void)? = nil) {
        for collection in allCollectionViews {
            update(listView: collection, animation: collection.defaultAnimation, completion: completion)
        }
    }
}

public extension ListAdapter where Self: TableListDelegate, Self: CollectionListDelegate {
    func update(completion: ((Bool) -> Void)? = nil) {
        for tableView in allTableViews {
            update(listView: tableView, animation: tableView.defaultAnimation, completion: completion)
        }
        for collection in allCollectionViews {
            update(listView: collection, animation: collection.defaultAnimation, completion: completion)
        }
    }
}




