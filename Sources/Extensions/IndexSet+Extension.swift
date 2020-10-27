//
//  IndexSet+Extension.swift
//  ListKit
//
//  Created by Frain on 2020/10/27.
//

import Foundation

extension IndexSet: UpdateIndexCollection {
    static func insert(_ elements: IndexSet, by list: ListView) { list.insertSections(elements) }
    static func delete(_ elements: IndexSet, by list: ListView) { list.deleteSections(elements) }
    static func reload(_ elements: IndexSet, by list: ListView) { list.reloadSections(elements) }
    static func move(_ element: Mapping<Int>, by list: ListView) {
        list.moveSection(element.source, toSection: element.target)
    }
    
    var elements: IndexSet { self }
    init(_ element: Int) { self.init(integer: element) }
    init(_ from: Int, _ to: Int) { self.init(integersIn: from..<to) }
    
    mutating func add(_ other: IndexSet) { formUnion(other) }
    mutating func add(_ element: Int) { insert(element) }
    mutating func add(_ from: Int, _ to: Int) { insert(integersIn: from..<to) }
    
    func elements(_ offset: Int?) -> IndexSet {
        guard let offset = offset else { return self }
        return .init(map { $0 + offset })
    }
}
