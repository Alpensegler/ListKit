//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

// swiftlint:disable comment_spacing

import Foundation

@propertyWrapper
public struct Sections<C: Collection, ContainType>: ContainerDataSource where C.Element: Collection, C.Element.Element == ContainType {
    struct Coordinator: ListCoordinator {
        var count = Count.sections(nil, [], nil)
        var indices = ContiguousArray<Int>()
        var list: ContiguousArray<ContiguousArray<ContainType>>
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

public extension Sections {
    init(wrappedValue: C) {
        self.init(list: wrappedValue)
    }

    init(_ models: C) {
        self.init(list: models)
    }

    func diff<ID: Hashable>(id: @escaping (ContainType) -> ID, by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> Sections<C, ContainType> {
        .init(list: list, identifier: { id($0) }, areEquivalent: areEquivalent)
    }

    func diff(by areEquivalent: @escaping (ContainType, ContainType) -> Bool) -> Sections<C, ContainType> {
        .init(list: list, areEquivalent: areEquivalent)
    }
}

public extension Sections where ContainType: Equatable {
    init(wrappedValue: C) {
        self.init(list: wrappedValue, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(list: models, areEquivalent: ==)
    }
}

public extension Sections where ContainType: Hashable {
    init(wrappedValue: C) {
        self.init(list: wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(list: models, identifier: { $0 }, areEquivalent: ==)
    }
}

extension Sections.Coordinator {
    init(list: C,
         identifier: ((ContainType) -> AnyHashable)? = nil,
         areEquivalent: ((ContainType, ContainType) -> Bool)? = nil
    ) {
        self.list = list.mapContiguous { $0.mapContiguous { $0 } }
        self.identifier = identifier
        self.areEquivalent = areEquivalent
        configCount()
    }
    
    mutating func configCount() {
        count = .sections(nil, list.map { $0.count }, nil)
    }

    func model(at indexPath: IndexPath) -> Any {
        list[indexPath.section][indexPath.item]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
