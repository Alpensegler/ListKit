//
//  Sources+Source.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Sources: Source, ListUpdatable {
    public func createSnapshot(with source: SubSource) -> SourceSnapshot {
        return createSnapshotWith(source)
    }
    
    public func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return itemFor(snapshot, indexPath)
    }
    
    public func update(context: UpdateContext<SourceSnapshot>) {
        updateContext(context)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willUpdateWith change: ListChange) {
        collectionViewWillUpdate?(collectionView, change)
    }
    
    public func tableView(_ tableView: UITableView, willUpdateWith change: ListChange) {
        tableViewWillUpdate?(tableView, change)
    }
}

public extension Source {
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never> {
        return .init(self)
    }
}

public extension Source where Self: Identifiable {
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never> {
        return .init(self)
    }
}

public extension Source where Self: Diffable {
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never> {
        return .init(self)
    }
}

public extension Source where Self: ListUpdatable {
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never> {
        return .init(self)
    }
}

public extension Source where Self: Identifiable, Self: ListUpdatable {
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never> {
        return .init(self)
    }
}

public extension Source where Self: Diffable, Self: ListUpdatable {
    func eraseToSources() -> Sources<SubSource, Item, SourceSnapshot, Never> {
        return .init(self)
    }
}

public extension Sources {
    private init<Value: Source>(_source: @escaping () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        sourceClosure = { _source().source }
        createSnapshotWith = { _source().createSnapshot(with: $0) }
        itemFor = { _source().item(for: $0, at: $1) }
        updateContext = { _source().update(context: $0) }
        
        sourceStored = nil
    }
    
    private init<Value: Source & ListUpdatable>(_source: @escaping () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        listUpdater = _source().listUpdater
        sourceClosure = { _source().source }
        createSnapshotWith = { _source().createSnapshot(with: $0) }
        itemFor = { _source().item(for: $0, at: $1) }
        updateContext = { _source().update(context: $0) }
        
        sourceStored = nil
    }
    
    init<Value: Source>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        self.init(_source: source)
    }
    
    init<Value: Source & Identifiable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        self.init(_source: source)
        diffable = .init(source)
    }
    
    init<Value: Source & Diffable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        self.init(_source: source)
        diffable = .init(source)
    }
    
    init<Value: Source & ListUpdatable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        self.init(_source: source)
    }
    
    init<Value: Source & Identifiable & ListUpdatable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        self.init(_source: source)
        diffable = .init(source)
    }
    
    init<Value: Source & Diffable & ListUpdatable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item,
        Value.SourceSnapshot == SourceSnapshot
    {
        self.init(_source: source)
        diffable = .init(source)
    }
}
