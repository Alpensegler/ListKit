//
//  Modifier.swift
//  ListKit
//
//  Created by Frain on 2023/5/30.
//

public struct Modifier<List: DataSource, V>: ListAdapter {
    public typealias View = V
    var id: AnyHashable
    public let list: List
    public var listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
}
