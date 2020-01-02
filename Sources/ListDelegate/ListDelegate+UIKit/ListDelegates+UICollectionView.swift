//
//  ListDelegate+UICollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

final class UICollectionListDelegate {
    typealias Delegate<Input, Output> = ListKit.Delegate<UICollectionView, Input, Output>
    //MARK - DataSources
    
    //Getting Views for Items
    var cellForItemAt = Delegate<IndexPath, UICollectionViewCell>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:))
    )
    
    var viewForSupplementaryElementOfKindAt = Delegate<(String, IndexPath), UICollectionReusableView>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:))
    )

    //Reordering Items
    var canMoveItemAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:))
    )
    
    var moveItemAtTo = Delegate<(IndexPath, IndexPath), Void>(
        #selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:))
    )
    
    //Configuring an Index
    var indexTitles = Delegate<Void, [String]?>(
        #selector(UICollectionViewDataSource.indexTitles(for:))
    )
    
    var indexPathForIndexTitleAt = Delegate<(String, Int), IndexPath>(
        #selector(UICollectionViewDataSource.collectionView(_:indexPathForIndexTitle:at:))
    )
    
    //MARK: - Delegates
    
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
    
    //MARK: - FlowLayout
    //Getting the Size of Items
    var layoutSizeForItemAt = Delegate<(UICollectionViewLayout, IndexPath), CGSize>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))
    )
    
    //Getting the Section Spacing
    var layoutInsetForSectionAt = Delegate<(UICollectionViewLayout, Int), UIEdgeInsets>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))
    )
    
    var layoutMinimumLineSpacingForSectionAt = Delegate<(UICollectionViewLayout, Int), CGFloat>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:))
    )
    
    var layoutMinimumInteritemSpacingForSectionAt = Delegate<(UICollectionViewLayout, Int), CGFloat>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))
    )
    
    //Getting the Header and Footer Sizes
    var layoutReferenceSizeForHeaderInSection = Delegate<(UICollectionViewLayout, Int), CGSize>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))
    )
    
    var layoutReferenceSizeForFooterInSection = Delegate<(UICollectionViewLayout, Int), CGSize>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))
    )
    
    func add(by selectorSets: inout SelectorSets) {
        //DataSource
        //Getting Views for Items
        selectorSets.add(cellForItemAt)
        selectorSets.add(viewForSupplementaryElementOfKindAt)

        //Reordering Items
        selectorSets.add(canMoveItemAt)
        selectorSets.add(moveItemAtTo)

        //Configuring an Index
        selectorSets.add(indexTitles)
        selectorSets.add(indexPathForIndexTitleAt)
        
        //Delegate
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
        
        //FlowLayout
        //Getting the Size of Items
        selectorSets.add(layoutSizeForItemAt)
        
        //Getting the Section Spacing
        selectorSets.add(layoutInsetForSectionAt)
        selectorSets.add(layoutMinimumLineSpacingForSectionAt)
        selectorSets.add(layoutMinimumInteritemSpacingForSectionAt)
        
        //Getting the Header and Footer Sizes
        selectorSets.add(layoutReferenceSizeForHeaderInSection)
        selectorSets.add(layoutReferenceSizeForFooterInSection)
    }
}

extension ListDelegate: UICollectionViewDataSource {
    //Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        coordinator.numbersOfItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        coordinator.numbersOfSections()
    }
    
    //Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        apply(\.collectionListDelegate.cellForItemAt, object: collectionView, with: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        apply(\.collectionListDelegate.viewForSupplementaryElementOfKindAt, object: collectionView, with: (kind, indexPath))
    }
    
    //Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.canMoveItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(\.collectionListDelegate.moveItemAtTo, object: collectionView, with: (sourceIndexPath, destinationIndexPath))
    }

    //Configuring an Index
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        apply(\.collectionListDelegate.indexTitles, object: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        apply(\.collectionListDelegate.indexPathForIndexTitleAt, object: collectionView, with: (title, index))
    }
}

