//
//  DiffableClass.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

class DiffableClass<Cache>: Hashable {
    var cache: Cache
    
    func hash(into hasher: inout Hasher) { }
    func isEquatable(with other: DiffableClass<Cache>) -> Bool { false }
    
    static func == (lhs: DiffableClass<Cache>, rhs: DiffableClass<Cache>) -> Bool {
        lhs.isEquatable(with: rhs)
    }
    
    init(cache: Cache) {
        self.cache = cache
    }
}

final class DiffableValue<Value, Cache>: DiffableClass<Cache> {
    var id: AnyHashable?
    var differ: Differ<Value>
    var value: Value
    
    init(id: AnyHashable?, differ: Differ<Value>, value: Value, cache: Cache) {
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
        id.map { hasher.combine($0) }
        differ.hash(value: value, into: &hasher)
    }
    
    override func isEquatable(with other: DiffableClass<Cache>) -> Bool {
        guard let other = other as? Self else { return false }
        return differ.diffEqual(lhs: value, rhs: other.value)
    }
    
    func isDiffEqual(
        with other: DiffableClass<Cache>,
        differ: Differ<Value>?
    ) -> Bool {
        guard let other = other as? Self, id == other.id else { return false }
        return (differ ?? self.differ).diffEqual(lhs: self.value, rhs: other.value)
    }
}
