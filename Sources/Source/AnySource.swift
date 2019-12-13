//
//  AnySources.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public protocol AnySourceConvertible: DataSource {
    init<Source: DataSource>(_ dataSource: Source) where Source.SourceBase.Item == Item
}

public struct AnySource<Item>: UpdatableDataSource, AnySourceConvertible {
    var coordinatorMaker: () -> ListCoordinator<AnySource<Item>>
    
    public let source: Any
    public var updater: Updater<Self>
    public var coordinatorStorage = CoordinatorStorage<AnySource<Item>>()
    public func makeListCoordinator() -> ListCoordinator<AnySource<Item>> { coordinatorMaker() }
    
    public init<Source: DataSource>(_ dataSource: Source) where Source.SourceBase.Item == Item {
        let updater = dataSource.updater
        let differ = Differ<Self>(differ: updater.source) { (($0.source) as? Source)?.sourceBase }
        self.source = dataSource
        self.updater = Updater(source: differ, item: updater.item)
        coordinatorMaker = { AnyItemSourceCoordinator(dataSource, coordinator: dataSource.listCoordinator) }
        coordinatorStorage.coordinator = AnyItemSourceCoordinator(dataSource, coordinator: dataSource.listCoordinator)
    }
}


