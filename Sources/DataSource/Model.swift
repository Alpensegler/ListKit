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
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    public var wrappedValue: ContainType {
        get { list }
        _modify { yield &list }
        set { list = newValue }
    }

    public init(_ model: ContainType) {
        list = model
        listCoordinator = Coordinator(list: list)
        listCoordinatorContext = .init(coordinator: listCoordinator)
    }

    public init(wrappedValue: ContainType) {
        self.init(wrappedValue)
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
