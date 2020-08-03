//
//  ListDelegate+UITableView.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

final class UITableListDelegate {
    typealias Delegate<Input, Output, Index> = ListKit.Delegate<UITableView, Input, Output, Index>
    
    //MARK: - DataSource
    
    //Providing Cells, Headers, and Footers
    var cellForRowAt = Delegate<IndexPath, UITableViewCell, IndexPath>(
        index: \.self,
        #selector(UITableViewDataSource.tableView(_:cellForRowAt:))
    )
    
    var titleForHeaderInSection = Delegate<Int, String?, Int>(
        index: \.self,
        #selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:))
    )
    
    var titleForFooterInSection = Delegate<Int, String?, Int>(
        index: \.self,
        #selector(UITableViewDataSource.tableView(_:titleForFooterInSection:))
    )
    
    //Inserting or Deleting Table Rows
    var commitForRowAt = Delegate<(UITableViewCell.EditingStyle, IndexPath), Void, IndexPath>(
        index: \.1,
        #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))
    )
    
    var canEditRowAt = Delegate<IndexPath, Bool, IndexPath>(
        index: \.self,
        #selector(UITableViewDataSource.tableView(_:canEditRowAt:))
    )
    
    //Reordering Table Rows
    var canMoveRowAt = Delegate<IndexPath, Bool, IndexPath>(
        index: \.self,
        #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))
    )
    
    var moveRowAtTo = Delegate<(IndexPath, IndexPath), Void, Void>(
        #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))
    )

    //Configuring an Index
    var sectionIndexTitles = Delegate<Void, [String]?, Void>(
        #selector(UITableViewDataSource.sectionIndexTitles(for:))
    )
    
    var sectionForSectionIndexTitleAt = Delegate<(String, Int), Int, Void>(
        #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:))
    )
    
    //MARK: - Delegate
    
    //Configuring Rows for the Table View
    var willDisplayForRowAt = Delegate<(UITableViewCell, IndexPath), Void, IndexPath>(
        index: \.1,
        #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))
    )
    
