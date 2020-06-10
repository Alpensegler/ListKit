//
//  Context.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

import Foundation

@dynamicMemberLookup
public protocol Context {
    associatedtype List
    associatedtype Source: DataSource where Source.SourceBase == Source
    
    var coordinator: ListCoordinator<Source> { get }
    var listView: List { get }
}

public protocol SectionContext: Context {
    var section: Int { get }
    var sectionOffset: Int { get }
}

public protocol ItemContext: SectionContext {
    var item: Int { get }
    var itemOffset: Int { get }
}

public extension Context {
    var source: Source.Source { coordinator.source }

    subscript<Value>(dynamicMember keyPath: KeyPath<Source.Source, Value>) -> Value {
        source[keyPath: keyPath]
    }
}

extension ItemContext {
    var itemValue: Source.Item { coordinator.item(at: section, item) }
    
    func setNestedCache(with key: AnyHashable, update: @escaping (Any) -> Void) {
        coordinator
            .itemRelatedCache(at: section, item)
            .nestedAdapterItemUpdate[key] = (true, update)
    }
    
    func cacheForItem(_ key: ObjectIdentifier) -> Any? {
        coordinator.itemRelatedCache(at: section, item)
    }
}
