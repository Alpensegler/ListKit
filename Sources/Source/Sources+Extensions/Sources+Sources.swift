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
    init(_ id: AnyHashable?, dataSources: Source, update: ListUpdate<SourceBase>, options: Options) {
        self.sourceValue = dataSources
        self.listUpdate = update
        self.listOptions = .init(id: id, options)
        self.coordinatorMaker = { $0.coordinator(with: SourcesCoordinator(sources: $0)) }
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item
{
    init(
        id: AnyHashable? = nil,
        dataSources: Source,
        update: ListUpdate<SourceBase>,
        options: Options = .init()
    ) {
        self.init(id, dataSources: dataSources, update: update, options: options)
    }
    
    init(id: AnyHashable? = nil, dataSources: Source, options: Options = .init()) {
        self.init(id, dataSources: dataSources, update: .reload, options: options)
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
    init(
        id: AnyHashable? = nil,
        dataSources: Source,
        update: ListUpdate<SourceBase>,
        options: Options = .init()
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
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
    init(
        id: AnyHashable? = nil,
        dataSources: Source,
        update: ListUpdate<SourceBase>,
        options: Options = .init()
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
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
    init(
        id: AnyHashable? = nil,
        dataSources: Source,
        update: ListUpdate<SourceBase>,
        options: Options = .init()
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
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
    init(
        id: AnyHashable? = nil,
        dataSources: Source,
        update: ListUpdate<SourceBase>,
        options: Options = .init()
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
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
    init(
        id: AnyHashable? = nil,
        dataSources: Source,
        update: ListUpdate<SourceBase>,
        options: Options = .init()
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }
}
