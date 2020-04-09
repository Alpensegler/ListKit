//
//  Diffable.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
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


struct Diffable<Value>: DiffEquatable {
    let id: AnyHashable
    let differ: Differ<Value>
    let value: Value
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        differ.hash(value: value, into: &hasher)
    }
    
    func diffEqual(to other: Self, default value: Bool) -> Bool {
        id == other.id && differ.diffEqual(lhs: self.value, rhs: other.value, default: value)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.differ.equal(lhs: lhs.value, rhs: rhs.value)
    }
}
