//
//  TableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2023/3/2.
//

public protocol TableList: DataSource { }

public protocol TableListAdapter: ListAdapter, TableList where View == TableView, List == TableList { }

public extension TableListAdapter where List == TableList {
    var listCoordinator: ListCoordinator { list.listCoordinator }
    var listCoordinatorContext: ListCoordinatorContext { list.listCoordinatorContext }
}

public extension UpdatableListAdapter where List == TableList {
    var listCoordinatorContext: ListCoordinatorContext {
        listCoordinatorContext(from: list)
    }
}
