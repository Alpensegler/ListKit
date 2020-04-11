//
//  AnySourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/6.
//

final class AnySourceCoordinator<OtherSourceBase>: WrapperCoordinator<AnySources, OtherSourceBase>
where OtherSourceBase: DataSource {
//    override var id: AnyHashable { wrappedCoodinator.id }
//    override var wrappedCoodinator: BaseCoordinator { coordinator }
    
    init(_ dataSource: OtherSourceBase, source: AnySources) {
//        self.coordinator = dataSource.makeListCoordinator()
//        self.storedSource = dataSource
        super.init(
            source: dataSource.source,
            wrappedCoodinator: dataSource.makeListCoordinator()
        ) { $0 }
//        super.init(update: source.listUpdate, storage: source.coordinatorStorage)
    }
}
