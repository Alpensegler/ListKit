//
//  ModelsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

// swiftlint:disable opening_brace

import Foundation

@propertyWrapper
public struct Models<C: Collection, ContainType>: ContainerDataSource where C.Element == ContainType {
    struct Coordinator: ListCoordinator {
        var list: ContiguousArray<ContainType>
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
        self.listCoordinator = Coordinator(list: list.mapContiguous { $0 }, identifier: identifier, areEquivalent: areEquivalent)
        self.listCoordinatorContext = .init(coordinator: listCoordinator)
    }
}

public extension Models {
    init(wrappedValue: C) {
        self.init(list: wrappedValue)
    }

    init(_ models: C) {
        self.init(list: models)
    }

    func diff<ID: Hashable>(id: @escaping (ContainType) -> ID, by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> Models<C, ContainType> {
        .init(list: list, identifier: { id($0) }, areEquivalent: areEquivalent)
    }

    func diff(by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> Models<C, ContainType> {
        .init(list: list, areEquivalent: areEquivalent)
    }
}

public extension Models where ContainType: Equatable {
    init(wrappedValue: C) {
        self.init(list: wrappedValue, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(list: models, areEquivalent: ==)
    }
}

public extension Models where ContainType: Hashable {
    init(wrappedValue: C) {
        self.init(list: wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(list: models, identifier: { $0 }, areEquivalent: ==)
    }
}

extension Models.Coordinator {
    var count: Count { .items(list.count) }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }

    func model(at indexPath: IndexPath) -> Any {
        list[indexPath.item]
    }
}
