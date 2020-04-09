//
//  Update.swift
//  ListKit
//
//  Created by Frain on 2020/1/13.
//

public struct Update<Item> {
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

extension Update {
    init(id: ((Item) -> AnyHashable)? = nil, by areEquivalent: ((Item, Item) -> Bool)? = nil) {
        self.init(diff: Differ(identifier: id, areEquivalent: areEquivalent))
    }
    
    init(diff: Differ<Item>) {
        way = .diff(diff)
    }
}

extension Update: DiffInitializable {
    public typealias Value = Item
    public static var reload: Update<Item> { .init(way: .reload) }
    
    public static func diff(
        by areEquivalent: @escaping (Item, Item) -> Bool
    ) -> Update<Item> {
        .init(id: nil, by: areEquivalent)
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (Item) -> ID
    ) -> Update<Item> {
        .init(id: id, by: nil)
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (Item) -> ID,
        by areEquivalent: @escaping (Item, Item) -> Bool
    ) -> Update<Item> {
        .init(id: id, by: areEquivalent)
    }
}

//Item Equatable

//Item Hashable

//Item Identifiable

//Item Identifiable + Equatable
//Item Identifiable + Equatable
