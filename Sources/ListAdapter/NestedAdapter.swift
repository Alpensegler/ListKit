//
//  NestedAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

import Foundation

public extension ListIndexContext where Index == IndexPath {
    @discardableResult
    func nestedAdapter<Adapter: CollectionListAdapter>(
        _ keyPath: KeyPath<Base.Item, Adapter>,
        applyBy collectionView: CollectionView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> CollectionList<Adapter.AdapterBase> {
        let adapter = itemValue[keyPath: keyPath]
        let list = adapter.apply(
            by: collectionView,
            update: .reload,
            animated: animated,
            completion: completion
        )
        var coordinator = list.listCoordinator
        setNestedCache { [weak collectionView] Base in
            guard let Base = Base as? Base.Item,
                  let collectionView = collectionView,
                  collectionView.isCoordinator(coordinator)
            else { return }
            let adapter = Base[keyPath: keyPath]
            let list = adapter.apply(by: collectionView, animated: animated, completion: completion)
            coordinator = list.listCoordinator
        }
        return list
    }
    
    @discardableResult
    func nestedAdapter<Adapter: TableListAdapter>(
        _ keyPath: KeyPath<Base.Item, Adapter>,
        applyBy tableView: TableView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<Adapter.AdapterBase> {
        let adapter = itemValue[keyPath: keyPath]
        let list = adapter.apply(
            by: tableView,
            update: .reload,
            animated: animated,
            completion: completion
        )
        var coordinator = list.listCoordinator
        setNestedCache { [weak tableView] Base in
            guard let Base = Base as? Base.Item,
                  let tableView = tableView,
                  tableView.isCoordinator(coordinator)
            else { return }
            let adapter = Base[keyPath: keyPath]
            let list = adapter.apply(by: tableView, animated: animated, completion: completion)
            coordinator = list.listCoordinator
        }
        return list
    }
}

public extension ListIndexContext where Index == IndexPath, Base.Item: CollectionListAdapter {
    @discardableResult
    func nestedAdapter(applyBy collectionView: CollectionView) -> CollectionList<Base.Item.AdapterBase> {
        nestedAdapter(\.self, applyBy: collectionView)
    }
}

public extension ListIndexContext where Index == IndexPath, Base.Item: TableListAdapter {
    @discardableResult
    func nestedAdapter(applyBy tableView: TableView) -> TableList<Base.Item.AdapterBase> {
        nestedAdapter(\.self, applyBy: tableView)
    }
}
