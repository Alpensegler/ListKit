//
//  CollectionListAdapter.swift
//  ListKit
//
//  Created by Frain on 2023/3/2.
//

public protocol CollectionList: DataSource { }

public protocol CollectionListAdapter: ListAdapter, CollectionList where View == CollectionView, List == CollectionList { }

public extension CollectionListAdapter where List == CollectionList {
    var listCoordinator: ListCoordinator { list.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext { list.listCoordinatorContext }
}

public extension UpdatableListAdapter where Self: CollectionListAdapter, List == CollectionList {
    var listCoordinator: ListCoordinator { list.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext {
        listCoordinatorContext(from: list)
    }
    
    func performReload(
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        _perform(reload: true, animated: animated, coordinatorGetter: list.listCoordinatorContext, completion: completion)
    }

    func performUpdate(
        animated: Bool = true,
        completion: ((ListView, Bool) -> Void)? = nil
    ) {
        _perform(reload: false, animated: animated, coordinatorGetter: list.listCoordinatorContext, completion: completion)
    }
}
