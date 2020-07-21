//
//  AnyItemSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public struct AnySources: DataSource {
    public typealias Item = Any
    public typealias SourceBase = Self
    let coordinatorMaker: (Self) -> ListCoordinator<AnySources>
    
    public let source: Any
    
    public let listOptions: ListOptions<AnySources>
    public let listUpdate: ListUpdate<SourceBase>
    
    public var listCoordinator: ListCoordinator<Self> { coordinatorMaker(self) }
    
    public init<Source: DataSource>(_ dataSource: Source) {
        self.source = dataSource
        self.listOptions = .init(dataSource.listOptions) { (($0.source) as! Source).sourceBase }
        self.listUpdate = dataSource.listUpdate.diff.map { .init(diff: .init($0)) } ?? .reload
        self.coordinatorMaker = {
            WrapperCoordinator<AnySources, Source>($0, wrapped: dataSource) { $0 }
        }
    }
}
