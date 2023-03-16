//
//  DataSources.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

// swiftlint:disable comment_spacing function_body_length opening_brace

import Foundation

@propertyWrapper
public struct DataSources<C: RangeReplaceableCollection, ContainType>: ContainerDataSource
where C.Element == ContainType, ContainType: DataSource {
    struct Coordinator: DataSourcesCoordinator {
        var list: ContiguousArray<ContainType>
        var contexts: ContiguousArray<ListCoordinatorContext>
        var contextsOffsets = ContiguousArray<Offset>()
        var indices = ContiguousArray<(indices: [Int], index: Int?)>()
        var subselectors = Set<Selector>()
        var count = Count.items(0)
        var needSetupWithListView = false
    }

    public var list: C
    public var listCoordinator: ListCoordinator { Coordinator(list) }
    public var wrappedValue: C { list }

    public init(_ dataSources: C) {
        self.list = dataSources
    }

    public init(wrappedValue: C) {
        self.list = wrappedValue
    }
}

extension DataSources: ListAdapter where ContainType: ListAdapter {
    public typealias View = ContainType.View
}

extension DataSources: TableList where ContainType: TableList { }
extension DataSources: CollectionList where ContainType: CollectionList { }

extension DataSources.Coordinator {
    init(_ list: C) {
        self.list = .init(list)
        self.contexts = list.mapContiguous { $0.listCoordinatorContext }
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }

    func model(at indexPath: IndexPath) -> Any {
        list[indices[indexPath.section].indices[indexPath.item]]
    }
}
