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
    }
    public var list: C
    public let listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
    public var wrappedValue: C {
        get { list }
        _modify { yield &list }
        set { list = newValue }
    }

    public init(_ models: C) {
        list = models
        listCoordinator = Coordinator(list: list)
        listCoordinatorContext = .init(coordinator: listCoordinator)
    }

    public init(wrappedValue: C) {
        self.init(wrappedValue)
    }
}

extension Sections.Coordinator {
    init(list: C) {
        self.list = list.mapContiguous { $0.mapContiguous { $0 } }
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
