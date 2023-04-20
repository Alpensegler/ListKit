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

public protocol ContainerDataSource: DataSource {
    associatedtype ContainType
    var listCoordinatorContext: ListCoordinatorContext { get set }
}
