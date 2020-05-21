//
//  Sources+Item.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source == Item {
    init(_ id: AnyHashable? = nil, item: Source, update: ListUpdate<Item>) {
        var source = item
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { ItemCoordinator(updatable: $0) }
    }
}

public extension Sources where Source == Item {
    init(id: AnyHashable? = nil, item: Source, update: ListUpdate<Item>) {
        self.init(id, item: item, update: update)
    }
    
    init(id: AnyHashable? = nil, item: Source) {
        self.init(id, item: item, update: .reload)
    }
}

//Equatable
public extension Sources where Source == Item, Item: Equatable {
    init(id: AnyHashable? = nil, item: Source) {
        self.init(id, item: item, update: .diff)
    }
}

//Hashable
public extension Sources where Source == Item, Item: Hashable {
    init(id: AnyHashable? = nil, item: Source) {
        self.init(id, item: item, update: .diff)
    }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable {
    init(id: AnyHashable? = nil, item: Source) {
        self.init(id, item: item, update: .diff)
    }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable, Item: Equatable {
    init(id: AnyHashable? = nil, item: Source) {
        self.init(id, item: item, update: .diff)
    }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable, Item: Hashable {
    init(id: AnyHashable? = nil, item: Source) {
        self.init(id, item: item, update: .diff)
    }
}
