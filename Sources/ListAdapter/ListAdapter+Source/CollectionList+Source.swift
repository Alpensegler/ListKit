//
//  CollectionList+Source.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

public extension CollectionListAdapter
where
    SourceBase.Source: CollectionListAdapter,
    SourceBase.Source.SourceBase.Item == Item
{
    var collectionList: CollectionList<SourceBase> { provideCollectionListBySubsource() }
    func provideCollectionListBySubsource() -> CollectionList<SourceBase> { toCollectionList() }
}

public extension CollectionListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: CollectionListAdapter,
    SourceBase.Source.Element.SourceBase.Item == Item
{
    var collectionList: CollectionList<SourceBase> { provideCollectionListBySubsource() }
    func provideCollectionListBySubsource() -> CollectionList<SourceBase> { toCollectionList() }
}
