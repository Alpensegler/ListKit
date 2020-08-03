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
        toTableList: (Self, @escaping (TableItemContext) -> Cache) -> TableList<SourceBase>
    ) -> TableList<SourceBase> {
        toTableList(self) { $0.itemCache(or: cacheFromItem) }
    }
}

public extension CollectionListAdapter {
    func collectionList<Cache>(
        withCacheFromItem cacheFromItem: @escaping (Item) -> Cache,
        toCollectionList: (Self, @escaping (CollectionItemContext) -> Cache) -> CollectionList<SourceBase>
    ) -> CollectionList<SourceBase> {
        toCollectionList(self) { $0.itemCache(or: cacheFromItem) }
    }
}

public extension TableListAdapter {
    func tableListWithCache(
        heightForItem: @escaping (Item) -> CGFloat,
        cellForItem: @escaping (TableItemContext, CGFloat, Item) -> UITableViewCell
    ) -> TableList<SourceBase> {
        tableList(withCacheFromItem: heightForItem) { (self, cacheGetter) in
            self.tableViewCellForRow { cellForItem($0, cacheGetter($0), $1) }
                .tableViewHeightForRow { (context, _) in cacheGetter(context) }
        }
    }
}

public extension CollectionListAdapter {
    func collectionListWithCache(
        sizeForItem: @escaping (Item) -> CGSize,
        cellForItem: @escaping (CollectionItemContext, CGSize, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        collectionList(withCacheFromItem: sizeForItem) { (self, cacheGetter) in
            self.collectionViewCellForItem { cellForItem($0, cacheGetter($0), $1) }
                .collectionViewLayoutSizeForItem { (context, _, _) in cacheGetter(context) }
        }
    }
}

#endif
