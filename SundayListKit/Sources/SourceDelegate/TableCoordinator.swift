//
//  TableCoordinator.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

public class TableCoordinator: NSObject, ListViewCoordinator {
    public typealias List = UITableView
    public func setListView(_ listView: UITableView) { }
}

public extension TableDataSource where Self: ListUpdatable {
    func tableCoordinator() -> TableCoordinator {
        return TableDataSourceCoordinator { self }
    }
}

public extension TableDataSource where Self: AnyObject, Self: ListUpdatable {
    func tableCoordinator() -> TableCoordinator {
        return TableDataSourceCoordinator { [unowned self] in self }
    }
}

public extension TableAdapter where Self: ListUpdatable {
    func tableCoordinator() -> TableCoordinator {
        return TableAdapterCoordinator { self }
    }
}

public extension TableAdapter where Self: AnyObject, Self: ListUpdatable {
    func tableCoordinator() -> TableCoordinator {
        return TableAdapterCoordinator { [unowned self] in self }
    }
}

#if iOS13
import SwiftUI

public extension TableDataSource where Self: ListUpdatable, Self: UIViewRepresentable, Self.UIViewType == UITableView, Self.Coordinator == TableCoordinator {
    func makeUIView(context: Context) -> UIViewType {
        let tableView = UITableView()
        context.coordinator.setListView(tableView)
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        performReload()
    }
    
    func makeCoordinator() -> Coordinator {
        return tableCoordinator()
    }
}

public extension TableDataSource where Self: AnyObject, Self: ListUpdatable, Self: UIViewRepresentable, Self.UIViewType == UITableView, Self.Coordinator == TableCoordinator {
    func makeCoordinator() -> Coordinator {
        return tableCoordinator()
    }
}

public extension TableAdapter where Self: ListUpdatable, Self: UIViewRepresentable, Self.UIViewType == UITableView, Self.Coordinator == TableCoordinator {
    func makeCoordinator() -> Coordinator {
        return tableCoordinator()
    }
}

public extension TableAdapter where Self: AnyObject, Self: ListUpdatable, Self: UIViewRepresentable, Self.UIViewType == UITableView, Self.Coordinator == TableCoordinator {
    func makeCoordinator() -> Coordinator {
        return tableCoordinator()
    }
}

#endif

private class TableDataSourceCoordinator<Snapshot>: TableCoordinator, UITableViewDataSource {
    var snapshot: Snapshot { return getSnapshot() }
    let getSnapshot: () -> Snapshot
    let setTableView: (UITableView) -> Void
    
    // Providing the Number of Rows and Sections
    let tableViewNumberOfRowsInSection: (Snapshot, Int) -> Int
    let numberOfSections: (Snapshot) -> Int
    
    //Providing Cells, Headers, and Footers
    let tableViewCellForRowAt: (Snapshot, UITableView, IndexPath) -> UITableViewCell
    let tableViewTitleForHeaderInSection: (Snapshot, UITableView, Int) -> String?
    let tableViewTitleForFooterInSection: (Snapshot, UITableView, Int) -> String?
    
