//
//  Source+UIKit.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

public extension Source where Self: TableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[tableView].snapshot.numbersOfItems(in: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self[tableView].snapshot.numbersOfSections()
    }
}

public extension Source where Self: CollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self[collectionView].snapshot.numbersOfItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self[collectionView].snapshot.numbersOfSections()
    }
}

public extension ListData where Self: TableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let context = self[tableView, indexPath]
        let viewModel = self.viewModel(for: context)
        return cellForViewModel(for: context, viewModel: viewModel)
    }
}

public extension ListData where Self: CollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let context = self[collectionView, indexPath]
        let viewModel = self.viewModel(for: context)
        return cellForViewModel(for: context, viewModel: viewModel)
    }
}

private var listSourceContextKey: Void?
private var listSourceSnapshotKey: Void?

extension Source {
    
    func didLoad<List: ListView>(listView: List) -> Bool {
        return (Associator.getValue(key: &listSourceSnapshotKey, from: listView) as Snapshot?) != nil
    }
    
    subscript<List: ListView>(listView: List) -> ListContext<List, Self> {
        return ListContext(listView: listView, snapshot: self[snapshot: listView])
    }
    
    subscript<List: ListView>(listView: List, indexPath: IndexPath) -> ListIndexContext<List, Self> {
        return ListIndexContext(listView: listView, snapshot: self[snapshot: listView], indexPath: indexPath)
    }
    
    subscript<List: ListView>(snapshot listView: List) -> Snapshot {
        get { return Associator.getValue(key: &listSourceSnapshotKey, from: listView, initialValue: snapshot(for: listView)) }
        nonmutating set { Associator.set(value: newValue, key: &listSourceSnapshotKey, to: listView) }
    }
}
