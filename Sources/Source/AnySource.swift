//
//  AnySources.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

public struct AnySource<Item>: UpdatableDataSource {
    var coordinatorMaker: () -> ListCoordinator<AnySource<Item>>
    
    public var source: Any
    public var updater: Updater<Self>
    public var coordinatorStorage = CoordinatorStorage<AnySource<Item>>()
    public func makeListCoordinator() -> ListCoordinator<AnySource<Item>> { coordinatorMaker() }
    
    init<Source: DataSource>(source: Source) where Source.SourceBase.Item == Item {
        let updater = source.updater
        let differ = Differ<Self>(differ: updater.source) { (($0.source) as? Source)?.sourceBase }
        self.source = source
        self.updater = Updater(source: differ, item: updater.item)
        coordinatorMaker = { AnyItemSourceCoordinator(source.makeListCoordinator()) }
        coordinatorStorage.coordinator = coordinatorMaker()
    }
}

public struct AnyItemSource: UpdatableDataSource {
    public typealias Item = Any
    var coordinatorMaker: () -> ListCoordinator<AnyItemSource>
    
    public var source: Any
    public var updater: Updater<Self>
    public var coordinatorStorage = CoordinatorStorage<AnyItemSource>()
    public func makeListCoordinator() -> ListCoordinator<AnyItemSource> { coordinatorMaker() }
    
    init<Source: DataSource>(source: Source) {
        let updater = source.updater
        let differ = Differ<Self>(differ: updater.source) { (($0.source) as? Source)?.sourceBase }
        let itemDiffer = Differ<Item>(differ: updater.item)
        self.source = source
        self.updater = Updater(source: differ, item: itemDiffer)
        coordinatorMaker = { AnySourceCoordinator(source.makeListCoordinator()) }
        coordinatorStorage.coordinator = coordinatorMaker()
    }
}


