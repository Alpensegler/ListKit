//
//  ItemReplatedCache.swift
//  ListKit
//
//  Created by Frain on 2019/12/18.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension TableListAdapter {
    func tableList<Cache>(
        withCacheFromItem cacheFromItem: @escaping (Item) -> Cache,
        toTableList: (Self, @escaping (TableItemContext<SourceBase>) -> Cache) -> TableList<SourceBase>
    ) -> TableList<SourceBase> {
        let cacheGetter: (TableItemContext<SourceBase>) -> Cache = {
            $0.coordinator.cacheForItem[$0.section][$0.item] as! Cache
        }
        var tableList = toTableList(self, cacheGetter)
        tableList.cacheFromItem = { cacheFromItem($0) }
        return tableList
    }
    
    func tableListWithCache(
        heightForItem: @escaping  (Item) -> CGFloat,
        cellForItem: @escaping (TableItemContext<SourceBase>, CGFloat, Item) -> UITableViewCell
    ) -> TableList<SourceBase> {
        tableList(withCacheFromItem: heightForItem) { (self, cacheGetter) in
            self.tableViewCellForRow { cellForItem($0, cacheGetter($0), $1) }
                .tableViewHeightForRow { (context, _) in cacheGetter(context) }
        }
    }
}

public extension CollectionListAdapter {
    func collectionList<Cache>(
        withCacheFromItem cacheFromItem: @escaping (Item) -> Cache,
        toCollectionList: (Self, @escaping (CollectionItemContext<SourceBase>) -> Cache) -> CollectionList<SourceBase>
    ) -> CollectionList<SourceBase> {
        let cacheGetter: (CollectionItemContext<SourceBase>) -> Cache = {
            $0.coordinator.cacheForItem[$0.section][$0.item] as! Cache
        }
        var tableList = toCollectionList(self, cacheGetter)
        tableList.cacheFromItem = { cacheFromItem($0) }
        return tableList
    }
    
    func collectionListWithCache(
        sizeForItem: @escaping  (Item) -> CGSize,
        cellForItem: @escaping (CollectionItemContext<SourceBase>, CGSize, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        collectionList(withCacheFromItem: sizeForItem) { (self, cacheGetter) in
            self.collectionViewCellForItem { cellForItem($0, cacheGetter($0), $1) }
                .collectionViewLayoutSizeForItem { (context, _, _) in cacheGetter(context) }
        }
    }
}

#endif
