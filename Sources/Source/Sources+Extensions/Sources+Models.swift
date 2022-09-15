//
//  Sources+Models.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

// swiftlint:disable opening_brace

//extension Sources where Source: Collection, Source.Element == Model {
//    init(_ id: AnyHashable?, models: Source, update: ListUpdate<SourceBase>.Whole, options: ListOptions) {
//        self.sourceValue = .value(models)
//        self.listDiffer = .init(id: id)
//        self.listUpdate = update
//        self.listOptions = options
//        self.coordinatorMaker = { $0.coordinator(with: ModelsCoordinator($0)) }
//    }
//}
//
//extension Sources where Source: RangeReplaceableCollection, Source.Element == Model {
//    init(_ id: AnyHashable?, models: Source, update: ListUpdate<SourceBase>.Whole, options: ListOptions) {
//        self.sourceValue = .value(models)
//        self.listDiffer = .init(id: id)
//        self.listUpdate = update
//        self.listOptions = options
//        self.coordinatorMaker = { $0.coordinator(with: RangeReplacableModelsCoordinator($0)) }
//    }
//}
//
//public extension Sources where Source: Collection, Source.Element == Model {
//    init(
//        models: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, models: models, update: update, options: options)
//    }
//
//    init(
//        wrappedValue: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, models: wrappedValue, update: update, options: options)
//    }
//
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .reload, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .reload, options: options)
//    }
//}
//
//public extension Sources where Source: RangeReplaceableCollection, Source.Element == Model {
//    init(
//        models: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, models: models, update: update, options: options)
//    }
//
//    init(
//        wrappedValue: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, models: wrappedValue, update: update, options: options)
//    }
//
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .reload, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .reload, options: options)
//    }
//}
//
//// MARK: - Equatable
//public extension Sources
//where
//    Source: Collection,
//    Source.Element == Model,
//    Model: Equatable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//public extension Sources
//where
//    Source: RangeReplaceableCollection,
//    Source.Element == Model,
//    Model: Equatable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Hashable
//public extension Sources
//where
//    Source: Collection,
//    Source.Element == Model,
//    Model: Hashable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//public extension Sources
//where
//    Source: RangeReplaceableCollection,
//    Source.Element == Model,
//    Model: Hashable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: Collection,
//    Source.Element == Model,
//    Model: Identifiable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: RangeReplaceableCollection,
//    Source.Element == Model,
//    Model: Identifiable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable + Equatable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: Collection,
//    Source.Element == Model,
//    Model: Identifiable,
//    Model: Equatable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: RangeReplaceableCollection,
//    Source.Element == Model,
//    Model: Identifiable,
//    Model: Equatable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable + Hashable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: Collection,
//    Source.Element == Model,
//    Model: Identifiable,
//    Model: Hashable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}
//
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: RangeReplaceableCollection,
//    Source.Element == Model,
//    Model: Identifiable,
//    Model: Hashable
//{
//    init(models: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: models, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, models: wrappedValue, update: .diff, options: options)
//    }
//}