    var indentationLevelForRowAt = Delegate<IndexPath, Int, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:))
    )
    
    private var anyShouldSpringLoadRowAtWith: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool, IndexPath>(
            index: \.0,
            #selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:))
        )
    }()
    
    @available(iOS 11.0, *)
    var springLoadRowAtWith: Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool, IndexPath> {
        get { anyShouldSpringLoadRowAtWith as! Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool, IndexPath> }
        set { anyShouldSpringLoadRowAtWith = newValue }
    }

    //Responding to Row Selections
    var willSelectRowAt = Delegate<IndexPath, IndexPath?, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:willSelectRowAt:))
    )
    
    var didSelectRowAt = Delegate<IndexPath, Void, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))
    )
    
    var willDeselectRowAt = Delegate<IndexPath, IndexPath?, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:))
    )
    
    var didDeselectRowAt = Delegate<IndexPath, Void, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:))
    )
    
    private var anyShouldBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<IndexPath, Bool, IndexPath>(
            index: \.self,
            #selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    private var anyDidBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<IndexPath, Void, IndexPath>(
            index: \.self,
            #selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:))
        )
    }()
    
    private var anyDidEndMultipleSelectionInteraction: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<Void, Void, Void>(
            #selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    @available(iOS 13.0, *)
    var shouldBeginMultipleSelectionInteractionAt: Delegate<IndexPath, Bool, IndexPath> {
        get { anyShouldBeginMultipleSelectionInteractionAt as! Delegate<IndexPath, Bool, IndexPath> }
        set { anyShouldBeginMultipleSelectionInteractionAt = newValue }
    }
    
    @available(iOS 13.0, *)
    var didBeginMultipleSelectionInteractionAt: Delegate<IndexPath, Void, IndexPath> {
        get { anyDidBeginMultipleSelectionInteractionAt as! Delegate<IndexPath, Void, IndexPath> }
        set { anyDidBeginMultipleSelectionInteractionAt = newValue }
    }
    
    @available(iOS 13.0, *)
    var didEndMultipleSelectionInteraction: Delegate<Void, Void, Void> {
        get { anyDidEndMultipleSelectionInteraction as! Delegate<Void, Void, Void> }
        set { anyDidEndMultipleSelectionInteraction = newValue }
    }

    //Providing Custom Header and Footer Views
    var viewForHeaderInSection = Delegate<Int, UIView?, Int>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))
    )
    
    var viewForFooterInSection = Delegate<Int, UIView?, Int>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:))
    )
    
    var willDisplayHeaderViewForSection = Delegate<(UIView, Int), Void, Int>(
        index: \.1,
        #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:))
    )
    
    var willDisplayFooterViewForSection = Delegate<(UIView, Int), Void, Int>(
        index: \.1,
        #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:))
    )
    
    //Providing Header, Footer, and Row Heights
    var heightForRowAt = Delegate<IndexPath, CGFloat, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:heightForRowAt:))
    )
    
    var heightForHeaderInSection = Delegate<Int, CGFloat, Int>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:))
    )
    
    var heightForFooterInSection = Delegate<Int, CGFloat, Int>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:))
    )

    //Estimating Heights for the Table's Content
    var estimatedHeightForRowAt = Delegate<IndexPath, CGFloat, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:))
    )
    
    var estimatedHeightForHeaderInSection = Delegate<Int, CGFloat, Int>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:))
    )
    
    var estimatedHeightForFooterInSection = Delegate<Int, CGFloat, Int>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:))
    )
    
    //Managing Accessory Views
    var accessoryButtonTappedForRowWith = Delegate<IndexPath, Void, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:))
    )

    //Responding to Row Actions
    var anyLeadingSwipeActionsConfigurationForRowAt: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<IndexPath, UISwipeActionsConfiguration?, IndexPath>(
            index: \.self,
            #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:))
        )
    }()
    
    var anyTrailingSwipeActionsConfigurationForRowAt: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<IndexPath, UISwipeActionsConfiguration?, IndexPath>(
            index: \.self,
            #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:))
        )
         
    }()
    
    @available(iOS 11.0, *)
    var leadingSwipeActionsConfigurationForRowAt: Delegate<IndexPath, UISwipeActionsConfiguration?, IndexPath> {
        get { anyLeadingSwipeActionsConfigurationForRowAt as! Delegate<IndexPath, UISwipeActionsConfiguration?, IndexPath> }
        set { anyLeadingSwipeActionsConfigurationForRowAt = newValue }
    }
    
    @available(iOS 11.0, *)
    var trailingSwipeActionsConfigurationForRowAt: Delegate<IndexPath, UISwipeActionsConfiguration?, IndexPath> {
        get { anyTrailingSwipeActionsConfigurationForRowAt as! Delegate<IndexPath, UISwipeActionsConfiguration?, IndexPath> }
        set { anyTrailingSwipeActionsConfigurationForRowAt = newValue }
    }
    
    var shouldShowMenuForRowAt = Delegate<IndexPath, Bool, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:))
    )
    
    var canPerformActionForRowAtWithSender = Delegate<(Selector, IndexPath, Any?), Bool, IndexPath>(
        index: \.1,
        #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:))
    )
    
    var performActionForRowAtWithSender = Delegate<(Selector, IndexPath, Any?), Void, IndexPath>(
        index: \.1,
        #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:))
    )
    
    var editActionsForRowAt = Delegate<IndexPath, [UITableViewRowAction]?, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:))
    )
    
    //Managing Table View Highlights
    var shouldHighlightRowAt = Delegate<IndexPath, Bool, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:))
    )
    
    var didHighlightRowAt = Delegate<IndexPath, Void, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:))
    )
    
    var didUnhighlightRowAt = Delegate<IndexPath, Void, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:))
    )

    //Editing Table Rows
    var willBeginEditingRowAt = Delegate<IndexPath, Void, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:))
    )
    
    var didEndEditingRowAt = Delegate<(IndexPath?), Void, Void>(
        #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:))
    )
    
    var editingStyleForRowAt = Delegate<IndexPath, UITableViewCell.EditingStyle, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:))
    )
    
    var titleForDeleteConfirmationButtonForRowAt = Delegate<IndexPath, String?, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:))
    )
    
    var shouldIndentWhileEditingRowAt = Delegate<IndexPath, Bool, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:))
    )

    //Reordering Table Rows
    var targetIndexPathForMoveFromRowAtToProposedIndexPath = Delegate<(IndexPath, IndexPath), IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:))
    )

    //Tracking the Removal of Views
    var didEndDisplayingForRowAt = Delegate<(UITableViewCell, IndexPath), Void, Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))
    )
    
    var didEndDisplayingHeaderViewForSection = Delegate<(UIView, Int), Void, Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:))
    )
    
    var didEndDisplayingFooterViewForSection = Delegate<(UIView, Int), Void, Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:))
    )
    
    //Managing Table View Focus
    var canFocusRowAt = Delegate<IndexPath, Bool, IndexPath>(
        index: \.self,
        #selector(UITableViewDelegate.tableView(_:canFocusRowAt:))
    )
    
    var shouldUpdateFocusIn = Delegate<UITableViewFocusUpdateContext, Bool, Void>(
        #selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:))
    )
    
    var didUpdateFocusInWith = Delegate<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, Void>(
        #selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:))
    )
    
    var indexPathForPreferredFocusedView = Delegate<Void, IndexPath?, Void>(
        #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:))
    )
    
    //Instance Methods
    
    private var anyContextMenuConfigurationForRowAtPoint: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration, IndexPath>(
            index: \.0,
            #selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:))
        )
         
    }()
    
    private var anyPreviewForDismissingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview, Void>(
            #selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:))
        )
    }()
    
    private var anyTableViewPreviewForHighlightingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview, Void>(
            #selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:))
        )
    }()
    
    private var anyTableViewWillPerformPreviewActionForMenuWithAnimator: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, Void>(
            #selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:))
        )
    }()
    
    
    @available(iOS 13.0, *)
    var contextMenuConfigurationForRowAtPoint: Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration, IndexPath> {
        get { anyContextMenuConfigurationForRowAtPoint as! Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration, IndexPath> }
        set { anyContextMenuConfigurationForRowAtPoint = newValue }
    }
    
    @available(iOS 13.0, *)
    var previewForDismissingContextMenuWithConfiguration: Delegate<UIContextMenuConfiguration, UITargetedPreview, Void> {
        get { anyPreviewForDismissingContextMenuWithConfiguration as! Delegate<UIContextMenuConfiguration, UITargetedPreview, Void> }
        set { anyPreviewForDismissingContextMenuWithConfiguration = newValue }
    }
    
    @available(iOS 13.0, *)
    var previewForHighlightingContextMenuWithConfiguration: Delegate<UIContextMenuConfiguration, UITargetedPreview, Void> {
        get { anyTableViewPreviewForHighlightingContextMenuWithConfiguration as! Delegate<UIContextMenuConfiguration, UITargetedPreview, Void> }
        set { anyTableViewPreviewForHighlightingContextMenuWithConfiguration = newValue }
    }
    
    @available(iOS 13.0, *)
    var willPerformPreviewActionForMenuWithAnimator: Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, Void> {
        get { anyTableViewWillPerformPreviewActionForMenuWithAnimator as! Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, Void> }
        set { anyTableViewWillPerformPreviewActionForMenuWithAnimator = newValue }
    }
    
    func add(by selectorSets: inout SelectorSets) {
        //DataSource
        //Providing Cells, Headers, and Footers
        selectorSets.add(cellForRowAt)
        selectorSets.add(titleForHeaderInSection)
        selectorSets.add(titleForFooterInSection)
        
        //Inserting or Deleting Table Rows
        selectorSets.add(commitForRowAt)
        selectorSets.add(canEditRowAt)
        
        //Reordering Table Rows
        selectorSets.add(canMoveRowAt)
        selectorSets.add(moveRowAtTo)
        
        //Configuring an Index
        selectorSets.add(sectionIndexTitles)
        selectorSets.add(sectionForSectionIndexTitleAt)
        
        //Delegate
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

extension ListDelegate: UITableViewDataSource {
    //Providing the Number of Rows and Sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        context.numbersOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        context.numbersOfSections()
    }
    
    //Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        apply(\.tableListDelegate.cellForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        apply(\.tableListDelegate.titleForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        apply(\.tableListDelegate.titleForFooterInSection, object: tableView, with: section)
    }

    //Inserting or Deleting Table Rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.commitForRowAt, object: tableView, with: (editingStyle, indexPath))
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.canEditRowAt, object: tableView, with: indexPath)
    }
    
    //Reordering Table Rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.canMoveRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(\.tableListDelegate.moveRowAtTo, object: tableView, with: (sourceIndexPath, destinationIndexPath))
    }

    //Configuring an Index
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        apply(\.tableListDelegate.sectionIndexTitles, object: (tableView))
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        apply(\.tableListDelegate.sectionForSectionIndexTitleAt, object: tableView, with: (title, index))
    }
}

