//
//  Updater.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

public struct Updater<Source: DataSource> {
    let source: Differ<Source>
    let item: Differ<Source.Item>
    let isNone: Bool
    
    init(source: Differ<Source>, item: Differ<Source.Item>) {
        self.source = source
        self.item = item
        self.isNone = source.isNone && item.isNone
    }
    
    init(
        sourceIdentifier: ((Source) -> AnyHashable)? = nil,
        sourceAreEquivalent: ((Source, Source) -> Bool)? = nil,
        itemIdentifier: ((Source.Item) -> AnyHashable)? = nil,
        itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) {
        self.init(
            source: Differ(identifier: sourceIdentifier, areEquivalent: sourceAreEquivalent),
            item: Differ(identifier: itemIdentifier, areEquivalent: itemAreEquivalent)
        )
    }
}

public extension Updater {
    static var none: Self { .init() }
    
    static func diffSelf(
        id: @escaping (Source) -> AnyHashable,
        by areEquivalent: ((Source, Source) -> Bool)? = nil
    ) -> Self {
        .init(sourceIdentifier: id, sourceAreEquivalent: areEquivalent)
    }
    
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = nil,
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
    
    static func diff(
        selfID: @escaping (Source) -> AnyHashable,
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = nil,
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

// MARK: - Item

//Item Equatable
public extension Updater where Source.Item: Equatable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = nil,
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Hashable
public extension Updater where Source.Item: Hashable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0 },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Identifiable
public extension Updater where Source.Item: Identifiable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0.id },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase.Item: Identifiable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Identifiable + Equatable
public extension Updater where Source.Item: Identifiable, Source.Item: Equatable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0.id },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Identifiable + Hashable
public extension Updater where Source.Item: Identifiable, Source.Item: Hashable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0.id },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase.Item: Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Swift.Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source.Item: Swift.Identifiable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0.id },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Swift.Identifiable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Swift.Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source.Item: Swift.Identifiable, Source.Item: Equatable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0.id },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Swift.Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diffItem() }
}

//Item Swift.Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source.Item: Swift.Identifiable, Source.Item: Hashable {
    static func diffItem(
        id: ((Source.Item) -> AnyHashable)? = { $0.id },
        by areEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(itemIdentifier: id, itemAreEquivalent: areEquivalent)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase.Item: Swift.Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diffItem() }
}


// MARK: - Source

// Source Identifiable
public extension Updater where Source: Identifiable {
    static func diffSelf(
        id: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil
    ) -> Self {
        .init(sourceIdentifier: id, sourceAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase: Identifiable {
    var updater: Updater<SourceBase> { .diffSelf() }
}

// Source Identifiable + Equatable
public extension Updater where Source: Identifiable, Source: Equatable {
    static func diffSelf(
        id: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(sourceIdentifier: id, sourceAreEquivalent: areEquivalent)
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable {
    var updater: Updater<SourceBase> { .diffSelf() }
}

// Source Swift.Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable {
    static func diffSelf(
        id: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil
    ) -> Self {
        .init(sourceIdentifier: id, sourceAreEquivalent: areEquivalent)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable {
    var updater: Updater<SourceBase> { .diffSelf() }
}

// Source Swift.Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source: Equatable {
    static func diffSelf(
        id: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(sourceIdentifier: id, sourceAreEquivalent: areEquivalent)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase: Equatable {
    var updater: Updater<SourceBase> { .diffSelf() }
}

// MARK: - Source Identifiable + Item

// Source Identifiable + Item Equatable
public extension Updater where Source: Identifiable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = nil,
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Item Hashable
public extension Updater where Source: Identifiable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0 },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Item Identifiable
public extension Updater where Source: Identifiable, Source.Item: Identifiable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase.Item: Identifiable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Item Identifiable + Equatable
public extension Updater where Source: Identifiable, Source.Item: Identifiable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase.Item: Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Item Identifiable + Hashable
public extension Updater where Source: Identifiable, Source.Item: Identifiable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase.Item: Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Item Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = nil,
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Item Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0 },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Item Swift.Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source.Item: Swift.Identifiable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase.Item: Swift.Identifiable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Item Swift.Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source.Item: Swift.Identifiable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase.Item: Swift.Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Item Swift.Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source.Item: Swift.Identifiable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = nil,
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase.Item: Swift.Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

//MARK: - Source Identifiable + Equatable + Item

// Source Identifiable + Equatable + Item Equatable
public extension Updater where Source: Identifiable, Source: Equatable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = nil,
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Equatable + Item Hashable
public extension Updater where Source: Identifiable, Source: Equatable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0 },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Equatable + Item Identifiable
public extension Updater where Source: Identifiable, Source: Equatable, Source.Item: Identifiable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable, SourceBase.Item: Identifiable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Equatable + Item Identifiable + Equatable
public extension Updater where Source: Identifiable, Source: Equatable, Source.Item: Identifiable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable, SourceBase.Item: Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Identifiable + Equatable + Item Identifiable + Hashable
public extension Updater where Source: Identifiable, Source: Equatable, Source.Item: Identifiable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

public extension DataSource where SourceBase: Identifiable, SourceBase: Equatable, SourceBase.Item: Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Equatable + Item Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source: Equatable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = nil,
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase: Equatable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Equatable + Item Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source: Equatable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0 },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase: Equatable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Equatable + Item Swift.Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source: Equatable, Source.Item: Swift.Identifiable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = nil
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase: Equatable, SourceBase.Item: Swift.Identifiable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Equatable + Item Swift.Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source: Equatable, Source.Item: Swift.Identifiable, Source.Item: Equatable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase: Equatable, SourceBase.Item: Swift.Identifiable, SourceBase.Item: Equatable {
    var updater: Updater<SourceBase> { .diff() }
}

// Source Swift.Identifiable + Equatable + Item Swift.Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Updater where Source: Swift.Identifiable, Source: Equatable, Source.Item: Swift.Identifiable, Source.Item: Hashable {
    static func diff(
        selfID: @escaping (Source) -> AnyHashable = { $0.id },
        by areEquivalent: ((Source, Source) -> Bool)? = { $0 == $1 },
        itemID: ((Source.Item) -> AnyHashable)? = { $0.id },
        itemBy itemAreEquivalent: ((Source.Item, Source.Item) -> Bool)? = { $0 == $1 }
    ) -> Self {
        .init(
            sourceIdentifier: selfID,
            sourceAreEquivalent: areEquivalent,
            itemIdentifier: itemID,
            itemAreEquivalent: itemAreEquivalent
        )
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataSource where SourceBase: Swift.Identifiable, SourceBase: Equatable, SourceBase.Item: Swift.Identifiable, SourceBase.Item: Hashable {
    var updater: Updater<SourceBase> { .diff() }
}

