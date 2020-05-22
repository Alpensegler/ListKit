//
//  Sources+Sources.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item
{
    init(_ id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        var source = dataSources
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { SourcesCoordinator(updatableSources: $0) }
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item
{
    init(id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        self.init(id, dataSources: dataSources, update: update)
    }
    
    init(id: AnyHashable? = nil, dataSources: Source) {
        self.init(id, dataSources: dataSources, update: .reload)
    }
}

//Equatable
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        self.init(id, dataSources: dataSources, update: .diff)
    }
}

//Hashable
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        self.init(id, dataSources: dataSources, update: .diff)
    }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item,
    Item: Identifiable
{
    init(id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        self.init(id, dataSources: dataSources, update: .diff)
    }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        self.init(id, dataSources: dataSources, update: .diff)
    }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable? = nil, dataSources: Source, update: ListUpdate<Item>) {
        self.init(id, dataSources: dataSources, update: .diff)
    }
}
