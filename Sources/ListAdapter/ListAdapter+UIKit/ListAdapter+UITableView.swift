//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if !os(macOS)
import UIKit

// MARK: - TableView DataSource
public extension ListAdapter {
    var cellForRow: IndexFunction<UITableView, List, IndexPath, UITableViewCell, (ListIndexContext<UITableView, IndexPath>) -> UITableViewCell, IndexPath> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }
}

public extension ListAdapter where View: UITableView {
    // MARK: - Providing Cells, Headers, and Footers
    var headerTitleForSection: SectionFunction<Int, String?, (SectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)), toClosure())
    }

    var footerTitleForSection: SectionFunction<Int, String?, (SectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)), toClosure())
    }

    // MARK: - Inserting or Deleting Table Rows
    var commitEdittingStyleForRow: ElementFunction<(IndexPath, UITableViewCell.EditingStyle), Void, (ElementContext, UITableViewCell.EditingStyle) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)), \.0, toClosure())
    }

    var canEditRow: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canEditRowAt:)), toClosure())
    }

    // MARK: - Reordering Table Rows
    var canMoveRow: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canMoveRowAt:)), toClosure())
    }

    var moveRow: Function<(IndexPath, IndexPath), Void, (ListContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)), toClosure())
    }

    // MARK: - Configuring an Index
    var sectionIndexTitles: Function<Void, [String]?, (ListContext) -> [String]?> {
        toFunction(#selector(UITableViewDataSource.sectionIndexTitles(for:)), toClosure())
    }

    var sectionForSectionIndexTitle: Function<(String, Int), Int, (ListContext, String, Int) -> Int> {
        toFunction(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)), toClosure())
    }
}

// MARK: - TableView Delegate
public extension ListAdapter where View: UITableView {
    // MARK: - Configuring Rows for the Table View
    var willDisplayRow: ElementFunction<(IndexPath, UITableViewCell), Void, (ElementContext, UITableViewCell) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), \.0, toClosure())
    }

    var indentationLevelForRow: ElementFunction<IndexPath, Int, (ElementContext) -> Int> {
        toFunction(#selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)), toClosure())
    }

    @available(iOS 11.0, *)
    var shouldSpringLoadRow: ElementFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (ElementContext, UISpringLoadedInteractionContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)), \.0, toClosure())
    }

    // MARK: - Responding to Row Selections
    var willSelectRow: ElementFunction<IndexPath, IndexPath?, (ElementContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willSelectRowAt:)), toClosure())
    }

    var didSelectRow: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), toClosure())
    }

    var willDeselectRow: ElementFunction<IndexPath, IndexPath?, (ElementContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)), toClosure())
    }

    var didDeselectRow: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var shouldBeginMultipleSelectionInteraction: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var didBeginMultipleSelectionInteraction: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var didEndMultipleSelectionInteraction: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }

    // MARK: - Providing Custom Header and Footer Views
    var viewHeaderForSection: SectionFunction<Int, UIView?, (SectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)), toClosure())
    }

    var viewFooterForSection: SectionFunction<Int, UIView?, (SectionContext) -> UIView?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)), toClosure())
    }

    var willDisplayHeaderView: SectionFunction<(Int, UIView), Void, (SectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)), \.0, toClosure())
    }

    var willDisplayFooterView: SectionFunction<(Int, UIView), Void, (SectionContext, UIView) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)), \.0, toClosure())
    }

    // MARK: - Providing Header, Footer, and Row Heights
    var heightForRow: ElementFunction<IndexPath, CGFloat, (ElementContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForRowAt:)), toClosure())
    }

    var heightForHeader: SectionFunction<Int, CGFloat, (SectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)), toClosure())
    }

    var heightForFooter: SectionFunction<Int, CGFloat, (SectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)), toClosure())
    }

    // MARK: - Estimating Heights for the Table's Content
    var estimatedHeightForRow: ElementFunction<IndexPath, CGFloat, (ElementContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)), toClosure())
    }

    var estimatedHeightForHeader: SectionFunction<Int, CGFloat, (SectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)), toClosure())
    }

    var estimatedHeightForFooter: SectionFunction<Int, CGFloat, (SectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)), toClosure())
    }

    // MARK: - Managing Accessory Views
    var accessoryButtonTapped: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)), toClosure())
    }

    // MARK: - Responding to Row Actions
    @available(iOS 11.0, *)
    var leadingSwipeActionsConfiguration: ElementFunction<IndexPath, UISwipeActionsConfiguration?, (ElementContext) -> UISwipeActionsConfiguration?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)), toClosure())
    }

    @available(iOS 11.0, *)
    var trailingSwipeActionsConfiguration: ElementFunction<IndexPath, UISwipeActionsConfiguration?, (ElementContext) -> UISwipeActionsConfiguration?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)), toClosure())
    }

    var shouldShowMenuForRow: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)), toClosure())
    }

    var canPerformActionWithSender: ElementFunction<(IndexPath, Selector, Any?), Bool, (ElementContext, Selector, Any?) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)), \.0, toClosure())
    }

    var performActionWithSender: ElementFunction<(IndexPath, Selector, Any?), Void, (ElementContext, Selector, Any?) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)), \.0, toClosure())
    }

    var editActionsForRow: ElementFunction<IndexPath, [UITableViewRowAction]?, (ElementContext) -> [UITableViewRowAction]?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)), toClosure())
    }

    // MARK: - Managing Table View Highlights
    var shouldHighlight: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), toClosure())
    }

    var didHighlight: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)), toClosure())
    }

    var didUnhighlight: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)), toClosure())
    }

    // MARK: - Editing Table Rows
    var willBeginEditing: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)), toClosure())
    }

    var didEndEditing: Function<IndexPath?, Void, (ListContext, IndexPath?) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)), toClosure())
    }

    var editingStyle: ElementFunction<IndexPath, UITableViewCell.EditingStyle, (ElementContext) -> UITableViewCell.EditingStyle> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)), toClosure())
    }

    var titleForDeleteConfirmationButton: ElementFunction<IndexPath, String?, (ElementContext) -> String?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)), toClosure())
    }

    var shouldIndentWhileEditing: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)), toClosure())
    }

    // MARK: - Reordering Table Rows
    var targetIndexPathForMoveFromRowAtToProposedIndexPath: Function<(IndexPath, IndexPath), IndexPath, (ListContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)), toClosure())
    }

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

    // MARK: - Managing Table View Focus
    var canFocusRow: ElementFunction<IndexPath, Bool, (ElementContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canFocusRowAt:)), toClosure())
    }

    var shouldUpdateFocusIn: Function<UITableViewFocusUpdateContext, Bool, (ListContext, UITableViewFocusUpdateContext) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)), toClosure())
    }

    var didUpdateFocusInWith: Function<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (ListContext, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)), toClosure())
    }

    var indexPathForPreferredFocusedView: Function<Void, IndexPath?, (ListContext) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
    }

    // MARK: - Instance Methods
    @available(iOS 13.0, *)
    var contextMenuConfigurationForRow: ElementFunction<(IndexPath, CGPoint), UIContextMenuConfiguration, (ElementContext, CGPoint) -> UIContextMenuConfiguration> {
        toFunction(#selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)), \.0, toClosure())
    }

    @available(iOS 13.0, *)
    var previewForDismissingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var previewForHighlightingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var willPerformPreviewActionForMenuWithAnimator: Function<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (ListContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
    }
}

#endif
