//
//  Sources+Source.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Sources: Source, ListUpdatable {
    public func createSnapshot(with source: SubSource) -> Snapshot<SubSource, Item> {
        return createSnapshotWith(source)
    }
    
    public func item(for snapshot: Snapshot<SubSource, Item>, at indexPath: IndexPath) -> Item {
        return itemFor(snapshot, indexPath)
    }
    
    public func update(context: UpdateContext<SubSource, Item>) {
        updateContext(context)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willUpdateWith change: ListChange) {
        collectionViewWillUpdate?(collectionView, change)
    }
    
    public func tableView(_ tableView: UITableView, willUpdateWith change: ListChange) {
        tableViewWillUpdate?(tableView, change)
    }
    
    public func eraseToSources() -> Sources<SubSource, Item, Never> {
        return castViewType()
    }
}

//Normal
public extension Source {
    func eraseToSources() -> Sources<SubSource, Item, Never> {
        return .init(self)
    }
}

public extension Sources {
    init<Value: Source>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        self.init(_source: source)
    }
}

//Identifiable
public extension Source where Self: Identifiable {
    func eraseToSources() -> Sources<SubSource, Item, Never> {
        return .init(self)
    }
}

public extension Sources {
    init<Value: Source & Identifiable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        self.init(_source: source)
        diffable = .init(source())
    }
}

//Diffable
public extension Source where Self: Diffable {
    func eraseToSources() -> Sources<SubSource, Item, Never> {
        return .init(self)
    }
}

public extension Sources {
    init<Value: Source & Diffable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        self.init(_source: source)
        diffable = .init(source())
    }
}

//ListUpdatable
public extension Source where Self: ListUpdatable {
    func eraseToSources() -> Sources<SubSource, Item, Never> {
        return .init(self)
    }
}

public extension Sources {
    init<Value: Source & ListUpdatable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        self.init(_source: source)
    }
}

//ListUpdatable + Identifiable
public extension Source where Self: Identifiable, Self: ListUpdatable {
    func eraseToSources() -> Sources<SubSource, Item, Never> {
        return .init(self)
    }
}
 
public extension Sources {
    init<Value: Source & Identifiable & ListUpdatable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        self.init(_source: source)
        diffable = .init(source())
    }
}

//ListUpdatable + Diffable
public extension Source where Self: Diffable, Self: ListUpdatable {
    func eraseToSources() -> Sources<SubSource, Item, Never> {
        return .init(self)
    }
}
    
public extension Sources {
    init<Value: Source & Diffable & ListUpdatable>(_ source: @escaping @autoclosure () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        self.init(_source: source)
        diffable = .init(source())
    }
}

extension Sources {
    init<Value: Source>(_source: @escaping () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        sourceClosure = { _source().source }
        createSnapshotWith = { _source().createSnapshot(with: $0) }
        itemFor = { _source().item(for: $0, at: $1) }
        updateContext = { _source().update(context: $0) }
    }
    
    init<Value: Source & ListUpdatable>(_source: @escaping () -> Value)
    where
        Value.SubSource == SubSource,
        Value.Item == Item
    {
        listUpdater = _source().listUpdater
        collectionViewWillUpdate = { _source().collectionView($0, willUpdateWith: $1) }
        tableViewWillUpdate = { _source().tableView($0, willUpdateWith: $1) }
        sourceClosure = { _source().source }
        createSnapshotWith = { _source().createSnapshot(with: $0) }
        itemFor = { _source().item(for: $0, at: $1) }
        updateContext = { _source().update(context: $0) }
    }
}
