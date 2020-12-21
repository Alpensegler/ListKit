//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    typealias TableContext = ListContext<UITableView, SourceBase>
    typealias TableItemContext = ListIndexContext<UITableView, SourceBase, IndexPath>
    typealias TableSectionContext = ListIndexContext<UITableView, SourceBase, Int>
    
    typealias TableFunction<Input, Output, Closure> = ListDelegate.Function<UITableView, Self, TableList<AdapterBase>, Input, Output, Closure>
    typealias TableItemFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UITableView, Self, TableList<AdapterBase>, Input, Output, Closure, IndexPath>
    typealias TableSectionFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UITableView, Self, TableList<AdapterBase>, Input, Output, Closure, Int>
}

//TableView DataSource
public extension DataSource {
    //Providing Cells, Headers, and Footers
    var tableViewCellForRow: TableItemFunction<IndexPath, UITableViewCell, (TableItemContext, Item) -> UITableViewCell> {
        toFunction(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), toClosure())
    }
    
    var tableViewHeaderTitleForSection: TableSectionFunction<Int, String?, (TableSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)), toClosure())
    }
    
    var tableViewFooterTitleForSection: TableSectionFunction<Int, String?, (TableSectionContext) -> String?> {
        toFunction(#selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)), toClosure())
    }
    
    //Inserting or Deleting Table Rows
    var tableViewCommitEdittingStyleForRow: TableItemFunction<(IndexPath, UITableViewCell.EditingStyle), Void, (TableItemContext, UITableViewCell.EditingStyle, Item) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)), \.0, toClosure())
    }
    
    var tableViewCanEditRow: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canEditRowAt:)), toClosure())
    }
    
    //Reordering Table Rows
    var tableViewCanMoveRow: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDataSource.tableView(_:canMoveRowAt:)), toClosure())
    }
    
    var tableViewMoveRow: TableFunction<(IndexPath, IndexPath), Void, (TableContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)), toClosure())
    }
    
    //Configuring an Index
    var tableViewSectionIndexTitles: TableFunction<Void, [String]?, (TableContext) -> [String]?> {
        toFunction(#selector(UITableViewDataSource.sectionIndexTitles(for:)), toClosure())
    }
    
    var tableViewSectionForSectionIndexTitle: TableFunction<(String, Int), Int, (TableContext, String, Int) -> Int> {
        toFunction(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)), toClosure())
    }
}

