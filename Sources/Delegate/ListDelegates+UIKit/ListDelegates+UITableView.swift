//
//  ListDelegate+UITableViewSwift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if !os(macOS)
import UIKit

extension Delegate: UITableViewDataSource {
    // MARK: - Providing the Number of Rows and Sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfItemsInSection(section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        numbersOfSections()
    }

    // MARK: - Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        apply(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: .init())
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        apply(#selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)), view: tableView, with: section, index: section, default: nil)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        apply(#selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)), view: tableView, with: section, index: section, default: nil)
    }

//    // MARK: - Inserting or DeletingTable Rows
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        apply(#selector(UITableViewDataSource.tableView(_:commit:forRowAt:)), view: tableView, with: (indexPath, editingStyle), index: indexPath, default: ())
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        apply(#selector(UITableViewDataSource.tableView(_:canEditRowAt:)), view: tableView, with: indexPath, index: indexPath, default: true)
//    }
//
//    // MARK: - ReorderingTable Rows
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        apply(#selector(UITableViewDataSource.tableView(_:canMoveRowAt:)), view: tableView, with: indexPath, index: indexPath, default: true)
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        apply(#selector(UITableViewDataSource.tableView(_:moveRowAt:to:)), view: tableView, with: (sourceIndexPath, destinationIndexPath), default: ())
//    }
//
//    // MARK: - Configuring an Index
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        apply(#selector(UITableViewDataSource.sectionIndexTitles(for:)), view: (tableView), default: nil)
//    }
//
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        apply(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)), view: tableView, with: (title, index), index: index, default: index)
//    }
}

extension Delegate: UITableViewDelegate {
    // MARK: - Configuring Rows for theTable View
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), view: tableView, with: (indexPath, cell), index: indexPath, default: ())
    }

//    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
//        apply(#selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: 0)
//    }
//
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)), view: tableView, with: (indexPath, context), index: indexPath, default: true)
//    }

    // MARK: - Responding to Row Selections
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(#selector(UITableViewDelegate.tableView(_:willSelectRowAt:)), view: tableView, with: indexPath, index: indexPath, default: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        apply(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), view: tableView, with: indexPath, index: indexPath, default: ())
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(#selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)), view: tableView, with: indexPath, index: indexPath, default: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        apply(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)), view: tableView, with: indexPath, index: indexPath, default: ())
    }

//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)), view: tableView, with: indexPath, index: indexPath, default: true)
//    }
//
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
//        apply(#selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)), view: tableView, with: indexPath, index: indexPath, default: ())
//    }
//
//    @available(iOS 13.0, *)
//    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
//        apply(#selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)), view: tableView, default: ())
//    }

    // MARK: - Providing Custom Header and Footer Views
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        apply(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)), view: tableView, with: section, index: section, default: nil)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        apply(#selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)), view: tableView, with: section, index: section, default: nil)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        apply(#selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)), view: tableView, with: (section, view), index: section, default: ())
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        apply(#selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)), view: tableView, with: (section, view), index: section, default: ())
    }

    // MARK: - Providing Header, Footer, and Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(#selector(UITableViewDelegate.tableView(_:heightForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: tableView.rowHeight)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        apply(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)), view: tableView, with: section, index: section, default: tableView.sectionHeaderHeight)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        apply(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)), view: tableView, with: section, index: section, default: tableView.sectionFooterHeight)
    }

    // MARK: - Estimating Heights for theTable's Content
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(#selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: tableView.estimatedRowHeight)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        apply(#selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)), view: tableView, with: section, index: section, default: tableView.estimatedSectionHeaderHeight)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        apply(#selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)), view: tableView, with: section, index: section, default: tableView.estimatedSectionFooterHeight)
    }

//    // MARK: - Managing Accessory Views
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        apply(#selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)), view: tableView, with: indexPath, index: indexPath, default: ())
//    }
//
//    // MARK: - Responding to Row Actions
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        apply(#selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: nil)
//    }
//
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        apply(#selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: nil)
//    }
//
//    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: true)
//    }
//
//    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)), view: tableView, with: (indexPath, action, sender), index: indexPath, default: true)
//    }
//
//    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
//        apply(#selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)), view: tableView, with: (indexPath, action, sender), index: indexPath, default: ())
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        apply(#selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: nil)
//    }

    // MARK: - ManagingTable View Highlights

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        apply(#selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), view: tableView, with: indexPath, index: indexPath, default: true)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        apply(#selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)), view: tableView, with: indexPath, index: indexPath, default: ())
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        apply(#selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)), view: tableView, with: indexPath, index: indexPath, default: ())
    }

//    // MARK: - EditingTable Rows
//
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        apply(#selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)), view: tableView, with: indexPath, index: indexPath, default: ())
//    }
//
//    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
//        apply(#selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)), view: tableView, with: indexPath, default: ())
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        apply(#selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: .none)
//    }
//
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        apply(#selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)), view: tableView, with: indexPath, index: indexPath, default: nil)
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)), view: tableView, with: indexPath, index: indexPath, default: false)
//    }
//
//    // MARK: - ReorderingTable Rows
//
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        apply(#selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)), view: tableView, with: (sourceIndexPath, proposedDestinationIndexPath), default: proposedDestinationIndexPath)
//    }

    // MARK: - Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)), view: tableView, with: (cell, indexPath), default: ())
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        apply(#selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)), view: tableView, with: (view, section), default: ())
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        apply(#selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)), view: tableView, with: (view, section), default: ())
    }

//    // MARK: - ManagingTable View Focus
//    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:canFocusRowAt:)), view: tableView, with: indexPath, index: indexPath, default: true)
//    }
//
//    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
//        apply(#selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)), view: tableView, with: context, default: true)
//    }
//
//    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        apply(#selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)), view: tableView, with: (context, coordinator), default: ())
//    }
//
//    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
//        apply(#selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)), view: tableView, default: nil)
//    }
//
//    // MARK: - Instance Methods
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        apply(#selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)), view: tableView, with: (indexPath, point), index: indexPath, default: nil)
//    }
//
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        apply(#selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)), view: tableView, with: configuration, default: nil)
//    }
//
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        apply(#selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)), view: tableView, with: (configuration), default: nil)
//    }
//
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//        apply(#selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:)), view: tableView, with: (configuration, animator), default: ())
//    }
}

#endif
