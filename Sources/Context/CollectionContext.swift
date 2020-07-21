//
//  CollectionContext.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

public struct CollectionContext<Source: DataSource>: Context where Source.SourceBase == Source {
    public let listView: CollectionView
    public let context: ListCoordinatorContext<Source>
}

public struct CollectionSectionContext<Source: DataSource>: SectionContext
where Source.SourceBase == Source {
    public let listView: CollectionView
    public let context: ListCoordinatorContext<Source>
    public let section: Int
    public let sectionOffset: Int
}

public struct CollectionItemContext<Source: DataSource>: ItemContext
where Source.SourceBase == Source {
    public let listView: CollectionView
    public let context: ListCoordinatorContext<Source>
    public let section: Int
    public let sectionOffset: Int
    public let item: Int
    public let itemOffset: Int
}
