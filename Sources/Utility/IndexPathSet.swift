//
//  IndexPathSet.swift
//  ListKit
//
//  Created by Frain on 2020/9/2.
//

import Foundation

struct IndexPathSet: UpdateIndexCollection {
    typealias Element = IndexPath
    typealias Elements = [IndexPath]
    
    static func insert(_ elements: Elements, by list: ListView) { list.insertItems(at: elements) }
    static func delete(_ elements: Elements, by list: ListView) { list.deleteItems(at: elements) }
    static func reload(_ elements: Elements, by list: ListView) { list.reloadItems(at: elements) }
    static func move(_ element: Mapping<IndexPath>, by list: ListView) {
        list.moveItem(at: element.source, to: element.target)
    }
    
    var sections = IndexSet()
    var items = [Int: IndexSet]()
    
    var isEmpty: Bool { items.isEmpty }
    
    init() { }
    
    init(_ element: IndexPath) {
        sections = .init(element.section)
        self[element.section] = .init(element.item)
    }
    
    init(_ elements: [IndexPath]) {
        elements.forEach { self.add($0) }
    }
    
    init(_ from: IndexPath, _ to: IndexPath) {
        sections.insert(from.section)
        self[from.section] = .init(from.item, to.item)
    }
    
    subscript(key: Int) -> IndexSet {
        get { items[key] ?? .init() }
        set { items[key] = newValue }
    }
    
    mutating func add(_ element: IndexPath) {
        sections.insert(element.section)
        self[element.section].insert(element.item)
    }
    
    mutating func add(_ elements: [IndexPath]) {
        elements.forEach { self.add($0) }
    }
    
    mutating func add(_ from: IndexPath, _ to: IndexPath) { add(.init(from, to)) }
    mutating func add(_ other: Self) { add(other.elements()) }
    
    mutating func remove(_ indexPath: IndexPath) {
        self[indexPath.section].remove(indexPath.item)
        if self[indexPath.section].isEmpty {
            sections.remove(indexPath.section)
            items[indexPath.section] = nil
        }
    }
    
    func elements(_ offset: IndexPath? = nil) -> [IndexPath] {
        sections.flatMap { section -> [IndexPath] in
            items[section]!.map { .init(offset, section: section, item: $0) }
        }
    }
}
