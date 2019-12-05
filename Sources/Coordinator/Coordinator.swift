//
//  ListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/12.
//

#if os(iOS) || os(tvOS)
import UIKit

public class Coordinator: NSObject {
    //MARK: ScrollView Delegate
    var scrollViewDidScroll: ((UIScrollView) -> Void)?
    var scrollViewDidZoom: ((UIScrollView) -> Void)?
    var scrollViewWillBeginDragging: ((UIScrollView) -> Void)?
    var scrollViewWillEndDragging: ((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void)?
    var scrollViewDidEndDragging: ((UIScrollView, Bool) -> Void)?
    var scrollViewWillBeginDecelerating: ((UIScrollView) -> Void)?
    var scrollViewDidEndDecelerating: ((UIScrollView) -> Void)?
    var scrollViewDidEndScrollingAnimation: ((UIScrollView) -> Void)?
    var viewForZooming: ((UIScrollView) -> UIView?)?
    var scrollViewWillBeginZooming: ((UIScrollView, UIView?) -> Void)?
    var scrollViewDidEndZooming: ((UIScrollView, UIView?, CGFloat) -> Void)?
    var scrollViewShouldScrollToTop: ((UIScrollView) -> Bool)?
    var scrollViewDidScrollToTop: ((UIScrollView) -> Void)?
    var scrollViewDidChangeAdjustedContentInset: ((UIScrollView) -> Void)?
    
    //MARK: ColectionView DataSource

    //Getting Views for Items
    var collectionViewCellForItemAt: ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    var collectionViewViewForSupplementaryElementOfKindAt: ((UICollectionView, String, IndexPath) -> UICollectionReusableView)?

    //Reordering Items
    var collectionViewCanMoveItemAt: ((UICollectionView, IndexPath) -> Bool)?
    var collectionViewMoveItemAtTo: ((UICollectionView, IndexPath, IndexPath) -> Void)?
    
    //Configuring an Index
    var indexTitles: ((UICollectionView) -> [String]?)?
    var collectionViewIndexPathForIndexTitleAt: ((UICollectionView, String, Int) -> IndexPath)?
    
    //MARK: CollectionView Delegate
    
    //Managing the Selected Cells
    var collectionViewShouldSelectItemAt: ((UICollectionView, IndexPath) -> Bool)?
    var collectionViewDidSelectItemAt: ((UICollectionView, IndexPath) -> Void)?
    var collectionViewShouldDeselectItemAt: ((UICollectionView, IndexPath) -> Bool)?
    var collectionViewDidDeselectItemAt: ((UICollectionView, IndexPath) -> Void)?
    
    var collectionViewShouldBeginMultipleSelectionInteractionAt: ((UICollectionView, IndexPath) -> Bool)?
    var collectionViewDidBeginMultipleSelectionInteractionAt: ((UICollectionView, IndexPath) -> Void)?
    var collectionViewDidEndMultipleSelectionInteraction: ((UICollectionView) -> Void)?
    
    //Managing Cell Highlighting
    var collectionViewShouldHighlightItemAt: ((UICollectionView, IndexPath) -> Bool)?
    var collectionViewDidHighlightItemAt: ((UICollectionView, IndexPath) -> Void)?
    var collectionViewDidUnhighlightItemAt: ((UICollectionView, IndexPath) -> Void)?

    //Tracking the Addition and Removal of Views
    var collectionViewWillDisplayForItemAt: ((UICollectionView, UICollectionViewCell, IndexPath) -> Void)?
    var collectionViewWillDisplaySupplementaryViewForElementKindAt: ((UICollectionView, UICollectionReusableView, String, IndexPath) -> Void)?
    var collectionViewDidEndDisplayingForItemAt: ((UICollectionView, UICollectionViewCell, IndexPath) -> Void)?
    var collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAt: ((UICollectionView, UICollectionReusableView, String, IndexPath) -> Void)?
    
    //Handling Layout Changes
    var collectionViewTransitionLayoutForOldLayoutNewLayout: ((UICollectionView, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout)?
    var collectionViewTargetContentOffsetForProposedContentOffset: ((UICollectionView, CGPoint) -> CGPoint)?
    var collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPath: ((UICollectionView, IndexPath, IndexPath) -> IndexPath)?
    
    //Managing Actions for Cells
    var collectionViewShouldShowMenuForItemAt: ((UICollectionView, IndexPath) -> Bool)?
    var collectionViewCanPerformActionForItemAtWithSender: ((UICollectionView, Selector, IndexPath, Any?) -> Bool)?
    var collectionViewPerformActionForItemAtWithSender: ((UICollectionView, Selector, IndexPath, Any?) -> Void)?
    
    //Managing Focus in a Collection View
    var collectionViewCanFocusItemAt: ((UICollectionView, IndexPath) -> Bool)?
    var indexPathForPreferredFocusedView: ((UICollectionView) -> IndexPath?)?
    var collectionViewShouldUpdateFocusIn: ((UICollectionView, UICollectionViewFocusUpdateContext) -> Bool)?
    var collectionViewDidUpdateFocusInWith: ((UICollectionView, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void)?

    //Controlling the Spring-Loading Behavior
    var anyCollectionViewShouldSpringLoadItemAtWith: Any?
    
    @available(iOS 11.0, *)
    var collectionViewShouldSpringLoadItemAtWith: ((UICollectionView, IndexPath, UISpringLoadedInteractionContext) -> Bool)? {
        anyCollectionViewShouldSpringLoadItemAtWith as? (UICollectionView, IndexPath, UISpringLoadedInteractionContext) -> Bool
    }
    var anyCollectionViewContextMenuConfigurationForItemAtPoint: Any?
    var anyCollectionViewPreviewForDismissingContextMenuWithConfiguration: Any?
    var anyCollectionViewPreviewForHighlightingContextMenuWithConfiguration: Any?
    var anyCollectionViewWillCommitMenuWithAnimator: Any?
    var anyCollectionViewWillPerformPreviewActionForMenuWithAnimator: Any?
    
    //Instance Methods
    @available(iOS 13.0, *)
    var collectionViewContextMenuConfigurationForItemAtPoint: ((UICollectionView, IndexPath, CGPoint) -> UIContextMenuConfiguration)? {
        anyCollectionViewContextMenuConfigurationForItemAtPoint as? (UICollectionView, IndexPath, CGPoint) -> UIContextMenuConfiguration
    }
    
    @available(iOS 13.0, *)
    var collectionViewPreviewForDismissingContextMenuWithConfiguration: ((UICollectionView, UIContextMenuConfiguration) -> UITargetedPreview)? {
        anyCollectionViewPreviewForDismissingContextMenuWithConfiguration as? (UICollectionView, UIContextMenuConfiguration) -> UITargetedPreview
    }
    
    @available(iOS 13.0, *)
    var collectionViewPreviewForHighlightingContextMenuWithConfiguration: ((UICollectionView, UIContextMenuConfiguration) -> UITargetedPreview)? {
        anyCollectionViewPreviewForHighlightingContextMenuWithConfiguration as? (UICollectionView, UIContextMenuConfiguration) -> UITargetedPreview
    }
    
    @available(iOS 13.0, *)
    var collectionViewWillCommitMenuWithAnimator: ((UICollectionView, UIContextMenuInteractionCommitAnimating) -> Void)? {
        anyCollectionViewWillCommitMenuWithAnimator as? (UICollectionView, UIContextMenuInteractionCommitAnimating) -> Void
    }
    
    @available(iOS 13.0, *)
    var collectionViewWillPerformPreviewActionForMenuWithAnimator: ((UICollectionView, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void)? {
        anyCollectionViewWillPerformPreviewActionForMenuWithAnimator as? (UICollectionView, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    }
    
    //MARK: CollectionView Delegate Flowlayout
    
    //Getting the Size of Items
    var collectionViewLayoutSizeForItemAt: ((UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize)?
    
    //Getting the Section Spacing
    var collectionViewLayoutInsetForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)?
    var collectionViewLayoutMinimumLineSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    var collectionViewLayoutMinimumInteritemSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    
    //Getting the Header and Footer Sizes
    var collectionViewLayoutReferenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)?
    var collectionViewLayoutReferenceSizeForFooterInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)?
    
    //MARK: TableView DataSource
    
    //Providing Cells, Headers, and Footers
    var tableViewCellForRowAt: ((UITableView, IndexPath) -> UITableViewCell)?
    var tableViewTitleForHeaderInSection: ((UITableView, Int) -> String?)?
    var tableViewTitleForFooterInSection: ((UITableView, Int) -> String?)?
    
    //Inserting or Deleting Table Rows
    var tableViewCommitforRowAt: ((UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void)?
    var tableViewCanEditRowAt: ((UITableView, IndexPath) -> Bool)?
    
    //Reordering Table Rows
    var tableViewCanMoveRowAt: ((UITableView, IndexPath) -> Bool)?
    var tableViewMoveRowAtTo: ((UITableView, IndexPath, IndexPath) -> Void)?

    //Configuring an Index
    var sectionIndexTitles: ((UITableView) -> [String]?)?
    var tableViewSectionForSectionIndexTitleAt: ((UITableView, String, Int) -> Int)?
    
    //MARK: TableView Delegate
    
    //Configuring Rows for the Table View
    var tableViewWillDisplayForRowAt: ((UITableView, UITableViewCell, IndexPath) -> Void)?
    var tableViewIndentationLevelForRowAt: ((UITableView, IndexPath) -> Int)?
    var anyTableViewShouldSpringLoadRowAtWith: Any?
    
    @available(iOS 11.0, *)
    var tableViewShouldSpringLoadRowAtWith: ((UITableView, IndexPath, UISpringLoadedInteractionContext) -> Bool)? {
        anyTableViewShouldSpringLoadRowAtWith as? (UITableView, IndexPath, UISpringLoadedInteractionContext) -> Bool
    }

    //Responding to Row Selections
    var tableViewWillSelectRowAt: ((UITableView, IndexPath) -> IndexPath?)?
    var tableViewDidSelectRowAt: ((UITableView, IndexPath) -> Void)?
    var tableViewWillDeselectRowAt: ((UITableView, IndexPath) -> IndexPath?)?
    var tableViewDidDeselectRowAt: ((UITableView, IndexPath) -> Void)?
    
    var tableViewShouldBeginMultipleSelectionInteractionAt: ((UITableView, IndexPath) -> Bool)?
    var tableViewDidEndMultipleSelectionInteraction: ((UITableView, IndexPath) -> Void)?
    var tableViewDidBeginMultipleSelectionInteractionAt: ((UITableView) -> Void)?

    //Providing Custom Header and Footer Views
    var tableViewViewForHeaderInSection: ((UITableView, Int) -> UIView?)?
    var tableViewViewForFooterInSection: ((UITableView, Int) -> UIView?)?
    var tableViewWillDisplayHeaderViewForSection: ((UITableView, UIView, Int) -> Void)?
    var tableViewWillDisplayFooterViewForSection: ((UITableView, UIView, Int) -> Void)?
    
    //Providing Header, Footer, and Row Heights
    var tableViewheightForRowAt: ((UITableView, IndexPath) -> CGFloat)?
    var tableViewheightForHeaderInSection: ((UITableView, Int) -> CGFloat)?
    var tableViewheightForFooterInSection: ((UITableView, Int) -> CGFloat)?

    //Estimating Heights for the Table's Content
    var tableViewEstimatedHeightForRowAt: ((UITableView, IndexPath) -> CGFloat)?
    var tableViewEstimatedHeightForHeaderInSection: ((UITableView, Int) -> CGFloat)?
    var tableViewEstimatedHeightForFooterInSection: ((UITableView, Int) -> CGFloat)?
    
    //Managing Accessory Views
    var tableViewAccessoryButtonTappedForRowWith: ((UITableView, IndexPath) -> Void)?

    //Responding to Row Actions
    var anyTableViewLeadingSwipeActionsConfigurationForRowAt: Any?
    
    @available(iOS 11.0, *)
    var tableViewLeadingSwipeActionsConfigurationForRowAt: ((UITableView, IndexPath) -> UISwipeActionsConfiguration?)? {
        anyTableViewLeadingSwipeActionsConfigurationForRowAt as? (UITableView, IndexPath) -> UISwipeActionsConfiguration?
    }
    
    var anyTableViewTrailingSwipeActionsConfigurationForRowAt: Any?
    
    @available(iOS 11.0, *)
    var tableViewTrailingSwipeActionsConfigurationForRowAt: ((UITableView, IndexPath) -> UISwipeActionsConfiguration?)? {
        anyTableViewTrailingSwipeActionsConfigurationForRowAt as? (UITableView, IndexPath) -> UISwipeActionsConfiguration?
    }
    
    var tableViewShouldShowMenuForRowAt: ((UITableView, IndexPath) -> Bool)?
    var tableViewCanPerformActionForRowAtWithSender: ((UITableView, Selector, IndexPath, Any?) -> Bool)?
    var tableViewPerformActionForRowAtWithSender: ((UITableView, Selector, IndexPath, Any?) -> Void)?
    var tableViewEditActionsForRowAt: ((UITableView, IndexPath) -> [UITableViewRowAction]?)?
    
    //Managing Table View Highlights
    var tableViewShouldHighlightRowAt: ((UITableView, IndexPath) -> Bool)?
    var tableViewDidHighlightRowAt: ((UITableView, IndexPath) -> Void)?
    var tableViewDidUnhighlightRowAt: ((UITableView, IndexPath) -> Void)?

    //Editing Table Rows
    var tableViewWillBeginEditingRowAt: ((UITableView, IndexPath) -> Void)?
    var tableViewDidEndEditingRowAt: ((UITableView, IndexPath?) -> Void)?
    var tableViewEditingStyleForRowAt: ((UITableView, IndexPath) -> UITableViewCell.EditingStyle)?
    var tableViewTitleForDeleteConfirmationButtonForRowAt: ((UITableView, IndexPath) -> String?)?
    var tableViewShouldIndentWhileEditingRowAt: ((UITableView, IndexPath) -> Bool)?

    //Reordering Table Rows
    var tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath: ((UITableView, IndexPath, IndexPath) -> IndexPath)?

    //Tracking the Removal of Views
    var tableViewDidEndDisplayingForRowAt: ((UITableView, UITableViewCell, IndexPath) -> Void)?
    var tableViewDidEndDisplayingHeaderViewForSection: ((UITableView, UIView, Int) -> Void)?
    var tableViewDidEndDisplayingFooterViewForSection: ((UITableView, UIView, Int) -> Void)?
    
    //Managing Table View Focus
    var tableViewCanFocusRowAt: ((UITableView, IndexPath) -> Bool)?
    var tableViewShouldUpdateFocusIn: ((UITableView, UITableViewFocusUpdateContext) -> Bool)?
    var tableViewDidUpdateFocusInWith: ((UITableView, UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void)?
    var indexPathForTableViewPreferredFocusedView: ((UITableView) -> IndexPath?)?
    
    var anyTableViewContextMenuConfigurationForRowAtPoint: Any?
    var anyTableViewPreviewForDismissingContextMenuWithConfiguration: Any?
    var anyTableViewPreviewForHighlightingContextMenuWithConfiguration: Any?
    var anyTableViewWillCommitMenuWithAnimator: Any?
    var anyTableViewWillPerformPreviewActionForMenuWithAnimator: Any?
    
    @available(iOS 13.0, *)
    var tableViewContextMenuConfigurationForRowAtPoint: ((UITableView, IndexPath, CGPoint) -> UIContextMenuConfiguration)? {
        anyTableViewContextMenuConfigurationForRowAtPoint as? (UITableView, IndexPath, CGPoint) -> UIContextMenuConfiguration
    }
    
    @available(iOS 13.0, *)
    var tableViewPreviewForDismissingContextMenuWithConfiguration: ((UITableView, UIContextMenuConfiguration) -> UITargetedPreview)? {
        anyTableViewPreviewForDismissingContextMenuWithConfiguration as? (UITableView, UIContextMenuConfiguration) -> UITargetedPreview
    }
    
    @available(iOS 13.0, *)
    var tableViewPreviewForHighlightingContextMenuWithConfiguration: ((UITableView, UIContextMenuConfiguration) -> UITargetedPreview)? {
        anyTableViewPreviewForHighlightingContextMenuWithConfiguration as? (UITableView, UIContextMenuConfiguration) -> UITargetedPreview
    }
    
    @available(iOS 13.0, *)
    var tableViewWillCommitMenuWithAnimator: ((UITableView, UIContextMenuInteractionCommitAnimating) -> Void)? {
        anyTableViewWillCommitMenuWithAnimator as? (UITableView, UIContextMenuInteractionCommitAnimating) -> Void
    }
    
    @available(iOS 13.0, *)
    var tableViewWillPerformPreviewActionForMenuWithAnimator: ((UITableView, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void)? {
        anyTableViewWillPerformPreviewActionForMenuWithAnimator as? (UITableView, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    }
    
    lazy var notAddedSelector: Set<Selector> = [
        //ScrollView Delegate
        #selector(scrollViewDidScroll(_:)),
        #selector(scrollViewDidZoom(_:)),
        #selector(scrollViewWillBeginDragging(_:)),
        #selector(scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)),
        #selector(scrollViewDidEndDragging(_:willDecelerate:)),
        #selector(scrollViewWillBeginDecelerating(_:)),
        #selector(scrollViewDidEndDecelerating(_:)),
        #selector(scrollViewDidEndScrollingAnimation(_:)),
        #selector(viewForZooming(in:)),
        #selector(scrollViewWillBeginZooming(_:with:)),
        #selector(scrollViewDidEndZooming(_:with:atScale:)),
        #selector(scrollViewShouldScrollToTop(_:)),
        #selector(scrollViewDidScrollToTop(_:)),
        #selector(scrollViewDidChangeAdjustedContentInset(_:)),
        
        //ColectionView DataSource
        #selector(collectionView(_:viewForSupplementaryElementOfKind:at:)),
        
        #selector(collectionView(_:canMoveItemAt:)),
        #selector(collectionView(_:moveItemAt:to:)),
        
        #selector(indexTitles(for:)),
        #selector(collectionView(_:indexPathForIndexTitle:at:)),
        
        //ColectionView Delegate
        #selector(collectionView(_:shouldSelectItemAt:)),
        #selector(collectionView(_:didSelectItemAt:)),
        #selector(collectionView(_:shouldDeselectItemAt:)),
        #selector(collectionView(_:didDeselectItemAt:)),
        #selector(collectionView(_:shouldBeginMultipleSelectionInteractionAt:)),
        #selector(collectionView(_:didBeginMultipleSelectionInteractionAt:)),
        #selector(collectionViewDidEndMultipleSelectionInteraction(_:)),
        
        #selector(collectionView(_:shouldHighlightItemAt:)),
        #selector(collectionView(_:didHighlightItemAt:)),
        #selector(collectionView(_:didUnhighlightItemAt:)),
        
        #selector(collectionView(_:willDisplay:forItemAt:)),
        #selector(collectionView(_:willDisplaySupplementaryView:forElementKind:at:)),
        #selector(collectionView(_:didEndDisplaying:forItemAt:)),
        #selector(collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)),
        
        #selector(collectionView(_:transitionLayoutForOldLayout:newLayout:)),
        #selector(collectionView(_:targetContentOffsetForProposedContentOffset:)),
        #selector(collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)),
        
        #selector(collectionView(_:shouldShowMenuForItemAt:)),
        #selector(collectionView(_:canPerformAction:forItemAt:withSender:)),
        #selector(collectionView(_:performAction:forItemAt:withSender:)),
        
        #selector(collectionView(_:canFocusItemAt:)),
        #selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:)),
        #selector(collectionView(_:shouldUpdateFocusIn:)),
        #selector(collectionView(_:didUpdateFocusIn:with:)),
        
        //ColectionView Delegate FlowLayout
        #selector(collectionView(_:layout:sizeForItemAt:)),
        
        #selector(collectionView(_:layout:insetForSectionAt:)),
        #selector(collectionView(_:layout:minimumLineSpacingForSectionAt:)),
        #selector(collectionView(_:layout:minimumInteritemSpacingForSectionAt:)),
        
        #selector(collectionView(_:layout:referenceSizeForHeaderInSection:)),
        #selector(collectionView(_:layout:referenceSizeForFooterInSection:)),
        
        //TableView DataSource
        #selector(tableView(_:titleForHeaderInSection:)),
        #selector(tableView(_:titleForFooterInSection:)),
        
        #selector(tableView(_:commit:forRowAt:)),
        #selector(tableView(_:canEditRowAt:)),
        
        #selector(tableView(_:canMoveRowAt:)),
        #selector(tableView(_:moveRowAt:to:)),
        
        #selector(sectionIndexTitles(for:)),
        #selector(tableView(_:sectionForSectionIndexTitle:at:)),
        
        //TableView Delegate
        #selector(tableView(_:willDisplay:forRowAt:)),
        #selector(tableView(_:indentationLevelForRowAt:)),
        
        #selector(tableView(_:willSelectRowAt:)),
        #selector(tableView(_:didSelectRowAt:)),
        #selector(tableView(_:willDeselectRowAt:)),
        #selector(tableView(_:didDeselectRowAt:)),
        #selector(tableView(_:shouldBeginMultipleSelectionInteractionAt:)),
        #selector(tableView(_:didBeginMultipleSelectionInteractionAt:)),
        #selector(tableViewDidEndMultipleSelectionInteraction(_:)),
        
        #selector(tableView(_:viewForHeaderInSection:)),
        #selector(tableView(_:viewForFooterInSection:)),
        #selector(tableView(_:willDisplayHeaderView:forSection:)),
        #selector(tableView(_:willDisplayFooterView:forSection:)),
        
        #selector(tableView(_:heightForRowAt:)),
        #selector(tableView(_:heightForHeaderInSection:)),
        #selector(tableView(_:heightForFooterInSection:)),
        
        #selector(tableView(_:estimatedHeightForRowAt:)),
        #selector(tableView(_:estimatedHeightForHeaderInSection:)),
        #selector(tableView(_:estimatedHeightForFooterInSection:)),
        
        #selector(tableView(_:accessoryButtonTappedForRowWith:)),
        
        #selector(tableView(_:shouldShowMenuForRowAt:)),
        #selector(tableView(_:canPerformAction:forRowAt:withSender:)),
        #selector(tableView(_:performAction:forRowAt:withSender:)),
        #selector(tableView(_:performAction:forRowAt:withSender:)),
        #selector(tableView(_:editActionsForRowAt:)),
        
        #selector(tableView(_:shouldHighlightRowAt:)),
        #selector(tableView(_:didHighlightRowAt:)),
        #selector(tableView(_:didUnhighlightRowAt:)),
        #selector(tableView(_:willBeginEditingRowAt:)),
        #selector(tableView(_:didEndEditingRowAt:)),
        #selector(tableView(_:editingStyleForRowAt:)),
        #selector(tableView(_:titleForDeleteConfirmationButtonForRowAt:)),
        #selector(tableView(_:shouldIndentWhileEditingRowAt:)),
        
        #selector(tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)),
        
        #selector(tableView(_:didEndDisplaying:forRowAt:)),
        #selector(tableView(_:didEndDisplayingHeaderView:forSection:)),
        #selector(tableView(_:didEndDisplayingFooterView:forSection:)),
        
        #selector(tableView(_:canFocusRowAt:)),
        #selector(tableView(_:shouldUpdateFocusIn:)),
        #selector(tableView(_:didUpdateFocusIn:with:)),
        #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)),
    ]
    

    @available(iOS 11.0, *)
    lazy var notAdded11Selector: Set<Selector> = [
        #selector(collectionView(_:shouldSpringLoadItemAt:with:)),
        
        #selector(tableView(_:shouldSpringLoadRowAt:with:)),
        #selector(tableView(_:leadingSwipeActionsConfigurationForRowAt:)),
        #selector(tableView(_:trailingSwipeActionsConfigurationForRowAt:)),
    ]

    @available(iOS 13.0, *)
    lazy var notAdded13Selector: Set<Selector> = [
        #selector(collectionView(_:shouldBeginMultipleSelectionInteractionAt:)),
        #selector(collectionView(_:didBeginMultipleSelectionInteractionAt:)),
        #selector(collectionViewDidEndMultipleSelectionInteraction(_:)),
        
        #selector(collectionView(_:contextMenuConfigurationForItemAt:point:)),
        #selector(collectionView(_:previewForDismissingContextMenuWithConfiguration:)),
        #selector(collectionView(_:previewForHighlightingContextMenuWithConfiguration:)),
        #selector(collectionView(_:willCommitMenuWithAnimator:)),
        #selector(collectionView(_:willPerformPreviewActionForMenuWith:animator:)),
        
        #selector(tableView(_:shouldBeginMultipleSelectionInteractionAt:)),
        #selector(tableView(_:didBeginMultipleSelectionInteractionAt:)),
        #selector(tableViewDidEndMultipleSelectionInteraction(_:)),
        
        #selector(tableView(_:leadingSwipeActionsConfigurationForRowAt:)),
        #selector(tableView(_:trailingSwipeActionsConfigurationForRowAt:)),
        
        #selector(tableView(_:contextMenuConfigurationForRowAt:point:)),
        #selector(tableView(_:previewForDismissingContextMenuWithConfiguration:)),
        #selector(tableView(_:previewForHighlightingContextMenuWithConfiguration:)),
        #selector(tableView(_:willCommitMenuWithAnimator:)),
        #selector(tableView(_:willPerformPreviewActionForMenuWith:animator:)),
        
        #selector(tableView(_:contextMenuConfigurationForRowAt:point:)),
        #selector(tableView(_:previewForDismissingContextMenuWithConfiguration:)),
        #selector(tableView(_:previewForHighlightingContextMenuWithConfiguration:)),
        #selector(tableView(_:willCommitMenuWithAnimator:)),
        #selector(tableView(_:willPerformPreviewActionForMenuWith:animator:)),
    ]
    
    override public func responds(to aSelector: Selector!) -> Bool {
        if notAddedSelector.contains(aSelector) { return false }
        if #available(iOS 11.0, *), notAdded11Selector.contains(aSelector) { return false }
        if #available(iOS 13.0, *), notAdded13Selector.contains(aSelector) { return false }
        return super.responds(to: aSelector)
    }
    
    func numbersOfSections() -> Int { fatalError() }
    func numbersOfItems(in section: Int) -> Int { fatalError() }
}

//MARK: - ScrollView Delegate
extension Coordinator: UIScrollViewDelegate { }

public extension Coordinator {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll!(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDidZoom!(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDragging!(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDragging!(scrollView, velocity, targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDragging!(scrollView, decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating!(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating!(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation!(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        viewForZooming!(scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewWillBeginZooming!(scrollView, view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDidEndZooming!(scrollView, view, scale)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollViewShouldScrollToTop!(scrollView)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidScrollToTop!(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDidChangeAdjustedContentInset!(scrollView)
    }
}

//MARK: - ColectionView DataSource

extension Coordinator: UICollectionViewDataSource { }

public extension Coordinator {
    //Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numbersOfItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        numbersOfSections()
    }
    
    //Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionViewCellForItemAt!(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        collectionViewViewForSupplementaryElementOfKindAt!(collectionView, kind, indexPath)
    }
    
    //Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        collectionViewCanMoveItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionViewMoveItemAtTo!(collectionView, sourceIndexPath, destinationIndexPath)
    }

    //Configuring an Index
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        indexTitles!(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        collectionViewIndexPathForIndexTitleAt!(collectionView, title, index)
    }
}

//MARK: - ColectionView Delegate

extension Coordinator: UICollectionViewDelegate { }

public extension Coordinator {
    
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionViewShouldSelectItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewDidSelectItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        collectionViewShouldDeselectItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionViewDidDeselectItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        collectionViewShouldBeginMultipleSelectionInteractionAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        collectionViewDidBeginMultipleSelectionInteractionAt!(collectionView, indexPath)
    }

    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        collectionViewDidEndMultipleSelectionInteraction!(collectionView)
    }

    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        collectionViewShouldHighlightItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionViewDidHighlightItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionViewDidUnhighlightItemAt!(collectionView, indexPath)
    }

    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionViewWillDisplayForItemAt!(collectionView, cell, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        collectionViewWillDisplaySupplementaryViewForElementKindAt!(collectionView, view, elementKind, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionViewDidEndDisplayingForItemAt!(collectionView, cell, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAt!(collectionView, view, elementKind, indexPath)
    }

    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        collectionViewTransitionLayoutForOldLayoutNewLayout!(collectionView, fromLayout, toLayout)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        collectionViewTargetContentOffsetForProposedContentOffset!(collectionView, proposedContentOffset)
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPath!(collectionView, originalIndexPath, proposedIndexPath)
    }

    //Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        collectionViewShouldShowMenuForItemAt!(collectionView, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        collectionViewCanPerformActionForItemAtWithSender!(collectionView, action, indexPath, sender)
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        collectionViewPerformActionForItemAtWithSender!(collectionView, action, indexPath, sender)
    }

    //Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        collectionViewCanFocusItemAt!(collectionView, indexPath)
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        indexPathForPreferredFocusedView!(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        collectionViewShouldUpdateFocusIn!(collectionView, context)
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        collectionViewDidUpdateFocusInWith!(collectionView, context, coordinator)
    }

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        collectionViewShouldSpringLoadItemAtWith!(collectionView, indexPath, context)
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        collectionViewContextMenuConfigurationForItemAtPoint!(collectionView, indexPath, point)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        collectionViewPreviewForDismissingContextMenuWithConfiguration!(collectionView, configuration)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        collectionViewPreviewForHighlightingContextMenuWithConfiguration!(collectionView, configuration)
    }
    
    @available(iOS 13.0, *)
    @objc func collectionView(_ collectionView: UICollectionView, willCommitMenuWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        collectionViewWillCommitMenuWithAnimator!(collectionView, animator)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        collectionViewWillPerformPreviewActionForMenuWithAnimator!(collectionView, configuration, animator)
    }
}

//MARK: - ColectionView Delegate FlowLayout
extension Coordinator: UICollectionViewDelegateFlowLayout { }

public extension Coordinator {
    //Getting the Size of Items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionViewLayoutSizeForItemAt!(collectionView, collectionViewLayout, indexPath)
    }

    //Getting the Section Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionViewLayoutInsetForSectionAt!(collectionView, collectionViewLayout, section)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionViewLayoutMinimumLineSpacingForSectionAt!(collectionView, collectionViewLayout, section)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionViewLayoutMinimumInteritemSpacingForSectionAt!(collectionView, collectionViewLayout, section)
    }

    //Getting the Header and Footer Sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        collectionViewLayoutReferenceSizeForHeaderInSection!(collectionView, collectionViewLayout, section)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        collectionViewLayoutReferenceSizeForFooterInSection!(collectionView, collectionViewLayout, section)
    }
}

//MARK: - TableView DataSource
extension Coordinator: UITableViewDataSource { }

public extension Coordinator {
    //Providing the Number of Rows and Sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numbersOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        numbersOfSections()
    }
    
    //Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableViewCellForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableViewTitleForHeaderInSection!(tableView, section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        tableViewTitleForFooterInSection!(tableView, section)
    }

    //Inserting or Deleting Table Rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableViewCommitforRowAt!(tableView, editingStyle, indexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tableViewCanEditRowAt!(tableView, indexPath)
    }
    
    //Reordering Table Rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        tableViewCanMoveRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableViewMoveRowAtTo!(tableView, sourceIndexPath, destinationIndexPath)
    }

    //Configuring an Index
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionIndexTitles!(tableView)
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableViewSectionForSectionIndexTitleAt!(tableView, title, index)
    }
}

//MARK: - TableView Delegate
extension Coordinator: UITableViewDelegate { }

public extension Coordinator {
    //Configuring Rows for the Table View
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewWillDisplayForRowAt!(tableView, cell, indexPath)
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        tableViewIndentationLevelForRowAt!(tableView, indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        tableViewShouldSpringLoadRowAtWith!(tableView, indexPath, context)
    }

    //Responding to Row Selections
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableViewWillSelectRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDidSelectRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        tableViewWillDeselectRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableViewDidDeselectRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        tableViewShouldBeginMultipleSelectionInteractionAt!(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        tableViewDidEndMultipleSelectionInteraction!(tableView, indexPath)
    }

    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        tableViewDidBeginMultipleSelectionInteractionAt!(tableView)
    }
    
    //Providing Custom Header and Footer Views
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableViewViewForHeaderInSection!(tableView, section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        tableViewViewForFooterInSection!(tableView, section)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableViewWillDisplayHeaderViewForSection!(tableView, view, section)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tableViewWillDisplayFooterViewForSection!(tableView, view, section)
    }

    //Providing Header, Footer, and Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableViewheightForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableViewheightForHeaderInSection!(tableView, section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        tableViewheightForFooterInSection!(tableView, section)
    }

