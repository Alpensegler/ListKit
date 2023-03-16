//
//  DataSource.swift
//  ListKit
//
//  Created by Frain on 2019/4/8.
//

public protocol DataSource {
    var listCoordinator: ListCoordinator { get }
    var listCoordinatorContext: ListCoordinatorContext { get }
}

public extension DataSource {
    var listCoordinatorContext: ListCoordinatorContext { .init(coordinator: listCoordinator) }
}

public protocol ContainerDataSource: DataSource {
    associatedtype ContainType
}
