//
//  IndexPath+extension.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

protocol ListIndex: Hashable {
    static var zero: Self { get }
    var section: Int { get }
    var item: Int { get }
    
    init(_ value: Self?, offset: Int)
    init(section: Int, item: Int)
    func offseted(_ offset: Int) -> Self
    
    func add<Cache>(
        _ related: Self,
        from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: inout [IndexPath: Cache?],
        _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
    )
    
    func remove<Cache>(from caches: inout ContiguousArray<ContiguousArray<Cache?>>)
    
    func insert<Cache>(
        to caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: [IndexPath: Cache?],
        _ sectionMoves: [Int: ContiguousArray<Cache?>],
        countIn: (Int) -> Int
    )
}

extension IndexPath: ListIndex {
    static var zero: IndexPath { IndexPath(section: 0, item: 0) }
    
    var section: Int {
        get { self[startIndex] }
        set { self[startIndex] = newValue }
    }
    
    var item: Int {
        get { self[index(before: endIndex)] }
        set { self[index(before: endIndex)] = newValue }
    }
    
    init(_ value: IndexPath?, offset: Int) {
        self = value?.offseted(offset) ?? .init(item: offset)
    }
    
    init(section: Int = 0, item: Int = 0) {
        self = [section, item]
    }
    
    func offseted(_ offset: Int = 0) -> IndexPath {
        var indexPath = self
        indexPath.item = item
        return indexPath
    }
    
    func add<Cache>(
        _ related: Self,
        from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: inout [IndexPath: Cache?],
        _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
    ) {
        itemMoves[self] = caches[related.section][related.item]
    }
    
    func remove<Cache>(from caches: inout ContiguousArray<ContiguousArray<Cache?>>) {
        caches[section].remove(at: item)
    }
    
    func insert<Cache>(
        to caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: [IndexPath: Cache?],
        _ sectionMoves: [Int: ContiguousArray<Cache?>],
        countIn: (Int) -> Int
    ) {
        let cache = itemMoves[self] ?? nil
        if caches[section].count > item {
            caches[section].insert(cache, at: item)
        } else {
            caches[section].append(cache)
        }
    }
}

extension Int: ListIndex {
    var section: Int { self }
    var item: Int { 0 }
    
    init(_ value: Int?, offset: Int) { self = (value ?? 0) + offset }
    init(section: Int = 0, item: Int = 0) { self = section }
    
    func offseted(_ offset: Int) -> Int { self + offset }
    
    func add<Cache>(
        _ related: Self,
        from caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: inout [IndexPath: Cache?],
        _ sectionMoves: inout [Int: ContiguousArray<Cache?>]
    ) {
        sectionMoves[self] = caches[related]
    }
    
    func remove<Cache>(from caches: inout ContiguousArray<ContiguousArray<Cache?>>) {
        caches.remove(at: self)
    }
    
    func insert<Cache>(
        to caches: inout ContiguousArray<ContiguousArray<Cache?>>,
        _ itemMoves: [IndexPath: Cache?],
        _ sectionMoves: [Int: ContiguousArray<Cache?>],
        countIn: (Int) -> Int
    ) {
        let cache = sectionMoves[self] ?? .init(repeatElement: nil, count: countIn(self))
        if caches.count > self {
            caches.insert(cache, at: self)
        } else {
            caches.append(cache)
        }
    }
}
