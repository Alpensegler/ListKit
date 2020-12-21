//
//  ItemCachedDataSource.swift
//  ListKit
//
//  Created by Frain on 2021/1/5.
//

public extension DataSource where SourceBase == Self {
    func withItemCached<ItemCache>(
        cacheForItem: @escaping (Item) -> ItemCache
    ) -> ItemCached<SourceBase, ItemCache> {
        .init(sourceBase: sourceBase, cacheForItem: cacheForItem)
    }
}

public protocol ItemCachedDataSource: DataSource {
    associatedtype ItemCache
    
    var itemCached: ItemCached<SourceBase, ItemCache> { get }
}

public struct ItemCached<Base: DataSource, ItemCache>: ItemCachedDataSource
where Base.SourceBase == Base {
    public typealias Item = Base.Item
    public typealias Source = Base.Source
    public typealias SourceBase = Base.SourceBase
    
    public var source: Source { sourceBase.source }
    public var sourceBase: Base
    var cacheForItem: ((Item) -> ItemCache)?
    
    public var itemCached: ItemCached<Base, ItemCache> { self }
    public var listDelegate: ListDelegate { sourceBase.listDelegate }
    public var listCoordinatorContext: ListCoordinatorContext<Base> {
        sourceBase.listCoordinatorContext
    }
}

public extension ItemCachedDataSource
where
    SourceBase.Source: DataSource,
    SourceBase.Source.SourceBase == AnySources,
    SourceBase.Item == Any
{
    var itemCached: ItemCached<SourceBase, ItemCache> { .init(sourceBase: sourceBase) }
}

public extension ItemCachedDataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: ItemCachedDataSource,
    SourceBase.Source.Element.SourceBase.Item == SourceBase.Item,
    SourceBase.Source.Element.ItemCache == ItemCache
{
    var itemCached: ItemCached<SourceBase, ItemCache> { .init(sourceBase: sourceBase) }
}
