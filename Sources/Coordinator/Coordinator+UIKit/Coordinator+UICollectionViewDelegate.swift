//
//  Coordinator+UICollectionViewDelegate.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

class UICollectionViewDelegates {
    typealias Delegate<Input, Output> = ListKit.Delegate<UICollectionView, Input, Output>
    
    //Managing the Selected Cells
    var shouldSelectItemAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:))
    )
    
    var didSelectItemAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:))
    )
    
    var shouldDeselectItemAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:))
    )
    
    var didDeselectItemAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:))
    )
    
    private var anyShouldBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<IndexPath, Bool>(
            index: .indexPath(\.self),
            #selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    private var anyDidBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<IndexPath, Void>(
            index: .indexPath(\.self),
            #selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:))
        )
    }()
    
    private var anyDidEndMultipleSelectionInteraction: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<Void, Void>(
            #selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:))
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
    
    //Managing Cell Highlighting
    var shouldHighlightItemAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:))
    )
    
    var didHighlightItemAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:))
    )
    
    var didUnhighlightItemAt = Delegate<IndexPath, Void>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:))
    )

    //Tracking the Addition and Removal of Views
    var willDisplayForItemAt = Delegate<(UICollectionViewCell, IndexPath), Void>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))
    )
    
    var willDisplaySupplementaryViewForElementKindAt = Delegate<(UICollectionReusableView, String, IndexPath), Void>(
        index: .indexPath(\.2),
        #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:))
    )
    
    var didEndDisplayingForItemAt = Delegate<(UICollectionViewCell, IndexPath), Void>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))
    )
    
    var didEndDisplayingSupplementaryViewForElementOfKindAt = Delegate<(UICollectionReusableView, String, IndexPath), Void>(
        index: .indexPath(\.2),
        #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))
    )
    
    //Handling Layout Changes
    var transitionLayoutForOldLayoutNewLayout = Delegate<(UICollectionViewLayout, UICollectionViewLayout), UICollectionViewTransitionLayout>(
        #selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:))
    )
    
    var targetContentOffsetForProposedContentOffset = Delegate<CGPoint, CGPoint>(
        #selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:))
    )
    
    var targetIndexPathForMoveFromItemAtToProposedIndexPath = Delegate<(IndexPath, IndexPath), IndexPath>(
        #selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:))
    )
    
    //Managing Actions for Cells
    var shouldShowMenuForItemAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:))
    )
    
    var canPerformActionForItemAtWithSender = Delegate<(Selector, IndexPath, Any?), Bool>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:))
    )
    
    var performActionForItemAtWithSender = Delegate<(Selector, IndexPath, Any?), Void>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:))
    )
    
    //Managing Focus in a Collection View
    var canFocusItemAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:))
    )
    
    var indexPathForPreferredFocusedView = Delegate<Void, IndexPath?>(
        #selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:))
    )
    
    var shouldUpdateFocusIn = Delegate<UICollectionViewFocusUpdateContext, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:))
    )
    
    var didUpdateFocusInWith = Delegate<(UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:))
    )

    //Controlling the Spring-Loading Behavior
    private var anyShouldSpringLoadItemAtWith: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool>(
            index: .indexPath(\.0),
            #selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:))
        )
    }()
    
    
    @available(iOS 11.0, *)
    var shouldSpringLoadItemAtWith: Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool> {
        get { anyShouldSpringLoadItemAtWith as! Delegate<(IndexPath, UISpringLoadedInteractionContext), Bool> }
        set { anyShouldSpringLoadItemAtWith = newValue }
    }
    
    //Instance Methods
    private var anyContextMenuConfigurationForItemAtPoint: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration>(
            index: .indexPath(\.0),
            #selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:))
        )
    }()
    
    private var anyPreviewForDismissingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:))
        )
    }()
    
    private var anyPreviewForHighlightingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:))
        )
    }()
    
    private var anyWillPerformPreviewActionForMenuWithAnimator: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void>(
            #selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:))
        )
    }()
    
    @available(iOS 13.0, *)
    var contextMenuConfigurationForItemAtPoint: Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration> {
        get { anyContextMenuConfigurationForItemAtPoint as! Delegate<(IndexPath, CGPoint), UIContextMenuConfiguration> }
        set { anyContextMenuConfigurationForItemAtPoint = newValue }
    }
    
    @available(iOS 13.0, *)
    var previewForDismissingContextMenuWithConfiguration: Delegate<UIContextMenuConfiguration, UITargetedPreview> {
        get { anyPreviewForDismissingContextMenuWithConfiguration as! Delegate<UIContextMenuConfiguration, UITargetedPreview> }
        set { anyPreviewForDismissingContextMenuWithConfiguration = newValue }
    }
    
    @available(iOS 13.0, *)
    var previewForHighlightingContextMenuWithConfiguration: Delegate<UIContextMenuConfiguration, UITargetedPreview> {
        get { anyPreviewForHighlightingContextMenuWithConfiguration as! Delegate<UIContextMenuConfiguration, UITargetedPreview> }
        set { anyPreviewForHighlightingContextMenuWithConfiguration = newValue }
    }
    
    @available(iOS 13.0, *)
    var willPerformPreviewActionForMenuWithAnimator: Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void> {
        get { anyWillPerformPreviewActionForMenuWithAnimator as! Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void> }
        set { anyWillPerformPreviewActionForMenuWithAnimator = newValue }
    }
    
    func add(by selectorSets: inout SelectorSets) {
        //Managing the Selected Cells
        selectorSets.add(shouldSelectItemAt)
        selectorSets.add(didSelectItemAt)
        selectorSets.add(shouldDeselectItemAt)
        selectorSets.add(didDeselectItemAt)
        if #available(iOS 13.0, *) {
            selectorSets.add(shouldBeginMultipleSelectionInteractionAt)
            selectorSets.add(didBeginMultipleSelectionInteractionAt)
            selectorSets.add(didEndMultipleSelectionInteraction)
        }
        
        //Managing Cell Highlighting
        selectorSets.add(shouldHighlightItemAt)
        selectorSets.add(didHighlightItemAt)
        selectorSets.add(didUnhighlightItemAt)
        
        //Tracking the Addition and Removal of Views
        selectorSets.add(willDisplayForItemAt)
        selectorSets.add(willDisplaySupplementaryViewForElementKindAt)
        selectorSets.add(didEndDisplayingForItemAt)
        selectorSets.add(didEndDisplayingSupplementaryViewForElementOfKindAt)
        
        //Handling Layout Changes
        selectorSets.add(transitionLayoutForOldLayoutNewLayout)
        selectorSets.add(targetContentOffsetForProposedContentOffset)
        selectorSets.add(targetIndexPathForMoveFromItemAtToProposedIndexPath)
        
        //Managing Actions for Cells
        selectorSets.add(shouldShowMenuForItemAt)
        selectorSets.add(canPerformActionForItemAtWithSender)
        selectorSets.add(performActionForItemAtWithSender)
        
        //Managing Focus in a Collection View
        selectorSets.add(canFocusItemAt)
        selectorSets.add(indexPathForPreferredFocusedView)
        selectorSets.add(shouldUpdateFocusIn)
        selectorSets.add(didUpdateFocusInWith)
        if #available(iOS 11.0, *) {
            selectorSets.add(shouldSpringLoadItemAtWith)
        }
        
        //Instance Methods
        if #available(iOS 13.0, *) {
            selectorSets.add(contextMenuConfigurationForItemAtPoint)
            selectorSets.add(previewForDismissingContextMenuWithConfiguration)
            selectorSets.add(previewForHighlightingContextMenuWithConfiguration)
            selectorSets.add(willPerformPreviewActionForMenuWithAnimator)
        }
    }
}

