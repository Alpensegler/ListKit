//
//  Sources+Coordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

public extension Sources where Source == Item {
    init(id: AnyHashable, item: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = item
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            ItemCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(item: Source, updater: Updater<Self> = .none) {
        self.source = item
        self.updater = updater
        self.listCoordinatorMaker = {
            ItemCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}

public extension Sources
where Source: Collection, Source.Element == Item {
    init(id: AnyHashable, items: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = items
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            ItemsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(items: Source, updater: Updater<Self> = .none) {
        self.source = items
        self.updater = updater
        self.listCoordinatorMaker = {
            ItemsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}

public extension Sources
where Source: RangeReplaceableCollection, Source.Element == Item {
    init(id: AnyHashable, items: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = items
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            RangeReplacableItemsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(items: Source, updater: Updater<Self> = .none) {
        self.source = items
        self.updater = updater
        self.listCoordinatorMaker = {
            RangeReplacableItemsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}

public extension Sources
where
    Source: Collection,
    Source.Element: Collection,
    Source.Element.Element == Item
{
    init(id: AnyHashable, sections: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = sections
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            SectionsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(sections: Source, updater: Updater<Self> = .none) {
        self.source = sections
        self.updater = updater
        self.listCoordinatorMaker = {
            SectionsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: RangeReplaceableCollection,
    Source.Element.Element == Item
{
    init(id: AnyHashable, sections: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = sections
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            RangeReplacableSectionsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(sections: Source, updater: Updater<Self> = .none) {
        self.source = sections
        self.updater = updater
        self.listCoordinatorMaker = {
            RangeReplacableSectionsCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}

public extension Sources where Source: DataSource, Source.Item == Item {
    init(id: AnyHashable, dataSource: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = dataSource
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            SourceCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(dataSource: Source, updater: Updater<Self> = .none) {
        self.source = dataSource
        self.updater = updater
        self.listCoordinatorMaker = {
            SourceCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}

public extension Sources
where
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.Item == Item
{
    init(id: AnyHashable, dataSources: Source, updater: Updater<Self> = .none) {
        self.id = id
        self.source = dataSources
        self.updater = .init(
            source: .init(identifier: { $0.id }),
            item: updater.item
        )
        self.listCoordinatorMaker = {
            SourcesCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
    
    init(dataSources: Source, updater: Updater<Self> = .none) {
        self.source = dataSources
        self.updater = updater
        self.listCoordinatorMaker = {
            SourcesCoordinator($0.sourceBase, storage: $0.coordinatorStorage)
        }
    }
}
