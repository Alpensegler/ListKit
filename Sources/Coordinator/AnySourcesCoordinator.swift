//
//  AnySourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/6.
//

class AnyItemSourceCoordinator<SourceBase: DataSource>: ItemTypedWrappedCoordinator<SourceBase>
where SourceBase.Source == Any {
    var coordinator: ItemTypedCoorinator<Item>
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var wrappedItemTypedCoodinator: ItemTypedCoorinator<Item> { coordinator }
    override var source: Any { wrappedCoodinator.anySource }
    
    override var selfType: ObjectIdentifier {
        get { wrappedCoodinator.selfType }
        set { wrappedCoodinator.selfType = newValue }
    }
    
    init(_ coordinator: ItemTypedCoorinator<Item>) {
        self.coordinator = coordinator
        super.init()
    }
}

class AnySourceCoordinator<SourceBase: DataSource>: WrapperCoordinator<SourceBase>
where SourceBase.Source == Any, SourceBase.Item == Any {
    var coordinator: BaseCoordinator
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var source: Any { wrappedCoodinator.anySource }
    
    override var selfType: ObjectIdentifier {
        get { wrappedCoodinator.selfType }
        set { wrappedCoodinator.selfType = newValue }
    }
    
    init(_ coordinator: BaseCoordinator) {
        self.coordinator = coordinator
        super.init()
    }
}
