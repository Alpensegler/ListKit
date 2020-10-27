//
//  IndexPath+extension.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

protocol ListIndex: Hashable {
    static var zero: Self { get }
    static var isSection: Bool { get }
    var section: Int { get }
    var item: Int { get }
    
    init(_ value: Self?, offset: Int)
    init(section: Int, item: Int)
    func offseted(_ offset: Int) -> Self
    func offseted(_ offset: Int, isSection: Bool) -> Self
    func offseted(_ index: Self, plus: Bool) -> Self
    
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

extension ListIndex {
    func offseted(_ index: Self) -> Self { offseted(index, plus: true) }
}

extension IndexPath: ListIndex {
    static var zero: IndexPath { IndexPath(section: 0, item: 0) }
    static var isSection: Bool { false }
    
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
    
    init(_ value: IndexPath?, section: Int, item: Int) {
        self = value?.offseted(section, item) ?? .init(section: section, item: item)
    }
    
    init(section: Int = 0, item: Int = 0) {
        self = [section, item]
    }
    
    func offseted(_ offset: Int = 0) -> IndexPath {
        var indexPath = self
        indexPath.item = item + offset
        return indexPath
    }
    
    func offseted(_ offset: Int, isSection: Bool) -> IndexPath {
        var indexPath = self
        isSection ? (indexPath.section += offset) : (indexPath.item += offset)
        return indexPath
    }
    
    func offseted(_ section: Int, _ item: Int, plus: Bool = true) -> IndexPath {
        if section == 0, item == 0 { return self }
        var indexPath = self
        indexPath.item = self.item + (plus ? item : -item)
        indexPath.section = self.section + (plus ? section : -section)
        return indexPath
    }
    
    func offseted(_ index: IndexPath, plus: Bool = true) -> IndexPath {
        offseted(index.section, index.item, plus: plus)
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
    static var isSection: Bool { true }
    
    var section: Int { self }
    var item: Int { 0 }
    
    init(_ value: Int?, offset: Int) { self = (value ?? 0) + offset }
    init(section: Int = 0, item: Int = 0) { self = section }
    
    func offseted(_ offset: Int) -> Int { self + offset }
    func offseted(_ offset: Int, isSection: Bool) -> Int { isSection ? self + offset : self }
    func offseted(_ index: Int, plus: Bool) -> Int { self + (plus ? index : -index) }
    
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
