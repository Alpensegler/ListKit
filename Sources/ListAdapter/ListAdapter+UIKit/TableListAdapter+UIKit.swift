//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

// swiftlint:disable identifier_name large_tuple

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    typealias TableContext = ListContext<UITableView, Self>
    typealias TableModelContext = ListIndexContext<UITableView, Self, IndexPath>
    typealias TableSectionContext = ListIndexContext<UITableView, Self, Int>

    typealias TableFunction<Input, Output, Closure> = ListDelegate.Function<UITableView, Self, TableList<AdapterBase>, Input, Output, Closure>
    typealias TableModelFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UITableView, Self, TableList<AdapterBase>, Input, Output, Closure, IndexPath>
    typealias TableSectionFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UITableView, Self, TableList<AdapterBase>, Input, Output, Closure, Int>
}

// MARK: - TableView DataSource
public extension DataSource {
    // MARK: - Providing Cells, Headers, and Footers
    var tableViewCellForRow: TableModelFunction<IndexPath, UITableViewCell, (TableModelContext, Model) -> UITableViewCell> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }

    var tableViewHeaderTitleForSection: TableSectionFunction<Int, String?, (TableSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)), toClosure())
    }

    var tableViewFooterTitleForSection: TableSectionFunction<Int, String?, (TableSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)), toClosure())
    }

    // MARK: - Inserting or Deleting Table Rows
    var tableViewCommitEdittingStyleForRow: TableModelFunction<(IndexPath, UITableViewCell.EditingStyle), Void, (TableModelContext, UITableViewCell.EditingStyle, Model) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)), \.0, toClosure())
    }

    var tableViewCanEditRow: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canEditRowAt:)), toClosure())
    }

    // MARK: - Reordering Table Rows
    var tableViewCanMoveRow: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canMoveRowAt:)), toClosure())
    }

    var tableViewMoveRow: TableFunction<(IndexPath, IndexPath), Void, (TableContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)), toClosure())
    }

    // MARK: - Configuring an Index
    var tableViewSectionIndexTitles: TableFunction<Void, [String]?, (TableContext) -> [String]?> {
        toFunction(#selector(UITableViewDataSource.sectionIndexTitles(for:)), toClosure())
    }

    var tableViewSectionForSectionIndexTitle: TableFunction<(String, Int), Int, (TableContext, String, Int) -> Int> {
        toFunction(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)), toClosure())
    }
}

