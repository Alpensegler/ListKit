//
//  Context+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension ListIndexContext where Index == IndexPath, List: UIListView {
    func selectItem(animated: Bool, scrollPosition: List.ScrollPosition) {
        listView.selectItem(at: index, animated: animated, scrollPosition: scrollPosition)
    }

    func deselectItem(animated: Bool) {
        listView.deselectItem(at: index, animated: animated)
    }

    var cell: List.Cell? {
        listView.cellForItem(at: index)
    }

    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        identifier: String = ""
    ) -> CustomCell {
        listView.dequeueReusableCell(
            cellClass,
            identifier: identifier,
            indexPath: index
        )
    }

    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        storyBoardIdentifier: String
    ) -> CustomCell {
        listView.dequeueReusableCell(
            cellClass,
            storyBoardIdentifier: storyBoardIdentifier,
            indexPath: index
        )
    }

    func dequeueReusableCell<CustomCell: UIView>(
        _ cellClass: CustomCell.Type,
        withNibName nibName: String,
        bundle: Bundle? = nil
      ) -> CustomCell {
        listView.dequeueReusableCell(
            cellClass,
            withNibName: nibName,
            bundle: bundle,
            indexPath: index
        )
    }
}

public extension ListIndexContext where Index == IndexPath, List: UICollectionView {
    func dequeueReusableSupplementaryView<SupplementaryView: UICollectionReusableView>(
        type: UICollectionView.SupplementaryViewType,
        _ supplementaryClass: SupplementaryView.Type,
        identifier: String = ""
    ) -> SupplementaryView {
        listView.dequeueReusableSupplementaryView(
            type: type,
            supplementaryClass,
            identifier: identifier,
            indexPath: index
        )
    }

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
            indexPath: index
        )
    }
}

public extension Context where List: UITableView {
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
}

#endif
