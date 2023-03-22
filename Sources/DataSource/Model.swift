//
//  ModelCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

// swiftlint:disable comment_spacing

import Foundation

@propertyWrapper
public struct Model<ContainType>: ContainerDataSource {
    struct Coordinator: ListCoordinator {
        var list: ContainType
    }
    public var list: ContainType
    public var listCoordinator: ListCoordinator { Coordinator(list: wrappedValue) }
    public var wrappedValue: ContainType { list }

    public init(_ model: ContainType) {
        self.list = model
    }

    public init(wrappedValue: ContainType) {
        self.list = wrappedValue
    }
}

public extension Model where ContainType == Void {
    init() { self.init(()) }
}

extension Model.Coordinator {
    var count: Count { .items(1) }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }

    func model(at indexPath: IndexPath) -> Any { list }
}
