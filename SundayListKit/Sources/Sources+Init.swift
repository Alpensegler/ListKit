//
//  Sources+Init.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/7.
//  Copyright © 2019 Frain. All rights reserved.
//

//MARK: - List

public typealias ListSources<Item> = Sources<[AnySources<Item>], Item, Snapshot<[AnySources<Item>], Item>, Never>

public extension Sources
where
    SubSource.Element: SourcesTypeAraser,
    SubSource.Element: Diffable,
    SubSource.Element.Item == Item,
    SourceSnapshot: ListSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Element == SubSource.Element,
    UIViewType == Never
{
    init<ID: Hashable>(id: ID, _ sources: SubSource) {
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        
        sourceClosure = nil
        sourceStored = sources
        
        diffable = AnyDiffable(id)
    }
    
    init(_ sources: SubSource) {
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        
        sourceClosure = nil
        sourceStored = sources
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element: SourcesTypeAraser,
    SubSource.Element: Diffable,
    SubSource.Element.Item == Item,
    SourceSnapshot: ListSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Element == SubSource.Element,
    UIViewType == Never
{
    
    private init(_ sources: [SubSource.Element]) {
        var _sources = SubSource()
        _sources.append(contentsOf: sources)
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        
        sourceClosure = nil
        sourceStored = _sources
    }
    
    init<S: Source>(source: S?) where S.Item == Item {
        self.init(source.map { [.init($0)] } ?? [])
    }
    
    init<S0: Source, S1: Source>(_ s0: S0?, _ s1: S1?) where S0.Item == Item, S1.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?) where S0.Item == Item, S1.Item == Item, S2.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S6.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source>(_ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S7.Item == Item, S6.Item == Item {
        self.init([
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
            s7.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
}

//MARK: - Section

public typealias SectionSources<Item> = Sources<[Item], Item, Snapshot<[Item], Item>, Never>

public extension Sources
where
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never
{
    private init(_items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        itemFor = { $0.item(at: $1) }
        createSnapshotWith = { .init($0) }
        updateContext = customUpdate
        
        sourceClosure = nil
        sourceStored = _items
    }
    
    private init<ID: Hashable>(id: ID, _items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(_items: _items, customUpdate: customUpdate)
        diffable = .init(id)
    }
    
    init(items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(_items: items, customUpdate: customUpdate)
    }
    
    init<ID: Hashable>(id: ID, items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never
{
    init(customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Equatable
public extension Sources
where
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Equatable
{
    
    init(items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_items: items, customUpdate: customUpdate)
    }
    
    init<ID: Hashable>(id: ID, items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Equatable
{
    init(customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Hashable
public extension Sources
where
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Hashable
{
    
    init(items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_items: items, customUpdate: customUpdate)
    }
    
    init<ID: Hashable>(id: ID, items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Hashable
{
    init(customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Identifiable
public extension Sources
where
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Identifiable
{
    
    init(items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_items: items, customUpdate: customUpdate)
    }
    
    init<ID: Hashable>(id: ID, items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Identifiable
{
    init(customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Diffable
public extension Sources
where
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Diffable
{
    
    init(items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_items: items, customUpdate: customUpdate)
    }
    
    init<ID: Hashable>(id: ID, items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Diffable
{
    init(customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Identifiable + Hashable
public extension Sources
where
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    
    init(items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_items: items, customUpdate: customUpdate)
        updateContext = { $0.diffUpdate() }
    }
    
    init<ID: Hashable>(id: ID, items: SubSource, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    SourceSnapshot: SectionSnapshot,
    SourceSnapshot.SubSource == SubSource,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    init(customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(items: .init(), customUpdate: customUpdate)
    }
}

//MARK: - Item

public typealias ItemSources<Item> = Sources<Item, Item, Snapshot<Item, Item>, Never>

public extension Sources
where
    SubSource == Item,
    SourceSnapshot: ItemSnapshot,
    SourceSnapshot.Item == Item,
    UIViewType == Never
{
    private init(_item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        itemFor = { (snapshot, _) in snapshot.item }
        createSnapshotWith = { .init($0) }
        updateContext = customUpdate
        
        sourceClosure = nil
        sourceStored = _item
    }
    
    private init<ID: Hashable>(id: ID, _item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(_item: _item, customUpdate: customUpdate)
        diffable = .init(id)
    }
    
    init(item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(_item: item, customUpdate: customUpdate)
    }
    
    init<ID: Hashable>(id: ID, item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
    }
}

//MARK: Equatable
public extension Sources
where
    SubSource == Item,
    SourceSnapshot: ItemSnapshot,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Equatable
{
    init(item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_item: item, customUpdate: customUpdate)
    }
}

//MARK: Hashable

public extension Sources
where
    SubSource == Item,
    SourceSnapshot: ItemSnapshot,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Hashable
{
    init(item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_item: item, customUpdate: customUpdate)
        diffable = .init(item)
    }
}

//MARK: Identifiable
public extension Sources
where
    SubSource == Item,
    SourceSnapshot: ItemSnapshot,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Identifiable
{
    init(item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_item: item, customUpdate: customUpdate)
        diffable = .init { item }
    }
}

//MARK: Diffable
public extension Sources
where
    SubSource == Item,
    SourceSnapshot: ItemSnapshot,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Diffable
{
    init(item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_item: item, customUpdate: customUpdate)
        diffable = .init { item }
    }
}

//MARK: Identifiable + Hashable
public extension Sources
where
    SubSource == Item,
    SourceSnapshot: ItemSnapshot,
    SourceSnapshot.Item == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    init(item: Item, customUpdate: @escaping (UpdateContext<SourceSnapshot>) -> Void = { $0.diffUpdate() }) {
        self.init(_item: item, customUpdate: customUpdate)
        diffable = .init { item }
    }
}
