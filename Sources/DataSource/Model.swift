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
        var areEquivalent: ((ContainType, ContainType) -> Bool)?
    }
    public var list: ContainType
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    public var wrappedValue: ContainType {
        get { list }
        _modify { yield &list }
        set { list = newValue }
    }

    init(list: ContainType, areEquivalent: ((ContainType, ContainType) -> Bool)? = nil) {
        self.list = list
        self.listCoordinator = Coordinator(list: list, areEquivalent: areEquivalent)
        self.listCoordinatorContext = .init(coordinator: listCoordinator)
    }
}

public extension Model {
    init(wrappedValue: ContainType) {
        self.init(list: wrappedValue)
    }

    init(_ model: ContainType) {
        self.init(list: model)
    }

    func diff(by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> Model<ContainType> {
        .init(list: list, areEquivalent: areEquivalent)
    }
}

public extension Model where ContainType: Equatable {
    init(wrappedValue: ContainType) {
        self.init(list: wrappedValue, areEquivalent: ==)
    }

    init(_ model: ContainType) {
        self.init(list: model, areEquivalent: ==)
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
