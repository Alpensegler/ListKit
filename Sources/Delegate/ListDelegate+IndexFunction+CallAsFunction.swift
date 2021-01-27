//
//  ListDelegate+IndexFunction+CallAsFunction.swift
//  ListKit
//
//  Created by Frain on 2021/1/19.
//

import Foundation

public extension ListDelegate.IndexFunction where Index == IndexPath, Output: FunctionOutput {
    func callAsFunction(outputWithItemCached: @escaping (Source.Item) -> Output) -> Target {
        toTarget(getCache: outputWithItemCached) { context, _ in context.cache() }
    }
}

#if canImport(UIKit)
import UIKit

// MARK: - CollectionView Related Functions
public extension ListDelegate.IndexFunction where Object: UICollectionView, Index == IndexPath {
    func callAsFunction<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        configCell: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item) -> Void = { _, _, _ in }
    ) -> Target where Output == UICollectionViewCell {
        toTarget { (context, input) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            configCell(cell, context, context.itemValue)
            return cell
        }
    }
    
    func callAsFunction<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        configCell: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item) -> Void = { _, _, _ in }
    ) -> Target where Output == UICollectionViewCell {
        toTarget { (context, input) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            configCell(cell, context, context.itemValue)
            return cell
        }
    }
}

public extension ListDelegate.IndexFunction where Object: UICollectionView, Index == IndexPath, Source: ItemCachedDataSource {
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> UICollectionViewCell
    ) -> Target where Output == UICollectionViewCell {
        toTarget { context, input in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    func callAsFunction<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        configCellWithCache: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> Void
    ) -> Target where Output == UICollectionViewCell {
        callAsFunction { (context, item, cache) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            configCellWithCache(cell, context, item, cache)
            return cell
        }
    }
    
    func callAsFunction<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        configCellWithCache: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> Void
    ) -> Target where Output == UICollectionViewCell {
        callAsFunction { (context, item, cache) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            configCellWithCache(cell, context, item, cache)
            return cell
        }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, CollectionView.SupplementaryViewType, Source.Item, Source.ItemCache) -> UICollectionReusableView
    ) -> Target where Output == UICollectionReusableView, Input == (String, IndexPath) {
        toTarget { context, input in closureWithCache(context, .init(input.0), context.itemValue, context.cache()) }
    }
    
    @available(iOS 11.0, *)
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, UISpringLoadedInteractionContext, Source.Item, Source.ItemCache) -> Bool
    ) -> Target where Input == (IndexPath, UISpringLoadedInteractionContext), Output == Bool {
        toTarget { context, input in closureWithCache(context, input.1, context.itemValue, context.cache()) }
    }
    
    @available(iOS 13.0, *)
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, CGPoint, Source.Item, Source.ItemCache) -> UIContextMenuConfiguration?
    ) -> Target where Input == (IndexPath, CGPoint), Output == UIContextMenuConfiguration? {
        toTarget { context, input in closureWithCache(context, input.1, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, UICollectionViewLayout, Source.Item, Source.ItemCache) -> CGSize
    ) -> Target where Input == (IndexPath, UICollectionViewLayout), Output == CGSize {
        toTarget { context, input in closureWithCache(context, input.1, context.itemValue, context.cache()) }
    }
}

// MARK: - TableView Related Functions
public extension ListDelegate.IndexFunction where Object: UITableView, Index == IndexPath {
    func callAsFunction() -> Target where Output == UITableViewCell {
        toTarget { context, input in
            let cell = context.dequeueReusableCell(UITableViewCell.self)
            cell.textLabel?.text = "\(context.itemValue)"
            return cell
        }
    }
    
    func callAsFunction<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        configCell: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item) -> Void = { _, _, _ in }
    ) -> Target where Output == UITableViewCell {
        toTarget { (context, input) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            configCell(cell, context, context.itemValue)
            return cell
        }
    }
    
    func callAsFunction<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        configCell: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item) -> Void = { _, _, _ in }
    ) -> Target where Output == UITableViewCell {
        toTarget { (context, input) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            configCell(cell, context, context.itemValue)
            return cell
        }
    }
}

public extension ListDelegate.IndexFunction where Object: UITableView, Index == IndexPath, Source: ItemCachedDataSource {
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> UITableViewCell
    ) -> Target where Output == UITableViewCell {
        toTarget { context, input in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    func callAsFunction<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        configCellWithCache: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> Void
    ) -> Target where Output == UITableViewCell {
        callAsFunction { (context, item, cache) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            configCellWithCache(cell, context, item, cache)
            return cell
        }
    }
    
    func callAsFunction<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        configCellWithCache: @escaping (Cell, ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> Void
    ) -> Target where Output == UITableViewCell {
        callAsFunction { (context, item, cache) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            configCellWithCache(cell, context, item, cache)
            return cell
        }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, UITableViewCell.EditingStyle, Source.Item, Source.ItemCache) -> Void
    ) -> Target where Input == (UITableViewCell.EditingStyle, IndexPath), Output == Void {
        toTarget { context, input in closureWithCache(context, input.0, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, UITableViewCell, Source.Item, Source.ItemCache) -> Void
    ) -> Target where Input == (UITableViewCell, IndexPath), Output == Void {
        toTarget { context, input in closureWithCache(context, input.0, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> Int
    ) -> Target where Input == Index, Output == Int {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    @available(iOS 11.0, *)
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, UISpringLoadedInteractionContext, Source.Item, Source.ItemCache) -> Bool
    ) -> Target where Input == (IndexPath, UISpringLoadedInteractionContext), Output == Bool {
        toTarget { context, input in closureWithCache(context, input.1, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> IndexPath?
    ) -> Target where Input == Index, Output == IndexPath? {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> CGFloat
    ) -> Target where Input == Index, Output == CGFloat {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    @available(iOS 11.0, *)
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> UISwipeActionsConfiguration?
    ) -> Target where Input == Index, Output == UISwipeActionsConfiguration? {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> [UITableViewRowAction]?
    ) -> Target where Input == Index, Output == [UITableViewRowAction]? {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> UITableViewCell.EditingStyle
    ) -> Target where Input == Index, Output == UITableViewCell.EditingStyle {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, Source.Item, Source.ItemCache) -> String?
    ) -> Target where Input == Index, Output == String? {
        toTarget { context, _ in closureWithCache(context, context.itemValue, context.cache()) }
    }
    
    @available(iOS 13.0, *)
    func callAsFunction(
        closureWithCache: @escaping (ListIndexContext<Object, Source.SourceBase, Index>, CGPoint, Source.Item, Source.ItemCache) -> UIContextMenuConfiguration
    ) -> Target where Input == (IndexPath, CGPoint), Output == UIContextMenuConfiguration {
        toTarget { context, input in closureWithCache(context, input.1, context.itemValue, context.cache()) }
    }
}

#endif
