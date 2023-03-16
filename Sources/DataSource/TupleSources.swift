//
//  TupleSources.swift
//  ListKit
//
//  Created by Frain on 2023/3/7.
//

import Foundation

public struct TupleSources<FirstSource: DataSource, SecondSource: DataSource>: DataSource {
    struct Coordinator: DataSourcesCoordinator {
        var contexts: ContiguousArray<ListCoordinatorContext>
        var contextsOffsets = ContiguousArray<Offset>()
        var indices = ContiguousArray<(indices: [Int], index: Int?)>()
        var subselectors = Set<Selector>()
        var count = Count.items(0)
        var needSetupWithListView = false
    }

    public var list: ContiguousArray<ListCoordinatorContext>
    public var listCoordinator: ListCoordinator { Coordinator(contexts: list) }
}

extension TupleSources: TableList where FirstSource: TableList, SecondSource: TableList { }
extension TupleSources: CollectionList where FirstSource: CollectionList, SecondSource: CollectionList { }
extension TupleSources: ListAdapter where FirstSource: ListAdapter, SecondSource: ListAdapter, FirstSource.View == SecondSource.View {
    public typealias View = FirstSource.View
}

extension TupleSources.Coordinator {
    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
