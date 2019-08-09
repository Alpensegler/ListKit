//
//  Sources+TypeErase.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol AnySourceSnapshotType: SnapshotType {
    var base: SnapshotType { get }
    init(_ base: SnapshotType)
}

public struct AnySourceSnapshot: AnySourceSnapshotType {
    public var base: SnapshotType
    
    public init(_ base: SnapshotType) {
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

public protocol SourcesTypeAraser: Source where SubSource == Any, SourceSnapshot: AnySourceSnapshotType {
    init<Value: Source>(_ source: Value) where Value.Item == Item
}

extension Sources: SourcesTypeAraser where SubSource == Any, SourceSnapshot: AnySourceSnapshotType, UIViewType == Never {
    public init<Value: Source>(_ source: Value) where Item == Value.Item {
        self.init(sources: source.eraseToSources())
    }
    
    init<Source, Snapshot, View>(sources: Sources<Source, Item, Snapshot, View>) {
        sourceClosure = sources.sourceClosure
        sourceStored = sources.sourceStored
        
        listUpdater = sources.listUpdater
        diffable = sources.diffable
        
        createSnapshotWith = { .init(sources.createSnapshot(with: $0 as! Source)) }
        itemFor = { sources.item(for: $0.base as! Snapshot, at: $1) }
        updateContext = { sources.update(context: .init(rawSnapshot: $0.rawSnapshot.base as! Snapshot, snapshot: $0.snapshot.base as! Snapshot)) }
    }
}
