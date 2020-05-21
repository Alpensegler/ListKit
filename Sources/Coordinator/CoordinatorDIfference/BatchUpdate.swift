//
//  Update.swift
//  ListKit
//
//  Created by Frain on 2020/5/7.
//

import Foundation

protocol DefaultInitializable {
    init()
}

protocol IndexCollection: DefaultInitializable, Collection {
    mutating func formUnion(_ other: Self)
}

protocol BatchUpdate: DefaultInitializable {
    mutating func add(other: Self)
    
    var isEmpty: Bool { get }
}

protocol ListViewApplyable: CustomDebugStringConvertible {
    func apply(by listView: ListView)
}

typealias ListUpdates = [(update: ListViewApplyable, change: (() -> Void)?)]

extension IndexSet: IndexCollection { }
extension Array: IndexCollection {
    mutating func formUnion(_ other: [Element]) { self += other }
}

struct SourceUpdate<Collection: IndexCollection>: BatchUpdate {
    var deletions = Collection()
    
    var isEmpty: Bool { deletions.isEmpty }
    
    mutating func add(other: SourceUpdate) {
        if !other.deletions.isEmpty { deletions.formUnion(other.deletions) }
    }
}

typealias SectionSourceUpdate = SourceUpdate<IndexSet>
typealias ItemSourceUpdate = SourceUpdate<[IndexPath]>

struct TargetUpdate<Collection: IndexCollection>: BatchUpdate {
    var insertions = Collection()
    var updates = Collection()
    var moves = [Mapping<Collection.Element>]()
    
    var isEmpty: Bool { insertions.isEmpty && updates.isEmpty && moves.isEmpty }
    
    mutating func add(other: TargetUpdate) {
        if !other.insertions.isEmpty { insertions.formUnion(other.insertions) }
        if !other.updates.isEmpty { updates.formUnion(other.updates) }
        if !other.moves.isEmpty { moves += other.moves }
    }
}

typealias SectionTargetUpdate = TargetUpdate<IndexSet>
typealias ItemTargetUpdate = TargetUpdate<[IndexPath]>

struct Update<Collection: IndexCollection>: BatchUpdate {
    var source = SourceUpdate<Collection>()
    var target = TargetUpdate<Collection>()
    var change: (() -> Void)?
    
    var isEmpty: Bool { source.isEmpty && target.isEmpty }
    
    mutating func add(other: Update<Collection>) {
        source.add(other: other.source)
        target.add(other: other.target)
        guard let otherChange = other.change else { return }
        add(otherChange: otherChange)
    }
    
    mutating func add(otherChange: (() -> Void)?) {
        guard let otherChange = otherChange else { return }
        change = change.map { change in
            {
                change()
                otherChange()
            }
        } ?? otherChange
    }
}

typealias ItemUpdate = Update<[IndexPath]>
typealias SectionUpdate = Update<IndexSet>

extension Update: ListViewApplyable where Collection == [IndexPath] {
    func apply(by listView: ListView) {
        if !source.deletions.isEmpty { listView.deleteItems(at: source.deletions) }
        if !target.insertions.isEmpty { listView.insertItems(at: target.insertions) }
        if !target.updates.isEmpty { listView.reloadItems(at: target.updates) }
        target.moves.forEach { listView.moveItem(at: $0, to: $1) }
    }
}

struct BatchUpdates<Section: BatchUpdate, Item: BatchUpdate>: BatchUpdate {
    var section = Section()
    var item = Item()

    var isEmpty: Bool { section.isEmpty && item.isEmpty }
    
    mutating func add(other: BatchUpdates) {
        section.add(other: other.section)
        item.add(other: other.item)
    }
}

typealias SourceBatchUpdates = BatchUpdates<SectionSourceUpdate, ItemSourceUpdate>
typealias TargetBatchUpdates = BatchUpdates<SectionTargetUpdate, ItemTargetUpdate>

typealias ListBatchUpdates = BatchUpdates<SectionUpdate, ItemUpdate>

extension BatchUpdates: ListViewApplyable where Section == SectionUpdate, Item == ItemUpdate {
    func apply(by listView: ListView) {
        if !section.source.deletions.isEmpty { listView.deleteSections(section.source.deletions) }
        if !section.target.insertions.isEmpty { listView.insertSections(section.target.insertions) }
        if !section.target.updates.isEmpty { listView.reloadSections(section.target.updates) }
        section.target.moves.forEach { listView.moveSection($0, toSection: $1) }
        
        item.apply(by: listView)
    }
}

struct Updates<Update: BatchUpdate> {
    var first = Update()
    var second = Update()
    var third = Update()
    var complete: (() -> Void)?
    
    var updates: [(isLast: Bool, update: Update)] {
        let notEmptys = [first, second, third].filter { !$0.isEmpty }
        return notEmptys.enumerated().map { ($0.offset == notEmptys.count - 1, $0.element) }
    }
    
    mutating func adding(other: Self) {
        first.add(other: other.first)
        second.add(other: other.second)
        third.add(other: other.third)
    }
}

extension Update: CustomDebugStringConvertible {
    var debugDescription: String {
        var descriptions = [String]()
        if !source.deletions.isEmpty {
            descriptions.append("D \(source.deletions.reduce("") { $0 + "\($1) " })")
        }
        if !target.insertions.isEmpty {
            descriptions.append("I \(target.insertions.reduce("") { $0 + "\($1) " })")
        }
        if !target.updates.isEmpty {
            descriptions.append("U \(target.updates.reduce("") { $0 + "\($1) " })")
        }
        if !target.moves.isEmpty {
            descriptions.append("M \(target.moves.reduce("") { $0 + "(\($1.source), \($1.target)) " })")
        }
        return descriptions.joined(separator: "\n")
    }
}

extension BatchUpdates: CustomDebugStringConvertible {
    var debugDescription: String {
        var descriptions = [String]()
        if !section.isEmpty {
            descriptions.append("Section:\n\(section)")
        }
        if !item.isEmpty {
            descriptions.append("Item:\n\(item)")
        }
        return descriptions.joined(separator: "\n")
    }
}
