//
//  Update.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

protocol IndexCollection: Collection {
    init()
    
    mutating func formUnion(_ other: Self)
    mutating func append(_ newElement: Element)
}

extension Array: IndexCollection {
    mutating func formUnion(_ other: [Element]) { self += other }
}

extension IndexSet: IndexCollection {
    mutating func append(_ newElement: Int) { insert(newElement) }
}

struct BatchUpdate {
    typealias Section = Update<IndexSet>
    typealias Item = Update<[IndexPath]>
    
    struct Update<Collection: IndexCollection> {
        typealias Index = Collection.Element
        var deletions = Collection()
        var insertions = Collection()
        var moves = [Mapping<Index>]()
        var updates = Collection()
        
        var isEmpty: Bool {
            deletions.isEmpty && insertions.isEmpty && moves.isEmpty && updates.isEmpty
        }
        
        mutating func adding(other: Update<Collection>, isSource: Bool? = nil) {
            if isSource != false {
                if !other.deletions.isEmpty { deletions.formUnion(other.deletions) }
            }
            if isSource != true {
                if !other.insertions.isEmpty { insertions.formUnion(other.insertions) }
                if !other.moves.isEmpty { moves += other.moves }
                if !other.updates.isEmpty { updates.formUnion(other.updates) }
            }
        }
    }
    
    var section = Section()
    var item = Item()
    var change: (() -> Void)?
}

struct ListUpdate {
    var batches = [BatchUpdate]()
    var complete: (() -> Void)?
}
