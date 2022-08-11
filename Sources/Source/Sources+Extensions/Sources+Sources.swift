//
//  Sources+Sources.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

// swiftlint:disable opening_brace

extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model
{
    init(
        _ id: AnyHashable?,
        dataSources: Source,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions
    ) {
        self.sourceValue = .value(dataSources)
        self.listDiffer = .init(id: id)
        self.listUpdate = update
        self.listOptions = options
        self.coordinatorMaker = { $0.coordinator(with: DataSourcesCoordinator(sources: $0)) }
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model
{
    init(
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: dataSources, update: update, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: update, options: options)
    }

    init(dataSources: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, dataSources: dataSources, update: .subupdate, options: options)
    }

    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
        self.init(id, dataSources: wrappedValue, update: .subupdate, options: options)
    }
}

// MARK: - Equatable
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model,
    Model: Equatable
{
    init(
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Hashable
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model,
    Model: Hashable
{
    init(
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model,
    Model: Identifiable
{
    init(
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable + Equatable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model,
    Model: Identifiable,
    Model: Equatable
{
    init(
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
    }
}

// MARK: - Identifiable + Hashable
@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Model == Model,
    Model: Identifiable,
    Model: Hashable
{
    init(
        dataSources: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: dataSources, update: .diff, options: options)
    }

    init(
        wrappedValue: Source,
        id: AnyHashable? = nil,
        update: ListUpdate<SourceBase>.Whole,
        options: ListOptions = .none
    ) {
        self.init(id, dataSources: wrappedValue, update: .diff, options: options)
    }
}
