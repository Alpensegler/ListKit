//
//  ListContext.swift
//  ListKit
//
//  Created by Frain on 2020/8/2.
//

import Foundation

@dynamicMemberLookup
public protocol Context {
    associatedtype SourceBase: DataSource where SourceBase.SourceBase == SourceBase
    associatedtype List
    
    var source: SourceBase.Source { get }
    var listView: List { get }
}

public struct ListContext<List, SourceBase: DataSource>: Context
where SourceBase.SourceBase == SourceBase {
    public let listView: List
    let context: ListCoordinatorContext<SourceBase>
    let root: CoordinatorContext
    
    public var source: SourceBase.Source { context.listCoordinator.source }
}

public struct ListIndexContext<List, SourceBase: DataSource, Index>: Context
where SourceBase.SourceBase == SourceBase {
    public let listView: List
    public let index: Index
    public let offset: Index
    let context: ListCoordinatorContext<SourceBase>
    let root: CoordinatorContext
    
    public var source: SourceBase.Source { context.listCoordinator.source }
}

public extension DataSource {
    typealias ListSectionContext<List: ListView> = ListIndexContext<List, SourceBase, Int>
    typealias ListItemContext<List: ListView> = ListIndexContext<List, SourceBase, IndexPath>
}

public extension Context {
    subscript<Value>(dynamicMember keyPath: KeyPath<SourceBase.Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
}

public extension ListIndexContext where Index == Int {
    var section: Int { index - offset }
}

public extension ListIndexContext where Index == IndexPath {
    var section: Int { index.section - offset.section }
    var item: Int { index.item - offset.item }
    
    var itemValue: SourceBase.Item {
        context.listCoordinator.item(at: index.offseted(offset, plus: false))
    }
}

public extension ListIndexContext where SourceBase: ItemCachedDataSource, Index == IndexPath {
    var itemCache: SourceBase.ItemCache { cache() }
}

extension ListIndexContext where Index == IndexPath {
    func setNestedCache(update: @escaping (Any) -> Void) {
        root.itemNestedCache[index.section][index.item] = update
    }
    
    func cache<Cache>() -> Cache {
        context.cache(for: &root.itemCaches[index.section][index.item], at: index)
    }
}
