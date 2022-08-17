//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

// swiftlint:disable identifier_name large_tuple

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - TableView DataSource
public extension DataSource {
    var tableViewCellForRow: ListDelegate.IndexFunction<UITableView, Self, IndexPath, UITableViewCell, (ListIndexContext<UITableView, Self, IndexPath>, Model) -> UITableViewCell, IndexPath> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }
}

public extension ListAdapter where View: UITableView {
    // MARK: - Providing Cells, Headers, and Footers
    var tableViewCellForRow: ModelFunction<IndexPath, UITableViewCell, (ListModelContext, Model) -> UITableViewCell> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }

    var tableViewHeaderTitleForSection: SectionFunction<Int, String?, (ListSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)), toClosure())
    }

    var tableViewFooterTitleForSection: SectionFunction<Int, String?, (ListSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)), toClosure())
    }

    // MARK: - Inserting or Deleting Table Rows
    var tableViewCommitEdittingStyleForRow: ModelFunction<(IndexPath, UITableViewCell.EditingStyle), Void, (ListModelContext, UITableViewCell.EditingStyle, Model) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)), \.0, toClosure())
    }

    var tableViewCanEditRow: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canEditRowAt:)), toClosure())
    }

    // MARK: - Reordering Table Rows
    var tableViewCanMoveRow: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canMoveRowAt:)), toClosure())
    }

    var tableViewMoveRow: Function<(IndexPath, IndexPath), Void, (ListContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)), toClosure())
    }

    // MARK: - Configuring an Index
    var tableViewSectionIndexTitles: Function<Void, [String]?, (ListContext) -> [String]?> {
        toFunction(#selector(UITableViewDataSource.sectionIndexTitles(for:)), toClosure())
    }

    var tableViewSectionForSectionIndexTitle: Function<(String, Int), Int, (ListContext, String, Int) -> Int> {
        toFunction(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)), toClosure())
    }
}

