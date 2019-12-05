//
//  Differ.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

protocol DiffEquatable: Hashable {
    func diffEqual(to other: Self, default value: Bool) -> Bool
    var shouldHash: Bool { get }
}

extension DiffEquatable {
    var shouldHash: Bool { true }
    func diffEqual(to other: Self) -> Bool { diffEqual(to: other, default: false) }
}

extension Never: DiffEquatable {
    func diffEqual(to other: Self, default value: Bool) -> Bool { }
}

struct Differ<Value> {
    var identifier: ((Value) -> AnyHashable)?
    var areEquivalent: ((Value, Value) -> Bool)?
    
    var shouldHash: Bool { identifier != nil }
    var isNone: Bool { identifier == nil && areEquivalent == nil }
    
    func hash(value: () -> Value, into hasher: inout Hasher) {
        identifier.map { hasher.combine($0(value())) }
    }
    
    func equal(lhs: () -> Value, rhs: () -> Value) -> Bool {
        guard let equivalent = areEquivalent else { return true }
        return equivalent(lhs(), rhs())
    }
    
    func diffEqual(lhs: () -> Value, rhs: () -> Value, default value: Bool = false) -> Bool {
        switch (identifier, areEquivalent) {
        case let (id?, areEquivalent?): return id(lhs()) == id(rhs()) && areEquivalent(lhs(), rhs())
        case let (id?, _): return id(lhs()) == id(rhs())
        case let (_, areEquivalent?): return areEquivalent(lhs(), rhs())
        default: return value
        }
    }
}

extension Differ {
    init<OtherValue>(
        differ: Differ<OtherValue>,
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
}

struct Diffable<Value>: DiffEquatable {
    let type: ObjectIdentifier
    let differ: Differ<Value>
    let value: () -> Value
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        differ.hash(value: value, into: &hasher)
    }
    
    func diffEqual(to other: Self, default value: Bool) -> Bool {
        type == other.type && differ.diffEqual(lhs: self.value, rhs: other.value, default: value)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type && lhs.differ.equal(lhs: lhs.value, rhs: rhs.value)
    }
}
