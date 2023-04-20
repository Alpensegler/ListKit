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
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    public var wrappedValue: C {
        get { list }
        _modify { yield &list }
        set { list = newValue }
    }

    public init(_ dataSources: C) {
        list = dataSources
        listCoordinator = Coordinator(list: list)
        listCoordinatorContext = .init(coordinator: listCoordinator)
    }

    public init(wrappedValue: C) {
        self.init(wrappedValue)
    }
}

extension DataSources: TableList where ContainType: TableList { }
extension DataSources: CollectionList where ContainType: CollectionList { }
extension DataSources: ListAdapter where ContainType: ListAdapter {
    public typealias View = ContainType.View
}

extension DataSources.Coordinator {
    init(list: C) {
        self.list = .init(list)
        self.contexts = list.mapContiguous { $0.listCoordinatorContext }
        configCount()
    }

    func model(at indexPath: IndexPath) -> Any {
        list[indices[indexPath.section].indices[indexPath.item]]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
