//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - TableView DataSource
public extension DataSource {
    var cellForRow: IndexFunction<Self, UITableView, IndexPath, UITableViewCell, (ListIndexContext<UITableView, IndexPath>) -> UITableViewCell, IndexPath> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }
}

public extension ListAdapter where View: UITableView {
    // MARK: - Providing Cells, Headers, and Footers
    var cellForRow: ModelFunction<IndexPath, UITableViewCell, (ListModelContext) -> UITableViewCell> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }

    var headerTitleForSection: SectionFunction<Int, String?, (ListSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)), toClosure())
    }

    var footerTitleForSection: SectionFunction<Int, String?, (ListSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)), toClosure())
    }

//    // MARK: - Inserting or Deleting Table Rows
//    var commitEdittingStyleForRow: ModelFunction<(IndexPath, UITableViewCell.EditingStyle), Void, (ListModelContext, UITableViewCell.EditingStyle) -> Void> {
//        toFunction(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)), \.0, toClosure())
//    }
//
//    var canEditRow: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UITableViewDataSource.tableView(_:canEditRowAt:)), toClosure())
//    }
//
//    // MARK: - Reordering Table Rows
//    var canMoveRow: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UITableViewDataSource.tableView(_:canMoveRowAt:)), toClosure())
//    }
//
//    var moveRow: Function<(IndexPath, IndexPath), Void, (ListContext, IndexPath, IndexPath) -> Void> {
//        toFunction(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)), toClosure())
//    }
//
//    // MARK: - Configuring an Index
//    var sectionIndexTitles: Function<Void, [String]?, (ListContext) -> [String]?> {
//        toFunction(#selector(UITableViewDataSource.sectionIndexTitles(for:)), toClosure())
//    }
//
//    var sectionForSectionIndexTitle: Function<(String, Int), Int, (ListContext, String, Int) -> Int> {
//        toFunction(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)), toClosure())
//    }
}

// MARK: - TableView Delegate
public extension ListAdapter where View: UITableView {
    // MARK: - Configuring Rows for the Table View
    var willDisplayRow: ModelFunction<(IndexPath, UITableViewCell), Void, (ListModelContext, UITableViewCell) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), \.0, toClosure())
    }

//    var indentationLevelForRow: ModelFunction<IndexPath, Int, (ListModelContext) -> Int> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)), toClosure())
//    }
//
//    @available(iOS 11.0, *)
//    var shouldSpringLoadRow: ModelFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (ListModelContext, UISpringLoadedInteractionContext) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)), \.0, toClosure())
//    }

    // MARK: - Responding to Row Selections
    var willSelectRow: ModelFunction<IndexPath, IndexPath?, (ListModelContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willSelectRowAt:)), toClosure())
    }

    var didSelectRow: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), toClosure())
    }

    var willDeselectRow: ModelFunction<IndexPath, IndexPath?, (ListModelContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)), toClosure())
    }

    var didDeselectRow: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)), toClosure())
    }

//    @available(iOS 13.0, *)
//    var shouldBeginMultipleSelectionInteraction: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var didBeginMultipleSelectionInteraction: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var didEndMultipleSelectionInteraction: Function<Void, Void, (ListContext) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)), toClosure())
//    }

    // MARK: - Providing Custom Header and Footer Views
    var viewHeaderForSection: SectionFunction<Int, UIView?, (ListSectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)), toClosure())
    }

    var viewFooterForSection: SectionFunction<Int, UIView?, (ListSectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)), toClosure())
    }

    var willDisplayHeaderView: SectionFunction<(Int, UIView), Void, (ListSectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)), \.0, toClosure())
    }

    var willDisplayFooterView: SectionFunction<(Int, UIView), Void, (ListSectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)), \.0, toClosure())
    }

    // MARK: - Providing Header, Footer, and Row Heights
    var heightForRow: ModelFunction<IndexPath, CGFloat, (ListModelContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForRowAt:)), toClosure())
    }

    var heightForHeader: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)), toClosure())
    }

    var heightForFooter: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)), toClosure())
    }

    // MARK: - Estimating Heights for the Table's Content
    var estimatedHeightForRow: ModelFunction<IndexPath, CGFloat, (ListModelContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)), toClosure())
    }

    var estimatedHeightForHeader: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)), toClosure())
    }

    var estimatedHeightForFooter: SectionFunction<Int, CGFloat, (ListSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)), toClosure())
    }

