//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

public struct Sources<Source, Item>: UpdatableDataSource {
    public let source: Source
    
    public var updater: Updater<Self> {
        fatalError()
    }
    
    public func makeListCoordinator() -> ListCoordinator<Self> {
        fatalError()
    }
    
    public var coordinatorStorage = CoordinatorStorage<Self>()
}
