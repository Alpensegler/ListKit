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
        let key = ObjectIdentifier(Cache.self)
        let cacheGetter: (TableItemContext<SourceBase>) -> Cache = {
            $0.cacheForItem(key) as! Cache
        }
        let tableList = toTableList(self, cacheGetter)
        var setups = tableList.coordinatorSetups
        setups.append { $0.cacheFromItem = cacheFromItem }
        return .init(coordinatorSetups: setups, source: tableList.source)
    }
}

public extension CollectionListAdapter {
    func collectionList<Cache>(
        withCacheFromItem cacheFromItem: @escaping (Item) -> Cache,
        toCollectionList: (Self, @escaping (CollectionItemContext<SourceBase>) -> Cache) -> CollectionList<SourceBase>
    ) -> CollectionList<SourceBase> {
        let key = ObjectIdentifier(Cache.self)
        let cacheGetter: (CollectionItemContext<SourceBase>) -> Cache = { $0.cacheForItem(key) as! Cache }
        let collectionList = toCollectionList(self, cacheGetter)
        var setups = collectionList.coordinatorSetups
        setups.append { $0.cacheFromItem = cacheFromItem }
        return .init(coordinatorSetups: setups, source: collectionList.source)
    }
}

public extension TableListAdapter {
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
