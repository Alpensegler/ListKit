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
    func offseted(_ offset: Int) -> Self
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
}

extension Int: ListIndex {
    var section: Int { self }
    var item: Int { 0 }
    
    init(_ value: Int?, offset: Int) { self = (value ?? 0) + offset }
    func offseted(_ offset: Int) -> Int { self + offset }
}
