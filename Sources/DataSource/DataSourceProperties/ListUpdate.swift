//
//  ListUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/1/13.
//

enum ListUpdateWay<Item> {
    case diff(Differ<Item>)
    case reload
    case remove
    case appendOrRemoveLast
    case prependOrRemoveFirst
}

public struct ListUpdate<SourceBase: DataSource> where SourceBase.SourceBase == SourceBase {
    let way: ListUpdateWay<SourceBase.Item>
    var diff: Differ<SourceBase.Item>? {
        guard case let .diff(differ) = way else { return nil }
        return differ
    }
}

extension ListUpdate: DiffInitializableUpdate {
    init(id: ((Value) -> AnyHashable)? = nil, by areEquivalent: ((Value, Value) -> Bool)? = nil) {
        self.init(diff: Differ(identifier: id, areEquivalent: areEquivalent))
    }
    
    init(diff: Differ<Value>) {
        way = .diff(diff)
    }
}

public extension ListUpdate {
    typealias Value = SourceBase.Item
    
    init(_ listUpdate: ListUpdate<SourceBase>) {
        self = listUpdate
    }
}
