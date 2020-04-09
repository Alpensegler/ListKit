//
//  Differ.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public struct Differ<Value> {
    var identifier: ((Value) -> AnyHashable)?
    var areEquivalent: ((Value, Value) -> Bool)?
    
    var shouldHash: Bool { identifier != nil }
    var isNone: Bool { identifier == nil && areEquivalent == nil }
    
    func hash(value: Value, into hasher: inout Hasher) {
        identifier.map { hasher.combine($0(value)) }
    }
    
    func equal(lhs: Value, rhs: Value) -> Bool {
        guard let equivalent = areEquivalent else { return true }
        return equivalent(lhs, rhs)
    }
    
    func diffEqual(lhs: Value, rhs: Value, default value: Bool = false) -> Bool {
        switch (identifier, areEquivalent) {
        case let (id?, areEquivalent?): return id(lhs) == id(rhs) && areEquivalent(lhs, rhs)
        case let (id?, _): return id(lhs) == id(rhs)
        case let (_, areEquivalent?): return areEquivalent(lhs, rhs)
        default: return value
        }
    }
    
    func diffEqual(lhs: Value, rhs: Value) -> Bool {
        switch (identifier, areEquivalent) {
        case let (id?, areEquivalent?): return id(lhs) == id(rhs) && areEquivalent(lhs, rhs)
        case let (id?, _): return id(lhs) == id(rhs)
        case let (_, areEquivalent?): return areEquivalent(lhs, rhs)
        default: return false
        }
    }
}

extension Differ {
    init<OtherValue>(
        _ differ: Differ<OtherValue>,
        casting: @escaping (Value) -> (OtherValue?) = { $0 as? OtherValue }
    ) {
        self.identifier = differ.identifier.map { id in { id(casting($0)!) } }
        self.areEquivalent = differ.areEquivalent.map { equal in
            { (lhs, rhs) -> Bool in
                guard let lhs = casting(lhs), let rhs = casting(rhs) else { return false }
                return equal(lhs, rhs)
            }
        }
    }
    
    func merging<OtherValue>(
        _ differ: Differ<OtherValue>?,
        casting: @escaping (OtherValue) -> (Value?) = { $0 as? Value }
    ) -> Differ<OtherValue> {
        if let differ = self as? Differ<OtherValue> { return differ }
        guard let differ = differ else { return .init(self, casting: casting) }
        let identifier: ((OtherValue) -> AnyHashable)? = {
            guard let selfID = self.identifier else { return differ.identifier }
            return { (casting($0).map(selfID) ?? differ.identifier?($0))! }
        }()
        let areEquivalent: ((OtherValue, OtherValue) -> Bool)? = {
            guard let selfEquivalent = self.areEquivalent else { return differ.areEquivalent }
            return { (lhs, rhs) in
                guard let l = casting(lhs), let r = casting(rhs) else {
                    return differ.areEquivalent?(lhs, rhs) ?? false
                }
                return selfEquivalent(l, r)
            }
        }()
        return .init(identifier: identifier, areEquivalent: areEquivalent)
    }
}

extension Differ: DiffInitializable {
    public static var none: Differ<Value> { .init() }
    
    public static func diff(
        by areEquivalent: @escaping (Value, Value) -> Bool
    ) -> Differ<Value> {
        .init(identifier: nil, areEquivalent: areEquivalent)
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (Value) -> ID
    ) -> Differ<Value> {
        .init(identifier: id, areEquivalent: nil)
    }
    
    public static func diff<ID: Hashable>(
        id: @escaping (Value) -> ID,
        by areEquivalent: @escaping (Value, Value) -> Bool
    ) -> Differ<Value> {
        .init(identifier: id, areEquivalent: areEquivalent)
    }
}