//    // MARK: - Managing Accessory Views
//    var accessoryButtonTapped: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)), toClosure())
//    }
//
//    // MARK: - Responding to Row Actions
//    @available(iOS 11.0, *)
//    var leadingSwipeActionsConfiguration: ModelFunction<IndexPath, UISwipeActionsConfiguration?, (ListModelContext) -> UISwipeActionsConfiguration?> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)), toClosure())
//    }
//
//    @available(iOS 11.0, *)
//    var trailingSwipeActionsConfiguration: ModelFunction<IndexPath, UISwipeActionsConfiguration?, (ListModelContext) -> UISwipeActionsConfiguration?> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)), toClosure())
//    }
//
//    var shouldShowMenuForRow: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)), toClosure())
//    }
//
//    var canPerformActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Bool, (ListModelContext, Selector, Any?) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)), \.0, toClosure())
//    }
//
//    var performActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Void, (ListModelContext, Selector, Any?) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)), \.0, toClosure())
//    }
//
//    var editActionsForRow: ModelFunction<IndexPath, [UITableViewRowAction]?, (ListModelContext) -> [UITableViewRowAction]?> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)), toClosure())
//    }

    // MARK: - Managing Table View Highlights
    var shouldHighlight: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), toClosure())
    }

    var didHighlight: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)), toClosure())
    }

    var didUnhighlight: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)), toClosure())
    }

//    // MARK: - Editing Table Rows
//    var willBeginEditing: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)), toClosure())
//    }
//
//    var didEndEditing: Function<IndexPath?, Void, (ListContext, IndexPath?) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)), toClosure())
//    }
//
//    var editingStyle: ModelFunction<IndexPath, UITableViewCell.EditingStyle, (ListModelContext) -> UITableViewCell.EditingStyle> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)), toClosure())
//    }
//
//    var titleForDeleteConfirmationButton: ModelFunction<IndexPath, String?, (ListModelContext) -> String?> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)), toClosure())
//    }
//
//    var shouldIndentWhileEditing: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)), toClosure())
//    }
//
//    // MARK: - Reordering Table Rows
//    var targetIndexPathForMoveFromRowAtToProposedIndexPath: Function<(IndexPath, IndexPath), IndexPath, (ListContext, IndexPath, IndexPath) -> IndexPath> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)), toClosure())
//    }

    // MARK: - Tracking the Removal of Views
    var didEndDisplayingForRowAt: Function<(UITableViewCell, IndexPath), Void, (ListContext, UITableViewCell, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)), toClosure())
    }

    var didEndDisplayingHeaderView: Function<(UIView, Int), Void, (ListContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)), toClosure())
    }

    var didEndDisplayingFooterView: Function<(UIView, Int), Void, (ListContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)), toClosure())
    }

//    // MARK: - Managing Table View Focus
//    var canFocusRow: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:canFocusRowAt:)), toClosure())
//    }
//
//    var shouldUpdateFocusIn: Function<UITableViewFocusUpdateContext, Bool, (ListContext, UITableViewFocusUpdateContext) -> Bool> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)), toClosure())
//    }
//
//    var didUpdateFocusInWith: Function<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (ListContext, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)), toClosure())
//    }
//
//    var indexPathForPreferredFocusedView: Function<Void, IndexPath?, (ListContext) -> IndexPath?> {
//        toFunction(#selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
//    }
//
//    // MARK: - Instance Methods
//    @available(iOS 13.0, *)
//    var contextMenuConfigurationForRow: ModelFunction<(IndexPath, CGPoint), UIContextMenuConfiguration, (ListModelContext, CGPoint) -> UIContextMenuConfiguration> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)), \.0, toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var previewForDismissingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var previewForHighlightingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var willPerformPreviewActionForMenuWithAnimator: Function<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (ListContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
//        toFunction(#selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
//    }
}

#endif
