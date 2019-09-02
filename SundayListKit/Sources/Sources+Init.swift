//
//  Sources+Init.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/7.
//  Copyright © 2019 Frain. All rights reserved.
//

//MARK: - List

public typealias ListSources<Item> = Sources<[AnySources<Item>], Item, Never>

public extension Sources
where
    SubSource: Collection,
    SubSource.Element: SourcesTypeAraser,
    SubSource.Element: Diffable,
    SubSource.Element.Item == Item,
    UIViewType == Never
{
    init(id: AnyHashable = UUID(), _ sources: SubSource) {
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        
        sourceClosure = nil
        sourceStored = sources
        
        diffable = AnyDiffable(id)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element: SourcesTypeAraser,
    SubSource.Element: Diffable,
    SubSource.Element.Item == Item,
    UIViewType == Never
{
    
    private init(id: AnyHashable, _ sources: [SubSource.Element]) {
        var _sources = SubSource()
        _sources.append(contentsOf: sources)
        createSnapshotWith = { .init($0) }
        itemFor = { $0.item(at: $1) }
        updateContext = { $0.diffUpdate() }
        diffable = .init(id)
        
        sourceClosure = nil
        sourceStored = _sources
    }
    
    init<S0: Source, S1: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?) where S0.Item == Item, S1.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?) where S0.Item == Item, S1.Item == Item, S2.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S6.Item == Item {
        self.init(id: id, [
            s0.map(SubSource.Element.init),
            s1.map(SubSource.Element.init),
            s2.map(SubSource.Element.init),
            s3.map(SubSource.Element.init),
            s4.map(SubSource.Element.init),
            s5.map(SubSource.Element.init),
            s6.map(SubSource.Element.init),
        ].compactMap { $0 })
    }
    
    init<S0: Source, S1: Source, S2: Source, S3: Source, S4: Source, S5: Source, S6: Source, S7: Source>(id: AnyHashable = UUID(), _ s0: S0?, _ s1: S1?, _ s2: S2?, _ s3: S3?, _ s4: S4?, _ s5: S5?, _ s6: S6?, _ s7: S7?) where S0.Item == Item, S1.Item == Item, S2.Item == Item, S3.Item == Item, S4.Item == Item, S5.Item == Item, S7.Item == Item, S6.Item == Item {
        self.init(id: id, [
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

public typealias SectionSources<Item> = Sources<[Item], Item, Never>

public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never
{
    private init(id: AnyHashable, _items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        itemFor = { $0.item(at: $1) }
        createSnapshotWith = { .init($0) }
        updateContext = customUpdate
        
        sourceClosure = nil
        sourceStored = _items
        diffable = .init(id)
    }
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Equatable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Equatable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Equatable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Hashable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Hashable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Hashable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Identifiable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Diffable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Diffable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Diffable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: .init(), customUpdate: customUpdate)
    }
}

//MARK: Identifiable + Hashable
public extension Sources
where
    SubSource: Collection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    
    init(id: AnyHashable = UUID(), items: SubSource, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _items: items, customUpdate: customUpdate)
    }
}

public extension Sources
where
    SubSource: RangeReplaceableCollection,
    SubSource.Element == Item,
    UIViewType == Never,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable = UUID(), customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, items: .init(), customUpdate: customUpdate)
    }
}

//MARK: - Item

public typealias ItemSources<Item> = Sources<Item, Item, Never>

public extension Sources where SubSource == Item, UIViewType == Never {
    private init(id: AnyHashable, _item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        itemFor = { (snapshot, _) in snapshot.item }
        createSnapshotWith = { .init($0) }
        updateContext = customUpdate
        
        sourceClosure = nil
        sourceStored = _item
        diffable = .init(id)
    }
    
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.reloadCurrent() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
    }
}

//MARK: Equatable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Equatable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
    }
}

//MARK: Hashable

public extension Sources where SubSource == Item, UIViewType == Never, Item: Hashable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}

//MARK: Identifiable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Identifiable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}

//MARK: Diffable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Diffable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}

//MARK: Identifiable + Hashable
public extension Sources where SubSource == Item, UIViewType == Never, Item: Identifiable, Item: Hashable {
    init(id: AnyHashable = UUID(), item: Item, customUpdate: @escaping (UpdateContext<SubSource, Item>) -> Void = { $0.diffUpdate() }) {
        self.init(id: id, _item: item, customUpdate: customUpdate)
        if id is UUID { diffable = .init(item) }
    }
}
