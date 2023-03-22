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

public extension UpdatableListAdapter where Self: TableListAdapter, List == TableList {
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
