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
    init(
        _ id: AnyHashable?,
        dataSources: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase>
    ) {
        self.sourceValue = .value(dataSources)
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
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
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: dataSources, update: update, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: update, options: options)
    }
    
    init(dataSources: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSources: dataSources, update: .subupdate, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSources: wrappedValue, update: .subupdate, options: options)
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
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
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
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
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
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
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
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
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
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
    }
}
