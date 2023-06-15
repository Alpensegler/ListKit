//
//  Modifier.swift
//  ListKit
//
//  Created by Frain on 2023/5/30.
//

public struct Modifier<List, V>: ListAdapter {
    public typealias View = V
    public let list: List
    public var listCoordinator: ListCoordinator
    public var listCoordinatorContext: ListCoordinatorContext
}

extension Modifier: TableList where View == TableView { }
extension Modifier: CollectionList where View == CollectionView { }
extension Modifier: TypedListAdapter where List: TypedListAdapter {
    public typealias Element = List.Element
}
