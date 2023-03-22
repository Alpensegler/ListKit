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
        init(list: C) {
            self.list = list.mapContiguous { $0 }
        }
    }
    public var list: C
    public var listCoordinator: ListCoordinator { Coordinator(list: list) }
    public var wrappedValue: C { list }

    public init(_ models: C) {
        self.list = models
    }

    public init(wrappedValue: C) {
        self.list = wrappedValue
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
