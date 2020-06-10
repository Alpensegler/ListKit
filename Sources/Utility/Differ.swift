//
//  Differ.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

struct Differ<Value> {
    let identifier: ((Value) -> AnyHashable)?
    let areEquivalent: ((Value, Value) -> Bool)?
    let diffEqual: (Value, Value) -> Bool
    
    var shouldHash: Bool { identifier != nil }
    var isNone: Bool { identifier == nil && areEquivalent == nil }
    
    func hash(value: Value, into hasher: inout Hasher) {
        identifier.map { hasher.combine($0(value)) }
    }
    
    func equal(lhs: Value, rhs: Value) -> Bool {
        guard let equivalent = areEquivalent else { return true }
        return equivalent(lhs, rhs)
    }
    
    init(
        identifier: ((Value) -> AnyHashable)? = nil,
        areEquivalent: ((Value, Value) -> Bool)? = nil,
        diffEqual: ((Value, Value) -> Bool)? = nil
    ) {
        self.identifier = identifier
        self.areEquivalent = areEquivalent
        self.diffEqual = diffEqual ?? { (lhs, rhs) in
            switch (identifier, areEquivalent) {
            case let (id?, areEquivalent?): return id(lhs) == id(rhs) && areEquivalent(lhs, rhs)
            case let (id?, _): return id(lhs) == id(rhs)
            case let (_, areEquivalent?): return areEquivalent(lhs, rhs)
            default: return false
            }
        }
    }
}

extension Differ {
    init<OtherValue>(
        _ differ: Differ<OtherValue>,
        cast: @escaping (Value) -> (OtherValue) = { $0 as! OtherValue }
    ) {
        let diffEqual = differ.diffEqual
        self.identifier = differ.identifier.map { id in { id(cast($0)) } }
        self.areEquivalent = differ.areEquivalent.map { equal in { equal(cast($0), cast($1)) } }
        self.diffEqual = { diffEqual(cast($0), cast($1)) }
    }
}