extension ListDelegate: UICollectionViewDelegate {
    
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.shouldSelectItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.didSelectItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.shouldDeselectItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.didDeselectItemAt, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.shouldBeginMultipleSelectionInteractionAt, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.didBeginMultipleSelectionInteractionAt, object: collectionView, with: indexPath)
    }
    
    @available(iOS 13.0, *)
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        apply(\.collectionListDelegate.didEndMultipleSelectionInteraction, object: collectionView)
    }

    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.shouldHighlightItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.didHighlightItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.didUnhighlightItemAt, object: collectionView, with: indexPath)
    }

    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.willDisplayForItemAt, object: collectionView, with: (cell, indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        apply(\.collectionListDelegate.willDisplaySupplementaryViewForElementKindAt, object: collectionView, with: (view, elementKind, indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        apply(\.collectionListDelegate.didEndDisplayingForItemAt, object: collectionView, with: (cell, indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        apply(\.collectionListDelegate.didEndDisplayingSupplementaryViewForElementOfKindAt, object: collectionView, with: (view, elementKind, indexPath))
    }

    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        apply(\.collectionListDelegate.transitionLayoutForOldLayoutNewLayout, object: collectionView, with: (fromLayout, toLayout))
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        apply(\.collectionListDelegate.targetContentOffsetForProposedContentOffset, object: collectionView, with: (proposedContentOffset))
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        apply(\.collectionListDelegate.targetIndexPathForMoveFromItemAtToProposedIndexPath, object: collectionView, with: (originalIndexPath, proposedIndexPath))
    }

    //Managing Actions for Cells
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.shouldShowMenuForItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        apply(\.collectionListDelegate.canPerformActionForItemAtWithSender, object: collectionView, with: (action, indexPath, sender))
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        apply(\.collectionListDelegate.performActionForItemAtWithSender, object: collectionView, with: (action, indexPath, sender))
    }

    //Managing Focus in a Collection View
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionListDelegate.canFocusItemAt, object: collectionView, with: indexPath)
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        apply(\.collectionListDelegate.indexPathForPreferredFocusedView, object: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        apply(\.collectionListDelegate.shouldUpdateFocusIn, object: collectionView, with: context)
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        apply(\.collectionListDelegate.didUpdateFocusInWith, object: collectionView, with: (context, coordinator))
    }

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        apply(\.collectionListDelegate.shouldSpringLoadItemAtWith, object: collectionView, with: (indexPath, context))
    }

    //Instance Methods
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        apply(\.collectionListDelegate.contextMenuConfigurationForItemAtPoint, object: collectionView, with: (indexPath, point))
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.collectionListDelegate.previewForDismissingContextMenuWithConfiguration, object: collectionView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        apply(\.collectionListDelegate.previewForHighlightingContextMenuWithConfiguration, object: collectionView, with: (configuration))
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        apply(\.collectionListDelegate.willPerformPreviewActionForMenuWithAnimator, object: collectionView, with: (configuration, animator))
    }
}

extension ListDelegate: UICollectionViewDelegateFlowLayout {
    //Getting the Size of Items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        apply(\.collectionListDelegate.layoutSizeForItemAt, object: collectionView, with: (collectionViewLayout, indexPath))
    }

    //Getting the Section Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        apply(\.collectionListDelegate.layoutInsetForSectionAt, object: collectionView, with: (collectionViewLayout, section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        apply(\.collectionListDelegate.layoutMinimumLineSpacingForSectionAt, object: collectionView, with: (collectionViewLayout, section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        apply(\.collectionListDelegate.layoutMinimumInteritemSpacingForSectionAt, object: collectionView, with: (collectionViewLayout, section))
    }

    //Getting the Header and Footer Sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        apply(\.collectionListDelegate.layoutReferenceSizeForHeaderInSection, object: collectionView, with: (collectionViewLayout, section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        apply(\.collectionListDelegate.layoutReferenceSizeForFooterInSection, object: collectionView, with: (collectionViewLayout, section))
    }
}


#endif
