//
//  Sources+Source.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source: DataSource, Source.Item == Item {
    init(
        _ id: AnyHashable?,
        dataSource: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase>
    ) {
        self.sourceValue = .value(dataSource)
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: WrapperCoordinator(wrapper: $0)) }
    }
    
    init(
        _ id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase>,
        getter: @escaping () -> Source
    ) {
        self.sourceValue = .getter(getter)
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: WrapperCoordinator(wrapper: $0)) }
    }
}

public extension Sources where Source: DataSource, Source.Item == Item {
    init(
        dataSource: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSource: dataSource, update: update, options: options)
    }
    
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions<SourceBase> = .none
    ) {
        self.init(id, dataSource: wrappedValue, update: update, options: options)
    }
    
    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: dataSource, update: .reload, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: wrappedValue, update: .reload, options: options)
    }
}

//Equatable
public extension Sources where Source: DataSource, Source.Item == Item, Item: Equatable {
    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
    }
}

//Hashable
public extension Sources where Source: DataSource, Source.Item == Item, Item: Hashable {
    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
    }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: DataSource,
    Source.Item == Item,
    Item: Identifiable
{
    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
    }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: DataSource,
    Source.Item == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
    }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: DataSource,
    Source.Item == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions<SourceBase> = .none) {
        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
    }
}

