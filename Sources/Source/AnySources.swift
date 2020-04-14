//
//  AnyItemSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public struct AnySources: UpdatableDataSource {
    public typealias Item = Any
    public typealias SourceBase = Self
    let coordinatorMaker: () -> ListCoordinator<AnySources>
    
    public let source: Any
    public let differ: Differ<AnySources>
    public let listUpdate: Update<Any>
    public var coordinatorStorage = CoordinatorStorage<AnySources>()
    public func makeListCoordinator() -> ListCoordinator<Self> { coordinatorMaker() }
    
    public init<Source: DataSource>(_ dataSource: Source) {
        self.source = dataSource
        self.differ = .init(dataSource.differ) { (($0.source) as? Source)?.sourceBase }
        self.listUpdate = dataSource.listUpdate.diff.map { .init(diff: .init($0)) } ?? .reload
        self.coordinatorMaker = {
            WrapperCoordinator<AnySources, Source>(
                source: dataSource.source,
                wrappedCoodinator: dataSource.makeListCoordinator()
            ) { $0 }
        }
    }
}
