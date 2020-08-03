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
    
    var context: ListCoordinatorContext<SourceBase> { get }
    var listView: List { get }
}

public struct ListContext<List, SourceBase: DataSource>: Context
where SourceBase.SourceBase == SourceBase {
    public let context: ListCoordinatorContext<SourceBase>
    public let listView: List
    let root: CoordinatorContext
}

public struct ListIndexContext<List, SourceBase: DataSource, Index>: Context
where SourceBase.SourceBase == SourceBase {
    public let context: ListCoordinatorContext<SourceBase>
    public let listView: List
    public let index: Index
    public let offset: Index
    let root: CoordinatorContext
}

public extension Context {
    var source: SourceBase.Source { context.coordinator.source }

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
}

extension ListIndexContext where Index == IndexPath {
    var itemValue: SourceBase.Item { context.coordinator.item(at: section, item) }
    func setNestedCache(update: @escaping (Any) -> Void) {
        context.itemNestedCache[index.section][index.item] = update
    }
    
    func itemCache<Cache>(or getter: (SourceBase.Item) -> Cache) -> Cache {
        context.itemCaches[index.section][index.item] as? Cache ?? {
            let cache = getter(itemValue)
            context.itemCaches[index.section][index.item] = cache
            return cache
        }()
    }
}
