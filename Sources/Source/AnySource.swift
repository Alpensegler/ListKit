//
//  AnySources.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

struct AnySource<Item>: DataSource {
    var source: Any
    var coordinatorGetter: () -> ListCoordinator
    var listCoordinatorMaker: () -> ListCoordinator
    
    var updater: Updater<Self>
    var listCoordinator: ListCoordinator { coordinatorGetter() }
    func makeListCoordinator() -> ListCoordinator { listCoordinatorMaker() }
    
    init<Source: DataSource>(source: Source) where Source.SourceBase.Item == Item {
        let updater = source.updater
        let differ = Differ<Self>(differ: updater.source) { (($0.source) as? Source)?.sourceBase }
        self.source = source
        self.updater = Updater(source: differ, item: updater.item)
        coordinatorGetter = { source.listCoordinator }
        listCoordinatorMaker = { source.makeListCoordinator() }
    }
}
