//
//  Sources+Items.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source: Collection, Source.Element == Item {
    init(_ id: AnyHashable?, items: Source, update: ListUpdate<SourceBase>.Whole, options: ListOptions<SourceBase>) {
        self.sourceValue = items
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: ItemsCoordinator($0)) }
    }
}

extension Sources where Source: RangeReplaceableCollection, Source.Element == Item {
    init(_ id: AnyHashable? = nil, items: Source, update: ListUpdate<SourceBase>.Whole, options: ListOptions<SourceBase>) {
        self.sourceValue = items
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: RangeReplacableItemsCoordinator($0)) }
    }
}

public extension Sources where Source: Collection, Source.Element == Item {
    init(
        items: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .init()
    ) {
        self.init(id, items: items, update: update, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .init()
    ) {
        self.init(id, items: wrappedValue, update: update, options: options)
    }
    
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .reload, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .reload, options: options)
    }
}

public extension Sources where Source: RangeReplaceableCollection, Source.Element == Item {
    init(
        items: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .init()
    ) {
        self.init(id, items: items, update: update, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .init()
    ) {
        self.init(id, items: wrappedValue, update: update, options: options)
    }
    
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .reload, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .reload, options: options)
    }
}

//Equatable
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Equatable
{
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Equatable
{
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
    }
}

//Hashable
public extension Sources
where
    Source: Collection,
    Source.Element == Item,
    Item: Hashable
{
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Hashable
{
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
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
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element == Item,
    Item: Identifiable
{
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
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
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
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
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
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
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
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
    init(items: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: items, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .init()) {
        self.init(id, items: wrappedValue, update: .diff, options: options)
    }
}

