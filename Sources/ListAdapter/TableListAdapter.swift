//
//  TableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2023/3/2.
//

#if !os(macOS)

public protocol TableListAdapter: ListAdapter where View == TableView, List == TableList { }

public struct TableList: TableListAdapter {
    public typealias View = TableView
    public var list: TableList { return self }
    public let listCoordinator: ListCoordinator
    public let listCoordinatorContext: ListCoordinatorContext
}

public extension ListBuilder where View == TableView {
    static func buildFinalResult<List: ListAdapter>(_ component: List) -> TableList where List.View == TableView {
        .init(
            listCoordinator: component.listCoordinator,
            listCoordinatorContext: component.listCoordinatorContext
        )
    }
}

#endif
