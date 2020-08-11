//
//  ItemReplatedCache.swift
//  ListKit
//
//  Created by Frain on 2019/12/18.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    func tableListWithCache<Cache>(
        forItem: @escaping (TableItemContext, Item) -> Cache,
        toTableList: (Self, @escaping (TableItemContext) -> Cache) -> TableList<SourceBase>
    ) -> TableList<SourceBase> {
        toTableList(self) { $0.itemCache(or: forItem) }
    }
    
    func collectionListWithCache<Cache>(
        forItem: @escaping (CollectionItemContext, Item) -> Cache,
        toCollectionList: (Self, @escaping (CollectionItemContext) -> Cache) -> CollectionList<SourceBase>
    ) -> CollectionList<SourceBase> {
        toCollectionList(self) { $0.itemCache(or: forItem) }
    }
    
    func tableListWithCacheHeight(
        forItem: @escaping (TableItemContext, Item) -> CGFloat,
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
    
    func tableListWithCacheHeight<Cell: UITableViewCell>(
        forItem: @escaping (TableItemContext, Item) -> CGFloat,
        _ cellClass: Cell.Type,
        identifier: String = "",
        _ closure: @escaping (Cell, TableItemContext, CGFloat, Item) -> Void
    ) -> TableList<SourceBase> {
        tableListWithCache(forItem: forItem) { (self, cacheGetter) in
            self.tableViewCellForRow(cellClass, identifier: identifier) { closure($0, $1, cacheGetter($1), $2) }
                .tableViewHeightForRow { (context, _) in cacheGetter(context) }
        }
    }
    
    func collectionListWithCacheSize(
        forItem: @escaping (CollectionItemContext, Item) -> CGSize,
        cellForItem: @escaping (CollectionItemContext, CGSize, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        collectionListWithCache(forItem: forItem) { (self, cacheGetter) in
            self.collectionViewCellForItem { cellForItem($0, cacheGetter($0), $1) }
                .collectionViewLayoutSizeForItem { (context, _, _) in cacheGetter(context) }
        }
    }
    
    func collectionListWithCacheSize<Cell: UICollectionViewCell>(
        forItem: @escaping (CollectionItemContext, Item) -> CGSize,
        _ cellClass: Cell.Type,
        identifier: String = "",
        closure: @escaping (Cell, CollectionItemContext, CGSize, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionListWithCache(forItem: forItem) { (self, cacheGetter) in
            self.collectionViewCellForItem(cellClass, identifier: identifier) { closure($0, $1, cacheGetter($1), $2) }
                .collectionViewLayoutSizeForItem { (context, _, _) in cacheGetter(context) }
        }
    }
}

#endif
