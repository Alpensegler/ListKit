//
//  Sources+Sections.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item
{
    init(_ id: AnyHashable? = nil, sections: Source, update: Update<Item>) {
        var source = sections
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { SectionsCoordinator(updatable: $0) }
    }
}

extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item
{
    init(_ id: AnyHashable? = nil, sections: Source, update: Update<Item>) {
        var source = sections
        self.sourceGetter = { source }
        self.sourceSetter = { source = $0 }
        self.differ = id.map { id in .diff(id: { _ in id }) } ?? .none
        self.listUpdate = update
        self.coordinatorMaker = { RangeReplacableSectionsCoordinator(updatable: $0) }
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item
{
    init(id: AnyHashable? = nil, sections: Source, update: Update<Item>) {
        self.init(id, sections: sections, update: update)
    }
    
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .reload)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item
{
    init(id: AnyHashable? = nil, sections: Source, update: Update<Item>) {
        self.init(id, sections: sections, update: update)
    }
    
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .reload)
    }
}

//Equatable
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Equatable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

//Hashable
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Hashable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

//Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Identifiable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Identifiable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

//Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

//Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}

@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(id: AnyHashable? = nil, sections: Source) {
        self.init(id: id, sections: sections, update: .diff)
    }
}
