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
        let adapter = itemValue[keyPath: keyPath]
        let list = adapter.apply(
            by: collectionView,
            update: .reload,
            animated: animated,
            completion: completion
        )
        var coordinator = list.makeListCoordinator()
        setNestedCache(with: keyPath) { [weak collectionView] sourceBase in
            guard let sourceBase = sourceBase as? Source.Item,
                let collectionView = collectionView,
                collectionView.isCoordinator(coordinator)
            else { return }
            let adapter = sourceBase[keyPath: keyPath]
            let list = adapter.apply(by: collectionView, animated: animated, completion: completion)
            coordinator = list.makeListCoordinator()
        }
        return list
    }
    
    @discardableResult
    func nestedAdapter<Adapter: TableListAdapter>(
        _ keyPath: KeyPath<Source.Item, Adapter>,
        applyBy tableView: TableView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<Adapter.SourceBase> {
        let adapter = itemValue[keyPath: keyPath]
        let list = adapter.apply(
            by: tableView,
            update: .reload,
            animated: animated,
            completion: completion
        )
        var coordinator = list.makeListCoordinator()
        setNestedCache(with: keyPath) { [weak tableView] sourceBase in
            guard let sourceBase = sourceBase as? Source.Item,
                let tableView = tableView,
                tableView.isCoordinator(coordinator)
            else { return }
            let adapter = sourceBase[keyPath: keyPath]
            let list = adapter.apply(by: tableView, animated: animated, completion: completion)
            coordinator = list.makeListCoordinator()
        }
        return list
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
