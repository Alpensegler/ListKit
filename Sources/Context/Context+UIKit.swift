//
//  Context+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if !os(macOS)
import UIKit

public extension ListIndexContext where Index == IndexPath, View: UIListView {
    func select(animated: Bool, scrollPosition: View.ScrollPosition) {
        listView.selectItem(at: rawIndex, animated: animated, scrollPosition: scrollPosition)
    }

    func deselect(animated: Bool) {
        listView.deselectItem(at: rawIndex, animated: animated)
    }

    var cell: View.Cell? {
        listView.cellForItem(at: rawIndex)
    }

    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        identifier: String = ""
    ) -> CustomCell {
        listView.dequeueReusableCell(
            cellClass,
            identifier: identifier,
            indexPath: rawIndex
        )
    }

    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        storyBoardIdentifier: String
    ) -> CustomCell {
        listView.dequeueReusableCell(
            cellClass,
            storyBoardIdentifier: storyBoardIdentifier,
            indexPath: rawIndex
        )
    }

    #if !os(visionOS)
    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        withNibName nibName: String,
        bundle: Bundle? = nil
      ) -> CustomCell {
        listView.dequeueReusableCell(
            cellClass,
            withNibName: nibName,
            bundle: bundle,
            indexPath: rawIndex
        )
    }
    #endif
}

public extension ListIndexContext where Index == IndexPath, View: UICollectionView {
    func dequeueReusableSupplementaryView<SupplementaryView: UICollectionReusableView>(
        type: UICollectionView.SupplementaryViewType,
        _ supplementaryClass: SupplementaryView.Type,
        identifier: String = ""
    ) -> SupplementaryView {
        listView.dequeueReusableSupplementaryView(
            type: type,
            supplementaryClass,
            identifier: identifier,
            indexPath: rawIndex
        )
    }

    #if !os(visionOS)
    func dequeueReusableSupplementaryView<SupplementaryView: UICollectionReusableView>(
        type: UICollectionView.SupplementaryViewType,
        _ supplementaryClass: SupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil
    ) -> SupplementaryView {
        listView.dequeueReusableSupplementaryView(
            type: type,
            supplementaryClass,
            nibName: nibName,
            bundle: bundle,
            indexPath: rawIndex
        )
    }
    #endif
}

public extension Context where View: UITableView {
    func dequeueReusableSupplementaryView<SupplementaryView: UITableViewHeaderFooterView>(
        type: UITableView.SupplementaryViewType,
        _ supplementaryClass: SupplementaryView.Type,
        identifier: String = "",
        configuration: (SupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView? {
        listView.dequeueReusableSupplementaryView(
            type: type,
            supplementaryClass,
            identifier: identifier
        )
    }
    
    #if !os(visionOS)
    func dequeueReusableSupplementaryView<SupplementaryView: UITableViewHeaderFooterView>(
        type: UITableView.SupplementaryViewType,
        _ supplementaryClass: SupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil
    ) -> SupplementaryView? {
        listView.dequeueReusableSupplementaryView(
            type: type,
            supplementaryClass,
            nibName: nibName,
            bundle: bundle
        )
    }
    #endif
}

#endif
