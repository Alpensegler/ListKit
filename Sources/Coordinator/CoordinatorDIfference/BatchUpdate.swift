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
    var isEmpty: Bool { get }
    mutating func add(other: Self)
}

protocol ListViewApplyable: CustomDebugStringConvertible {
    func apply(by listView: ListView)
    mutating func offset(sectionOffset: Int, itemOffset: Int)
}

extension ListViewApplyable {
    func offseted(by sectionOffset: Int, _ itemOffset: Int) -> Self {
        var mutableSelf = self
        mutableSelf.offset(sectionOffset: sectionOffset, itemOffset: itemOffset)
        return mutableSelf
    }
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
    
    var isEmpty: Bool { source.isEmpty && target.isEmpty }
    
    mutating func add(other: Update<Collection>) {
        source.add(other: other.source)
        target.add(other: other.target)
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
    
    mutating func offset(sectionOffset: Int, itemOffset: Int) {
        if sectionOffset == 0, itemOffset == 0 { return }
        if !source.deletions.isEmpty {
            source.deletions = source.deletions.map { $0.offseted(sectionOffset, itemOffset) }
        }
        if !target.insertions.isEmpty {
            target.insertions = target.insertions.map { $0.offseted(sectionOffset, itemOffset) }
        }
        if !target.updates.isEmpty {
            target.updates = target.updates.map { $0.offseted(sectionOffset, itemOffset) }
        }
        if !target.moves.isEmpty {
            target.moves = target.moves.map {
                ($0.offseted(sectionOffset, itemOffset), $1.offseted(sectionOffset, itemOffset))
            }
        }
    }
}

typealias ListBatchUpdates = BatchUpdates<SectionUpdate, ItemUpdate>

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

extension BatchUpdates: ListViewApplyable where Section == SectionUpdate, Item == ItemUpdate {
    func apply(by listView: ListView) {
        if !section.source.deletions.isEmpty { listView.deleteSections(section.source.deletions) }
        if !section.target.insertions.isEmpty { listView.insertSections(section.target.insertions) }
        if !section.target.updates.isEmpty { listView.reloadSections(section.target.updates) }
        section.target.moves.forEach { listView.moveSection($0, toSection: $1) }
        
        item.apply(by: listView)
    }
    
    mutating func offset(sectionOffset: Int, itemOffset: Int) {
        guard sectionOffset != 0 else { return }
        if !section.source.deletions.isEmpty {
            section.source.deletions = .init(section.source.deletions.map { $0 + sectionOffset })
        }
        if !section.target.insertions.isEmpty {
            section.target.insertions = .init(section.target.insertions.map { $0 + sectionOffset })
        }
        if !section.target.updates.isEmpty {
            section.target.updates = .init(section.target.updates.map { $0 + sectionOffset })
        }
        if !section.target.moves.isEmpty {
            section.target.moves = section.target.moves.map {
                ($0 + sectionOffset, $1 + sectionOffset)
            }
        }
        
        item.offset(sectionOffset: sectionOffset, itemOffset: itemOffset)
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
