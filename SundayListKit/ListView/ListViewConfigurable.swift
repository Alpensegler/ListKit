//
//  ListViewConfigurable.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

public protocol ListSource {
    func dataSource<List: ListView>(for listView: List) -> AnyCollection<Any>?
    func numbersOfSections<List: ListView>(for listContext: ListContext<List>) -> Int
    func numbersOfItems<List: ListView>(for listContext: ListContext<List>, in section: Int) -> Int
    func update<List: ListView>(listContext: ListContext<List>, from oldValue: Any, to newVlaue: Any)
}

public extension ListSource {
    func dataSource<List: ListView>(for listView: List) -> AnyCollection<Any>? {
        return nil
    }
    
    func update<List: ListView>(listContext: ListContext<List>, from oldValue: Any, to newVlaue: Any) {
        listContext.reloadCurrentContext()
    }
}

public extension ListSource where Self: TableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbersOfItems(for: .init(listView: tableView, listViewData: self[tableView]), in: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numbersOfSections(for: .init(listView: tableView, listViewData: self[tableView]))
    }
}

public extension ListSource where Self: CollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbersOfItems(for: .init(listView: collectionView, listViewData: self[collectionView]), in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numbersOfSections(for: .init(listView: collectionView, listViewData: self[collectionView]))
    }
}

public protocol ListViewSupplementaryConfigurable {
    func headerCell<List: ListView>(for listContext: ListContext<List>) -> List.SupplementaryView?
    func headerSize<List: ListView>(for listContext: ListContext<List>) -> ListSize
    
    func footerCell<List: ListView>(for listContext: ListContext<List>) -> List.SupplementaryView?
    func footerSize<List: ListView>(for listContext: ListContext<List>) -> ListSize
}

public extension ListViewSupplementaryConfigurable {
    func headerCell<List: ListView>(for listContext: ListContext<List>) -> List.SupplementaryView? {
        return nil
    }
    
    func headerSize<List: ListView>(for listContext: ListContext<List>) -> ListSize {
        return CGSize.zero
    }
    
    func footerCell<List: ListView>(for listContext: ListContext<List>) -> List.SupplementaryView?  {
        return nil
    }
    
    func footerSize<List: ListView>(for listContext: ListContext<List>) -> ListSize {
        return CGSize.zero
    }
}

public extension ListViewSupplementaryConfigurable where Self: TableViewDataSource, Self: ListSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerSize(for: ListContext(listView: tableView, listViewIndexPath: IndexPath(row: 0, section: section), listViewData: self[tableView])).height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerSize(for: ListContext(listView: tableView, listViewIndexPath: IndexPath(row: 0, section: section), listViewData: self[tableView])).height
    }
}

public extension ListViewSupplementaryConfigurable where Self: CollectionViewDelegateFlowLayout, Self: ListSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return headerSize(for: ListContext(listView: collectionView, listViewIndexPath: IndexPath(row: 0, section: section), listViewData: self[collectionView])).size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return footerSize(for: ListContext(listView: collectionView, listViewIndexPath: IndexPath(row: 0, section: section), listViewData: self[collectionView])).size
    }
}

public protocol ListViewConfigurable: ListSource {
    func cellForItem<List: ListView>(for listContext: ListContext<List>) -> List.Cell
    func sizeForItem<List: ListView>(for listContext: ListContext<List>) -> ListSize
}

public extension ListViewConfigurable {
    func sizeForItem<List: ListView>(for listContext: ListContext<List>) -> ListSize {
        return listContext.listView.defaultItemSize
    }
}

public extension ListViewConfigurable where Self: TableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sizeForItem(for: ListContext(listView: tableView, listViewIndexPath: indexPath, listViewData: self[tableView])).height
    }
}

public extension ListViewConfigurable where Self: CollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem(for: ListContext(listView: collectionView, listViewIndexPath: indexPath, listViewData: self[collectionView])).size
    }
}

public extension ListViewConfigurable where Self: TableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForItem(for: ListContext(listView: tableView, listViewIndexPath: indexPath, listViewData: self[tableView]))
    }
}

public extension ListViewConfigurable where Self: CollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItem(for: ListContext(listView: collectionView, listViewIndexPath: indexPath, listViewData: self[collectionView]))
    }
}

private var listModelSourceListViewDataStorageKey: Void?

extension ListSource {
    
    subscript<List: ListView>(listView: List) -> ListData {
        get {
            return Associator.getValue(key: &listModelSourceListViewDataStorageKey, from: listView, initialValue: .init())
        }
        nonmutating set {
            Associator.set(value: newValue, key: &listModelSourceListViewDataStorageKey, to: listView)
        }
    }
}
