//
//  Context+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension IndexPathContext where List: UIListView {
    var listIndexPath: IndexPath {
        IndexPath(item: itemOffset + item, section: sectionOffset + section)
    }
    
    func selectItem(animated: Bool, scrollPosition: List.ScrollPosition) {
        listView.selectItem(at: listIndexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(animated: Bool) {
        listView.deselectItem(at: listIndexPath, animated: animated)
    }
    
    var cell: List.Cell? {
        listView.cellForItem(at: listIndexPath)
    }
    
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        identifier: String = "",
        configuration: (CustomCell) -> Void = { _ in }
    ) -> List.Cell {
        listView.dequeueReusableCell(
            withCellClass: cellClass,
            identifier: identifier,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }

    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        storyBoardIdentifier: String,
        indexPath: IndexPath,
        configuration: (CustomCell) -> Void = { _ in }
    ) -> List.Cell {
        listView.dequeueReusableCell(
            withCellClass: cellClass,
            storyBoardIdentifier: storyBoardIdentifier,
            indexPath: indexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        withNibName nibName: String,
        bundle: Bundle? = nil,
        configuration: (CustomCell) -> Void = { _ in }
      ) -> List.Cell {
        listView.dequeueReusableCell(
            withCellClass: cellClass,
            withNibName: nibName,
            bundle: bundle,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
}

public extension IndexPathContext where List: UICollectionView {
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UICollectionReusableView>(
        type: UICollectionView.SupplementaryViewType,
        withSupplementaryClass supplementaryClass: CustomSupplementaryView.Type,
        identifier: String = "",
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> UICollectionReusableView {
        listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: supplementaryClass,
            identifier: identifier,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UICollectionReusableView>(
        type: UICollectionView.SupplementaryViewType,
        withSupplementaryClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> UICollectionReusableView {
        listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: cellClass,
            nibName: nibName,
            bundle: bundle,
            indexPath: listIndexPath,
            configuration: configuration
        )
    }
}

public extension Context where List: UITableView {
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UITableViewHeaderFooterView>(
        type: UITableView.SupplementaryViewType,
        withSupplementaryClass supplementaryClass: CustomSupplementaryView.Type,
        identifier: String = "",
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> UITableViewHeaderFooterView? {
        listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: supplementaryClass,
            identifier: identifier,
            configuration: configuration
        )
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UITableViewHeaderFooterView>(
        type: UITableView.SupplementaryViewType,
        withSupplementaryClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> UITableViewHeaderFooterView? {
        listView.dequeueReusableSupplementaryView(
            type: type,
            withSupplementaryClass: cellClass,
            nibName: nibName,
            bundle: bundle,
            configuration: configuration
        )
    }
}

#endif



