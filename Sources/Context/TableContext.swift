//
//  TableContext.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

public struct TableContext<Source: DataSource>: Context where Source.SourceBase == Source {
    public let listView: TableView
    public let context: ListCoordinatorContext<Source>
}

public struct TableSectionContext<Source: DataSource>: SectionContext
where Source.SourceBase == Source {
    public let listView: TableView
    public let context: ListCoordinatorContext<Source>
    public let section: Int
    public let sectionOffset: Int
}

public struct TableItemContext<Source: DataSource>: ItemContext
where Source.SourceBase == Source {
    public let listView: TableView
    public let context: ListCoordinatorContext<Source>
    public let section: Int
    public let sectionOffset: Int
    public let item: Int
    public let itemOffset: Int
}