    //Inserting or Deleting Table Rows
    let tableViewCommitforRowAt: (Snapshot, UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void
    let tableViewCanEditRowAt: (Snapshot, UITableView, IndexPath) -> Bool
    
    //Reordering Table Rows
    let tableViewCanMoveRowAt: (Snapshot, UITableView, IndexPath) -> Bool
    let tableViewMoveRowAtTo: (Snapshot, UITableView, IndexPath, IndexPath) -> Void

    //Configuring an Index
    let sectionIndexTitles: (Snapshot, UITableView) -> [String]?
    let tableViewSectionForSectionIndexTitleAt: (Snapshot, UITableView, String, Int) -> Int
    
    override func setListView(_ tableView: UITableView) {
        setTableView(tableView)
        tableView.didReload = false
        tableView.dataSource = self
    }
    
    init<Coordinator: TableDataSource & ListUpdatable>(_ coordinator: @escaping () -> Coordinator) where Coordinator.SourceSnapshot == Snapshot {
        getSnapshot = { coordinator().snapshot }
        setTableView = { coordinator().setTableView($0) }
        
        tableViewNumberOfRowsInSection = { $0.numbersOfItems(in: $1) }
        numberOfSections = { $0.numbersOfSections() }
        
        tableViewCellForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), cellForItem: coordinator().item(for: $0, at: $2)) }
        tableViewTitleForHeaderInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), titleForHeaderInSection: $2) }
        tableViewTitleForFooterInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), titleForFooterInSection: $2) }
        
        tableViewCommitforRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $3, snapshot: $0), commit: $2, forItem: coordinator().item(for: $0, at: $3)) }
        tableViewCanEditRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), canEditItem: coordinator().item(for: $0, at: $2)) }
        
        tableViewCanMoveRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), canMoveItem: coordinator().item(for: $0, at: $2)) }
        tableViewMoveRowAtTo = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), moveItem: coordinator().item(for: $0, at: $2), to: $3) }
        
        sectionIndexTitles = { coordinator().sectionIndexTitles(for: .init(listView: $1, indexPath: .default, snapshot: $0)) }
        tableViewSectionForSectionIndexTitleAt = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), sectionForSectionIndexTitle: $2, at: $3) }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewNumberOfRowsInSection(snapshot, section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCellForRowAt(snapshot, tableView, indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections(snapshot)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewTitleForHeaderInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewTitleForFooterInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableViewCanEditRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableViewCanMoveRowAt(snapshot, tableView, indexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles(snapshot, tableView)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return tableViewSectionForSectionIndexTitleAt(snapshot, tableView, title, index)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableViewCommitforRowAt(snapshot, tableView, editingStyle, indexPath)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableViewMoveRowAtTo(snapshot, tableView, sourceIndexPath, destinationIndexPath)
    }
}

private final class TableAdapterCoordinator<Snapshot>: TableDataSourceCoordinator<Snapshot>, UITableViewDelegate {
    //Configuring Rows for the Table View
    let tableViewWillDisplayForRowAt: (Snapshot, UITableView, UITableViewCell, IndexPath) -> Void
    let tableViewIndentationLevelForRowAt: (Snapshot, UITableView, IndexPath) -> Int
    let anyTableViewShouldSpringLoadRowAtWith: Any?
    
    @available(iOS 11.0, *)
    var tableViewShouldSpringLoadRowAtWith: ((Snapshot, UITableView, IndexPath, UISpringLoadedInteractionContext) -> Bool)? {
        return anyTableViewShouldSpringLoadRowAtWith as? (Snapshot, UITableView, IndexPath, UISpringLoadedInteractionContext) -> Bool
    }

    //Responding to Row Selections
    let tableViewWillSelectRowAt: (Snapshot, UITableView, IndexPath) -> IndexPath?
    let tableViewWillDeselectRowAt: (Snapshot, UITableView, IndexPath) -> IndexPath?
    let tableViewDidSelectRowAt: (Snapshot, UITableView, IndexPath) -> Void
    let tableViewDidDeselectRowAt: (Snapshot, UITableView, IndexPath) -> Void

    //Providing Custom Header and Footer Views
    let tableViewViewForHeaderInSection: (Snapshot, UITableView, Int) -> UIView?
    let tableViewViewForFooterInSection: (Snapshot, UITableView, Int) -> UIView?
    let tableViewWillDisplayHeaderViewForSection: (Snapshot, UITableView, UIView, Int) -> Void
    let tableViewWillDisplayFooterViewForSection: (Snapshot, UITableView, UIView, Int) -> Void
    
    //Providing Header, Footer, and Row Heights
    let tableViewheightForRowAt: (Snapshot, UITableView, IndexPath) -> CGFloat
    let tableViewheightForHeaderInSection: (Snapshot, UITableView, Int) -> CGFloat
    let tableViewheightForFooterInSection: (Snapshot, UITableView, Int) -> CGFloat

    //Estimating Heights for the Table's Content
    let tableViewEstimatedHeightForRowAt: (Snapshot, UITableView, IndexPath) -> CGFloat
    let tableViewEstimatedHeightForHeaderInSection: (Snapshot, UITableView, Int) -> CGFloat
    let tableViewEstimatedHeightForFooterInSection: (Snapshot, UITableView, Int) -> CGFloat
    
    //Managing Accessory Views
    let tableViewAccessoryButtonTappedForRowWith: (Snapshot, UITableView, IndexPath) -> Void

    //Responding to Row Actions
    let anyTableViewLeadingSwipeActionsConfigurationForRowAt: Any?
    
    @available(iOS 11.0, *)
    var tableViewLeadingSwipeActionsConfigurationForRowAt: ((Snapshot, UITableView, IndexPath) -> UISwipeActionsConfiguration?)? {
        return anyTableViewLeadingSwipeActionsConfigurationForRowAt as? (Snapshot, UITableView, IndexPath) -> UISwipeActionsConfiguration?
    }
    
    let anyTableViewTrailingSwipeActionsConfigurationForRowAt: Any?
    
    @available(iOS 11.0, *)
    var tableViewTrailingSwipeActionsConfigurationForRowAt: ((Snapshot, UITableView, IndexPath) -> UISwipeActionsConfiguration?)? {
        return anyTableViewTrailingSwipeActionsConfigurationForRowAt as? (Snapshot, UITableView, IndexPath) -> UISwipeActionsConfiguration?
    }
    
    #if iOS13
    
    #else
    let tableViewShouldShowMenuForRowAt: (Snapshot, UITableView, IndexPath) -> Bool
    let tableViewCanPerformActionForRowAtWithSender: (Snapshot, UITableView, Selector, IndexPath, Any?) -> Bool
    let tableViewPerformActionForRowAtWithSender: (Snapshot, UITableView, Selector, IndexPath, Any?) -> Void
    let tableViewEditActionsForRowAt: (Snapshot, UITableView, IndexPath) -> [UITableViewRowAction]?
    #endif
    
    //Managing Table View Highlights
    let tableViewShouldHighlightRowAt: (Snapshot, UITableView, IndexPath) -> Bool
    let tableViewDidHighlightRowAt: (Snapshot, UITableView, IndexPath) -> Void
    let tableViewDidUnhighlightRowAt: (Snapshot, UITableView, IndexPath) -> Void

    //Editing Table Rows
    let tableViewWillBeginEditingRowAt: (Snapshot, UITableView, IndexPath) -> Void
    let tableViewDidEndEditingRowAt: (Snapshot, UITableView, IndexPath?) -> Void
    let tableViewEditingStyleForRowAt: (Snapshot, UITableView, IndexPath) -> UITableViewCell.EditingStyle
    let tableViewTitleForDeleteConfirmationButtonForRowAt: (Snapshot, UITableView, IndexPath) -> String?
    let tableViewShouldIndentWhileEditingRowAt: (Snapshot, UITableView, IndexPath) -> Bool

    //Reordering Table Rows
    let tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath: (Snapshot, UITableView, IndexPath, IndexPath) -> IndexPath

    //Tracking the Removal of Views
    let tableViewDidEndDisplayingForRowAt: (Snapshot, UITableView, UITableViewCell, IndexPath) -> Void
    let tableViewDidEndDisplayingHeaderViewForSection: (Snapshot, UITableView, UIView, Int) -> Void
    let tableViewDidEndDisplayingFooterViewForSection: (Snapshot, UITableView, UIView, Int) -> Void
    
    //Managing Table View Focus
    let tableViewCanFocusRowAt: (Snapshot, UITableView, IndexPath) -> Bool
    let tableViewShouldUpdateFocusIn: (Snapshot, UITableView, UITableViewFocusUpdateContext) -> Bool
    let tableViewDidUpdateFocusInWith: (Snapshot, UITableView, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    let indexPathForPreferredFocusedView: (Snapshot, UITableView) -> IndexPath?

    //ScrollView Delegate
    let scrollViewDidScroll: (UIScrollView) -> Void
    let scrollViewDidZoom: (UIScrollView) -> Void
    let scrollViewWillBeginDragging: (UIScrollView) -> Void
    let scrollViewWillEndDragging: (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void
    let scrollViewDidEndDragging: (UIScrollView, Bool) -> Void
    let scrollViewWillBeginDecelerating: (UIScrollView) -> Void
    let scrollViewDidEndDecelerating: (UIScrollView) -> Void
    let scrollViewDidEndScrollingAnimation: (UIScrollView) -> Void
    let viewForZooming: (UIScrollView) -> UIView?
    let scrollViewWillBeginZooming: (UIScrollView, UIView?) -> Void
    let scrollViewDidEndZooming: (UIScrollView, UIView?, CGFloat) -> Void
    let scrollViewShouldScrollToTop: (UIScrollView) -> Bool
    let scrollViewDidScrollToTop: (UIScrollView) -> Void
    let scrollViewDidChangeAdjustedContentInset: (UIScrollView) -> Void
    
    override func setListView(_ tableView: UITableView) {
        super.setListView(tableView)
        tableView.delegate = self
    }
    
    override init<Coordinator: TableAdapter & ListUpdatable>(_ coordinator: @escaping () -> Coordinator) where Coordinator.SourceSnapshot == Snapshot {
        tableViewWillDisplayForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $3, snapshot: $0), willDisplay: $2, forItem: coordinator().item(for: $0, at: $3)) }
        tableViewWillDisplayHeaderViewForSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), willDisplayHeaderView: $2, forSection: $3) }
        tableViewWillDisplayFooterViewForSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), willDisplayFooterView: $2, forSection: $3) }
        tableViewDidEndDisplayingForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $3, snapshot: $0), didEndDisplaying: $2, forItem: coordinator().item(for: $0, at: $3)) }
        tableViewDidEndDisplayingHeaderViewForSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), didEndDisplayingHeaderView: $2, forSection: $3) }
        tableViewDidEndDisplayingFooterViewForSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), didEndDisplayingFooterView: $2, forSection: $3) }
        tableViewheightForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), heightForItem: coordinator().item(for: $0, at: $2)) }
        tableViewheightForHeaderInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), heightForHeaderInSection: $2) }
        tableViewheightForFooterInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), heightForFooterInSection: $2) }
        tableViewEstimatedHeightForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), estimatedHeightForItem: coordinator().item(for: $0, at: $2)) }
        tableViewEstimatedHeightForHeaderInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), estimatedHeightForHeaderInSection: $2) }
        tableViewEstimatedHeightForFooterInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), estimatedHeightForFooterInSection: $2) }
        tableViewViewForHeaderInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), viewForHeaderInSection: $2) }
        tableViewViewForFooterInSection = { coordinator().tableContext(.init(listView: $1, indexPath: .init(section: $2), snapshot: $0), viewForFooterInSection: $2) }
        tableViewAccessoryButtonTappedForRowWith = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), accessoryButtonTappedForItem: coordinator().item(for: $0, at: $2)) }
        tableViewShouldHighlightRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldHighlightItem: coordinator().item(for: $0, at: $2)) }
        tableViewDidHighlightRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), didHighlightItem: coordinator().item(for: $0, at: $2)) }
        tableViewDidUnhighlightRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), didUnhighlightItem: coordinator().item(for: $0, at: $2)) }
        tableViewWillSelectRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), willSelectItem: coordinator().item(for: $0, at: $2)) }
        tableViewWillDeselectRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), willDeselectItem: coordinator().item(for: $0, at: $2)) }
        tableViewDidSelectRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), didSelectItem: coordinator().item(for: $0, at: $2)) }
        tableViewDidDeselectRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), didDeselectItem: coordinator().item(for: $0, at: $2)) }
        tableViewEditingStyleForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), editingStyleForItem: coordinator().item(for: $0, at: $2)) }
        tableViewTitleForDeleteConfirmationButtonForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), titleForDeleteConfirmationButtonForItem: coordinator().item(for: $0, at: $2)) }
        tableViewShouldIndentWhileEditingRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldIndentWhileEditingItem: coordinator().item(for: $0, at: $2)) }
        tableViewWillBeginEditingRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), willBeginEditingItem: coordinator().item(for: $0, at: $2)) }
        tableViewDidEndEditingRowAt = { (snapshot, listView, indexPath) in coordinator().tableContext(.init(listView: listView, indexPath: indexPath ?? .default, snapshot: snapshot), didEndEditingItem: indexPath.map { coordinator().item(for: snapshot, at: $0) }) }
        tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), targetIndexPathForMoveFromItem: coordinator().item(for: $0, at: $2), toProposedIndexPath: $3) }
        tableViewIndentationLevelForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), indentationLevelForItem: coordinator().item(for: $0, at: $2)) }
        tableViewCanFocusRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), canFocusItem: coordinator().item(for: $0, at: $2)) }
        tableViewShouldUpdateFocusIn = { coordinator().tableContext(.init(listView: $1, indexPath: .default, snapshot: $0), shouldUpdateFocusIn: $2) }
        tableViewDidUpdateFocusInWith = { coordinator().tableContext(.init(listView: $1, indexPath: .default, snapshot: $0), didUpdateFocusIn: $2, with: $3) }
        indexPathForPreferredFocusedView = { coordinator().indexPathForPreferredFocusedView(in: .init(listView: $1, indexPath: .default, snapshot: $0)) }
        
        if #available(iOS 11.0, *) {
            anyTableViewLeadingSwipeActionsConfigurationForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), leadingSwipeActionsConfigurationForItem: coordinator().item(for: $0, at: $2)) }
            anyTableViewTrailingSwipeActionsConfigurationForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), trailingSwipeActionsConfigurationForItem: coordinator().item(for: $0, at: $2)) }
            anyTableViewShouldSpringLoadRowAtWith = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldSpringLoadItem: coordinator().item(for: $0, at: $2), with: $3) }
        } else {
            anyTableViewLeadingSwipeActionsConfigurationForRowAt = nil
            anyTableViewTrailingSwipeActionsConfigurationForRowAt = nil
            anyTableViewShouldSpringLoadRowAtWith = nil
        }
        
        #if iOS13
        
        #else
        tableViewShouldShowMenuForRowAt = { coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldShowMenuForItem: coordinator().item(for: $0, at: $2)) }
        tableViewCanPerformActionForRowAtWithSender = { coordinator().tableContext(.init(listView: $1, indexPath: $3, snapshot: $0), canPerformAction: $2, forItem: coordinator().item(for: $0, at: $3), withSender: $4) }
        tableViewPerformActionForRowAtWithSender = { coordinator().tableContext(.init(listView: $1, indexPath: $3, snapshot: $0), performAction: $2, forItem: coordinator().item(for: $0, at: $3), withSender: $4) }
        tableViewEditActionsForRowAt = { return coordinator().tableContext(.init(listView: $1, indexPath: $2, snapshot: $0), editActionsForItem: coordinator().item(for: $0, at: $2)) }
        #endif

        scrollViewDidScroll = { coordinator().scrollViewDidScroll($0) }
        scrollViewDidZoom = { coordinator().scrollViewDidZoom($0) }
        scrollViewWillBeginDragging = { coordinator().scrollViewWillBeginDragging($0) }
        scrollViewWillEndDragging = { coordinator().scrollViewWillEndDragging($0, withVelocity: $1, targetContentOffset: $2) }
        scrollViewDidEndDragging = { coordinator().scrollViewDidEndDragging($0, willDecelerate: $1) }
        scrollViewWillBeginDecelerating = { coordinator().scrollViewWillBeginDecelerating($0) }
        scrollViewDidEndDecelerating = { coordinator().scrollViewDidEndDecelerating($0) }
        scrollViewDidEndScrollingAnimation = { coordinator().scrollViewDidEndScrollingAnimation($0) }
        viewForZooming = { coordinator().viewForZooming(in: $0) }
        scrollViewWillBeginZooming = { coordinator().scrollViewWillBeginZooming($0, with: $1) }
        scrollViewDidEndZooming = { coordinator().scrollViewDidEndZooming($0, with: $1, atScale: $2) }
        scrollViewShouldScrollToTop = { coordinator().scrollViewShouldScrollToTop($0) }
        scrollViewDidScrollToTop = { coordinator().scrollViewDidScrollToTop($0) }
        scrollViewDidChangeAdjustedContentInset = { coordinator().scrollViewDidChangeAdjustedContentInset($0) }
        
        super.init(coordinator)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewWillDisplayForRowAt(snapshot, tableView, cell, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableViewWillDisplayHeaderViewForSection(snapshot, tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tableViewWillDisplayFooterViewForSection(snapshot, tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewDidEndDisplayingForRowAt(snapshot, tableView, cell, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tableViewDidEndDisplayingHeaderViewForSection(snapshot, tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tableViewDidEndDisplayingFooterViewForSection(snapshot, tableView, view, section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewheightForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewheightForHeaderInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableViewheightForFooterInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewEstimatedHeightForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableViewEstimatedHeightForHeaderInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableViewEstimatedHeightForFooterInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewViewForHeaderInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableViewViewForFooterInSection(snapshot, tableView, section)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableViewAccessoryButtonTappedForRowWith(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return tableViewShouldHighlightRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableViewDidHighlightRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableViewDidUnhighlightRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableViewWillSelectRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableViewWillDeselectRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDidSelectRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableViewDidDeselectRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableViewEditingStyleForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return tableViewTitleForDeleteConfirmationButtonForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return tableViewShouldIndentWhileEditingRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableViewWillBeginEditingRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableViewDidEndEditingRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath(snapshot, tableView, sourceIndexPath, proposedDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return tableViewIndentationLevelForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return tableViewCanFocusRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return tableViewShouldUpdateFocusIn(snapshot, tableView, context)
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        tableViewDidUpdateFocusInWith(snapshot, tableView, context, coordinator)
    }
    
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return indexPathForPreferredFocusedView(snapshot, tableView)
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableViewLeadingSwipeActionsConfigurationForRowAt?(snapshot, tableView, indexPath)
    }
    
    #if iOS13
    
    #else
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return tableViewEditActionsForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return tableViewShouldShowMenuForRowAt(snapshot, tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return tableViewCanPerformActionForRowAtWithSender(snapshot, tableView, action, indexPath, sender)
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        tableViewPerformActionForRowAtWithSender(snapshot, tableView, action, indexPath, sender)
    }
    
    #endif
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableViewTrailingSwipeActionsConfigurationForRowAt?(snapshot, tableView, indexPath)
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return tableViewShouldSpringLoadRowAtWith?(snapshot, tableView, indexPath, context) ?? true
    }
    
    //ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDidZoom(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDragging(scrollView, velocity, targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDragging(scrollView, decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForZooming(scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewWillBeginZooming(scrollView, view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDidEndZooming(scrollView, view, scale)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return scrollViewShouldScrollToTop(scrollView)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidScrollToTop(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDidChangeAdjustedContentInset(scrollView)
    }
}
