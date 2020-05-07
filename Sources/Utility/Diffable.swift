//
//  Diffable.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

class Diffable<Cache>: Hashable {
    var cache: Cache
    
    func hash(into hasher: inout Hasher) { }
    func isEquatable(with other: Diffable<Cache>) -> Bool { false }
    
    static func == (lhs: Diffable<Cache>, rhs: Diffable<Cache>) -> Bool {
        lhs.isEquatable(with: rhs)
    }
    
    init(cache: Cache) {
        self.cache = cache
    }
}

final class DiffableValue<Value, Cache>: Diffable<Cache> {
    var id: AnyHashable
    var differ: Differ<Value>
    var value: Value
    
    init(
        id: AnyHashable = ObjectIdentifier(Value.self),
        differ: Differ<Value>,
        value: Value,
        cache: Cache
    ) {
        self.differ = differ
        self.value = value
        self.id = id
        super.init(cache: cache)
    }
    
    convenience init(differ: Differ<Value>?, value: Value, cache: Cache) {
        let id = differ?.isNone != false ? nil : ObjectIdentifier(Value.self)
        self.init(id: id, differ: differ ?? .init(), value: value, cache: cache)
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        differ.hash(value: value, into: &hasher)
    }
    
    override func isEquatable(with other: Diffable<Cache>) -> Bool {
        guard let other = other as? Self else { return false }
        return differ.diffEqual(lhs: value, rhs: other.value)
    }
    
    func isDiffEqual(
        with other: Diffable<Cache>,
        differ: Differ<Value>?
    ) -> Bool {
        guard let other = other as? Self, id == other.id else { return false }
        return (differ ?? self.differ).diffEqual(lhs: self.value, rhs: other.value)
    }
}
