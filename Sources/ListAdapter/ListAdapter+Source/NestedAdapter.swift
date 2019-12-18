//
//  NestedAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension ItemContext {
    @discardableResult
    func nestedAdapter<Adapter: CollectionListAdapter>(
    _ keyPath: KeyPath<Source.Item, Adapter>,
        applyBy collectionView: CollectionView
    ) -> CollectionList<Adapter.SourceBase> {
        let subAdapter = itemValue[keyPath: keyPath]
        let collectionList = subAdapter.apply(by: collectionView)
        var subcoordinator = collectionList.listCoordinator
        coordinator.nestedAdapterItemUpdate[keyPath] = { sourceBase in
            let newAdapter = sourceBase[keyPath: keyPath]
            let newcoordinator = newAdapter.makeCollectionListCoordinator()
            newcoordinator.update(from: subcoordinator) { subcoordinator = newcoordinator }
        }
        return collectionList
    }
    
    @discardableResult
    func nestedAdapter<Adapter: TableListAdapter>(
        _ keyPath: KeyPath<Source.Item, Adapter>,
        applyBy tableView: TableView
    ) -> TableList<Adapter.SourceBase> {
        let subAdapter = itemValue[keyPath: keyPath]
        let tableList = subAdapter.apply(by: tableView)
        var subcoordinator = tableList.listCoordinator
        coordinator.nestedAdapterItemUpdate[keyPath] = { sourceBase in
            let newAdapter = sourceBase[keyPath: keyPath]
            let newcoordinator = newAdapter.makeTableListCoordinator()
            newcoordinator.update(from: subcoordinator) { subcoordinator = newcoordinator }
        }
        return tableList
    }
}

public extension ItemContext where Source.Item: CollectionListAdapter {
    @discardableResult
    func nestedAdapter(applyBy collectionView: CollectionView) -> CollectionList<Source.Item.SourceBase> {
        nestedAdapter(\.self, applyBy: collectionView)
    }
}

public extension ItemContext where Source.Item: TableListAdapter {
    @discardableResult
    func nestedAdapter(applyBy tableView: TableView) -> TableList<Source.Item.SourceBase> {
        nestedAdapter(\.self, applyBy: tableView)
    }
}
