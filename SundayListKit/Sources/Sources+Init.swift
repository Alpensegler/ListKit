//
//  Sources+Init.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/7.
//  Copyright © 2019 Frain. All rights reserved.
//

//MARK: - List

public typealias ListSources<Item> = Sources<[AnySources<Item>], Item, Snapshot<[AnySources<Item>], Item>, Never>

public extension Sources where SubSource == [AnySources<Item>], SourceSnapshot == Snapshot<[AnySources<Item>], Item>, UIViewType == Never {
    init<ID: Hashable>(id: ID, _ sources: [AnySources<Item>]) {
        sourceStored = sources
        sourceClosure = nil
        
        diffable = AnyDiffable(id)
        
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
    }
    
    init(_ sources: [AnySources<Item>]) {
        sourceStored = sources
        sourceClosure = nil
        
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
    }
    
    init<S: Source>(source: S?) where S.Item == Item {
        self.init(source.map { [$0.eraseToAnySources()] } ?? [])
    }
    
    init<S0: Source, S1: Source>(_ s0: S0?, _ s1: S1?) where S0.Item == Item, S1.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?) where S0.Item == Item, S1.Item == Item, S2.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            s2?.eraseToAnySources(),
            ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            s2?.eraseToAnySources(),
            s3?.eraseToAnySources(),
            ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            s2?.eraseToAnySources(),
            s3?.eraseToAnySources(),
            s4?.eraseToAnySources(),
            ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            s2?.eraseToAnySources(),
            s3?.eraseToAnySources(),
            s4?.eraseToAnySources(),
            s5?.eraseToAnySources(),
            ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S6.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            s2?.eraseToAnySources(),
            s3?.eraseToAnySources(),
            s4?.eraseToAnySources(),
            s5?.eraseToAnySources(),
            s6?.eraseToAnySources(),
            ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S7.Item == Item, S6.Item == Item {
        self.init([
            s0?.eraseToAnySources(),
            s1?.eraseToAnySources(),
            s2?.eraseToAnySources(),
            s3?.eraseToAnySources(),
            s4?.eraseToAnySources(),
            s5?.eraseToAnySources(),
            s6?.eraseToAnySources(),
            s7?.eraseToAnySources(),
            ].compactMap { $0 })
    }
}

//MARK: - Section

public typealias SectionSources<Item> = Sources<[Item], Item, Snapshot<[Item], Item>, Never>

public extension Sources where SubSource == [Item], SourceSnapshot == Snapshot<[Item], Item>, UIViewType == Never {
    private init(_items: [Item]) {
        sourceClosure = nil
        sourceStored = _items
        
        itemFor = { $0.item(at: $1) }
        createSnapshotWith = { .init($0) }
        updateContext = { $0.reloadCurrent() }
    }
    
    private init<ID: Hashable>(id: ID, _items: [Item]) {
        self.init(_items: _items)
        diffable = .init(id)
    }
    
    init(items: [Item]) {
        self.init(_items: items)
    }
    
    init<ID: Hashable>(id: ID, items: [Item]) {
        self.init(id: id, _items: items)
    }
}

//MARK: Equatable
public extension Sources where SubSource == [Item], SourceSnapshot == Snapshot<[Item], Item>, UIViewType == Never, Item: Equatable {
    
    init(items: [Item]) {
        self.init(_items: items)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, items: [Item]) {
        self.init(items: items)
        diffable = .init(id)
    }
}

//MARK: Hashable
public extension Sources where SubSource == [Item], SourceSnapshot == Snapshot<[Item], Item>, UIViewType == Never, Item: Hashable {
    
    init(items: [Item]) {
        self.init(_items: items)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, items: [Item]) {
        self.init(items: items)
        diffable = .init(id)
    }
}

//MARK: Identifiable
public extension Sources where SubSource == [Item], SourceSnapshot == Snapshot<[Item], Item>, UIViewType == Never, Item: Identifiable {
    
    init(items: [Item]) {
        self.init(_items: items)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, items: [Item]) {
        self.init(items: items)
        diffable = .init(id)
    }
}

//MARK: Diffable
public extension Sources where SubSource == [Item], SourceSnapshot == Snapshot<[Item], Item>, UIViewType == Never, Item: Diffable {
    
    init(items: [Item]) {
        self.init(_items: items)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, items: [Item]) {
        self.init(items: items)
        diffable = .init(id)
    }
}

//MARK: Identifiable + Hashable
public extension Sources where SubSource == [Item], SourceSnapshot == Snapshot<[Item], Item>, UIViewType == Never, Item: Identifiable, Item: Hashable {
    
    init(items: [Item]) {
        self.init(_items: items)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, items: [Item]) {
        self.init(items: items)
        diffable = .init(id)
    }
}

//MARK: - Item

public typealias ItemSources<Item> = Sources<Item, Item, Snapshot<Item, Item>, Never>

public extension Sources where SubSource == Item, SourceSnapshot == Snapshot<Item, Item>, UIViewType == Never {
    private init(_item: Item) {
        sourceClosure = nil
        sourceStored = _item
        
        itemFor = { (snapshot, _) in snapshot.item }
        createSnapshotWith = { .init($0) }
        updateContext = { $0.reloadCurrent() }
    }
    
    private init<ID: Hashable>(id: ID, _item: Item) {
        self.init(_item: _item)
        diffable = .init(id)
    }
    
    init(item: Item) {
        self.init(_item: item)
    }
    
    init<ID: Hashable>(id: ID, item: Item) {
        self.init(id: id, _item: item)
    }
}

//MARK: Equatable
public extension Sources where SubSource == Item, SourceSnapshot == Snapshot<Item, Item>, UIViewType == Never, Item: Equatable {
    init(item: Item) {
        self.init(_item: item)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, item: Item) {
        self.init(id: id, _item: item)
        diffable = .init(id)
    }
}

//MARK: Hashable
public extension Sources where SubSource == Item, SourceSnapshot == Snapshot<Item, Item>, UIViewType == Never, Item: Hashable {
    init(item: Item) {
        self.init(_item: item)
        updateContext = { $0.diffUpdate() }
        diffable = .init(item)
    }
}

//MARK: Identifiable
public extension Sources where SubSource == Item, SourceSnapshot == Snapshot<Item, Item>, UIViewType == Never, Item: Identifiable {
    init(item: Item) {
        self.init(_item: item)
        updateContext = { $0.diffUpdate() }
        diffable = .init { item }
    }
}

//MARK: Diffable
public extension Sources where SubSource == Item, SourceSnapshot == Snapshot<Item, Item>, UIViewType == Never, Item: Diffable {
    init(item: Item) {
        self.init(_item: item)
        updateContext = { $0.diffUpdate() }
        diffable = .init { item }
    }
}

//MARK: Identifiable + Hashable
public extension Sources where SubSource == Item, SourceSnapshot == Snapshot<Item, Item>, UIViewType == Never, Item: Identifiable, Item: Hashable {
    init(item: Item) {
        self.init(_item: item)
        updateContext = { $0.diffUpdate() }
        diffable = .init { item }
    }
}
