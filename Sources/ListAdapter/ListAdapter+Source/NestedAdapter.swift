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
        applyBy collectionView: CollectionView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> CollectionList<Adapter.SourceBase> {
        coordinator.nestedAdapterItemUpdate[keyPath] = { [weak collectionView] sourceBase in
            guard let collectionView = collectionView else { return }
            let adapter = sourceBase[keyPath: keyPath]
            adapter.apply(by: collectionView, animated: animated, completion: completion)
        }
        let subAdapter = itemValue[keyPath: keyPath]
        return subAdapter.apply(by: collectionView, animated: animated, completion: completion)
    }
    
    @discardableResult
    func nestedAdapter<Adapter: TableListAdapter>(
        _ keyPath: KeyPath<Source.Item, Adapter>,
        applyBy tableView: TableView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<Adapter.SourceBase> {
        coordinator.nestedAdapterItemUpdate[keyPath] = { [weak tableView] sourceBase in
            guard let tableView = tableView else { return }
            let adapter = sourceBase[keyPath: keyPath]
            adapter.apply(by: tableView, animated: animated, completion: completion)
        }
        let subAdapter = itemValue[keyPath: keyPath]
        return subAdapter.apply(by: tableView)
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
