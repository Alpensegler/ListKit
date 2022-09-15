//
//  Sources+Source.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

// swiftlint:disable opening_brace

//extension Sources where Source: DataSource, Source.Model == Model {
//    init(
//        _ id: AnyHashable?,
//        dataSource: Source,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions
//    ) {
//        self.sourceValue = .value(dataSource)
//        self.listDiffer = .init(id: id)
//        self.listUpdate = update
//        self.listOptions = options
//        self.coordinatorMaker = { $0.coordinator(with: WrapperCoordinator(wrapper: $0)) }
//    }
//
//    init(
//        _ id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions,
//        getter: @escaping () -> Source
//    ) {
//        self.sourceValue = .getter(getter)
//        self.listDiffer = .init(id: id)
//        self.listUpdate = update
//        self.listOptions = options
//        self.coordinatorMaker = { $0.coordinator(with: WrapperCoordinator(wrapper: $0)) }
//    }
//}
//
//public extension Sources where Source: DataSource, Source.Model == Model {
//    init(
//        dataSource: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, dataSource: dataSource, update: update, options: options)
//    }
//
//    init(
//        wrappedValue: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, dataSource: wrappedValue, update: update, options: options)
//    }
//
//    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: dataSource, update: .reload, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: wrappedValue, update: .reload, options: options)
//    }
//}
//
//// MARK: - Equatable
//public extension Sources where Source: DataSource, Source.Model == Model, Model: Equatable {
//    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: dataSource, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Hashable
//public extension Sources where Source: DataSource, Source.Model == Model, Model: Hashable {
//    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: dataSource, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: DataSource,
//    Source.Model == Model,
//    Model: Identifiable
//{
//    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: dataSource, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable + Equatable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: DataSource,
//    Source.Model == Model,
//    Model: Identifiable,
//    Model: Equatable
//{
//    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: dataSource, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable + Hashable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources
//where
//    Source: DataSource,
//    Source.Model == Model,
//    Model: Identifiable,
//    Model: Hashable
//{
//    init(dataSource: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: dataSource, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, dataSource: wrappedValue, update: .diff, options: options)
//    }
//}
