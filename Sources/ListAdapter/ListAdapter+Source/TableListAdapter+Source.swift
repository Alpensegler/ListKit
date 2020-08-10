//
//  TableListAdapter+Source.swift
//  ListKit
//
//  Created by Frain on 2019/12/12.
//

public extension DataSource
where
    SourceBase.Source: TableListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    func tableListBySubsource() -> TableList<SourceBase> { .init(self) }
}

public extension TableListAdapter
where
    SourceBase.Source: TableListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    var tableList: TableList<SourceBase> { tableListBySubsource() }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    func tableListBySubsource() -> TableList<SourceBase> { .init(self) }
}

public extension TableListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: TableListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    var tableList: TableList<SourceBase> { tableListBySubsource() }
}
