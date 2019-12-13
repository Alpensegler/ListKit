//
//  CollectionContext.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

public struct CollectionContext<Source: DataSource>: Context where Source.SourceBase == Source {
    public let listView: CollectionView
    public let coordinator: ListCoordinator<Source>
    
    init(_ listView: CollectionView, _ coordinator: ListCoordinator<Source>) {
        self.listView = listView
        self.coordinator = coordinator
    }
}

public struct CollectionSectionContext<Source: DataSource>: SectionContext
where Source.SourceBase == Source {
    public let listView: CollectionView
    public let coordinator: ListCoordinator<Source>
    public let section: Int
    public let sectionOffset: Int
    
    init(
        _ listView: CollectionView,
        _ coordinator: ListCoordinator<Source>,
        section: Int
    ) {
        let (sectionOffset, _) = coordinator.offsets(for: listView)
        self.listView = listView
        self.coordinator = coordinator
        self.sectionOffset = sectionOffset
        self.section = section - sectionOffset
    }
}

public struct CollectionItemContext<Source: DataSource>: ItemContext
where Source.SourceBase == Source {
    public let listView: CollectionView
    public let coordinator: ListCoordinator<Source>
    public let section: Int
    public let sectionOffset: Int
    public let item: Int
    public let itemOffset: Int
    
    init<Path: PathConvertible>(
        _ listView: CollectionView,
        _ coordinator: ListCoordinator<Source>,
        path: Path
    ) {
        let (sectionOffset, itemOffset) = coordinator.offsets(for: listView)
        self.listView = listView
        self.coordinator = coordinator
        self.sectionOffset = sectionOffset
        self.itemOffset = itemOffset
        self.section = path.section - sectionOffset
        self.item = path.item - itemOffset
    }
}
