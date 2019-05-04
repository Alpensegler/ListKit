//
//  CollectionViewDelegate.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/29.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class UICollectionDelegateWrapper: ScrollViewDelegateWrapper, UICollectionViewDelegate {
    let collectionViewShouldHighlightItemAtBlock: (UICollectionView, IndexPath) -> Bool
    let collectionViewDidHighlightItemAtBlock: (UICollectionView, IndexPath) -> Void
    let collectionViewDidUnhighlightItemAtBlock: (UICollectionView, IndexPath) -> Void
    let collectionViewShouldSelectItemAtBlock:  (UICollectionView, IndexPath) -> Bool
    let collectionViewShouldDeselectItemAtBlock:  (UICollectionView, IndexPath) -> Bool
    let collectionViewDidSelectItemAtBlock: (UICollectionView, IndexPath) -> Void
    let collectionViewDidDeselectItemAtBlock: (UICollectionView, IndexPath) -> Void
    let collectionViewWillDisplayForItemAtBlock: (UICollectionView, UICollectionViewCell, IndexPath) -> Void
    let collectionViewWillDisplaySupplementaryViewForElementKindAtBlock: (UICollectionView, UICollectionReusableView, String, IndexPath) -> Void
    let collectionViewDidEndDisplayingForItemAtBlock: (UICollectionView, UICollectionViewCell, IndexPath) -> Void
    let collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAtBlock: (UICollectionView, UICollectionReusableView, String, IndexPath) -> Void
    let collectionViewShouldShowMenuForItemAtBlock: (UICollectionView, IndexPath) -> Bool
    let collectionViewCanPerformActionForItemAtWithSenderBlock: (UICollectionView, Selector, IndexPath, Any?) -> Bool
    let collectionViewPerformActionForItemAtWithSenderBlock: (UICollectionView, Selector, IndexPath, Any?) -> Void
    let collectionViewTransitionLayoutForOldLayoutNewLayoutBlock: (UICollectionView, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout
    let collectionViewCanFocusItemAtBlock: (UICollectionView, IndexPath) -> Bool
    let collectionViewShouldUpdateFocusInBlock: (UICollectionView, UICollectionViewFocusUpdateContext) -> Bool
    let collectionViewDidUpdateFocusInWithBlock: (UICollectionView, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    let indexPathForPreferredFocusedViewBlock: (UICollectionView) -> IndexPath?
    let collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPathBlock: (UICollectionView, IndexPath, IndexPath) -> IndexPath
    let collectionViewTargetContentOffsetForProposedContentOffsetBlock: (UICollectionView, CGPoint) -> CGPoint
    
    let collectionViewShouldSpringLoadItemAtWith: Any?
    
    @available(iOS 11.0, *)
    var collectionViewShouldSpringLoadItemAtWithBlock: ((UICollectionView, IndexPath, UISpringLoadedInteractionContext) -> Bool)? {
        return collectionViewShouldSpringLoadItemAtWith as? (UICollectionView, IndexPath, UISpringLoadedInteractionContext) -> Bool
    }
    
    init(_ delegate: CollectionViewDelegate) {
        collectionViewShouldHighlightItemAtBlock = { [unowned delegate] in delegate.collectionView($0, shouldHighlightItemAt: $1) }
        collectionViewDidHighlightItemAtBlock = { [unowned delegate] in delegate.collectionView($0, didHighlightItemAt: $1) }
        collectionViewDidUnhighlightItemAtBlock = { [unowned delegate] in delegate.collectionView($0, didUnhighlightItemAt: $1) }
        collectionViewShouldSelectItemAtBlock = { [unowned delegate] in delegate.collectionView($0, shouldSelectItemAt: $1) }
        collectionViewShouldDeselectItemAtBlock = { [unowned delegate] in delegate.collectionView($0, shouldDeselectItemAt: $1) }
        collectionViewDidSelectItemAtBlock = { [unowned delegate] in delegate.collectionView($0, didSelectItemAt: $1) }
        collectionViewDidDeselectItemAtBlock = { [unowned delegate] in delegate.collectionView($0, didDeselectItemAt: $1) }
        collectionViewWillDisplayForItemAtBlock = { [unowned delegate] in delegate.collectionView($0, willDisplay: $1, forItemAt: $2) }
        collectionViewWillDisplaySupplementaryViewForElementKindAtBlock = { [unowned delegate] in delegate.collectionView($0, willDisplaySupplementaryView: $1, forElementKind: $2, at: $3) }
        collectionViewDidEndDisplayingForItemAtBlock = { [unowned delegate] in delegate.collectionView($0, didEndDisplaying: $1, forItemAt: $2) }
        collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAtBlock = { [unowned delegate] in delegate.collectionView($0, didEndDisplayingSupplementaryView: $1, forElementOfKind: $2, at: $3) }
        collectionViewShouldShowMenuForItemAtBlock = { [unowned delegate] in delegate.collectionView($0, shouldShowMenuForItemAt: $1) }
        collectionViewCanPerformActionForItemAtWithSenderBlock = { [unowned delegate] in delegate.collectionView($0, canPerformAction: $1, forItemAt: $2, withSender: $3) }
        collectionViewPerformActionForItemAtWithSenderBlock = { [unowned delegate] in delegate.collectionView($0, performAction: $1, forItemAt: $2, withSender: $3) }
        collectionViewTransitionLayoutForOldLayoutNewLayoutBlock = { [unowned delegate] in delegate.collectionView($0, transitionLayoutForOldLayout: $1, newLayout: $2) }
        collectionViewCanFocusItemAtBlock = { [unowned delegate] in delegate.collectionView($0, canFocusItemAt: $1) }
        collectionViewShouldUpdateFocusInBlock = { [unowned delegate] in delegate.collectionView($0, shouldUpdateFocusIn: $1) }
        collectionViewDidUpdateFocusInWithBlock = { [unowned delegate] in delegate.collectionView($0, didUpdateFocusIn: $1, with: $2) }
        indexPathForPreferredFocusedViewBlock = { [unowned delegate] in delegate.indexPathForPreferredFocusedView(in: $0) }
        collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPathBlock = { [unowned delegate] in delegate.collectionView($0, targetIndexPathForMoveFromItemAt: $1, toProposedIndexPath: $2) }
        collectionViewTargetContentOffsetForProposedContentOffsetBlock = { [unowned delegate] in delegate.collectionView($0, targetContentOffsetForProposedContentOffset: $1) }
        
        if #available(iOS 11.0, *) {
            collectionViewShouldSpringLoadItemAtWith = { [unowned delegate] in delegate.collectionView($0, shouldSpringLoadItemAt: $1, with: $2) }
        } else {
            collectionViewShouldSpringLoadItemAtWith = nil
        }
        super.init(delegate)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldHighlightItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
         collectionViewDidHighlightItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
         collectionViewDidUnhighlightItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldSelectItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldDeselectItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         collectionViewDidSelectItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
         collectionViewDidDeselectItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         collectionViewWillDisplayForItemAtBlock(collectionView, cell, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        collectionViewWillDisplaySupplementaryViewForElementKindAtBlock(collectionView, view, elementKind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         collectionViewDidEndDisplayingForItemAtBlock(collectionView, cell, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
         collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAtBlock(collectionView, view, elementKind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldShowMenuForItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
         return collectionViewCanPerformActionForItemAtWithSenderBlock(collectionView, action, indexPath, sender)
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
         collectionViewPerformActionForItemAtWithSenderBlock(collectionView, action, indexPath, sender)
    }
    
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
         return collectionViewTransitionLayoutForOldLayoutNewLayoutBlock(collectionView, fromLayout, toLayout)
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
         return collectionViewCanFocusItemAtBlock(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
         return collectionViewShouldUpdateFocusInBlock(collectionView, context)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
         collectionViewDidUpdateFocusInWithBlock(collectionView, context, coordinator)
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
         return indexPathForPreferredFocusedViewBlock(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
         return collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPathBlock(collectionView, originalIndexPath, proposedIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
         return collectionViewTargetContentOffsetForProposedContentOffsetBlock(collectionView, proposedContentOffset)
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return collectionViewShouldSpringLoadItemAtWithBlock?(collectionView, indexPath, context) ?? true
    }
}

public protocol CollectionViewDelegate: ScrollViewDelegate {
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    
    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    
    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath)
    
    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
    
    //Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
    
    //Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath?
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
    
    var asCollectionViewDelegate: UICollectionViewDelegate { get }
}

private var collectionViewDelegateKey: Void?

public extension CollectionViewDelegate {
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return true }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool { return true }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { }
    
    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return true }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) { }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) { }
    
    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) { }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) { }
    
    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout { return .init(currentLayout: fromLayout, nextLayout: toLayout) }
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint { return  proposedContentOffset }
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath { return proposedIndexPath }
    
    //Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool { return false }
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool { return false }
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) { }
    
    //Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool { return collectionView.allowsSelection }
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool { return true }
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) { }
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? { return nil }
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool { return true }
    
    var asCollectionViewDelegate: UICollectionViewDelegate {
        return Associator.getValue(key: &collectionViewDelegateKey, from: self, initialValue: UICollectionDelegateWrapper(self))
    }
    
    var asScrollViewDelegate: UIScrollViewDelegate {
        return asCollectionViewDelegate
    }
}

public extension CollectionViewDelegate where Self: TableViewDelegate {
    var asScrollViewDelegate: UIScrollViewDelegate {
        return asCollectionViewDelegate
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) { }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) { }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { }
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) { }
}
