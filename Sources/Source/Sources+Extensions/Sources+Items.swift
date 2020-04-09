//
//  Sources+Items.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source: Collection, Source.Element == Item {
    init(_ id: AnyHashable? = nil, items: Source, update: Update<Item>) {
        var source = items
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { ItemsCoordinator(updatable: $0) }
    }
}

extension Sources where Source: RangeReplaceableCollection, Source.Element == Item {
    init(_ id: AnyHashable? = nil, items: Source, update: Update<Item>) {
        var source = items
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { RangeReplacableItemsCoordinator(updatable: $0) }
    }
}

public extension Sources where Source: Collection, Source.Element == Item {
    init(id: AnyHashable? = nil, items: Source, update: Update<Item>) {
        self.init(id, items: items, update: update)
    }
    
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .reload)
    }
}

public extension Sources where Source: RangeReplaceableCollection, Source.Element == Item {
    init(id: AnyHashable? = nil, items: Source, update: Update<Item>) {
        self.init(id, items: items, update: update)
    }
    
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .reload)
    }
}

//Equatable
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

//Hashable
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Identifiable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Identifiable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable? = nil, items: Source) {
        self.init(id, items: items, update: .diff)
    }
}

