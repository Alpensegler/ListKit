//
//  Sources+Item.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources where Source == Item {
    init(_ id: AnyHashable?, item: Source, update: ListUpdate<SourceBase>.Whole, options: ListOptions) {
        self.sourceValue = .value(item)
        self.listDiffer = .init(id: id)
        self.listOptions = options
        self.listUpdate = update
        self.coordinatorMaker = { $0.coordinator(with: ItemCoordinator($0)) }
    }
}

public extension Sources where Source == Item {
    init(
        item: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, item: item, update: update, options: options)
    }
    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, item: wrappedValue, update: update, options: options)
    }

    init(item: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: item, update: .reload, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: wrappedValue, update: .reload, options: options)
    }
}

// MARK: - Equatable
public extension Sources where Source == Item, Item: Equatable {
    init(item: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: item, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Hashable
public extension Sources where Source == Item, Item: Hashable {
    init(item: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: item, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable {
    init(item: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: item, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable, Item: Equatable {
    init(item: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: item, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources where Source == Item, Item: Identifiable, Item: Hashable {
    init(item: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: item, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, item: wrappedValue, update: .diff, options: options)
    }
}