// MARK: - TableView Delegate
public extension ListAdapter where View: UITableView {
    // MARK: - Configuring Rows for the Table View
    var tableViewWillDisplayRow: ModelFunction<(IndexPath, UITableViewCell), Void, (ListModelContext, UITableViewCell, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), \.0, toClosure())
    }

    var tableViewIndentationLevelForRow: ModelFunction<IndexPath, Int, (ListModelContext, Model) -> Int> {
        toFunction(#selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)), toClosure())
    }

    @available(iOS 11.0, *)
    var tableViewShouldSpringLoadRow: ModelFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (ListModelContext, UISpringLoadedInteractionContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)), \.0, toClosure())
    }

    // MARK: - Responding to Row Selections
    var tableViewWillSelectRow: ModelFunction<IndexPath, IndexPath?, (ListModelContext, Model) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willSelectRowAt:)), toClosure())
    }

    var tableViewDidSelectRow: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), toClosure())
    }

    var tableViewWillDeselectRow: ModelFunction<IndexPath, IndexPath?, (ListModelContext, Model) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)), toClosure())
    }

    var tableViewDidDeselectRow: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewShouldBeginMultipleSelectionInteraction: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewDidBeginMultipleSelectionInteraction: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewDidEndMultipleSelectionInteraction: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }

    // MARK: - Providing Custom Header and Footer Views
    var tableViewViewHeaderForSection: SectionFunction<Int, UIView?, (ListSectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)), toClosure())
    }

    var tableViewViewFooterForSection: SectionFunction<Int, UIView?, (ListSectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)), toClosure())
    }

    var tableViewWillDisplayHeaderView: SectionFunction<(Int, UIView), Void, (ListSectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)), \.0, toClosure())
    }

    var tableViewWillDisplayFooterView: SectionFunction<(Int, UIView), Void, (ListSectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)), \.0, toClosure())
    }

    // MARK: - Providing Header, Footer, and Row Heights
    var tableViewHeightForRow: ModelFunction<IndexPath, CGFloat, (ListModelContext, Model) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForRowAt:)), toClosure())
    }

    var tableViewHeightForHeader: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)), toClosure())
    }

    var tableViewHeightForFooter: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)), toClosure())
    }

    // MARK: - Estimating Heights for the Table's Content
    var tableViewEstimatedHeightForRow: ModelFunction<IndexPath, CGFloat, (ListModelContext, Model) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)), toClosure())
    }

    var tableViewEstimatedHeightForHeader: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)), toClosure())
    }

    var tableViewEstimatedHeightForFooter: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)), toClosure())
    }

    // MARK: - Managing Accessory Views
    var tableViewAccessoryButtonTapped: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)), toClosure())
    }

    // MARK: - Responding to Row Actions
    @available(iOS 11.0, *)
    var tableViewLeadingSwipeActionsConfiguration: ModelFunction<IndexPath, UISwipeActionsConfiguration?, (ListModelContext, Model) -> UISwipeActionsConfiguration?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)), toClosure())
    }

    @available(iOS 11.0, *)
    var tableViewTrailingSwipeActionsConfiguration: ModelFunction<IndexPath, UISwipeActionsConfiguration?, (ListModelContext, Model) -> UISwipeActionsConfiguration?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)), toClosure())
    }

    var tableViewShouldShowMenuForRow: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)), toClosure())
    }

    var tableViewCanPerformActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Bool, (ListModelContext, Selector, Any?, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)), \.0, toClosure())
    }

    var tableViewPerformActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Void, (ListModelContext, Selector, Any?, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)), \.0, toClosure())
    }

    var tableViewEditActionsForRow: ModelFunction<IndexPath, [UITableViewRowAction]?, (ListModelContext, Model) -> [UITableViewRowAction]?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)), toClosure())
    }

    // MARK: - Managing Table View Highlights
    var tableViewShouldHighlight: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), toClosure())
    }

    var tableViewDidHighlight: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)), toClosure())
    }

    var tableViewDidUnhighlight: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)), toClosure())
    }

    // MARK: - Editing Table Rows
    var tableViewWillBeginEditing: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)), toClosure())
    }

    var tableViewDidEndEditing: Function<IndexPath?, Void, (ListContext, IndexPath?) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)), toClosure())
    }

    var tableViewEditingStyle: ModelFunction<IndexPath, UITableViewCell.EditingStyle, (ListModelContext, Model) -> UITableViewCell.EditingStyle> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)), toClosure())
    }

    var tableViewTitleForDeleteConfirmationButton: ModelFunction<IndexPath, String?, (ListModelContext, Model) -> String?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)), toClosure())
    }

    var tableViewShouldIndentWhileEditing: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)), toClosure())
    }

    // MARK: - Reordering Table Rows
    var tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath: Function<(IndexPath, IndexPath), IndexPath, (ListContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)), toClosure())
    }

    // MARK: - Tracking the Removal of Views
    var tableViewdidEndDisplayingForRowAt: Function<(UITableViewCell, IndexPath), Void, (ListContext, UITableViewCell, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)), toClosure())
    }

    var tableViewDidEndDisplayingHeaderView: Function<(UIView, Int), Void, (ListContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)), toClosure())
    }

    var tableViewDidEndDisplayingFooterView: Function<(UIView, Int), Void, (ListContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)), toClosure())
    }

    // MARK: - Managing Table View Focus
    var tableViewCanFocusRow: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canFocusRowAt:)), toClosure())
    }

    var tableViewShouldUpdateFocusIn: Function<UITableViewFocusUpdateContext, Bool, (ListContext, UITableViewFocusUpdateContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)), toClosure())
    }

    var tableViewDidUpdateFocusInWith: Function<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (ListContext, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)), toClosure())
    }

    var tableViewIndexPathForPreferredFocusedView: Function<Void, IndexPath?, (ListContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
    }

    // MARK: - Instance Methods
    @available(iOS 13.0, *)
    var tableViewContextMenuConfigurationForRow: ModelFunction<(IndexPath, CGPoint), UIContextMenuConfiguration, (ListModelContext, CGPoint, Model) -> UIContextMenuConfiguration> {
        toFunction(#selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)), \.0, toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewPreviewForDismissingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewPreviewForHighlightingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var tableViewWillPerformPreviewActionForMenuWithAnimator: Function<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (ListContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
    }
}

#endif
