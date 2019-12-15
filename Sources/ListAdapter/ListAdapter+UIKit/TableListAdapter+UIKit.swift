//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    func provideTableViewCell(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UITableViewCell = { (context, item) in
            context.dequeueReusableCell(UITableViewCell.self) {
                $0.textLabel?.text = "\(item)"
            }
        }
    ) -> TableList<SourceBase> {
        toTableList().set(\.cellForRowAt) {
            closure($0.0, $0.0.itemValue)
        }
    }
    
    func provideTableViewCell<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        _ closure: @escaping (Cell, TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        provideTableViewCell { (context, item) in
            context.dequeueReusableCell(cellClass, identifier: identifier) {
                closure($0, context, item)
            }
        }
    }
}

public extension TableListAdapter {
    @discardableResult
    func apply(by tableView: UITableView) -> TableList<SourceBase> {
        let tableList = self.tableList
//        tableView.setupWith(coordinator: tableList.listCoordinator)
        return tableList
    }
}

//TableView DataSource
public extension TableListAdapter {
    //Providing Cells, Headers, and Footers
    @discardableResult
    func provideTableViewHeaderTitle(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> String?
    ) -> TableList<SourceBase> {
        set(\.titleForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func provideTableViewFooterTitle(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> String?
    ) -> TableList<SourceBase> {
        set(\.titleForFooterInSection) { closure($0.0) }
    }
    
    //Inserting or Deleting Table Rows
    @discardableResult
    func tableViewCommitEdittingStyleForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, UITableViewCell.EditingStyle, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.commitForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewCanEditItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.canEditRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Reordering Table Rows
    @discardableResult
    func tableViewCanMoveItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.canMoveRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewMoveItem(
        _ closure: @escaping (TableContext<SourceBase>, IndexPath, IndexPath) -> Void
    ) -> TableList<SourceBase> {
        set(\.moveRowAtTo) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Configuring an Index
    @discardableResult
    func tableViewSectionIndexTitles(
        _ closure: @escaping (TableContext<SourceBase>) -> [String]?
    ) -> TableList<SourceBase> {
        set(\.sectionIndexTitles) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewsectionForSectionIndexTitleAt(
        _ closure: @escaping (TableContext<SourceBase>, String, Int) -> Int
    ) -> TableList<SourceBase> {
        set(\.sectionForSectionIndexTitleAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//TableView Delegate
public extension TableListAdapter {
    //Configuring Rows for the Table View
    @discardableResult
    func tableViewWillDisplayItem(
        _ closure: @escaping (TableItemContext<SourceBase>, UITableViewCell, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.willDisplayForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewIndentationLevelForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Int
    ) -> TableList<SourceBase> {
        set(\.indentationLevelForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewShouldSpringLoadItem(
        _ closure: @escaping (TableItemContext<SourceBase>, UISpringLoadedInteractionContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.springLoadRowAtWith) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    //Responding to Row Selections
    @discardableResult
    func tableViewWillSelectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> IndexPath?
    ) -> TableList<SourceBase> {
        set(\.willSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidSelectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.didSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewWillDeselectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> IndexPath?
    ) -> TableList<SourceBase> {
        set(\.willDeselectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidDeselectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.didDeselectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewShouldBeginMultipleSelectionInteraction(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.shouldBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewDidBeginMultipleSelectionInteraction(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.didBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewDidEndMultipleSelectionInteraction(
        _ closure: @escaping (TableContext<SourceBase>) -> Void
    ) -> TableList<SourceBase> {
        set(\.didEndMultipleSelectionInteraction) { closure($0.0) }
    }
    
    //Providing Custom Header and Footer Views
    @discardableResult
    func provideTableViewViewHeader(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> UIView?
    ) -> TableList<SourceBase> {
        set(\.viewForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func provideTableViewViewFooter(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> UIView?
    ) -> TableList<SourceBase> {
        set(\.viewForFooterInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewWillDisplayHeaderView(
        _ closure: @escaping (TableSectionContext<SourceBase>, UIView) -> Void
    ) -> TableList<SourceBase> {
        set(\.willDisplayHeaderViewForSection) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func tableViewWillDisplayFooterView(
        _ closure: @escaping (TableSectionContext<SourceBase>, UIView) -> Void
    ) -> TableList<SourceBase> {
        set(\.willDisplayFooterViewForSection) { closure($0.0, $0.1.0) }
    }
    
    //Providing Header, Footer, and Row Heights
    @discardableResult
    func tableViewHeightForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.heightForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewHeightForHeader(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.heightForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewHeightForFooter(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.heightForFooterInSection) { closure($0.0) }
    }
    
    //Estimating Heights for the Table's Content
    @discardableResult
    func tableViewEstimatedHeightForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.estimatedHeightForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewEstimatedHeightForHeader(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.estimatedHeightForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewEstimatedHeightForFooter(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.estimatedHeightForFooterInSection) { closure($0.0) }
    }
    
    //Managing Accessory Views
    @discardableResult
    func tableViewAccessoryButtonTapped(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.accessoryButtonTappedForRowWith) { closure($0.0, $0.0.itemValue) }
    }
    
    //Responding to Row Actions
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewLeadingSwipeActionsConfiguration(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UISwipeActionsConfiguration
    ) -> TableList<SourceBase> {
        set(\.leadingSwipeActionsConfigurationForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewTrailingSwipeActionsConfiguration(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UISwipeActionsConfiguration
    ) -> TableList<SourceBase> {
        set(\.trailingSwipeActionsConfigurationForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldShowMenuForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.shouldShowMenuForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewCanPerformActionWithSender(
        _ closure: @escaping (TableItemContext<SourceBase>, Selector, Any?, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.canPerformActionForRowAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewPerformActionWithSender(
        _ closure: @escaping (TableItemContext<SourceBase>, Selector, Any?, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.performActionForRowAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewEditActionsForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> [UITableViewRowAction]?
    ) -> TableList<SourceBase> {
        set(\.editActionsForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Managing Table View Highlights
    @discardableResult
    func tableViewShouldHighlight(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.shouldHighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidHighlight(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.didHighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidUnhighlight(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.didUnhighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Editing Table Rows
    @discardableResult
    func tableViewWillBeginEditing(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.willBeginEditingRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidEndEditing(
        _ closure: @escaping (TableContext<SourceBase>, IndexPath?) -> Void
    ) -> TableList<SourceBase> {
        set(\.didEndEditingRowAt) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func tableViewEditingStyle(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UITableViewCell.EditingStyle
    ) -> TableList<SourceBase> {
        set(\.editingStyleForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewTitleForDeleteConfirmationButton(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> String?
    ) -> TableList<SourceBase> {
        set(\.titleForDeleteConfirmationButtonForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldIndentWhileEditing(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.shouldIndentWhileEditingRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Reordering Table Rows
    @discardableResult
    func tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath(
        _ closure: @escaping (TableContext<SourceBase>, IndexPath, IndexPath) -> IndexPath
    ) -> TableList<SourceBase> {
        set(\.targetIndexPathForMoveFromRowAtToProposedIndexPath) { closure($0.0, $0.1.0, $0.1.1) }
    }
            
    //Tracking the Removal of Views
    @discardableResult
    func tableViewdidEndDisplayingForRowAt(
        _ closure: @escaping (TableContext<SourceBase>, UITableViewCell, IndexPath) -> Void
    ) -> TableList<SourceBase> {
        set(\.didEndDisplayingForRowAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewDidEndDisplayingHeaderView(
        _ closure: @escaping (TableContext<SourceBase>, UIView, Int) -> Void
    ) -> TableList<SourceBase> {
        set(\.didEndDisplayingHeaderViewForSection) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewDidEndDisplayingFooterView(
        _ closure: @escaping (TableContext<SourceBase>, UIView, Int) -> Void
    ) -> TableList<SourceBase> {
        set(\.didEndDisplayingFooterViewForSection) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Managing Table View Focus
    @discardableResult
    func tableViewCanFocusItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.canFocusRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldUpdateFocusIn(
        _ closure: @escaping (TableContext<SourceBase>, UITableViewFocusUpdateContext) -> Bool
    ) -> TableList<SourceBase> {
        set(\.shouldUpdateFocusIn) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func tableViewdidUpdateFocusInWith(
        _ closure: @escaping (TableContext<SourceBase>, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    ) -> TableList<SourceBase> {
        set(\.didUpdateFocusInWith) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewIndexPathForPreferredFocusedView(
        _ closure: @escaping (TableContext<SourceBase>) -> IndexPath?
    ) -> TableList<SourceBase> {
        set(\.indexPathForPreferredFocusedView) { closure($0.0) }
    }
    
    //Instance Methods
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewContextMenuConfigurationForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, CGPoint, Item) -> UIContextMenuConfiguration
    ) -> TableList<SourceBase> {
        set(\.contextMenuConfigurationForRowAtPoint) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewPreviewForDismissingContextMenuWithConfiguration(
        _ closure: @escaping (TableContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> TableList<SourceBase> {
        set(\.previewForDismissingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewPreviewForHighlightingContextMenuWithConfiguration(
        _ closure: @escaping (TableContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> TableList<SourceBase> {
        set(\.previewForHighlightingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func tableViewWillPerformPreviewActionForMenuWithAnimator(
        _ closure: @escaping (TableContext<SourceBase>, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    ) -> TableList<SourceBase> {
        set(\.willPerformPreviewActionForMenuWithAnimator) { closure($0.0, $0.1.0, $0.1.1) }
    }
}


#endif
