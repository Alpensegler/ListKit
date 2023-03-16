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

public extension UpdatableListAdapter where List == CollectionList {
    var listCoordinatorContext: ListCoordinatorContext {
        listCoordinatorContext(from: list)
    }
}
