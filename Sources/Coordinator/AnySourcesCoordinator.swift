//
//  AnySourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/6.
//

//final class AnySourceCoordinator: WrapperCoordinator<AnySources> {
//    var coordinator: BaseCoordinator
//    var storedSource: Any
//    override var id: AnyHashable { wrappedCoodinator.id }
//    override var wrappedCoodinator: BaseCoordinator { coordinator }
//    override var source: Any { storedSource }    
//    
//    init<Source: DataSource>(_ dataSource: Source, source: AnySources) {
//        self.coordinator = dataSource.makeListCoordinator()
//        self.storedSource = dataSource
//        super.init(update: source.listUpdate, storage: source.coordinatorStorage)
//    }
//}
