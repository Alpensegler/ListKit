//
//  AnyItemSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/11.
//

public protocol AnyItemSourceConvertible: DataSource {
    init<Source: DataSource>(_ dataSource: Source)
}

public struct AnyItemSource: UpdatableDataSource, AnyItemSourceConvertible {
    public typealias Item = Any
    var coordinatorMaker: (Self) -> ListCoordinator<AnyItemSource>
    
    public let source: Any
    public let updater: Updater<Self>
    public let coordinatorStorage = CoordinatorStorage<AnyItemSource>()
    public func makeListCoordinator() -> ListCoordinator<AnyItemSource> { coordinatorMaker(self) }
    
    public init<Source: DataSource>(_ dataSource: Source) {
        let updater = dataSource.updater
        let differ = Differ<Self>(differ: updater.source) { (($0.source) as? Source)?.sourceBase }
        let itemDiffer = Differ<Item>(differ: updater.item)
        self.source = dataSource
        self.updater = Updater(source: differ, item: itemDiffer)
        self.coordinatorMaker = { $0.addToStorage(AnySourceCoordinator(dataSource)) }
    }
}
