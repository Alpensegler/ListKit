//
//  ListDelegate+IndexFunction+CallAsFunction.swift
//  ListKit
//
//  Created by Frain on 2021/1/19.
//

import Foundation

//public extension ListDelegate.IndexFunction where Index == IndexPath, Output: FunctionOutput {
//    func callAsFunction(outputWithModelCached: @escaping (Source.Model) -> Output) -> ListAdaptation<Source.AdapterBase, View> {
//        toTarget(getCache: outputWithModelCached) { context, _ in context.cache() }
//    }
//}

#if canImport(UIKit)
import UIKit

// MARK: - CollectionView Related Functions
public extension ListDelegate.IndexFunction where View: UICollectionView, Index == IndexPath {
    func callAsFunction<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        configCell: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model) -> Void = { _, _, _ in }
    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UICollectionViewCell {
        toTarget { (context, _) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            configCell(cell, context, context.model)
            return cell
        }
    }

    func callAsFunction<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        configCell: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model) -> Void = { _, _, _ in }
    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UICollectionViewCell {
        toTarget { (context, _) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            configCell(cell, context, context.model)
            return cell
        }
    }
}

//public extension ListDelegate.IndexFunction where View: UICollectionView, Index == IndexPath, Source: ModelCachedDataSource {
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> UICollectionViewCell
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UICollectionViewCell {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    func callAsFunction<Cell: UICollectionViewCell>(
//        _ cellClass: Cell.Type,
//        identifier: String = "",
//        configCellWithCache: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> Void
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UICollectionViewCell {
//        callAsFunction { (context, model, cache) in
//            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
//            configCellWithCache(cell, context, model, cache)
//            return cell
//        }
//    }
//
//    func callAsFunction<Cell: UICollectionViewCell>(
//        _ cellClass: Cell.Type,
//        storyBoardIdentifier: String,
//        configCellWithCache: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> Void
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UICollectionViewCell {
//        callAsFunction { (context, model, cache) in
//            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
//            configCellWithCache(cell, context, model, cache)
//            return cell
//        }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, CollectionView.SupplementaryViewType, Source.Model, Source.ModelCache) -> UICollectionReusableView
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UICollectionReusableView, Input == (String, IndexPath) {
//        toTarget { context, input in closureWithCache(context, .init(rawValue: input.0), context.model, context.cache()) }
//    }
//
//    @available(iOS 11.0, *)
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, UISpringLoadedInteractionContext, Source.Model, Source.ModelCache) -> Bool
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (IndexPath, UISpringLoadedInteractionContext), Output == Bool {
//        toTarget { context, input in closureWithCache(context, input.1, context.model, context.cache()) }
//    }
//
//    @available(iOS 13.0, *)
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, CGPoint, Source.Model, Source.ModelCache) -> UIContextMenuConfiguration?
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (IndexPath, CGPoint), Output == UIContextMenuConfiguration? {
//        toTarget { context, input in closureWithCache(context, input.1, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, UICollectionViewLayout, Source.Model, Source.ModelCache) -> CGSize
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (IndexPath, UICollectionViewLayout), Output == CGSize {
//        toTarget { context, input in closureWithCache(context, input.1, context.model, context.cache()) }
//    }
//}

// MARK: - TableView Related Functions
public extension ListDelegate.IndexFunction where View: UITableView, Index == IndexPath {
    func callAsFunction() -> ListAdaptation<Source.AdapterBase, View> where Output == UITableViewCell {
        toTarget { context, _ in
            let cell = context.dequeueReusableCell(UITableViewCell.self)
            cell.textLabel?.text = "\(context.model)"
            return cell
        }
    }

    func callAsFunction<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        configCell: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model) -> Void = { _, _, _ in }
    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UITableViewCell {
        toTarget { (context, _) in
            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
            configCell(cell, context, context.model)
            return cell
        }
    }

    func callAsFunction<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        storyBoardIdentifier: String,
        configCell: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model) -> Void = { _, _, _ in }
    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UITableViewCell {
        toTarget { (context, _) in
            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
            configCell(cell, context, context.model)
            return cell
        }
    }
}

//public extension ListDelegate.IndexFunction where View: UITableView, Index == IndexPath, Source: ModelCachedDataSource {
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> UITableViewCell
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UITableViewCell {
//        toTarget { (context, _) in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    func callAsFunction<Cell: UITableViewCell>(
//        _ cellClass: Cell.Type,
//        identifier: String = "",
//        configCellWithCache: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> Void
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UITableViewCell {
//        callAsFunction { (context, model, cache) in
//            let cell = context.dequeueReusableCell(cellClass, identifier: identifier)
//            configCellWithCache(cell, context, model, cache)
//            return cell
//        }
//    }
//
//    func callAsFunction<Cell: UITableViewCell>(
//        _ cellClass: Cell.Type,
//        storyBoardIdentifier: String,
//        configCellWithCache: @escaping (Cell, ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> Void
//    ) -> ListAdaptation<Source.AdapterBase, View> where Output == UITableViewCell {
//        callAsFunction { (context, model, cache) in
//            let cell = context.dequeueReusableCell(cellClass, storyBoardIdentifier: storyBoardIdentifier)
//            configCellWithCache(cell, context, model, cache)
//            return cell
//        }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, UITableViewCell.EditingStyle, Source.Model, Source.ModelCache) -> Void
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (UITableViewCell.EditingStyle, IndexPath), Output == Void {
//        toTarget { context, input in closureWithCache(context, input.0, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, UITableViewCell, Source.Model, Source.ModelCache) -> Void
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (UITableViewCell, IndexPath), Output == Void {
//        toTarget { context, input in closureWithCache(context, input.0, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> Int
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == Int {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    @available(iOS 11.0, *)
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, UISpringLoadedInteractionContext, Source.Model, Source.ModelCache) -> Bool
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (IndexPath, UISpringLoadedInteractionContext), Output == Bool {
//        toTarget { context, input in closureWithCache(context, input.1, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> IndexPath?
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == IndexPath? {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> CGFloat
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == CGFloat {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    @available(iOS 11.0, *)
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> UISwipeActionsConfiguration?
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == UISwipeActionsConfiguration? {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> [UITableViewRowAction]?
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == [UITableViewRowAction]? {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> UITableViewCell.EditingStyle
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == UITableViewCell.EditingStyle {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, Source.Model, Source.ModelCache) -> String?
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == Index, Output == String? {
//        toTarget { context, _ in closureWithCache(context, context.model, context.cache()) }
//    }
//
//    @available(iOS 13.0, *)
//    func callAsFunction(
//        closureWithCache: @escaping (ListIndexContext<View, Source, Index>, CGPoint, Source.Model, Source.ModelCache) -> UIContextMenuConfiguration
//    ) -> ListAdaptation<Source.AdapterBase, View> where Input == (IndexPath, CGPoint), Output == UIContextMenuConfiguration {
//        toTarget { context, input in closureWithCache(context, input.1, context.model, context.cache()) }
//    }
//}

#endif
