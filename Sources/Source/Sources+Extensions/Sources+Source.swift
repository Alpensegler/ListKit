//
//  Sources+Source.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source: DataSource, Source.Item == Item {
    init(_ id: AnyHashable?, dataSource: Source, update: ListUpdate<SourceBase>.Whole, options: Options) {
        self.sourceValue = dataSource
        self.listUpdate = update
        self.listOptions = .init(id: id, options)
        self.coordinatorMaker = { $0.coordinator(with: WrapperCoordinator(wrapper: $0)) }
    }
}

public extension Sources where Source: DataSource, Source.Item == Item {
    init(
        id: AnyHashable? = nil,
        dataSource: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: Options = .init()
    ) {
        self.init(id, dataSource: dataSource, update: update, options: options)
    }
    
    init(id: AnyHashable? = nil, dataSource: Source, options: Options = .init()) {
        self.init(id, dataSource: dataSource, update: .reload, options: options)
    }
}

//Equatable
public extension Sources where Source: DataSource, Source.Item == Item, Item: Equatable {
    init(id: AnyHashable? = nil, dataSource: Source, options: Options = .init()) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
}

//Hashable
public extension Sources where Source: DataSource, Source.Item == Item, Item: Hashable {
    init(id: AnyHashable? = nil, dataSource: Source, options: Options = .init()) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, dataSource: Source, options: Options = .init()) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, dataSource: Source, options: Options = .init()) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
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
    init(id: AnyHashable? = nil, dataSource: Source, options: Options = .init()) {
        self.init(id, dataSource: dataSource, update: .diff, options: options)
    }
}

