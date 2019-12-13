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
        toTableList().set(\.tableViewDataSources.cellForRowAt) {
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
        tableView.setupWith(coordinator: tableList.listCoordinator)
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
        set(\.tableViewDataSources.titleForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func provideTableViewFooterTitle(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> String?
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.titleForFooterInSection) { closure($0.0) }
    }
    
    //Inserting or Deleting Table Rows
    @discardableResult
    func tableViewCommitEdittingStyleForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, UITableViewCell.EditingStyle, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.commitForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewCanEditItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.canEditRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Reordering Table Rows
    @discardableResult
    func tableViewCanMoveItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.canMoveRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewMoveItem(
        _ closure: @escaping (TableContext<SourceBase>, IndexPath, IndexPath) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.moveRowAtTo) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Configuring an Index
    @discardableResult
    func tableViewSectionIndexTitles(
        _ closure: @escaping (TableContext<SourceBase>) -> [String]?
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.sectionIndexTitles) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewsectionForSectionIndexTitleAt(
        _ closure: @escaping (TableContext<SourceBase>, String, Int) -> Int
    ) -> TableList<SourceBase> {
        set(\.tableViewDataSources.sectionForSectionIndexTitleAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//TableView Delegate
public extension TableListAdapter {
    //Configuring Rows for the Table View
    @discardableResult
    func tableViewWillDisplayItem(
        _ closure: @escaping (TableItemContext<SourceBase>, UITableViewCell, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willDisplayForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewIndentationLevelForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Int
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.indentationLevelForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewShouldSpringLoadItem(
        _ closure: @escaping (TableItemContext<SourceBase>, UISpringLoadedInteractionContext, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.springLoadRowAtWith) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    //Responding to Row Selections
    @discardableResult
    func tableViewWillSelectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> IndexPath?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidSelectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewWillDeselectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> IndexPath?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willDeselectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidDeselectItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didDeselectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewShouldBeginMultipleSelectionInteraction(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.shouldBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewDidBeginMultipleSelectionInteraction(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewDidEndMultipleSelectionInteraction(
        _ closure: @escaping (TableContext<SourceBase>) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didEndMultipleSelectionInteraction) { closure($0.0) }
    }
    
    //Providing Custom Header and Footer Views
    @discardableResult
    func provideTableViewViewHeader(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> UIView?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.viewForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func provideTableViewViewFooter(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> UIView?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.viewForFooterInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewWillDisplayHeaderView(
        _ closure: @escaping (TableSectionContext<SourceBase>, UIView) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willDisplayHeaderViewForSection) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func tableViewWillDisplayFooterView(
        _ closure: @escaping (TableSectionContext<SourceBase>, UIView) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willDisplayFooterViewForSection) { closure($0.0, $0.1.0) }
    }
    
    //Providing Header, Footer, and Row Heights
    @discardableResult
    func tableViewHeightForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.heightForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewHeightForHeader(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.heightForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewHeightForFooter(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.heightForFooterInSection) { closure($0.0) }
    }
    
    //Estimating Heights for the Table's Content
    @discardableResult
    func tableViewEstimatedHeightForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.estimatedHeightForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewEstimatedHeightForHeader(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.estimatedHeightForHeaderInSection) { closure($0.0) }
    }
    
    @discardableResult
    func tableViewEstimatedHeightForFooter(
        _ closure: @escaping (TableSectionContext<SourceBase>) -> CGFloat
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.estimatedHeightForFooterInSection) { closure($0.0) }
    }
    
    //Managing Accessory Views
    @discardableResult
    func tableViewAccessoryButtonTapped(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.accessoryButtonTappedForRowWith) { closure($0.0, $0.0.itemValue) }
    }
    
    //Responding to Row Actions
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewLeadingSwipeActionsConfiguration(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UISwipeActionsConfiguration
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.leadingSwipeActionsConfigurationForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func tableViewTrailingSwipeActionsConfiguration(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UISwipeActionsConfiguration
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.trailingSwipeActionsConfigurationForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldShowMenuForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.shouldShowMenuForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewCanPerformActionWithSender(
        _ closure: @escaping (TableItemContext<SourceBase>, Selector, Any?, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.canPerformActionForRowAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewPerformActionWithSender(
        _ closure: @escaping (TableItemContext<SourceBase>, Selector, Any?, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.performActionForRowAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewEditActionsForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> [UITableViewRowAction]?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.editActionsForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Managing Table View Highlights
    @discardableResult
    func tableViewShouldHighlight(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.shouldHighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidHighlight(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didHighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidUnhighlight(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didUnhighlightRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Editing Table Rows
    @discardableResult
    func tableViewWillBeginEditing(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willBeginEditingRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewDidEndEditing(
        _ closure: @escaping (TableContext<SourceBase>, IndexPath?) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didEndEditingRowAt) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func tableViewEditingStyle(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> UITableViewCell.EditingStyle
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.editingStyleForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewTitleForDeleteConfirmationButton(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> String?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.titleForDeleteConfirmationButtonForRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldIndentWhileEditing(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.shouldIndentWhileEditingRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Reordering Table Rows
    @discardableResult
    func tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath(
        _ closure: @escaping (TableContext<SourceBase>, IndexPath, IndexPath) -> IndexPath
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.targetIndexPathForMoveFromRowAtToProposedIndexPath) { closure($0.0, $0.1.0, $0.1.1) }
    }
            
    //Tracking the Removal of Views
    @discardableResult
    func tableViewdidEndDisplayingForRowAt(
        _ closure: @escaping (TableContext<SourceBase>, UITableViewCell, IndexPath) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didEndDisplayingForRowAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewDidEndDisplayingHeaderView(
        _ closure: @escaping (TableContext<SourceBase>, UIView, Int) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didEndDisplayingHeaderViewForSection) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewDidEndDisplayingFooterView(
        _ closure: @escaping (TableContext<SourceBase>, UIView, Int) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didEndDisplayingFooterViewForSection) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Managing Table View Focus
    @discardableResult
    func tableViewCanFocusItem(
        _ closure: @escaping (TableItemContext<SourceBase>, Item) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.canFocusRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func tableViewShouldUpdateFocusIn(
        _ closure: @escaping (TableContext<SourceBase>, UITableViewFocusUpdateContext) -> Bool
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.shouldUpdateFocusIn) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func tableViewdidUpdateFocusInWith(
        _ closure: @escaping (TableContext<SourceBase>, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.didUpdateFocusInWith) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func tableViewIndexPathForPreferredFocusedView(
        _ closure: @escaping (TableContext<SourceBase>) -> IndexPath?
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.indexPathForPreferredFocusedView) { closure($0.0) }
    }
    
    //Instance Methods
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewContextMenuConfigurationForItem(
        _ closure: @escaping (TableItemContext<SourceBase>, CGPoint, Item) -> UIContextMenuConfiguration
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.contextMenuConfigurationForRowAtPoint) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewPreviewForDismissingContextMenuWithConfiguration(
        _ closure: @escaping (TableContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.previewForDismissingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func tableViewPreviewForHighlightingContextMenuWithConfiguration(
        _ closure: @escaping (TableContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.previewForHighlightingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }

    @available(iOS 13.0, *)
    @discardableResult
    func tableViewWillPerformPreviewActionForMenuWithAnimator(
        _ closure: @escaping (TableContext<SourceBase>, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    ) -> TableList<SourceBase> {
        set(\.tableViewDelegates.willPerformPreviewActionForMenuWithAnimator) { closure($0.0, $0.1.0, $0.1.1) }
    }
}


#endif
