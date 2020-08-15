//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/4/8.
//

public protocol DataSource {
    associatedtype Item
    associatedtype Source = [Item]
    associatedtype SourceBase: DataSource = Self
        where SourceBase.Item == Item, SourceBase.SourceBase == SourceBase
    
    var source: Source { get }
    var sourceBase: SourceBase { get }
    
    var listUpdate: ListUpdate<SourceBase>.Whole { get }
    var listDiffer: ListDiffer<SourceBase> { get }
    var listOptions: ListOptions<SourceBase> { get }
    
    var listCoordinator: ListCoordinator<SourceBase> { get }
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] { get }
}

public extension DataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        fatalError("unsupported source \(Source.self) item \(Item.self)")
    }
    
    var listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] { [] }
}

public extension DataSource where SourceBase == Self {
    var sourceBase: SourceBase { self }
}
