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
    var coordinatorMaker: (Self) -> ListCoordinator<AnySource<Item>>
    
    public let source: Any
    public var updater: Updater<Self>
    public let coordinatorStorage = CoordinatorStorage<AnySource<Item>>()
    public func makeListCoordinator() -> ListCoordinator<AnySource<Item>> { coordinatorMaker(self) }
    
    public init<Source: DataSource>(_ dataSource: Source) where Source.SourceBase.Item == Item {
        let updater = dataSource.updater
        let differ = Differ<Self>(differ: updater.source) { (($0.source) as? Source)?.sourceBase }
        self.source = dataSource
        self.updater = Updater(source: differ, item: updater.item)
        self.coordinatorMaker = { $0.addToStorage(AnyItemSourceCoordinator(dataSource)) }
    }
}


