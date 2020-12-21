//
//  ListDelegate+UICollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

extension Delegate: UICollectionViewDataSource {
    //Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        context.numbersOfItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        context.numbersOfSections()
    }
    
    //Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        apply(collectionViewCellForItem, object: collectionView, with: indexPath) ?? .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        apply(collectionViewSupplementaryViewForItem, object: collectionView, with: (indexPath, kind)) ?? .init()
    }
    
    //Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        apply(collectionViewCanMoveItem, object: collectionView, with: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(collectionViewMoveItem, object: collectionView, with: (sourceIndexPath, destinationIndexPath))
    }

    //Configuring an Index
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        apply(collectionViewIndexTitles, object: collectionView) ?? nil
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        apply(collectionViewIndexPathForIndexTitle, object: collectionView, with: (title, index)) ?? .zero
    }
}

extension Delegate: UICollectionViewDelegate {
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        apply(collectionViewShouldSelectItem, object: collectionView, with: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        apply(collectionViewDidSelectItem, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        apply(collectionViewShouldDeselectItem, object: collectionView, with: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        apply(collectionViewDidDeselectItem, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(collectionViewShouldBeginMultipleSelectionInteractionForItem, object: collectionView, with: indexPath) ?? true
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(collectionViewDidBeginMultipleSelectionInteractionAtForItem, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        apply(collectionViewDidEndMultipleSelectionInteraction, object: collectionView)
    }

    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        apply(collectionViewShouldHighlightItem, object: collectionView, with: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        apply(collectionViewDidHighlightItem, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        apply(collectionViewDidUnhighlightItem, object: collectionView, with: indexPath)
    }

    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(collectionViewWillDisplayForItem, object: collectionView, with: (indexPath, cell))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        apply(collectionViewWillDisplaySupplementaryView, object: collectionView, with: (indexPath, view, elementKind))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(collectionViewDidEndDisplayingItem, object: collectionView, with: (indexPath, cell))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        apply(collectionViewDidEndDisplayingSupplementaryView, object: collectionView, with: (view, elementKind, indexPath))
    }

    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        apply(collectionViewTransitionLayoutForOldLayoutNewLayout, object: collectionView, with: (fromLayout, toLayout)) ?? .init(currentLayout: fromLayout, nextLayout: toLayout)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        apply(collectionViewTargetContentOffset, object: collectionView, with: (proposedContentOffset)) ?? proposedContentOffset
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        apply(collectionViewTargetIndexPathForMoveFromItem, object: collectionView, with: (originalIndexPath, proposedIndexPath)) ?? proposedIndexPath
    }

    //Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        apply(collectionViewShouldShowMenuForItem, object: collectionView, with: indexPath) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(collectionViewCanPerformActionWithSender, object: collectionView, with: (indexPath, action, sender)) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        apply(collectionViewPerformActionWithSender, object: collectionView, with: (indexPath, action, sender))
    }

    //Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        apply(collectionViewCanFocusItem, object: collectionView, with: indexPath) ?? true
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        apply(collectionViewIndexPathForPreferredFocusedView, object: collectionView) ?? nil
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        apply(collectionViewShouldUpdateFocusIn, object: collectionView, with: context) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(collectionViewDidUpdateFocusInWith, object: collectionView, with: (context, coordinator))
    }

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(collectionViewShouldSpringLoadItemAtWith, object: collectionView, with: (indexPath, context)) ?? true
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(collectionViewContextMenuConfigurationForItem, object: collectionView, with: (indexPath, point)) ?? nil
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(collectionViewPreviewForDismissingContextMenuWithConfiguration, object: collectionView, with: (configuration)) ?? nil
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(collectionViewPreviewForHighlightingContextMenuWithConfiguration, object: collectionView, with: (configuration)) ?? nil
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(collectionViewWillPerformPreviewActionForMenuWithAnimator, object: collectionView, with: (configuration, animator))
    }
}

extension Delegate: UICollectionViewDelegateFlowLayout {
    //Getting the Size of Items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        apply(collectionViewLayoutSizeForItem, object: collectionView, with: (indexPath, collectionViewLayout)) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }

    //Getting the Section Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        apply(collectionViewLayoutInsetForSection, object: collectionView, with: (section, collectionViewLayout)) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        apply(collectionViewLayoutMinimumLineSpacingForSection, object: collectionView, with: (section, collectionViewLayout)) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        apply(collectionViewLayoutMinimumInteritemSpacingForSection, object: collectionView, with: (section, collectionViewLayout)) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? .zero
    }

    //Getting the Header and Footer Sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        apply(collectionViewLayoutReferenceSizeForHeaderInSection, object: collectionView, with: (section, collectionViewLayout)) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        apply(collectionViewLayoutReferenceSizeForFooterInSection, object: collectionView, with: (section, collectionViewLayout)) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
    }
}


#endif