extension ListDelegate: UITableViewDelegate {
    //Configuring Rows for the Table View
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.willDisplayForRowAt, object: tableView, with: (cell, indexPath))
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        apply(\.tableListDelegate.indentationLevelForRowAt, object: tableView, with: indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(\.tableListDelegate.springLoadRowAtWith, object: tableView, with: (indexPath, context))
    }

    //Responding to Row Selections
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(\.tableListDelegate.willSelectRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.didSelectRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        apply(\.tableListDelegate.willDeselectRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.didDeselectRowAt, object: tableView, with: indexPath)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.shouldBeginMultipleSelectionInteractionAt, object: tableView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(\.tableListDelegate.didBeginMultipleSelectionInteractionAt, object: tableView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        apply(\.tableListDelegate.didEndMultipleSelectionInteraction, object: tableView)
    }
    
    //Providing Custom Header and Footer Views
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        apply(\.tableListDelegate.viewForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        apply(\.tableListDelegate.viewForFooterInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        apply(\.tableListDelegate.willDisplayHeaderViewForSection, object: tableView, with: (view, section))
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        apply(\.tableListDelegate.willDisplayFooterViewForSection, object: tableView, with: (view, section))
    }

    //Providing Header, Footer, and Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(\.tableListDelegate.heightForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        apply(\.tableListDelegate.heightForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        apply(\.tableListDelegate.heightForFooterInSection, object: tableView, with: section)
    }

    //Estimating Heights for the Table's Content
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        apply(\.tableListDelegate.estimatedHeightForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        apply(\.tableListDelegate.estimatedHeightForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        apply(\.tableListDelegate.estimatedHeightForFooterInSection, object: tableView, with: section)
    }

    //Managing Accessory Views
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        apply(\.tableListDelegate.accessoryButtonTappedForRowWith, object: tableView, with: indexPath)
    }

    //Responding to Row Actions
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        apply(\.tableListDelegate.leadingSwipeActionsConfigurationForRowAt, object: tableView, with: indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        apply(\.tableListDelegate.trailingSwipeActionsConfigurationForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.shouldShowMenuForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(\.tableListDelegate.canPerformActionForRowAtWithSender, object: tableView, with: (action, indexPath, sender))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        apply(\.tableListDelegate.performActionForRowAtWithSender, object: tableView, with: (action, indexPath, sender))
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        apply(\.tableListDelegate.editActionsForRowAt, object: tableView, with: indexPath)
    }

    //Managing Table View Highlights
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.shouldHighlightRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.didHighlightRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.didUnhighlightRowAt, object: tableView, with: indexPath)
    }

    //Editing Table Rows

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.willBeginEditingRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        apply(\.tableListDelegate.didEndEditingRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        apply(\.tableListDelegate.editingStyleForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        apply(\.tableListDelegate.titleForDeleteConfirmationButtonForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.shouldIndentWhileEditingRowAt, object: tableView, with: indexPath)
    }

    //Reordering Table Rows

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        apply(\.tableListDelegate.targetIndexPathForMoveFromRowAtToProposedIndexPath, object: tableView, with: (sourceIndexPath, proposedDestinationIndexPath))
    }

    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        apply(\.tableListDelegate.didEndDisplayingForRowAt, object: tableView, with: (cell, indexPath))
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        apply(\.tableListDelegate.didEndDisplayingHeaderViewForSection, object: tableView, with: (view, section))
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        apply(\.tableListDelegate.didEndDisplayingFooterViewForSection, object: tableView, with: (view, section))
    }

    //Managing Table View Focus
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableListDelegate.canFocusRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        apply(\.tableListDelegate.shouldUpdateFocusIn, object: tableView, with: context)
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(\.tableListDelegate.didUpdateFocusInWith, object: tableView, with: (context, coordinator))
    }

    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        apply(\.tableListDelegate.indexPathForPreferredFocusedView, object: tableView)
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(\.tableListDelegate.contextMenuConfigurationForRowAtPoint, object: tableView, with: (indexPath, point))
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.tableListDelegate.previewForDismissingContextMenuWithConfiguration, object: tableView, with: configuration)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.tableListDelegate.previewForHighlightingContextMenuWithConfiguration, object: tableView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(\.tableListDelegate.willPerformPreviewActionForMenuWithAnimator, object: tableView, with: (configuration, animator))
    }
}

#endif
