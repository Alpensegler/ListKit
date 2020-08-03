//
//  ItemReplatedCache.swift
//  ListKit
//
//  Created by Frain on 2019/12/18.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension TableListAdapter {
    func tableListWithCache<Cache>(
        forItem: @escaping (Item) -> Cache,
        toTableList: (Self, @escaping (TableItemContext) -> Cache) -> TableList<SourceBase>
    ) -> TableList<SourceBase> {
        toTableList(self) { $0.itemCache(or: forItem) }
    }
}

public extension CollectionListAdapter {
    func collectionListWithCache<Cache>(
        forItem: @escaping (Item) -> Cache,
        toCollectionList: (Self, @escaping (CollectionItemContext) -> Cache) -> CollectionList<SourceBase>
    ) -> CollectionList<SourceBase> {
        toCollectionList(self) { $0.itemCache(or: forItem) }
    }
}

public extension TableListAdapter {
    func tableListWithCacheHeight(
        forItem: @escaping (Item) -> CGFloat,
        cellForItem: @escaping (TableItemContext, CGFloat, Item) -> UITableViewCell = { (context, _, item) in
            let cell = context.dequeueReusableCell(UITableViewCell.self)
            cell.textLabel?.text = "\(item)"
            return cell
        }
    ) -> TableList<SourceBase> {
        tableListWithCache(forItem: forItem) { (self, cacheGetter) in
            self.tableViewCellForRow { cellForItem($0, cacheGetter($0), $1) }
                .tableViewHeightForRow { (context, _) in cacheGetter(context) }
        }
    }
}

public extension CollectionListAdapter {
    func collectionListWithCacheSize(
        forItem: @escaping (Item) -> CGSize,
        cellForItem: @escaping (CollectionItemContext, CGSize, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        collectionListWithCache(forItem: forItem) { (self, cacheGetter) in
            self.collectionViewCellForItem { cellForItem($0, cacheGetter($0), $1) }
                .collectionViewLayoutSizeForItem { (context, _, _) in cacheGetter(context) }
        }
    }
}

#endif
