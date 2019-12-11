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
    var updater: Updater<SourceBase> { get }
    var listCoordinator: ListCoordinator<SourceBase> { get }
    
    func makeListCoordinator() -> ListCoordinator<SourceBase>
}

public extension DataSource where SourceBase == Self {
    var sourceBase: SourceBase { self }
}

public extension DataSource {
    var updater: Updater<SourceBase> { .none }
    var listCoordinator: ListCoordinator<SourceBase> { makeListCoordinator() }
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        fatalError("unsupported source \(Source.self) item \(Item.self)")
    }
}

extension DataSource {
    var baseCoordinator: BaseCoordinator { listCoordinator }
    var itemTypedCoordinator: ItemTypedCoorinator<Item> { listCoordinator }
}

extension Optional: DataSource where Wrapped: DataSource {
    public typealias Item = Wrapped.Item
    public typealias Source = Self
    
    public var source: Source { self }
    public var updater: Updater<Self> { .none }
    
    public func makeListCoordinator() -> ListCoordinator<Self> { .init() }
    
}
