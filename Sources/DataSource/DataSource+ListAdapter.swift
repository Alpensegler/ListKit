//
//  DataSource+ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

public extension DataSource where Self: TableListAdapter {
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] {
        tableList.listContextSetups
    }
}

public extension DataSource where Self: CollectionListAdapter {
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] {
        collectionList.listContextSetups
    }
}

public extension DataSource where Self: TableListAdapter, Self: CollectionListAdapter {
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] {
        collectionList.listContextSetups + tableList.listContextSetups
    }
}