extension BaseCoordinator: UICollectionViewDelegate { }

public extension BaseCoordinator {
    
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDelegates.shouldSelectItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didSelectItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDelegates.shouldDeselectItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didDeselectItemAt, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDelegates.shouldBeginMultipleSelectionInteractionAt, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didBeginMultipleSelectionInteractionAt, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        apply(\.collectionViewDelegates.didEndMultipleSelectionInteraction, object: collectionView)
    }

    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDelegates.shouldHighlightItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didHighlightItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didUnhighlightItemAt, object: collectionView, with: indexPath)
    }

    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.willDisplayForItemAt, object: collectionView, with: (cell, indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        apply(\.collectionViewDelegates.willDisplaySupplementaryViewForElementKindAt, object: collectionView, with: (view, elementKind, indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didEndDisplayingForItemAt, object: collectionView, with: (cell, indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        apply(\.collectionViewDelegates.didEndDisplayingSupplementaryViewForElementOfKindAt, object: collectionView, with: (view, elementKind, indexPath))
    }

    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        apply(\.collectionViewDelegates.transitionLayoutForOldLayoutNewLayout, object: collectionView, with: (fromLayout, toLayout))
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        apply(\.collectionViewDelegates.targetContentOffsetForProposedContentOffset, object: collectionView, with: (proposedContentOffset))
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        apply(\.collectionViewDelegates.targetIndexPathForMoveFromItemAtToProposedIndexPath, object: collectionView, with: (originalIndexPath, proposedIndexPath))
    }

    //Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDelegates.shouldShowMenuForItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(\.collectionViewDelegates.canPerformActionForItemAtWithSender, object: collectionView, with: (action, indexPath, sender))
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        apply(\.collectionViewDelegates.performActionForItemAtWithSender, object: collectionView, with: (action, indexPath, sender))
    }

    //Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDelegates.canFocusItemAt, object: collectionView, with: indexPath)
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        apply(\.collectionViewDelegates.indexPathForPreferredFocusedView, object: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        apply(\.collectionViewDelegates.shouldUpdateFocusIn, object: collectionView, with: context)
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(\.collectionViewDelegates.didUpdateFocusInWith, object: collectionView, with: (context, coordinator))
    }

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(\.collectionViewDelegates.shouldSpringLoadItemAtWith, object: collectionView, with: (indexPath, context))
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(\.collectionViewDelegates.contextMenuConfigurationForItemAtPoint, object: collectionView, with: (indexPath, point))
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.collectionViewDelegates.previewForDismissingContextMenuWithConfiguration, object: collectionView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.collectionViewDelegates.previewForHighlightingContextMenuWithConfiguration, object: collectionView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(\.collectionViewDelegates.willPerformPreviewActionForMenuWithAnimator, object: collectionView, with: (configuration, animator))
    }
}


#endif
