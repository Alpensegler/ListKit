//
//  CollectionListAdapter.swift
//  ListKit
//
//  Created by Frain on 2023/3/2.
//

public protocol CollectionListAdapter: ListAdapter where View == CollectionView, List == CollectionList { }

public struct CollectionList: CollectionListAdapter {
    public typealias View = CollectionView
    public var list: CollectionList { return self }
    public let listCoordinator: ListCoordinator
    public let listCoordinatorContext: ListCoordinatorContext
}

public extension ListBuilder where View == CollectionView {
    static func buildFinalResult<List: ListAdapter>(_ component: List) -> CollectionList where List.View == CollectionView {
        .init(
            listCoordinator: component.listCoordinator,
            listCoordinatorContext: component.listCoordinatorContext
        )
    }
}
