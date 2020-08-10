//
//  Sources+Item.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source == Item {
    init(_ id: AnyHashable?, item: Source, update: ListUpdate<SourceBase>.Whole, options: Options) {
        self.sourceValue = item
        self.listOptions = .init(id: id, options)
        self.listUpdate = update
        self.coordinatorMaker = { $0.coordinator(with: ItemCoordinator($0)) }
    }
}

public extension Sources where Source == Item {
    init(
        item: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: Options = .init()
    ) {
        self.init(id, item: item, update: update, options: options)
    }
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: Options = .init()
    ) {
        self.init(id, item: wrappedValue, update: update, options: options)
    }
    
    init(item: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: item, update: .reload, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: wrappedValue, update: .reload, options: options)
    }
}

//Equatable
public extension Sources where Source == Item, Item: Equatable {
    init(item: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: item, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

//Hashable
public extension Sources where Source == Item, Item: Hashable {
    init(item: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: item, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable {
    init(item: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: item, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable, Item: Equatable {
    init(item: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: item, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable, Item: Hashable {
    init(item: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: item, update: .diff, options: options)
    }
    
    init(wrappedValue: Source, id: AnyHashable? = nil, options: Options = .init()) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}
