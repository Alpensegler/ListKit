//
//  TupleListAdapters.swift
//  ListKit
//
//  Created by Frain on 2023/3/7.
//

import Foundation

public struct TupleListAdapters<FirstSource: ListAdapter, SecondSource: ListAdapter>: ListAdapter, DataSourcesCoordinator where FirstSource.View == SecondSource.View {
    public typealias View = FirstSource.View
    public var contexts: ContiguousArray<ListCoordinatorContext>
    public var contextsOffsets = ContiguousArray<Offset>()
    public var indices = ContiguousArray<(indices: [Int], index: Int?)>()
    public var subselectors = Set<Selector>()
    public var count = Count.items(0)
    public var needSetupWithListView = false

    init(_ value: ContiguousArray<ListCoordinatorContext>) {
        self.contexts = value
        configCount()
    }
}

extension TupleListAdapters: TableList where FirstSource: TableList, SecondSource: TableList { }
extension TupleListAdapters: CollectionList where FirstSource: CollectionList, SecondSource: CollectionList { }

public extension TupleListAdapters {
    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
