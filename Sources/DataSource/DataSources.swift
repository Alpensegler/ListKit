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
        var identifier: ((ContainType) -> AnyHashable)?
        var areEquivalent: ((ContainType, ContainType) -> Bool)?
    }

    public var list: C
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    public var wrappedValue: C {
        get { list }
        _modify { yield &list }
        set { list = newValue }
    }

    init(list: C,
         identifier: ((ContainType) -> AnyHashable)? = nil,
         areEquivalent: ((ContainType, ContainType) -> Bool)? = nil
    ) {
        self.list = list
        self.listCoordinator = Coordinator(list: list, identifier: identifier, areEquivalent: areEquivalent)
        self.listCoordinatorContext = .init(coordinator: listCoordinator)
    }
}

public extension DataSources {
    init(_ dataSources: C) {
        self.init(list: dataSources)
    }

    init(wrappedValue: C) {
        self.init(list: wrappedValue)
    }

    func diff<ID: Hashable>(id: @escaping (ContainType) -> ID, by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> Sections<C, ContainType> {
        .init(list: list, identifier: { id($0) }, areEquivalent: areEquivalent)
    }

    func diff(by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> DataSources<C, ContainType> {
        .init(list: list, areEquivalent: areEquivalent)
    }
}

extension DataSources: TableList where ContainType: TableList { }
extension DataSources: CollectionList where ContainType: CollectionList { }
extension DataSources: ListAdapter where ContainType: ListAdapter {
    public typealias View = ContainType.View
}

extension DataSources.Coordinator {
    init(list: C,
         identifier: ((ContainType) -> AnyHashable)? = nil,
         areEquivalent: ((ContainType, ContainType) -> Bool)? = nil
    ) {
        self.list = .init(list)
        self.contexts = list.mapContiguous { $0.listCoordinatorContext }
        self.identifier = identifier
        self.areEquivalent = areEquivalent
        configCount()
    }

    func model(at indexPath: IndexPath) -> Any {
        list[indices[indexPath.section].indices[indexPath.item]]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
