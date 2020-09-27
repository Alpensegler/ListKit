//
//  ChangeSet.swift
//  ListKit
//
//  Created by Frain on 2020/9/2.
//

import Foundation

protocol ChangeSet {
    associatedtype Element
    associatedtype Elements where Elements: UpdateIndexCollection, Elements.Element == Element
    
    init()
    
    var isEmpty: Bool { get }
    
    mutating func add(_ index: Element)
    mutating func add(_ indices: Elements)
    func elements(_ offset: Element?) -> Elements
}

extension IndexSet: ChangeSet {
    typealias Elements = IndexSet
    
    func elements(_ offset: Int? = nil) -> IndexSet {
        guard let offset = offset else { return self }
        return .init(map { $0 + offset })
    }
}

extension IndexPathSet: ChangeSet {
    typealias Element = IndexPath
    typealias Elements = [IndexPath]
}

struct ChangeSets<Set: ChangeSet> {
    typealias Index = Set.Element
    typealias Indices = Set.Elements
    
    var all: Mapping<Set> = (.init(), .init())
    var changes: Mapping<Set> = (.init(), .init())
    var reload = Set()
    var move = Set()
    var reloadDict = [Index: Index]()
    var moveDict = [Index: Index]()
    
    func toSource(offset: Index?) -> BatchUpdates.Source<Indices> {
        .init(
            all: all.source.elements(offset),
            deletes: changes.source.elements(offset),
            reloads: reload.elements(offset),
            isEmpty: all.source.isEmpty
        )
    }
    
    func toTarget(offset: Mapping<Index>?) -> BatchUpdates.Target<Indices> {
        .init(
            all: all.target.elements(offset?.target),
            inserts: changes.target.elements(offset?.target),
            moves: move.elements(nil).map {
                guard let index = moveDict[$0] else { fatalError() }
                let source = offset?.source.offseted(index, plus: true) ?? index
                let target = offset?.target.offseted($0, plus: true) ?? $0
                return (source, target)
            },
            moveDict: moveDict,
            isEmpty: all.target.isEmpty
        )
    }
}

extension ChangeSets {
    mutating func insert(_ index: Index) {
        changes.target.add(index)
        all.target.add(index)
    }
    
    mutating func insert(_ indices: Indices) {
        changes.target.add(indices)
        all.target.add(indices)
    }
    
    mutating func delete(_ index: Index) {
        changes.source.add(index)
        all.source.add(index)
    }
    
    mutating func delete(_ indices: Indices) {
        changes.source.add(indices)
        all.source.add(indices)
    }
    
    mutating func reload(_ index: Index, newIndex: Index) {
        reload.add(index)
        reloadDict[index] = newIndex
        all.source.add(index)
        all.target.add(newIndex)
    }
    
    mutating func reload(_ indices: Indices, newIndices: Indices) {
        reload.add(indices)
        zip(indices, newIndices).forEach { reloadDict[$0.0] = $0.1 }
        all.source.add(indices)
        all.target.add(newIndices)
    }
    
    mutating func move(_ index: Index, to newIndex: Index) {
        move.add(newIndex)
        moveDict[newIndex] = index
        all.source.add(index)
        all.target.add(newIndex)
    }
}
