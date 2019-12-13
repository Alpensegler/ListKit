//
//  AnySourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/6.
//

class AnyItemSourceCoordinator<SourceBase: DataSource>: ItemTypedWrappedCoordinator<SourceBase>
where SourceBase.Source == Any {
    var coordinator: ItemTypedCoorinator<Item>
    var storedSource: Any
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var wrappedItemTypedCoodinator: ItemTypedCoorinator<Item> { coordinator }
    override var source: Any { storedSource }
    
    override var selfType: ObjectIdentifier {
        get { wrappedCoodinator.selfType }
        set { wrappedCoodinator.selfType = newValue }
    }
    
    init<Source: DataSource>(_ dataSource: Source) where Source.Item == SourceBase.Item {
        self.coordinator = dataSource.itemTypedCoordinator
        self.storedSource = dataSource
        super.init()
    }
}

class AnySourceCoordinator<SourceBase: DataSource>: WrapperCoordinator<SourceBase>
where SourceBase.Source == Any, SourceBase.Item == Any {
    var coordinator: BaseCoordinator
    var storedSource: Any
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var source: Any { storedSource }
    
    override var selfType: ObjectIdentifier {
        get { wrappedCoodinator.selfType }
        set { wrappedCoodinator.selfType = newValue }
    }
    
    init<Source: DataSource>(_ dataSource: Source) {
        self.coordinator = dataSource.baseCoordinator
        self.storedSource = dataSource
        super.init()
    }
}
