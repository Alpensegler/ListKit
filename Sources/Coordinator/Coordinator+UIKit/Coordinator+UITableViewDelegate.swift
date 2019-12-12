//
//  Coordinator+UITableViewDelegate.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

class UITableViewDelegates {
    typealias Delegate<Input, Output> = ListKit.Delegate<UITableView, Input, Output>
    
    //Configuring Rows for the Table View
    var willDisplayForRowAt = Delegate<(UITableViewCell, IndexPath), Void>(
        index: .indexPath(\.1),
        #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))
    )
    
    var indentationLevelForRowAt = Delegate<IndexPath, Int>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:))
    )
    
    private var anyShouldSpringLoadRowAtWith: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool>(
            index: .indexPath(\.0),
            #selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:))
        )
    }()
    
    @available(iOS 11.0, *)
    var springLoadRowAtWith: Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool> {
        get { anyShouldSpringLoadRowAtWith as! Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool> }
        set { anyShouldSpringLoadRowAtWith = newValue }
    }

    //Responding to Row Selections
    var willSelectRowAt = Delegate<IndexPath, IndexPath?>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:willSelectRowAt:))
    )
    
    var didSelectRowAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))
    )
    
    var willDeselectRowAt = Delegate<IndexPath, IndexPath?>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:))
    )
    
    var didDeselectRowAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:))
    )
    
    private var anyShouldBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<IndexPath, Bool>(
            index: .indexPath(\.self),
            #selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    private var anyDidBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<IndexPath, Void>(
            index: .indexPath(\.self),
            #selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:))
        )
    }()
    
    private var anyDidEndMultipleSelectionInteraction: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<Void, Void>(
            #selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    @available(iOS 13.0, *)
    var shouldBeginMultipleSelectionInteractionAt: Delegate<IndexPath, Bool> {
        get { anyShouldBeginMultipleSelectionInteractionAt as! Delegate<IndexPath, Bool> }
        set { anyShouldBeginMultipleSelectionInteractionAt = newValue }
    }
    
    @available(iOS 13.0, *)
    var didBeginMultipleSelectionInteractionAt: Delegate<IndexPath, Void> {
        get { anyDidBeginMultipleSelectionInteractionAt as! Delegate<IndexPath, Void> }
        set { anyDidBeginMultipleSelectionInteractionAt = newValue }
    }
    
    @available(iOS 13.0, *)
    var didEndMultipleSelectionInteraction: Delegate<Void, Void> {
        get { anyDidEndMultipleSelectionInteraction as! Delegate<Void, Void> }
        set { anyDidEndMultipleSelectionInteraction = newValue }
    }

    //Providing Custom Header and Footer Views
    var viewForHeaderInSection = Delegate<Int, UIView?>(
        index: .index(\.self),
        #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))
    )
    
    var viewForFooterInSection = Delegate<Int, UIView?>(
        index: .index(\.self),
        #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:))
    )
    
    var willDisplayHeaderViewForSection = Delegate<(UIView, Int), Void>(
        index: .index(\.1),
        #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:))
    )
    
    var willDisplayFooterViewForSection = Delegate<(UIView, Int), Void>(
        index: .index(\.1),
        #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:))
    )
    
    //Providing Header, Footer, and Row Heights
    var heightForRowAt = Delegate<IndexPath, CGFloat>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:heightForRowAt:))
    )
    
    var heightForHeaderInSection = Delegate<Int, CGFloat>(
        index: .index(\.self),
        #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:))
    )
    
    var heightForFooterInSection = Delegate<Int, CGFloat>(
        index: .index(\.self),
        #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:))
    )

    //Estimating Heights for the Table's Content
    var estimatedHeightForRowAt = Delegate<IndexPath, CGFloat>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:))
    )
    
    var estimatedHeightForHeaderInSection = Delegate<Int, CGFloat>(
        index: .index(\.self),
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:))
    )
    
    var estimatedHeightForFooterInSection = Delegate<Int, CGFloat>(
        index: .index(\.self),
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:))
    )
    
    //Managing Accessory Views
    var accessoryButtonTappedForRowWith = Delegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:))
    )

    //Responding to Row Actions
    var anyLeadingSwipeActionsConfigurationForRowAt: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<IndexPath, UISwipeActionsConfiguration?>(
            index: .indexPath(\.self),
            #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:))
        )
    }()
    
    var anyTrailingSwipeActionsConfigurationForRowAt: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<IndexPath, UISwipeActionsConfiguration?>(
            index: .indexPath(\.self),
            #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:))
        )
         
    }()
    
    @available(iOS 11.0, *)
    var leadingSwipeActionsConfigurationForRowAt: Delegate<IndexPath, UISwipeActionsConfiguration?> {
        get { anyLeadingSwipeActionsConfigurationForRowAt as! Delegate<IndexPath, UISwipeActionsConfiguration?> }
        set { anyLeadingSwipeActionsConfigurationForRowAt = newValue }
    }
    
    @available(iOS 11.0, *)
    var trailingSwipeActionsConfigurationForRowAt: Delegate<IndexPath, UISwipeActionsConfiguration?> {
        get { anyTrailingSwipeActionsConfigurationForRowAt as! Delegate<IndexPath, UISwipeActionsConfiguration?> }
        set { anyTrailingSwipeActionsConfigurationForRowAt = newValue }
    }
    
    var shouldShowMenuForRowAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:))
    )
    
    var canPerformActionForRowAtWithSender = Delegate<(Selector, IndexPath, Any?), Bool>(
        index: .indexPath(\.1),
        #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:))
    )
    
    var performActionForRowAtWithSender = Delegate<(Selector, IndexPath, Any?), Void>(
        index: .indexPath(\.1),
        #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:))
    )
    
    var editActionsForRowAt = Delegate<IndexPath, [UITableViewRowAction]?>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:))
    )
    
    //Managing Table View Highlights
    var shouldHighlightRowAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:))
    )
    
    var didHighlightRowAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:))
    )
    
    var didUnhighlightRowAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:))
    )

    //Editing Table Rows
    var willBeginEditingRowAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:))
    )
    
    var didEndEditingRowAt = Delegate<(IndexPath?), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:))
    )
    
    var editingStyleForRowAt = Delegate<IndexPath, UITableViewCell.EditingStyle>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:))
    )
    
    var titleForDeleteConfirmationButtonForRowAt = Delegate<IndexPath, String?>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:))
    )
    
    var shouldIndentWhileEditingRowAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:))
    )

    //Reordering Table Rows
    var targetIndexPathForMoveFromRowAtToProposedIndexPath = Delegate<(IndexPath, IndexPath), IndexPath>(
        #selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:))
    )

    //Tracking the Removal of Views
    var didEndDisplayingForRowAt = Delegate<(UITableViewCell, IndexPath), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))
    )
    
    var didEndDisplayingHeaderViewForSection = Delegate<(UIView, Int), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:))
    )
    
    var didEndDisplayingFooterViewForSection = Delegate<(UIView, Int), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:))
    )
    
    //Managing Table View Focus
    var canFocusRowAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UITableViewDelegate.tableView(_:canFocusRowAt:))
    )
    
    var shouldUpdateFocusIn = Delegate<UITableViewFocusUpdateContext, Bool>(
        #selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:))
    )
    
    var didUpdateFocusInWith = Delegate<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void>(
        #selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:))
    )
    
    var indexPathForPreferredFocusedView = Delegate<Void, IndexPath?>(
        #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:))
    )
    
    //Instance Methods
    
    private var anyContextMenuConfigurationForRowAtPoint: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration>(
            index: .indexPath(\.0),
            #selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:))
        )
         
    }()
    
    private var anyPreviewForDismissingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:))
        )
    }()
    
    private var anyTableViewPreviewForHighlightingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:))
        )
    }()
    
    private var anyTableViewWillPerformPreviewActionForMenuWithAnimator: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void>(
            #selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:))
        )
    }()
    
    
    @available(iOS 13.0, *)
    var contextMenuConfigurationForRowAtPoint: Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration> {
        get { anyContextMenuConfigurationForRowAtPoint as! Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration> }
        set { anyContextMenuConfigurationForRowAtPoint = newValue }
    }
    
    @available(iOS 13.0, *)
    var previewForDismissingContextMenuWithConfiguration: Delegate<UIContextMenuConfiguration, UITargetedPreview> {
        get { anyPreviewForDismissingContextMenuWithConfiguration as! Delegate<UIContextMenuConfiguration, UITargetedPreview> }
        set { anyPreviewForDismissingContextMenuWithConfiguration = newValue }
    }
    
    @available(iOS 13.0, *)
    var previewForHighlightingContextMenuWithConfiguration: Delegate<UIContextMenuConfiguration, UITargetedPreview> {
        get { anyTableViewPreviewForHighlightingContextMenuWithConfiguration as! Delegate<UIContextMenuConfiguration, UITargetedPreview> }
        set { anyTableViewPreviewForHighlightingContextMenuWithConfiguration = newValue }
    }
    
    @available(iOS 13.0, *)
    var willPerformPreviewActionForMenuWithAnimator: Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void> {
        get { anyTableViewWillPerformPreviewActionForMenuWithAnimator as! Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void> }
        set { anyTableViewWillPerformPreviewActionForMenuWithAnimator = newValue }
    }
    
    func add(by selectorSets: inout SelectorSets) {
        //Configuring Rows for the Table View
        selectorSets.add(willDisplayForRowAt)
        selectorSets.add(indentationLevelForRowAt)
        if #available(iOS 11.0, *) {
            selectorSets.add(springLoadRowAtWith)
        }
        
        //Responding to Row Selections
        selectorSets.add(willSelectRowAt)
        selectorSets.add(didSelectRowAt)
        selectorSets.add(willDeselectRowAt)
        selectorSets.add(didDeselectRowAt)
        if #available(iOS 13.0, *) {
            selectorSets.add(shouldBeginMultipleSelectionInteractionAt)
            selectorSets.add(didEndMultipleSelectionInteraction)
            selectorSets.add(didBeginMultipleSelectionInteractionAt)
        }
        
        //Providing Custom Header and Footer Views
        selectorSets.add(viewForHeaderInSection)
        selectorSets.add(viewForFooterInSection)
        selectorSets.add(willDisplayHeaderViewForSection)
        selectorSets.add(willDisplayFooterViewForSection)
        
        //Providing Header, Footer, and Row Heights
        selectorSets.add(heightForRowAt)
        selectorSets.add(heightForHeaderInSection)
        selectorSets.add(heightForFooterInSection)
        
        //Estimating Heights for the Table's Content
        selectorSets.add(estimatedHeightForRowAt)
        selectorSets.add(estimatedHeightForHeaderInSection)
        selectorSets.add(estimatedHeightForFooterInSection)
        
        //Managing Accessory Views
        selectorSets.add(accessoryButtonTappedForRowWith)
        
        //Responding to Row Actions
        if #available(iOS 11.0, *) {
            selectorSets.add(leadingSwipeActionsConfigurationForRowAt)
            selectorSets.add(trailingSwipeActionsConfigurationForRowAt)
        }
        selectorSets.add(shouldShowMenuForRowAt)
        selectorSets.add(canPerformActionForRowAtWithSender)
        selectorSets.add(performActionForRowAtWithSender)
        selectorSets.add(editActionsForRowAt)
        
        //Managing Table View Highlights
        selectorSets.add(shouldHighlightRowAt)
        selectorSets.add(didHighlightRowAt)
        selectorSets.add(didUnhighlightRowAt)
        
        //Editing Table Rows
        selectorSets.add(willBeginEditingRowAt)
        selectorSets.add(didEndEditingRowAt)
        selectorSets.add(editingStyleForRowAt)
        selectorSets.add(titleForDeleteConfirmationButtonForRowAt)
        selectorSets.add(shouldIndentWhileEditingRowAt)
        
        //Reordering Table Rows
        selectorSets.add(targetIndexPathForMoveFromRowAtToProposedIndexPath)
        
        //Tracking the Removal of Views
        selectorSets.add(didEndDisplayingForRowAt)
        selectorSets.add(didEndDisplayingHeaderViewForSection)
        selectorSets.add(didEndDisplayingFooterViewForSection)
        
        //Managing Table View Focus
        selectorSets.add(canFocusRowAt)
        selectorSets.add(shouldUpdateFocusIn)
        selectorSets.add(didUpdateFocusInWith)
        selectorSets.add(indexPathForPreferredFocusedView)
        
        //Instance Methods
        if #available(iOS 13.0, *) {
            selectorSets.add(contextMenuConfigurationForRowAtPoint)
            selectorSets.add(previewForDismissingContextMenuWithConfiguration)
            selectorSets.add(previewForHighlightingContextMenuWithConfiguration)
            selectorSets.add(willPerformPreviewActionForMenuWithAnimator)
        }
    }
}

