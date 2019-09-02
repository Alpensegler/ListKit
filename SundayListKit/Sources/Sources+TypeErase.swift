//
//  Sources+TypeErase.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias AnyListSources<Item, UIViewType> = Sources<Any, Item, UIViewType>
public typealias AnySources<Item> = Sources<Any, Item, Never>

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

public protocol SourcesTypeAraser: Source where SubSource == Any {
    init<Value: Source>(_ source: Value) where Value.Item == Item
}

extension Sources: SourcesTypeAraser where SubSource == Any, UIViewType == Never {
    public init<Value: Source>(_ source: Value) where Item == Value.Item {
        self.init(sources: source.eraseToSources())
    }
    
    init<Source, View>(sources: Sources<Source, Item, View>) {
        createSnapshotWith = { sources.createSnapshot(with: $0 as! Source).castToSnapshot() }
        itemFor = { sources.item(for: $0.castToSnapshot(), at: $1) }
        updateContext = { sources.update(context: $0.castSnapshotType()) }
        
        sourceClosure = sources.sourceClosure
        sourceStored = sources.sourceStored
        
        listUpdater = sources.listUpdater
        diffable = sources.diffable
    }
}
