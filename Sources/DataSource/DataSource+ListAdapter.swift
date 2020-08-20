//
//  DataSource+ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

public extension DataSource where Self: TableListAdapter {
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] {
        scrollList.listContextSetups + tableList.listContextSetups
    }
}

public extension DataSource where Self: CollectionListAdapter {
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] {
        scrollList.listContextSetups + collectionList.listContextSetups
    }
}

public extension DataSource where Self: TableListAdapter, Self: CollectionListAdapter {
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] {
        scrollList.listContextSetups + collectionList.listContextSetups + tableList.listContextSetups
    }
}
