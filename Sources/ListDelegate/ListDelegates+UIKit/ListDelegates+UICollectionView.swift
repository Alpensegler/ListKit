//
//  ListDelegate+UICollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

final class UICollectionListDelegate: ListDelegates<UICollectionView> {
    //MARK - DataSources
    
    //Getting Views for Items
    lazy var cellForItemAt = ItemDelegate<IndexPath, UICollectionViewCell>(
        #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)),
        index: \.self
    ) { _, _  in UICollectionViewCell() }
    
    lazy var viewForSupplementaryElementOfKindAt = ItemDelegate<(String, IndexPath), UICollectionReusableView>(
        #selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)),
        index: \.1
    ) { _, _ in UICollectionReusableView() }

    //Reordering Items
    lazy var canMoveItemAt = ItemDelegate<IndexPath, Bool>(
        #selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var moveItemAtTo = Delegate<(IndexPath, IndexPath), Void>(
        #selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:))
    )
    
    //Configuring an Index
    lazy var indexTitles = Delegate<Void, [String]?>(
        #selector(UICollectionViewDataSource.indexTitles(for:))
    )
    
    lazy var indexPathForIndexTitleAt = Delegate<(String, Int), IndexPath>(
        #selector(UICollectionViewDataSource.collectionView(_:indexPathForIndexTitle:at:))
    )
    
    //MARK: - Delegates
    
