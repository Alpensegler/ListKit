//
//  ListDelegate+UITableView.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

final class UITableListDelegate: ListDelegates<UITableView> {
    //MARK: - DataSource
    
    //Providing Cells, Headers, and Footers
    lazy var cellForRowAt = ItemDelegate<IndexPath, UITableViewCell>(
        #selector(UITableViewDataSource.tableView(_:cellForRowAt:)),
        index: \.self
    ) { _, _ in UITableViewCell() }
    
    lazy var titleForHeaderInSection = SectionDelegate<Int, String?>(
        #selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)),
        index: \.self
    ) { _, _ in nil }
    
    lazy var titleForFooterInSection = SectionDelegate<Int, String?>(
        #selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)),
        index: \.self
    ) { _, _ in nil }
    
    //Inserting or Deleting Table Rows
    lazy var commitForRowAt = ItemDelegate<(UITableViewCell.EditingStyle, IndexPath), Void>(
        #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)),
        index: \.1
    )
    
    lazy var canEditRowAt = ItemDelegate<IndexPath, Bool>(
        #selector(UITableViewDataSource.tableView(_:canEditRowAt:)),
        index: \.self
    ) { _, _ in false }
    
    //Reordering Table Rows
    lazy var canMoveRowAt = ItemDelegate<IndexPath, Bool>(
        #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)),
        index: \.self
    ) { _, _ in false }
    
    lazy var moveRowAtTo = Delegate<(IndexPath, IndexPath), Void>(
        #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))
    )

    //Configuring an Index
    lazy var sectionIndexTitles = Delegate<Void, [String]?>(
        #selector(UITableViewDataSource.sectionIndexTitles(for:))
    )
    
    lazy var sectionForSectionIndexTitleAt = Delegate<(String, Int), Int>(
        #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:))
    )
    
    //MARK: - Delegate
    
    //Configuring Rows for the Table View
    lazy var willDisplayForRowAt = ItemDelegate<(UITableViewCell, IndexPath), Void>(
        #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)),
        index: \.1
    )
    
    lazy var indentationLevelForRowAt = ItemDelegate<IndexPath, Int>(
        #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)),
        index: \.self
    ) { _, _ in 0 }
    
