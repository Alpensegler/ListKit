//
//  TableViewDelegate.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/27.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class TableViewDelegateWrapper: ScrollViewDelegateWrapper, UITableViewDelegate {
    let tableViewWillDisplayForRowAtBlock: (UITableView, UITableViewCell, IndexPath) -> Void
    let tableViewWillDisplayHeaderViewForSectionBlock: (UITableView, UIView, Int) -> Void
    let tableViewWillDisplayFooterViewForSectionBlock: (UITableView, UIView, Int) -> Void
    let tableViewDidEndDisplayingForRowAtBlock: (UITableView, UITableViewCell, IndexPath) -> Void
    let tableViewDidEndDisplayingHeaderViewForSectionBlock: (UITableView, UIView, Int) -> Void
    let tableViewDidEndDisplayingFooterViewForSectionBlock: (UITableView, UIView, Int) -> Void
    let tableViewheightForRowAtBlock: (UITableView, IndexPath) -> CGFloat
    let tableViewheightForHeaderInSectionBlock: (UITableView, Int) -> CGFloat
    let tableViewheightForFooterInSectionBlock: (UITableView, Int) -> CGFloat
    let tableViewEstimatedHeightForRowAtBlock: (UITableView, IndexPath) -> CGFloat
    let tableViewEstimatedHeightForHeaderInSectionBlock: (UITableView, Int) -> CGFloat
    let tableViewEstimatedHeightForFooterInSectionBlock: (UITableView, Int) -> CGFloat
    let tableViewViewForHeaderInSectionBlock: (UITableView, Int) -> UIView?
    let tableViewViewForFooterInSectionBlock: (UITableView, Int) -> UIView?
    let tableViewAccessoryButtonTappedForRowWithBlock: (UITableView, IndexPath) -> Void
    let tableViewShouldHighlightRowAtBlock: (UITableView, IndexPath) -> Bool
    let tableViewDidHighlightRowAtBlock: (UITableView, IndexPath) -> Void
    let tableViewDidUnhighlightRowAtBlock: (UITableView, IndexPath) -> Void
    let tableViewWillSelectRowAtBlock: (UITableView, IndexPath) -> IndexPath?
    let tableViewWillDeselectRowAtBlock: (UITableView, IndexPath) -> IndexPath?
    let tableViewDidSelectRowAtBlock: (UITableView, IndexPath) -> Void
    let tableViewDidDeselectRowAtBlock: (UITableView, IndexPath) -> Void
    let tableViewEditingStyleForRowAtBlock: (UITableView, IndexPath) -> UITableViewCell.EditingStyle
    let tableViewTitleForDeleteConfirmationButtonForRowAtBlock: (UITableView, IndexPath) -> String?
    let tableViewEditActionsForRowAtBlock: (UITableView, IndexPath) -> [UITableViewRowAction]?
    let tableViewShouldIndentWhileEditingRowAtBlock: (UITableView, IndexPath) -> Bool
    let tableViewWillBeginEditingRowAtBlock: (UITableView, IndexPath) -> Void
    let tableViewDidEndEditingRowAtBlock: (UITableView, IndexPath?) -> Void
    let tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPathBlock: (UITableView, IndexPath, IndexPath) -> IndexPath
    let tableViewIndentationLevelForRowAtBlock: (UITableView, IndexPath) -> Int
    let tableViewShouldShowMenuForRowAtBlock: (UITableView, IndexPath) -> Bool
    let tableViewCanPerformActionForRowAtWithSenderBlock: (UITableView, Selector, IndexPath, Any?) -> Bool
    let tableViewPerformActionForRowAtWithSenderBlock: (UITableView, Selector, IndexPath, Any?) -> Void
    let tableViewCanFocusRowAtBlock: (UITableView, IndexPath) -> Bool
    let tableViewShouldUpdateFocusInBlock: (UITableView, UITableViewFocusUpdateContext) -> Bool
    let tableViewDidUpdateFocusInWithBlock: (UITableView, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    let indexPathForPreferredFocusedViewBlock: (UITableView) -> IndexPath?
    
    let tableViewLeadingSwipeActionsConfigurationForRowAt: Any?
    
    @available(iOS 11.0, *)
    var tableViewLeadingSwipeActionsConfigurationForRowAtBlock: ((UITableView, IndexPath) -> UISwipeActionsConfiguration?)? {
        return tableViewLeadingSwipeActionsConfigurationForRowAt as? (UITableView, IndexPath) -> UISwipeActionsConfiguration?
    }
    
    let tableViewTrailingSwipeActionsConfigurationForRowAt: Any?
    
    @available(iOS 11.0, *)
    var tableViewTrailingSwipeActionsConfigurationForRowAtBlock: ((UITableView, IndexPath) -> UISwipeActionsConfiguration?)? {
        return tableViewTrailingSwipeActionsConfigurationForRowAt as? (UITableView, IndexPath) -> UISwipeActionsConfiguration?
    }
    
    let tableViewShouldSpringLoadRowAtWith: Any?
    
    @available(iOS 11.0, *)
    var tableViewShouldSpringLoadRowAtWithBlock: ((UITableView, IndexPath, UISpringLoadedInteractionContext) -> Bool)? {
        return tableViewShouldSpringLoadRowAtWith as? (UITableView, IndexPath, UISpringLoadedInteractionContext) -> Bool
    }
    
    init(_ delegate: TableViewDelegate) {
        tableViewWillDisplayForRowAtBlock = { [unowned delegate] in delegate.tableView($0, willDisplay: $1, forRowAt: $2) }
        tableViewWillDisplayHeaderViewForSectionBlock = { [unowned delegate] in delegate.tableView($0, willDisplayHeaderView: $1, forSection: $2) }
        tableViewWillDisplayFooterViewForSectionBlock = { [unowned delegate] in delegate.tableView($0, willDisplayFooterView: $1, forSection: $2) }
        tableViewDidEndDisplayingForRowAtBlock = { [unowned delegate] in delegate.tableView($0, didEndDisplaying: $1, forRowAt: $2) }
        tableViewDidEndDisplayingHeaderViewForSectionBlock = { [unowned delegate] in delegate.tableView($0, didEndDisplayingHeaderView: $1, forSection: $2) }
        tableViewDidEndDisplayingFooterViewForSectionBlock = { [unowned delegate] in delegate.tableView($0, didEndDisplayingFooterView: $1, forSection: $2) }
        tableViewheightForRowAtBlock = { [unowned delegate] in delegate.tableView($0, heightForRowAt: $1) }
        tableViewheightForHeaderInSectionBlock = { [unowned delegate] in delegate.tableView($0, heightForHeaderInSection: $1) }
        tableViewheightForFooterInSectionBlock = { [unowned delegate] in delegate.tableView($0, heightForFooterInSection: $1) }
        tableViewEstimatedHeightForRowAtBlock = { [unowned delegate] in delegate.tableView($0, estimatedHeightForRowAt: $1) }
        tableViewEstimatedHeightForHeaderInSectionBlock = { [unowned delegate] in delegate.tableView($0, estimatedHeightForHeaderInSection: $1) }
        tableViewEstimatedHeightForFooterInSectionBlock = { [unowned delegate] in delegate.tableView($0, estimatedHeightForFooterInSection: $1) }
        tableViewViewForHeaderInSectionBlock = { [unowned delegate] in delegate.tableView($0, viewForHeaderInSection: $1) }
        tableViewViewForFooterInSectionBlock = { [unowned delegate] in delegate.tableView($0, viewForFooterInSection: $1) }
        tableViewAccessoryButtonTappedForRowWithBlock = { [unowned delegate] in delegate.tableView($0, accessoryButtonTappedForRowWith: $1) }
        tableViewShouldHighlightRowAtBlock = { [unowned delegate] in delegate.tableView($0, shouldHighlightRowAt: $1) }
        tableViewDidHighlightRowAtBlock = { [unowned delegate] in delegate.tableView($0, didHighlightRowAt: $1) }
        tableViewDidUnhighlightRowAtBlock = { [unowned delegate] in delegate.tableView($0, didUnhighlightRowAt: $1) }
        tableViewWillSelectRowAtBlock = { [unowned delegate] in delegate.tableView($0, willSelectRowAt: $1) }
        tableViewWillDeselectRowAtBlock = { [unowned delegate] in delegate.tableView($0, willDeselectRowAt: $1) }
        tableViewDidSelectRowAtBlock = { [unowned delegate] in delegate.tableView($0, didSelectRowAt: $1) }
        tableViewDidDeselectRowAtBlock = { [unowned delegate] in delegate.tableView($0, didDeselectRowAt: $1) }
        tableViewEditingStyleForRowAtBlock = { [unowned delegate] in delegate.tableView($0, editingStyleForRowAt: $1) }
        tableViewTitleForDeleteConfirmationButtonForRowAtBlock = { [unowned delegate] in delegate.tableView($0, titleForDeleteConfirmationButtonForRowAt: $1) }
        tableViewEditActionsForRowAtBlock = { [unowned delegate] in delegate.tableView($0, editActionsForRowAt: $1) }
        tableViewShouldIndentWhileEditingRowAtBlock = { [unowned delegate] in delegate.tableView($0, shouldIndentWhileEditingRowAt: $1) }
        tableViewWillBeginEditingRowAtBlock = { [unowned delegate] in delegate.tableView($0, willBeginEditingRowAt: $1) }
        tableViewDidEndEditingRowAtBlock = { [unowned delegate] in delegate.tableView($0, didEndEditingRowAt: $1) }
        tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPathBlock = { [unowned delegate] in delegate.tableView($0, targetIndexPathForMoveFromRowAt: $1, toProposedIndexPath: $2) }
        tableViewIndentationLevelForRowAtBlock = { [unowned delegate] in delegate.tableView($0, indentationLevelForRowAt: $1) }
        tableViewShouldShowMenuForRowAtBlock = { [unowned delegate] in delegate.tableView($0, shouldShowMenuForRowAt: $1) }
        tableViewCanPerformActionForRowAtWithSenderBlock = { [unowned delegate] in delegate.tableView($0, canPerformAction: $1, forRowAt: $2, withSender: $3) }
        tableViewPerformActionForRowAtWithSenderBlock = { [unowned delegate] in delegate.tableView($0, performAction: $1, forRowAt: $2, withSender: $3) }
        tableViewCanFocusRowAtBlock = { [unowned delegate] in delegate.tableView($0, canFocusRowAt: $1) }
        tableViewShouldUpdateFocusInBlock = { [unowned delegate] in delegate.tableView($0, shouldUpdateFocusIn: $1) }
        tableViewDidUpdateFocusInWithBlock = { [unowned delegate] in delegate.tableView($0, didUpdateFocusIn: $1, with: $2) }
        indexPathForPreferredFocusedViewBlock = { [unowned delegate] in delegate.indexPathForPreferredFocusedView(in: $0) }
        if #available(iOS 11.0, *) {
            tableViewLeadingSwipeActionsConfigurationForRowAt = { [unowned delegate] in delegate.tableView($0, leadingSwipeActionsConfigurationForRowAt: $1) }
        } else {
            tableViewLeadingSwipeActionsConfigurationForRowAt = nil
        }
        if #available(iOS 11.0, *) {
            tableViewTrailingSwipeActionsConfigurationForRowAt = { [unowned delegate] in delegate.tableView($0, trailingSwipeActionsConfigurationForRowAt: $1) }
        } else {
            tableViewTrailingSwipeActionsConfigurationForRowAt = nil
        }
        if #available(iOS 11.0, *) {
            tableViewShouldSpringLoadRowAtWith = { [unowned delegate] in delegate.tableView($0, shouldSpringLoadRowAt: $1, with: $2) }
        } else {
            tableViewShouldSpringLoadRowAtWith = nil
        }
        super.init(delegate)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewWillDisplayForRowAtBlock(tableView, cell, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableViewWillDisplayHeaderViewForSectionBlock(tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tableViewWillDisplayFooterViewForSectionBlock(tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewDidEndDisplayingForRowAtBlock(tableView, cell, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tableViewDidEndDisplayingHeaderViewForSectionBlock(tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tableViewDidEndDisplayingFooterViewForSectionBlock(tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewheightForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewheightForHeaderInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableViewheightForFooterInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewEstimatedHeightForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableViewEstimatedHeightForHeaderInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableViewEstimatedHeightForFooterInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewViewForHeaderInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableViewViewForFooterInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableViewAccessoryButtonTappedForRowWithBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return tableViewShouldHighlightRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableViewDidHighlightRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableViewDidUnhighlightRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableViewWillSelectRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableViewWillDeselectRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDidSelectRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableViewDidDeselectRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableViewEditingStyleForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return tableViewTitleForDeleteConfirmationButtonForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return tableViewEditActionsForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return tableViewShouldIndentWhileEditingRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableViewWillBeginEditingRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableViewDidEndEditingRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPathBlock(tableView, sourceIndexPath, proposedDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return tableViewIndentationLevelForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return tableViewShouldShowMenuForRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return tableViewCanPerformActionForRowAtWithSenderBlock(tableView, action, indexPath, sender)
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        tableViewPerformActionForRowAtWithSenderBlock(tableView, action, indexPath, sender)
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return tableViewCanFocusRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return tableViewShouldUpdateFocusInBlock(tableView, context)
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        tableViewDidUpdateFocusInWithBlock(tableView, context, coordinator)
    }
    
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return indexPathForPreferredFocusedViewBlock(tableView)
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableViewLeadingSwipeActionsConfigurationForRowAtBlock?(tableView, indexPath)
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableViewTrailingSwipeActionsConfigurationForRowAtBlock?(tableView, indexPath)
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return tableViewShouldSpringLoadRowAtWithBlock?(tableView, indexPath, context) ?? true
    }
}

public protocol TableViewDelegate: ScrollViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
}

private var tableViewDelegateKey: Void?

public extension TableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) { }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return tableView.rowHeight }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return tableView.sectionHeaderHeight }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return tableView.sectionFooterHeight }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return tableView.estimatedRowHeight }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return tableView.estimatedSectionHeaderHeight }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat { return tableView.estimatedSectionFooterHeight }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return true }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return tableView.cellForRow(at: indexPath)?.editingStyle ?? .none }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return nil }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { return nil }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return true }
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) { }
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath { return proposedDestinationIndexPath }
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int { return 0 }
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool { return false }
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool { return false }
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) { }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool { return true }
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool { return false }
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) { }
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? { return nil }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool { return true }
    
    var asTableViewDelegate: UITableViewDelegate {
        return Associator.getValue(key: &tableViewDelegateKey, from: self, initialValue: TableViewDelegateWrapper(self))
    }
    
    var asScrollViewDelegate: UIScrollViewDelegate {
        return asTableViewDelegate
    }
}
