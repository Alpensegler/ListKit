//
//  Sources+Source.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source: DataSource, Source.Item == Item {
    init(_ id: AnyHashable? = nil, dataSource: Source, update: ListUpdate<Item>) {
        var source = dataSource
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { WrapperCoordinator(updatableWrapper: $0) }
    }
}

public extension Sources where Source: DataSource, Source.Item == Item {
    init(id: AnyHashable? = nil, dataSource: Source, update: ListUpdate<Item>) {
        self.init(id, dataSource: dataSource, update: update)
    }
    
    init(id: AnyHashable? = nil, dataSource: Source) {
        self.init(id, dataSource: dataSource, update: .reload)
    }
}

//Equatable
public extension Sources where Source: DataSource, Source.Item == Item, Item: Equatable {
    init(id: AnyHashable? = nil, dataSource: Source) {
        self.init(id, dataSource: dataSource, update: .diff)
    }
}

//Hashable
public extension Sources where Source: DataSource, Source.Item == Item, Item: Hashable {
    init(id: AnyHashable? = nil, dataSource: Source) {
        self.init(id, dataSource: dataSource, update: .diff)
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
    init(id: AnyHashable? = nil, dataSource: Source) {
        self.init(id, dataSource: dataSource, update: .diff)
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
    init(id: AnyHashable? = nil, dataSource: Source) {
        self.init(id, dataSource: dataSource, update: .diff)
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
    init(id: AnyHashable? = nil, dataSource: Source) {
        self.init(id, dataSource: dataSource, update: .diff)
    }
}