extension BaseCoordinator: UITableViewDelegate { }

public extension BaseCoordinator {
    //Configuring Rows for the Table View
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.willDisplayForRowAt, object: tableView, with: (cell, indexPath))
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        apply(\.tableViewDelegates.indentationLevelForRowAt, object: tableView, with: indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(\.tableViewDelegates.springLoadRowAtWith, object: tableView, with: (indexPath, context))
    }

    //Responding to Row Selections
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(\.tableViewDelegates.willSelectRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.didSelectRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(\.tableViewDelegates.willDeselectRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.didDeselectRowAt, object: tableView, with: indexPath)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDelegates.shouldBeginMultipleSelectionInteractionAt, object: tableView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.didBeginMultipleSelectionInteractionAt, object: tableView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        apply(\.tableViewDelegates.didEndMultipleSelectionInteraction, object: tableView)
    }
    
    //Providing Custom Header and Footer Views
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        apply(\.tableViewDelegates.viewForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        apply(\.tableViewDelegates.viewForFooterInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        apply(\.tableViewDelegates.willDisplayHeaderViewForSection, object: tableView, with: (view, section))
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        apply(\.tableViewDelegates.willDisplayFooterViewForSection, object: tableView, with: (view, section))
    }

    //Providing Header, Footer, and Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(\.tableViewDelegates.heightForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        apply(\.tableViewDelegates.heightForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        apply(\.tableViewDelegates.heightForFooterInSection, object: tableView, with: section)
    }

    //Estimating Heights for the Table's Content
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(\.tableViewDelegates.estimatedHeightForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        apply(\.tableViewDelegates.estimatedHeightForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        apply(\.tableViewDelegates.estimatedHeightForFooterInSection, object: tableView, with: section)
    }

    //Managing Accessory Views
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        apply(\.tableViewDelegates.accessoryButtonTappedForRowWith, object: tableView, with: indexPath)
    }

    //Responding to Row Actions
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        apply(\.tableViewDelegates.leadingSwipeActionsConfigurationForRowAt, object: tableView, with: indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        apply(\.tableViewDelegates.trailingSwipeActionsConfigurationForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDelegates.shouldShowMenuForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(\.tableViewDelegates.canPerformActionForRowAtWithSender, object: tableView, with: (action, indexPath, sender))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        apply(\.tableViewDelegates.performActionForRowAtWithSender, object: tableView, with: (action, indexPath, sender))
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        apply(\.tableViewDelegates.editActionsForRowAt, object: tableView, with: indexPath)
    }

    //Managing Table View Highlights
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDelegates.shouldHighlightRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.didHighlightRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.didUnhighlightRowAt, object: tableView, with: indexPath)
    }

    //Editing Table Rows

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.willBeginEditingRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        apply(\.tableViewDelegates.didEndEditingRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        apply(\.tableViewDelegates.editingStyleForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        apply(\.tableViewDelegates.titleForDeleteConfirmationButtonForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDelegates.shouldIndentWhileEditingRowAt, object: tableView, with: indexPath)
    }

    //Reordering Table Rows

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        apply(\.tableViewDelegates.targetIndexPathForMoveFromRowAtToProposedIndexPath, object: tableView, with: (sourceIndexPath, proposedDestinationIndexPath))
    }

    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(\.tableViewDelegates.didEndDisplayingForRowAt, object: tableView, with: (cell, indexPath))
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        apply(\.tableViewDelegates.didEndDisplayingHeaderViewForSection, object: tableView, with: (view, section))
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        apply(\.tableViewDelegates.didEndDisplayingFooterViewForSection, object: tableView, with: (view, section))
    }

    //Managing Table View Focus
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDelegates.canFocusRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        apply(\.tableViewDelegates.shouldUpdateFocusIn, object: tableView, with: context)
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(\.tableViewDelegates.didUpdateFocusInWith, object: tableView, with: (context, coordinator))
    }

    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        apply(\.tableViewDelegates.indexPathForPreferredFocusedView, object: tableView)
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(\.tableViewDelegates.contextMenuConfigurationForRowAtPoint, object: tableView, with: (indexPath, point))
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.tableViewDelegates.previewForDismissingContextMenuWithConfiguration, object: tableView, with: configuration)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.tableViewDelegates.previewForHighlightingContextMenuWithConfiguration, object: tableView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(\.tableViewDelegates.willPerformPreviewActionForMenuWithAnimator, object: tableView, with: (configuration, animator))
    }
}

#endif
