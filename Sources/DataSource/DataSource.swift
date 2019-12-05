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
    var listCoordinator: ListCoordinator { get }
    
    func makeListCoordinator() -> ListCoordinator
}

public extension DataSource where SourceBase == Self {
    var sourceBase: SourceBase { self }
}

public extension DataSource {
    var listCoordinator: ListCoordinator { makeListCoordinator() }
}

extension Optional: DataSource where Wrapped: DataSource {
    public typealias Item = Wrapped.Item
    public typealias Source = Wrapped
    public typealias SourceBase = Wrapped.SourceBase
    
    public var source: Source {
        self ?? { fatalError("shuold not call source for nil") }()
    }
    
    public var sourceBase: SourceBase {
        self!.sourceBase
    }
    
    public var listCoordinator: ListCoordinator {
        self?.listCoordinator ?? .init()
    }
    
    public func makeListCoordinator() -> ListCoordinator {
        self?.makeListCoordinator() ?? .init()
    }
    
    public var updater: Updater<Source.SourceBase> {
        self?.updater ?? .none
    }
}
