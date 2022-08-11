//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/4/8.
//

public protocol DataSource {
    associatedtype Model
    associatedtype Source = [Model]
    associatedtype SourceBase: DataSource = Self
        where SourceBase.Model == Model, SourceBase.SourceBase == SourceBase
    associatedtype AdapterBase: DataSource = Self
        where AdapterBase.Model == Model, AdapterBase.AdapterBase == AdapterBase

    var source: Source { get }
    var sourceBase: SourceBase { get }
    var adapterBase: AdapterBase { get }

    var listOptions: ListOptions { get }
    var listUpdate: ListUpdate<SourceBase>.Whole { get }
    var listDiffer: ListDiffer<SourceBase> { get }

    var listDelegate: ListDelegate { get }
    var listCoordinator: ListCoordinator<SourceBase> { get }
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> { get }
}

public extension DataSource {
    var listDelegate: ListDelegate { .init() }
    var listCoordinator: ListCoordinator<SourceBase> {
        fatalError("unsupported source \(Source.self) model \(Model.self)")
    }
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: listDelegate)
    }
}

public extension DataSource where SourceBase == Self {
    var sourceBase: SourceBase { self }
}

public extension DataSource where AdapterBase == Self {
    var adapterBase: AdapterBase { self }
}
