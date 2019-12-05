//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

public struct Source<Source, Item>: UpdatableDataSource {
    public var source: Source
    
    public var updater: Updater<Self> {
        fatalError()
    }
    
    public func makeListCoordinator() -> ListCoordinator {
        fatalError()
    }
    
    public var coordinatorStorage = CoordinatorStorage<Self>()
}
