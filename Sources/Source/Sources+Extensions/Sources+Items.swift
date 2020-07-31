//
//  Sources+Items.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source: Collection, Source.Element == Item {
    init(_ id: AnyHashable?, items: Source, update: ListUpdate<SourceBase>.Whole, options: Options) {
        self.sourceValue = items
        self.listUpdate = update
        self.listOptions = .init(id: id, options)
        self.coordinatorMaker = { $0.coordinator(with: ItemsCoordinator($0)) }
    }
}

extension Sources where Source: RangeReplaceableCollection, Source.Element == Item {
    init(_ id: AnyHashable? = nil, items: Source, update: ListUpdate<SourceBase>.Whole, options: Options) {
        self.sourceValue = items
        self.listUpdate = update
        self.listOptions = .init(id: id, options)
        self.coordinatorMaker = { $0.coordinator(with: RangeReplacableItemsCoordinator($0)) }
    }
}

public extension Sources where Source: Collection, Source.Element == Item {
    init(
        id: AnyHashable? = nil,
        items: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: Options = .init()
    ) {
        self.init(id, items: items, update: update, options: options)
    }
    
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .reload, options: options)
    }
}

public extension Sources where Source: RangeReplaceableCollection, Source.Element == Item {
    init(id: AnyHashable? = nil, items: Source, update: ListUpdate<SourceBase>.Whole, options: Options = .init()) {
        self.init(id, items: items, update: update, options: options)
    }
    
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .reload, options: options)
    }
}

//Equatable
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
}

//Hashable
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Identifiable
{
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, items: Source, options: Options = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
}

