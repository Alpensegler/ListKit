//
//  Sources+Model.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

//extension Sources where Source == Model {
//    init(_ id: AnyHashable?, model: Source, update: ListUpdate<SourceBase>.Whole, options: ListOptions) {
//        self.sourceValue = .value(model)
//        self.listDiffer = .init(id: id)
//        self.listOptions = options
//        self.listUpdate = update
//        self.coordinatorMaker = { $0.coordinator(with: ModelCoordinator($0)) }
//    }
//}
//
//public extension Sources where Source == Model {
//    init(
//        model: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, model: model, update: update, options: options)
//    }
//    init(
//        wrappedValue: Source,
//        id: AnyHashable? = nil,
//        update: ListUpdate<SourceBase>.Whole,
//        options: ListOptions = .none
//    ) {
//        self.init(id, model: wrappedValue, update: update, options: options)
//    }
//
//    init(model: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: model, update: .reload, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: wrappedValue, update: .reload, options: options)
//    }
//}
//
//// MARK: - Equatable
//public extension Sources where Source == Model, Model: Equatable {
//    init(model: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: model, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Hashable
//public extension Sources where Source == Model, Model: Hashable {
//    init(model: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: model, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources where Source == Model, Model: Identifiable {
//    init(model: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: model, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable + Equatable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources where Source == Model, Model: Identifiable, Model: Equatable {
//    init(model: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: model, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: wrappedValue, update: .diff, options: options)
//    }
//}
//
//// MARK: - Identifiable + Hashable
//@available(OSX 10.15, iOS 13, tvOS 13, watchOS 6, *)
//public extension Sources where Source == Model, Model: Identifiable, Model: Hashable {
//    init(model: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: model, update: .diff, options: options)
//    }
//
//    init(wrappedValue: Source, id: AnyHashable? = nil, options: ListOptions = .none) {
//        self.init(id, model: wrappedValue, update: .diff, options: options)
//    }
//}
