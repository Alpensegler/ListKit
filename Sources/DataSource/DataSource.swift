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
    var listUpdate: Update<Item> { get }
    var differ: Differ<SourceBase> { get }
    
    func makeListCoordinator() -> ListCoordinator<SourceBase>
}

public extension DataSource {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        fatalError("unsupported source \(Source.self) item \(Item.self)")
    }
}

public extension DataSource where SourceBase == Self {
    var sourceBase: SourceBase { self }
}