    //Estimating Heights for the Table's Content
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        tableViewEstimatedHeightForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        tableViewEstimatedHeightForHeaderInSection!(tableView, section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        tableViewEstimatedHeightForFooterInSection!(tableView, section)
    }

    //Managing Accessory Views
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableViewAccessoryButtonTappedForRowWith!(tableView, indexPath)
    }

    //Responding to Row Actions
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        tableViewLeadingSwipeActionsConfigurationForRowAt!(tableView, indexPath)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        tableViewTrailingSwipeActionsConfigurationForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        tableViewShouldShowMenuForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        tableViewCanPerformActionForRowAtWithSender!(tableView, action, indexPath, sender)
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        tableViewPerformActionForRowAtWithSender!(tableView, action, indexPath, sender)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        tableViewEditActionsForRowAt!(tableView, indexPath)
    }

    //Managing Table View Highlights
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        tableViewShouldHighlightRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableViewDidHighlightRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableViewDidUnhighlightRowAt!(tableView, indexPath)
    }

    //Editing Table Rows

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableViewWillBeginEditingRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableViewDidEndEditingRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        tableViewEditingStyleForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        tableViewTitleForDeleteConfirmationButtonForRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        tableViewShouldIndentWhileEditingRowAt!(tableView, indexPath)
    }

    //Reordering Table Rows

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        tableViewTargetIndexPathForMoveFromRowAtToProposedIndexPath!(tableView, sourceIndexPath, proposedDestinationIndexPath)
    }

    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewDidEndDisplayingForRowAt!(tableView, cell, indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tableViewDidEndDisplayingHeaderViewForSection!(tableView, view, section)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tableViewDidEndDisplayingFooterViewForSection!(tableView, view, section)
    }

    //Managing Table View Focus
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        tableViewCanFocusRowAt!(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        tableViewShouldUpdateFocusIn!(tableView, context)
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        tableViewDidUpdateFocusInWith!(tableView, context, coordinator)
    }

    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        indexPathForTableViewPreferredFocusedView!(tableView)
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        tableViewContextMenuConfigurationForRowAtPoint!(tableView, indexPath, point)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        tableViewPreviewForDismissingContextMenuWithConfiguration!(tableView, configuration)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        tableViewPreviewForHighlightingContextMenuWithConfiguration!(tableView, configuration)
    }

    @available(iOS 13.0, *)
    @objc func tableView(_ tableView: UITableView, willCommitMenuWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        tableViewWillCommitMenuWithAnimator!(tableView, animator)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        tableViewWillPerformPreviewActionForMenuWithAnimator!(tableView, configuration, animator)
    }
}

#endif