// MARK: - TableView Delegate
public extension DataSource {
    // MARK: - Configuring Rows for the Table View
    var tableViewWillDisplayRow: TableModelFunction<(IndexPath, UITableViewCell), Void, (TableModelContext, UITableViewCell, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), \.0, toClosure())
    }

    var tableViewIndentationLevelForRow: TableModelFunction<IndexPath, Int, (TableModelContext, Model) -> Int> {
        toFunction(#selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)), toClosure())
    }

    @available(iOS 11.0, *)
    var tableViewShouldSpringLoadRow: TableModelFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (TableModelContext, UISpringLoadedInteractionContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)), \.0, toClosure())
    }

    // MARK: - Responding to Row Selections
    var tableViewWillSelectRow: TableModelFunction<IndexPath, IndexPath?, (TableModelContext, Model) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willSelectRowAt:)), toClosure())
    }

    var tableViewDidSelectRow: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), toClosure())
    }

    var tableViewWillDeselectRow: TableModelFunction<IndexPath, IndexPath?, (TableModelContext, Model) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)), toClosure())
    }

    var tableViewDidDeselectRow: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewShouldBeginMultipleSelectionInteraction: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewDidBeginMultipleSelectionInteraction: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewDidEndMultipleSelectionInteraction: TableFunction<Void, Void, (TableContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    // MARK: - Providing Custom Header and Footer Views
    var tableViewViewHeaderForSection: TableSectionFunction<Int, UIView?, (TableSectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)), toClosure())
    }

    var tableViewViewFooterForSection: TableSectionFunction<Int, UIView?, (TableSectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)), toClosure())
    }

    var tableViewWillDisplayHeaderView: TableSectionFunction<(Int, UIView), Void, (TableSectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)), \.0, toClosure())
    }

    var tableViewWillDisplayFooterView: TableSectionFunction<(Int, UIView), Void, (TableSectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)), \.0, toClosure())
    }

    // MARK: - Providing Header, Footer, and Row Heights
    var tableViewHeightForRow: TableModelFunction<IndexPath, CGFloat, (TableModelContext, Model) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForRowAt:)), toClosure())
    }

    var tableViewHeightForHeader: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)), toClosure())
    }

    var tableViewHeightForFooter: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)), toClosure())
    }

    // MARK: - Estimating Heights for the Table's Content
    var tableViewEstimatedHeightForRow: TableModelFunction<IndexPath, CGFloat, (TableModelContext, Model) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)), toClosure())
    }

    var tableViewEstimatedHeightForHeader: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)), toClosure())
    }

    var tableViewEstimatedHeightForFooter: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)), toClosure())
    }

    // MARK: - Managing Accessory Views
    var tableViewAccessoryButtonTapped: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)), toClosure())
    }

    // MARK: - Responding to Row Actions
    @available(iOS 11.0, *)
    var tableViewLeadingSwipeActionsConfiguration: TableModelFunction<IndexPath, UISwipeActionsConfiguration?, (TableModelContext, Model) -> UISwipeActionsConfiguration?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)), toClosure())
    }

    @available(iOS 11.0, *)
    var tableViewTrailingSwipeActionsConfiguration: TableModelFunction<IndexPath, UISwipeActionsConfiguration?, (TableModelContext, Model) -> UISwipeActionsConfiguration?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)), toClosure())
    }

    var tableViewShouldShowMenuForRow: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)), toClosure())
    }

    var tableViewCanPerformActionWithSender: TableModelFunction<(IndexPath, Selector, Any?), Bool, (TableModelContext, Selector, Any?, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)), \.0, toClosure())
    }

    var tableViewPerformActionWithSender: TableModelFunction<(IndexPath, Selector, Any?), Void, (TableModelContext, Selector, Any?, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)), \.0, toClosure())
    }

    var tableViewEditActionsForRow: TableModelFunction<IndexPath, [UITableViewRowAction]?, (TableModelContext, Model) -> [UITableViewRowAction]?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)), toClosure())
    }

    // MARK: - Managing Table View Highlights
    var tableViewShouldHighlight: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), toClosure())
    }

    var tableViewDidHighlight: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)), toClosure())
    }

    var tableViewDidUnhighlight: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)), toClosure())
    }

    // MARK: - Editing Table Rows
    var tableViewWillBeginEditing: TableModelFunction<IndexPath, Void, (TableModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)), toClosure())
    }

    var tableViewDidEndEditing: TableFunction<IndexPath?, Void, (TableContext, IndexPath?) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)), toClosure())
    }

    var tableViewEditingStyle: TableModelFunction<IndexPath, UITableViewCell.EditingStyle, (TableModelContext, Model) -> UITableViewCell.EditingStyle> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)), toClosure())
    }

    var tableViewTitleForDeleteConfirmationButton: TableModelFunction<IndexPath, String?, (TableModelContext, Model) -> String?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)), toClosure())
    }

    var tableViewShouldIndentWhileEditing: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)), toClosure())
    }

    // MARK: - Reordering Table Rows
    var tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath: TableFunction<(IndexPath, IndexPath), IndexPath, (TableContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)), toClosure())
    }

    // MARK: - Tracking the Removal of Views
    var tableViewdidEndDisplayingForRowAt: TableFunction<(UITableViewCell, IndexPath), Void, (TableContext, UITableViewCell, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)), toClosure())
    }

    var tableViewDidEndDisplayingHeaderView: TableFunction<(UIView, Int), Void, (TableContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)), toClosure())
    }

    var tableViewDidEndDisplayingFooterView: TableFunction<(UIView, Int), Void, (TableContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)), toClosure())
    }

    // MARK: - Managing Table View Focus
    var tableViewCanFocusRow: TableModelFunction<IndexPath, Bool, (TableModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canFocusRowAt:)), toClosure())
    }

    var tableViewShouldUpdateFocusIn: TableFunction<UITableViewFocusUpdateContext, Bool, (TableContext, UITableViewFocusUpdateContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)), toClosure())
    }

    var tableViewDidUpdateFocusInWith: TableFunction<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (TableContext, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)), toClosure())
    }

    var tableViewIndexPathForPreferredFocusedView: TableFunction<Void, IndexPath?, (TableContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
    }

    // MARK: - Instance Methods
    @available(iOS 13.0, *)
    var tableViewContextMenuConfigurationForRow: TableModelFunction<(IndexPath, CGPoint), UIContextMenuConfiguration, (TableModelContext, CGPoint, Model) -> UIContextMenuConfiguration> {
        toFunction(#selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)), \.0, toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewPreviewForDismissingContextMenuWithConfiguration: TableFunction<UIContextMenuConfiguration, UITargetedPreview, (TableContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewPreviewForHighlightingContextMenuWithConfiguration: TableFunction<UIContextMenuConfiguration, UITargetedPreview, (TableContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewWillPerformPreviewActionForMenuWithAnimator: TableFunction<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (TableContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
    }
}

#endif
