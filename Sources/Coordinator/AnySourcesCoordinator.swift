//
//  AnySourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/6.
//

final class AnySourceCoordinator: WrapperCoordinator<AnySources> {
    var coordinator: BaseCoordinator
    var storedSource: Any
    override var wrappedCoodinator: BaseCoordinator { coordinator }
    override var source: Any { storedSource }
    
    override var selfType: ObjectIdentifier {
        get { wrappedCoodinator.selfType }
        set { wrappedCoodinator.selfType = newValue }
    }
    
    init<Source: DataSource>(_ dataSource: Source, storage: CoordinatorStorage<AnySources>) {
        self.coordinator = dataSource.makeListCoordinator()
        self.storedSource = dataSource
        super.init(storage: storage)
    }
}
