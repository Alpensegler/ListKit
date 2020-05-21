//
//  Update.swift
//  ListKit
//
//  Created by Frain on 2020/1/13.
//

public struct ListUpdate<Item> {
    enum Way {
        case reload
        case diff(Differ<Item>)
    }
    
    let way: Way
    var diff: Differ<Item>? {
        guard case let .diff(differ) = way else { return nil }
        return differ
    }
}

extension ListUpdate {
    init(id: ((Item) -> AnyHashable)? = nil, by areEquivalent: ((Item, Item) -> Bool)? = nil) {
        self.init(diff: Differ(identifier: id, areEquivalent: areEquivalent))
    }
    
    init(diff: Differ<Item>) {
        way = .diff(diff)
    }
}

extension ListUpdate: DiffInitializable {
    public typealias Value = Item
    public static var reload: ListUpdate<Item> { .init(way: .reload) }
    
    public static func diff(
        by areEquivalent: @escaping (Item, Item) -> Bool
    ) -> ListUpdate<Item> {
        .init(id: nil, by: areEquivalent)
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (Item) -> ID
    ) -> ListUpdate<Item> {
        .init(id: id, by: nil)
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (Item) -> ID,
        by areEquivalent: @escaping (Item, Item) -> Bool
    ) -> ListUpdate<Item> {
        .init(id: id, by: areEquivalent)
    }
}
