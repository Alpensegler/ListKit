//
//  Sources+TypeErase.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public struct AnySourceSnapshot: SnapshotType {
    var base: SnapshotType
    
    public init<Snapshot: SnapshotType>(_ base: Snapshot) {
        self.base = base
    }
    
    public func numbersOfSections() -> Int {
        return base.numbersOfSections()
    }
    
    public func numbersOfItems(in section: Int) -> Int {
        return base.numbersOfItems(in: section)
    }
}

public typealias AnyListSources<Item, UIViewType> = Sources<Any, Item, AnySourceSnapshot, UIViewType>
public typealias AnySources<Item> = Sources<Any, Item, AnySourceSnapshot, Never>

extension Source {
    func eraseToAnySources() -> AnySources<Item> {
        return eraseToSources().eraseToAnySources()
    }
}

extension Sources {
    func eraseToAnySources() -> AnySources<Item> {
        return .init(sources: self)
    }
}

extension Sources where SubSource == Any, SourceSnapshot == AnySourceSnapshot, UIViewType == Never {
    init<Source, Snapshot, View>(sources: Sources<Source, Item, Snapshot, View>) {
        sourceClosure = sources.sourceClosure
        sourceStored = sources.sourceStored
        
        listUpdater = sources.listUpdater
        diffable = sources.diffable
        
        createSnapshotWith = { AnySourceSnapshot(sources.createSnapshot(with: $0 as! Source)) }
        itemFor = { sources.item(for: $0.base as! Snapshot, at: $1) }
        updateContext = { sources.update(context: .init(rawSnapshot: $0.rawSnapshot.base as! Snapshot, snapshot: $0.snapshot.base as! Snapshot)) }
    }
}
