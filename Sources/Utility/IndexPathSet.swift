//
//  IndexPathSet.swift
//  ListKit
//
//  Created by Frain on 2020/9/2.
//

import Foundation

struct IndexPathSet {
    var sections = IndexSet()
    var items = [Int: IndexSet]()
    
    var isEmpty: Bool { items.isEmpty }
    
    mutating func add(_ element: IndexPath) {
        sections.insert(element.section)
        self[element.section].insert(element.item)
    }
    
    mutating func add(_ elements: [IndexPath]) {
        elements.forEach { self.add($0) }
    }
    
    mutating func remove(_ indexPath: IndexPath) {
        sections.remove(indexPath.section)
        self[indexPath.section].remove(indexPath.item)
    }
    
    subscript(key: Int) -> IndexSet {
        get { items[key] ?? .init() }
        set { items[key] = newValue }
    }
    
    func elements(_ offset: IndexPath? = nil) -> [IndexPath] {
        sections.flatMap { section -> [IndexPath] in
            guard let indexSet = items[section] else { return [] }
            return indexSet.map { IndexPath(offset, section: section, item: $0) }
        }
    }
}