    private lazy var anyShouldSpringLoadRowAtWith: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return ItemDelegate<(IndexPath, UISpringLoadedInteractionContext), Bool>(
            #selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)),
            index: \.0
        ) { _, _ in false }
    }()
    
    @available(iOS 11.0, *)
    var springLoadRowAtWith: ItemDelegate<(IndexPath, UISpringLoadedInteractionContext), Bool> {
        get { anyShouldSpringLoadRowAtWith as! ItemDelegate<(IndexPath, UISpringLoadedInteractionContext), Bool> }
        set { anyShouldSpringLoadRowAtWith = newValue }
    }

    //Responding to Row Selections
    lazy var willSelectRowAt = ItemDelegate<IndexPath, IndexPath?>(
        #selector(UITableViewDelegate.tableView(_:willSelectRowAt:)),
        index: \.self
    ) { input, _ in input }
    
    lazy var didSelectRowAt = ItemDelegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)),
        index: \.self
    )
    
    lazy var willDeselectRowAt = ItemDelegate<IndexPath, IndexPath?>(
        #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)),
        index: \.self
    ) { input, _ in input }
    
    lazy var didDeselectRowAt = ItemDelegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)),
        index: \.self
    )
    
    private lazy var anyShouldBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return ItemDelegate<IndexPath, Bool>(
            #selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)),
            index: \.self
        ) { _, _ in false }
    }()
    
    private lazy var anyDidBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return ItemDelegate<IndexPath, Void>(
            #selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)),
            index: \.self
        )
    }()
    
    private lazy var anyDidEndMultipleSelectionInteraction: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<Void, Void>(
            #selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    @available(iOS 13.0, *)
    var shouldBeginMultipleSelectionInteractionAt: ItemDelegate<IndexPath, Bool> {
        get { anyShouldBeginMultipleSelectionInteractionAt as! ItemDelegate<IndexPath, Bool> }
        set { anyShouldBeginMultipleSelectionInteractionAt = newValue }
    }
    
    @available(iOS 13.0, *)
    var didBeginMultipleSelectionInteractionAt: ItemDelegate<IndexPath, Void> {
        get { anyDidBeginMultipleSelectionInteractionAt as! ItemDelegate<IndexPath, Void> }
        set { anyDidBeginMultipleSelectionInteractionAt = newValue }
    }
    
    @available(iOS 13.0, *)
    var didEndMultipleSelectionInteraction: Delegate<Void, Void> {
        get { anyDidEndMultipleSelectionInteraction as! Delegate<Void, Void> }
        set { anyDidEndMultipleSelectionInteraction = newValue }
    }

    //Providing Custom Header and Footer Views
    lazy var viewForHeaderInSection = SectionDelegate<Int, UIView?>(
        #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)),
        index: \.self
    ) { _, _ in nil }
    
    lazy var viewForFooterInSection = SectionDelegate<Int, UIView?>(
        #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)),
        index: \.self
    ) { _, _ in nil }
    
    lazy var willDisplayHeaderViewForSection = SectionDelegate<(UIView, Int), Void>(
        #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)),
        index: \.1
    )
    
    lazy var willDisplayFooterViewForSection = SectionDelegate<(UIView, Int), Void>(
        #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)),
        index: \.1
    )
    
    //Providing Header, Footer, and Row Heights
    lazy var heightForRowAt = ItemDelegate<IndexPath, CGFloat>(
        #selector(UITableViewDelegate.tableView(_:heightForRowAt:)),
        index: \.self
    ) { _, tableView in tableView.rowHeight }
    
    lazy var heightForHeaderInSection = SectionDelegate<Int, CGFloat>(
        #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)),
        index: \.self
    ) { _, tableView in tableView.sectionHeaderHeight }
    
    lazy var heightForFooterInSection = SectionDelegate<Int, CGFloat>(
        #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)),
        index: \.self
    ) { _, tableView in tableView.sectionFooterHeight }

    //Estimating Heights for the Table's Content
    lazy var estimatedHeightForRowAt = ItemDelegate<IndexPath, CGFloat>(
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)),
        index: \.self
    ) { _, tableView in tableView.estimatedRowHeight }
    
    lazy var estimatedHeightForHeaderInSection = SectionDelegate<Int, CGFloat>(
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)),
        index: \.self
    ) { _, tableView in tableView.estimatedSectionHeaderHeight }
    
    lazy var estimatedHeightForFooterInSection = SectionDelegate<Int, CGFloat>(
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)),
        index: \.self
    ) { _, tableView in tableView.estimatedSectionFooterHeight }
    
    //Managing Accessory Views
    lazy var accessoryButtonTappedForRowWith = ItemDelegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)),
        index: \.self
    )

    //Responding to Row Actions
    lazy var anyLeadingSwipeActionsConfigurationForRowAt: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return ItemDelegate<IndexPath, UISwipeActionsConfiguration?>(
            #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)),
            index: \.self
        ) { _, _ in nil }
    }()
    
    lazy var anyTrailingSwipeActionsConfigurationForRowAt: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return ItemDelegate<IndexPath, UISwipeActionsConfiguration?>(
            #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)),
            index: \.self
        ) { _, _ in nil }
    }()
    
    @available(iOS 11.0, *)
    var leadingSwipeActionsConfigurationForRowAt: ItemDelegate<IndexPath, UISwipeActionsConfiguration?> {
        get { anyLeadingSwipeActionsConfigurationForRowAt as! ItemDelegate<IndexPath, UISwipeActionsConfiguration?> }
        set { anyLeadingSwipeActionsConfigurationForRowAt = newValue }
    }
    
    @available(iOS 11.0, *)
    var trailingSwipeActionsConfigurationForRowAt: ItemDelegate<IndexPath, UISwipeActionsConfiguration?> {
        get { anyTrailingSwipeActionsConfigurationForRowAt as! ItemDelegate<IndexPath, UISwipeActionsConfiguration?> }
        set { anyTrailingSwipeActionsConfigurationForRowAt = newValue }
    }
    
    lazy var shouldShowMenuForRowAt = ItemDelegate<IndexPath, Bool>(
        #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)),
        index: \.self
    ) { _, _ in false }
    
    lazy var canPerformActionForRowAtWithSender = ItemDelegate<(Selector, IndexPath, Any?), Bool>(
        #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)),
        index: \.1
    ) { _, _ in false }
    
    lazy var performActionForRowAtWithSender = ItemDelegate<(Selector, IndexPath, Any?), Void>(
        #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)),
        index: \.1
    )
    
    lazy var editActionsForRowAt = ItemDelegate<IndexPath, [UITableViewRowAction]?>(
        #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)),
        index: \.self
    ) { _, _ in nil }
    
    //Managing Table View Highlights
    lazy var shouldHighlightRowAt = ItemDelegate<IndexPath, Bool>(
        #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var didHighlightRowAt = ItemDelegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)),
        index: \.self
    )
    
    lazy var didUnhighlightRowAt = ItemDelegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)),
        index: \.self
    )

    //Editing Table Rows
    lazy var willBeginEditingRowAt = ItemDelegate<IndexPath, Void>(
        #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)),
        index: \.self
    )
    
    lazy var didEndEditingRowAt = Delegate<(IndexPath?), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:))
    )
    
    lazy var editingStyleForRowAt = ItemDelegate<IndexPath, UITableViewCell.EditingStyle>(
        #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)),
        index: \.self
    ) { input, tableView in tableView.cellForRow(at: input)?.editingStyle ?? .none }
    
    lazy var titleForDeleteConfirmationButtonForRowAt = ItemDelegate<IndexPath, String?>(
        #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)),
        index: \.self
    ) { _, _ in nil }
    
    lazy var shouldIndentWhileEditingRowAt = ItemDelegate<IndexPath, Bool>(
        #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)),
        index: \.self
    ) { _, _ in true }

    //Reordering Table Rows
    lazy var targetIndexPathForMoveFromRowAtToProposedIndexPath = Delegate<(IndexPath, IndexPath), IndexPath>(
        #selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:))
    )

    //Tracking the Removal of Views
    lazy var didEndDisplayingForRowAt = Delegate<(UITableViewCell, IndexPath), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))
    )
    
    lazy var didEndDisplayingHeaderViewForSection = Delegate<(UIView, Int), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:))
    )
    
    lazy var didEndDisplayingFooterViewForSection = Delegate<(UIView, Int), Void>(
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:))
    )
    
    //Managing Table View Focus
    lazy var canFocusRowAt = ItemDelegate<IndexPath, Bool>(
        #selector(UITableViewDelegate.tableView(_:canFocusRowAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var shouldUpdateFocusIn = Delegate<UITableViewFocusUpdateContext, Bool>(
        #selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:))
    )
    
    lazy var didUpdateFocusInWith = Delegate<(UITableViewFocusUpdateContext, UIFocusAnimationCoordinator), Void>(
        #selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:))
    )
    
    lazy var indexPathForPreferredFocusedView = Delegate<Void, IndexPath?>(
        #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:))
    )
    
    //Instance Methods
    
    private lazy var anyContextMenuConfigurationForRowAtPoint: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return ItemDelegate<(IndexPath, CGPoint), UIContextMenuConfiguration>(
            #selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)),
            index: \.0
        ) { _, _ in .init() }
         
    }()
    
    private lazy var anyPreviewForDismissingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:))
        )
    }()
    
    private lazy var anyTableViewPreviewForHighlightingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:))
        )
    }()
    
    private lazy var anyTableViewWillPerformPreviewActionForMenuWithAnimator: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void>(
            #selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:))
        )
    }()
    
    
    @available(iOS 13.0, *)
    var contextMenuConfigurationForRowAtPoint: ItemDelegate<(IndexPath, CGPoint), UIContextMenuConfiguration> {
        get { anyContextMenuConfigurationForRowAtPoint as! ItemDelegate<(IndexPath, CGPoint), UIContextMenuConfiguration> }
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
