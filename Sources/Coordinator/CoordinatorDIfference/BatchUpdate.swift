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
}

extension IndexSet: IndexCollection { }
extension Array: IndexCollection {
    mutating func formUnion(_ other: [Element]) { self += other }
}


struct BatchUpdate {
    typealias Section = Update<IndexSet>
    typealias Item = Update<[IndexPath]>
    
    struct Update<Collection: IndexCollection> {
        typealias Index = Collection.Element
        var deletions = Collection()
        var insertions = Collection()
        var updates = Collection()
        var moves = [Mapping<Index>]()
        
        var isEmpty: Bool {
            deletions.isEmpty && insertions.isEmpty && moves.isEmpty && updates.isEmpty
        }
        
        mutating func adding(other: Update<Collection>, isSource: Bool? = nil) {
            if isSource != false {
                if !other.deletions.isEmpty { deletions.formUnion(other.deletions) }
            }
            if isSource != true {
                if !other.insertions.isEmpty { insertions.formUnion(other.insertions) }
                if !other.updates.isEmpty { updates.formUnion(other.updates) }
                if !other.moves.isEmpty { moves += other.moves }
            }
        }
    }
    
    var section = Section()
    var item = Item()
    var change: (() -> Void)?

    var isEmpty: Bool { section.isEmpty && item.isEmpty }
    
    mutating func adding(other: BatchUpdate) {
        if !other.section.isEmpty { section.adding(other: other.section) }
        if !other.item.isEmpty { item.adding(other: other.item) }
        guard let otherChange = other.change else { return }
        adding(otherChange: otherChange)
    }
    
    mutating func adding(otherChange: (() -> Void)?) {
        guard let otherChange = otherChange else { return }
        change = change.map { change in
            {
                change()
                otherChange()
            }
        } ?? otherChange
    }
}

struct ListUpdate {
    var first = BatchUpdate()
    var second = BatchUpdate()
    var third = BatchUpdate()
    var complete: (() -> Void)?
    
    var updates: [(isLast: Bool, update: BatchUpdate)] {
        [first, second, third]
            .enumerated()
            .filter { !$0.element.isEmpty }
            .map { ($0.offset == 2, $0.element) }
    }
    
    mutating func adding(other: ListUpdate) {
        if !other.first.isEmpty { first.adding(other: other.first) }
        if !other.second.isEmpty { second.adding(other: other.second) }
        if !other.third.isEmpty { third.adding(other: other.third) }
    }
}

extension BatchUpdate.Update: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        D \(deletions.reduce("") { $0 + "\($1) " })
        I \(insertions.reduce("") { $0 + "\($1) " })
        U \(updates.reduce("") { $0 + "\($1) " })
        M \(moves.reduce("") { $0 + "(\($1.source), \($1.target)) " })
        """
    }
}

extension BatchUpdate: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        D \(item.deletions.reduce("") { $0 + "\($1) " })
        I \(item.insertions.reduce("") { $0 + "\($1) " })
        M \(item.moves.reduce("") { $0 + "(\($1.source), \($1.target)) " })
        """
    }
}
