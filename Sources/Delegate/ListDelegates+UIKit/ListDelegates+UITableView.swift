//
//  ListDelegate+UITableViewSwift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

extension Delegate: UITableViewDataSource {
    //Providing the Number of Rows and Sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        context.numbersOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        context.numbersOfSections()
    }
    
    //Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        apply(tableViewCellForRow, object: tableView, with: indexPath) ?? .init()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        apply(tableViewHeaderTitleForSection, object: tableView, with: section) ?? nil
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        apply(tableViewFooterTitleForSection, object: tableView, with: section) ?? nil
    }

    //Inserting or DeletingTable Rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        apply(tableViewCommitEdittingStyleForRow, object: tableView, with: (indexPath, editingStyle))
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        apply(tableViewCanEditRow, object: tableView, with: indexPath) ?? true
    }
    
    //ReorderingTable Rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        apply(tableViewCanMoveRow, object: tableView, with: indexPath) ?? true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(tableViewMoveRow, object: tableView, with: (sourceIndexPath, destinationIndexPath))
    }

    //Configuring an Index
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        apply(tableViewSectionIndexTitles, object: (tableView)) ?? nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        apply(tableViewSectionForSectionIndexTitle, object: tableView, with: (title, index)) ?? index
    }
}

extension Delegate: UITableViewDelegate {
    //Configuring Rows for theTable View
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(tableViewWillDisplayRow, object: tableView, with: (indexPath, cell))
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        apply(tableViewIndentationLevelForRow, object: tableView, with: indexPath) ?? 0
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(tableViewShouldSpringLoadRow, object: tableView, with: (indexPath, context)) ?? true
    }

    //Responding to Row Selections
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(tableViewWillSelectRow, object: tableView, with: indexPath) ?? indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        apply(tableViewDidSelectRow, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(tableViewWillDeselectRow, object: tableView, with: indexPath) ?? indexPath
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        apply(tableViewDidDeselectRow, object: tableView, with: indexPath)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(tableViewShouldBeginMultipleSelectionInteraction, object: tableView, with: indexPath) ?? true
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(tableViewDidBeginMultipleSelectionInteraction, object: tableView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        apply(tableViewDidEndMultipleSelectionInteraction, object: tableView)
    }
    
    //Providing Custom Header and Footer Views
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        apply(tableViewViewHeaderForSection, object: tableView, with: section) ?? nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        apply(tableViewViewFooterForSection, object: tableView, with: section) ?? nil
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        apply(tableViewWillDisplayHeaderView, object: tableView, with: (section, view))
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        apply(tableViewWillDisplayFooterView, object: tableView, with: (section, view))
    }

    //Providing Header, Footer, and Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(tableViewHeightForRow, object: tableView, with: indexPath) ?? tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        apply(tableViewHeightForHeader, object: tableView, with: section) ?? tableView.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        apply(tableViewHeightForFooter, object: tableView, with: section) ?? tableView.sectionFooterHeight
    }

    //Estimating Heights for theTable's Content
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(tableViewEstimatedHeightForRow, object: tableView, with: indexPath) ?? tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        apply(tableViewEstimatedHeightForHeader, object: tableView, with: section) ?? tableView.estimatedSectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        apply(tableViewEstimatedHeightForFooter, object: tableView, with: section) ?? tableView.estimatedSectionFooterHeight
    }

    //Managing Accessory Views
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        apply(tableViewAccessoryButtonTapped, object: tableView, with: indexPath)
    }

    //Responding to Row Actions
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        apply(tableViewLeadingSwipeActionsConfiguration, object: tableView, with: indexPath) ?? nil
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        apply(tableViewTrailingSwipeActionsConfiguration, object: tableView, with: indexPath) ?? nil
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        apply(tableViewShouldShowMenuForRow, object: tableView, with: indexPath) ?? true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(tableViewCanPerformActionWithSender, object: tableView, with: (indexPath, action, sender)) ?? true
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        apply(tableViewPerformActionWithSender, object: tableView, with: (indexPath, action, sender))
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        apply(tableViewEditActionsForRow, object: tableView, with: indexPath) ?? nil
    }

    //ManagingTable View Highlights
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        apply(tableViewShouldHighlight, object: tableView, with: indexPath) ?? true
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        apply(tableViewDidHighlight, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        apply(tableViewDidUnhighlight, object: tableView, with: indexPath)
    }

    //EditingTable Rows

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        apply(tableViewWillBeginEditing, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        apply(tableViewDidEndEditing, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        apply(tableViewEditingStyle, object: tableView, with: indexPath) ?? .none
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        apply(tableViewTitleForDeleteConfirmationButton, object: tableView, with: indexPath) ?? nil
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        apply(tableViewShouldIndentWhileEditing, object: tableView, with: indexPath) ?? false
    }

    //ReorderingTable Rows

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        apply(tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath, object: tableView, with: (sourceIndexPath, proposedDestinationIndexPath)) ?? proposedDestinationIndexPath
    }

    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(tableViewdidEndDisplayingForRowAt, object: tableView, with: (cell, indexPath))
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        apply(tableViewDidEndDisplayingHeaderView, object: tableView, with: (view, section))
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        apply(tableViewDidEndDisplayingFooterView, object: tableView, with: (view, section))
    }

    //ManagingTable View Focus
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        apply(tableViewCanFocusRow, object: tableView, with: indexPath) ?? true
    }

    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        apply(tableViewShouldUpdateFocusIn, object: tableView, with: context) ?? true
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(tableViewDidUpdateFocusInWith, object: tableView, with: (context, coordinator))
    }

    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        apply(tableViewIndexPathForPreferredFocusedView, object: tableView) ?? nil
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(tableViewContextMenuConfigurationForRow, object: tableView, with: (indexPath, point))
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(tableViewPreviewForDismissingContextMenuWithConfiguration, object: tableView, with: configuration)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(tableViewPreviewForHighlightingContextMenuWithConfiguration, object: tableView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(tableViewWillPerformPreviewActionForMenuWithAnimator, object: tableView, with: (configuration, animator))
    }
}

#endif