//TableView Delegate
public extension DataSource {
    //Configuring Rows for the Table View
    var tableViewWillDisplayRow: TableItemFunction<(IndexPath, UITableViewCell), Void, (TableItemContext, UITableViewCell, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), \.0, toClosure())
    }
    
    var tableViewIndentationLevelForRow: TableItemFunction<IndexPath, Int, (TableItemContext, Item) -> Int> {
        toFunction(#selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)), toClosure())
    }
    
    @available(iOS 11.0, *)
    var tableViewShouldSpringLoadRow: TableItemFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (TableItemContext, UISpringLoadedInteractionContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)), \.0, toClosure())
    }
    
    //Responding to Row Selections
    var tableViewWillSelectRow: TableItemFunction<IndexPath, IndexPath?, (TableItemContext, Item) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willSelectRowAt:)), toClosure())
    }
    
    var tableViewDidSelectRow: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), toClosure())
    }
    
    var tableViewWillDeselectRow: TableItemFunction<IndexPath, IndexPath?, (TableItemContext, Item) -> IndexPath?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)), toClosure())
    }
    
    var tableViewDidDeselectRow: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)), toClosure())
    }
    
    @available(iOS 13.0, *)
    var tableViewShouldBeginMultipleSelectionInteraction: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }
    
    @available(iOS 13.0, *)
    var tableViewDidBeginMultipleSelectionInteraction: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }
    
    @available(iOS 13.0, *)
    var tableViewDidEndMultipleSelectionInteraction: TableFunction<Void, Void, (TableContext) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }
    
    //Providing Custom Header and Footer Views
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
    
    //Providing Header, Footer, and Row Heights
    var tableViewHeightForRow: TableItemFunction<IndexPath, CGFloat, (TableItemContext, Item) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForRowAt:)), toClosure())
    }
    
    var tableViewHeightForHeader: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)), toClosure())
    }
    
    var tableViewHeightForFooter: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)), toClosure())
    }
    
    //Estimating Heights for the Table's Content
    var tableViewEstimatedHeightForRow: TableItemFunction<IndexPath, CGFloat, (TableItemContext, Item) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)), toClosure())
    }
    
    var tableViewEstimatedHeightForHeader: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)), toClosure())
    }
    
    var tableViewEstimatedHeightForFooter: TableSectionFunction<Int, CGFloat, (TableSectionContext) -> CGFloat> {
        toFunction(#selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)), toClosure())
    }
    
    //Managing Accessory Views
    var tableViewAccessoryButtonTapped: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)), toClosure())
    }
    
    //Responding to Row Actions
    @available(iOS 11.0, *)
    var tableViewLeadingSwipeActionsConfiguration: TableItemFunction<IndexPath, UISwipeActionsConfiguration?, (TableItemContext, Item) -> UISwipeActionsConfiguration> {
        toFunction(#selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)), toClosure())
    }
    
    @available(iOS 11.0, *)
    var tableViewTrailingSwipeActionsConfiguration: TableItemFunction<IndexPath, UISwipeActionsConfiguration?, (TableItemContext, Item) -> UISwipeActionsConfiguration> {
        toFunction(#selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)), toClosure())
    }
    
    var tableViewShouldShowMenuForRow: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)), toClosure())
    }
    
    var tableViewCanPerformActionWithSender: TableItemFunction<(IndexPath, Selector, Any?), Bool, (TableItemContext, Selector, Any?, Item) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)), \.0, toClosure())
    }
    
    var tableViewPerformActionWithSender: TableItemFunction<(IndexPath, Selector, Any?), Void, (TableItemContext, Selector, Any?, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)), \.0, toClosure())
    }
    
    var tableViewEditActionsForRow: TableItemFunction<IndexPath, [UITableViewRowAction]?, (TableItemContext, Item) -> [UITableViewRowAction]?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)), toClosure())
    }
    
    //Managing Table View Highlights
    var tableViewShouldHighlight: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), toClosure())
    }
    
    var tableViewDidHighlight: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)), toClosure())
    }
    
    var tableViewDidUnhighlight: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)), toClosure())
    }
    
    //Editing Table Rows
    var tableViewWillBeginEditing: TableItemFunction<IndexPath, Void, (TableItemContext, Item) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)), toClosure())
    }
    
    var tableViewDidEndEditing: TableFunction<IndexPath?, Void, (TableContext, IndexPath?) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)), toClosure())
    }
    
    var tableViewEditingStyle: TableItemFunction<IndexPath, UITableViewCell.EditingStyle, (TableItemContext, Item) -> UITableViewCell.EditingStyle> {
        toFunction(#selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)), toClosure())
    }
    
    var tableViewTitleForDeleteConfirmationButton: TableItemFunction<IndexPath, String?, (TableItemContext, Item) -> String?> {
        toFunction(#selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)), toClosure())
    }
    
    var tableViewShouldIndentWhileEditing: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
        toFunction(#selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)), toClosure())
    }
    
    //Reordering Table Rows
    var tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath: TableFunction<(IndexPath, IndexPath), IndexPath, (TableContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)), toClosure())
    }
            
    //Tracking the Removal of Views
    var tableViewdidEndDisplayingForRowAt: TableFunction<(UITableViewCell, IndexPath), Void, (TableContext, UITableViewCell, IndexPath) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)), toClosure())
    }
    
    var tableViewDidEndDisplayingHeaderView: TableFunction<(UIView, Int), Void, (TableContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)), toClosure())
    }
    
    var tableViewDidEndDisplayingFooterView: TableFunction<(UIView, Int), Void, (TableContext, UIView, Int) -> Void> {
        toFunction(#selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)), toClosure())
    }
    
    //Managing Table View Focus
    var tableViewCanFocusRow: TableItemFunction<IndexPath, Bool, (TableItemContext, Item) -> Bool> {
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
    
    //Instance Methods
    @available(iOS 13.0, *)
    var tableViewContextMenuConfigurationForRow: TableItemFunction<(IndexPath, CGPoint), UIContextMenuConfiguration, (TableItemContext, CGPoint, Item) -> UIContextMenuConfiguration> {
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