    //Managing the Selected Cells
    lazy var shouldSelectItemAt = ItemDelegate<IndexPath, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var didSelectItemAt = ItemDelegate<IndexPath, Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)),
        index: \.self
    )
    
    lazy var shouldDeselectItemAt = ItemDelegate<IndexPath, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var didDeselectItemAt = ItemDelegate<IndexPath, Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)),
        index: \.self
    )
    
    private lazy var anyShouldBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return ItemDelegate<IndexPath, Bool>(
            #selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)),
            index: \.self
        ) { _, _ in false }
    }()
    
    private lazy var anyDidBeginMultipleSelectionInteractionAt: Any = {
        guard #available(iOS 13, *) else { return () }
        return ItemDelegate<IndexPath, Void>(
            #selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)),
            index: \.self
        )
    }()
    
    private lazy var anyDidEndMultipleSelectionInteraction: Any = {
        guard #available(iOS 13, *) else { return () }
        return Delegate<Void, Void>(
            #selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:))
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
    
    //Managing Cell Highlighting
    lazy var shouldHighlightItemAt = ItemDelegate<IndexPath, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var didHighlightItemAt = ItemDelegate<IndexPath, Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)),
        index: \.self
    )
    
    lazy var didUnhighlightItemAt = ItemDelegate<IndexPath, Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)),
        index: \.self
    )

    //Tracking the Addition and Removal of Views
    lazy var willDisplayForItemAt = ItemDelegate<(UICollectionViewCell, IndexPath), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)),
        index: \.1
    )
    
    lazy var willDisplaySupplementaryViewForElementKindAt = ItemDelegate<(UICollectionReusableView, String, IndexPath), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)),
        index: \.2
    )
    
    lazy var didEndDisplayingForItemAt = ItemDelegate<(UICollectionViewCell, IndexPath), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)),
        index: \.1
    )
    
    lazy var didEndDisplayingSupplementaryViewForElementOfKindAt = ItemDelegate<(UICollectionReusableView, String, IndexPath), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)),
        index: \.2
    )
    
    //Handling Layout Changes
    lazy var transitionLayoutForOldLayoutNewLayout = Delegate<(UICollectionViewLayout, UICollectionViewLayout), UICollectionViewTransitionLayout>(
        #selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:))
    )
    
    lazy var targetContentOffsetForProposedContentOffset = Delegate<CGPoint, CGPoint>(
        #selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:))
    )
    
    lazy var targetIndexPathForMoveFromItemAtToProposedIndexPath = Delegate<(IndexPath, IndexPath), IndexPath>(
        #selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:))
    )
    
    //Managing Actions for Cells
    lazy var shouldShowMenuForItemAt = ItemDelegate<IndexPath, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)),
        index: \.self
    ) { _, _ in false }
    
    lazy var canPerformActionForItemAtWithSender = ItemDelegate<(Selector, IndexPath, Any?), Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)),
        index: \.1
    ) { _, _ in false }
    
    lazy var performActionForItemAtWithSender = ItemDelegate<(Selector, IndexPath, Any?), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)),
        index: \.1
    )
    
    //Managing Focus in a Collection View
    lazy var canFocusItemAt = ItemDelegate<IndexPath, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)),
        index: \.self
    ) { _, _ in true }
    
    lazy var indexPathForPreferredFocusedView = Delegate<Void, IndexPath?>(
        #selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:))
    )
    
    lazy var shouldUpdateFocusIn = Delegate<UICollectionViewFocusUpdateContext, Bool>(
        #selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:))
    )
    
    lazy var didUpdateFocusInWith = Delegate<(UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator), Void>(
        #selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:))
    )

    //Controlling the Spring-Loading Behavior
    private lazy var anyShouldSpringLoadItemAtWith: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return ItemDelegate<(IndexPath, UISpringLoadedInteractionContext), Bool>(
            #selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)),
            index: \.0
        ) { _, _ in true }
    }()
    
    
    @available(iOS 11.0, *)
    var shouldSpringLoadItemAtWith: ItemDelegate<(IndexPath, UISpringLoadedInteractionContext), Bool> {
        get { anyShouldSpringLoadItemAtWith as! ItemDelegate<(IndexPath, UISpringLoadedInteractionContext), Bool> }
        set { anyShouldSpringLoadItemAtWith = newValue }
    }
    
    //Instance Methods
    private lazy var anyContextMenuConfigurationForItemAtPoint: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return ItemDelegate<(IndexPath, CGPoint), UIContextMenuConfiguration?>(
            #selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:)),
            index: \.0
        ) { _, _ in nil }
    }()
    
    private lazy var anyPreviewForDismissingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:))
        )
    }()
    
    private lazy var anyPreviewForHighlightingContextMenuWithConfiguration: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<UIContextMenuConfiguration, UITargetedPreview>(
            #selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:))
        )
    }()
    
    private lazy var anyWillPerformPreviewActionForMenuWithAnimator: Any = {
        guard #available(iOS 13.0, *) else { return () }
        return Delegate<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void>(
            #selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:))
        )
    }()
    
    @available(iOS 13.0, *)
    var contextMenuConfigurationForItemAtPoint: ItemDelegate<(IndexPath, CGPoint), UIContextMenuConfiguration?> {
        get { anyContextMenuConfigurationForItemAtPoint as! ItemDelegate<(IndexPath, CGPoint), UIContextMenuConfiguration?> }
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
    lazy var layoutSizeForItemAt = ItemDelegate<(UICollectionViewLayout, IndexPath), CGSize>(
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)),
        index: \.1
    ) { input, _ in (input.0 as? UICollectionViewFlowLayout)?.itemSize ?? .zero }
    
    //Getting the Section Spacing
    lazy var layoutInsetForSectionAt = SectionDelegate<(UICollectionViewLayout, Int), UIEdgeInsets>(
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)),
        index: \.1
    ) { input, _ in (input.0 as? UICollectionViewFlowLayout)?.sectionInset ?? .zero }
    
    lazy var layoutMinimumLineSpacingForSectionAt = SectionDelegate<(UICollectionViewLayout, Int), CGFloat>(
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)),
        index: \.1
    ) { input, _ in (input.0 as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0 }
    
    lazy var layoutMinimumInteritemSpacingForSectionAt = SectionDelegate<(UICollectionViewLayout, Int), CGFloat>(
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)),
        index: \.1
    ) { input, _ in (input.0 as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0 }
    
    //Getting the Header and Footer Sizes
    lazy var layoutReferenceSizeForHeaderInSection = SectionDelegate<(UICollectionViewLayout, Int), CGSize>(
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)),
        index: \.1
    ) { input, _ in (input.0 as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero }
    
    lazy var layoutReferenceSizeForFooterInSection = SectionDelegate<(UICollectionViewLayout, Int), CGSize>(
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)),
        index: \.1
    ) { input, _ in (input.0 as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero }
}

extension ListDelegate: UICollectionViewDataSource {
    //Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        context.numbersOfItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        context.numbersOfSections()
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
