//
//  Sources+Sections.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

// swiftlint:disable opening_brace

extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item
{
    init(
        _ id: AnyHashable?,
        sections: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions
    ) {
        self.sourceValue = .value(sections)
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: SectionsCoordinator($0)) }
    }
}

extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item
{
    init(
        _ id: AnyHashable?,
        sections: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions
    ) {
        self.sourceValue = .value(sections)
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: RangeReplacableSectionsCoordinator($0)) }
    }
}

public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item
{
    init(
        sections: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, sections: sections, update: update, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, sections: wrappedValue, update: update, options: options)
    }

    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .reload, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .reload, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item
{
    init(
        sections: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, sections: sections, update: update, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, sections: wrappedValue, update: update, options: options)
    }

    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .reload, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .reload, options: options)
    }
}

// MARK: - Equatable
public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Equatable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Equatable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Hashable
public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Hashable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item,
    Item: Hashable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Identifiable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
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
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Identifiable,
    Item: Equatable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
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
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item,
    Item: Identifiable,
    Item: Hashable
{
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
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
    init(sections: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: sections, update: .diff, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, sections: wrappedValue, update: .diff, options: options)
    }
}
