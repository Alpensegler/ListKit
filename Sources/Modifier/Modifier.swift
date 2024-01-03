//
//  Modifier.swift
//  ListKit
//
//  Created by Frain on 2023/5/30.
//

public struct Modifier<V, List: ListAdapter>: ListAdapter {
    public typealias View = V
    public let list: List
    public var listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
}

extension Modifier: TypedListAdapter where List: TypedListAdapter { }
