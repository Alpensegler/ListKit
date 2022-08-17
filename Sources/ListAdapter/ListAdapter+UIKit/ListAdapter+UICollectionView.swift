//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

// swiftlint:disable identifier_name large_tuple line_length

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - Collection View Data Source
public extension DataSource {
    var collectionViewCellForItem: ListDelegate.IndexFunction<UICollectionView, Self, IndexPath, UICollectionViewCell, (ListIndexContext<UICollectionView, Self, IndexPath>, Model) -> UICollectionViewCell, IndexPath> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), toClosure())
    }
}

public extension ListAdapter where View: UICollectionView {
    // MARK: - Getting Views for Items
    var collectionViewCellForItem: ModelFunction<IndexPath, UICollectionViewCell, (ListModelContext, Model) -> UICollectionViewCell> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), toClosure())
    }

    var collectionViewSupplementaryViewForItem: ModelFunction<(IndexPath, String), UICollectionReusableView, (ListModelContext, CollectionView.SupplementaryViewType) -> UICollectionReusableView> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), \.0) { closure in { context, input in closure(context, .init(rawValue: input.1)) } }
    }

    // MARK: - Reordering Items
    var collectionViewCanMoveItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)), toClosure())
    }

    var collectionViewMoveItem: Function<(IndexPath, IndexPath), Void, (ListContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)), toClosure())
    }
}

// MARK: - Collection View Delegate
public extension ListAdapter where View: UICollectionView {
    // MARK: - Managing the Selected Cells
    var collectionViewShouldSelectItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)), toClosure())
    }

    var collectionViewDidSelectItem: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)), toClosure())
    }

    var collectionViewShouldDeselectItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)), toClosure())
    }

    var collectionViewDidDeselectItem: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewShouldBeginMultipleSelectionInteractionForItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewDidBeginMultipleSelectionInteractionAtForItem: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewDidEndMultipleSelectionInteraction: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }

    // MARK: - Managing Cell Highlighting
    var collectionViewShouldHighlightItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)), toClosure())
    }

    var collectionViewDidHighlightItem: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)), toClosure())
    }

    var collectionViewDidUnhighlightItem: ModelFunction<IndexPath, Void, (ListModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)), toClosure())
    }

    // MARK: - Tracking the Addition and Removal of Views
    var collectionViewWillDisplayForItem: ModelFunction<(IndexPath, UICollectionViewCell), Void, (ListModelContext, UICollectionViewCell, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)), \.0, toClosure())
    }

    var collectionViewWillDisplaySupplementaryView: ModelFunction<(IndexPath, UICollectionReusableView, String), Void, (ListModelContext, UICollectionReusableView, CollectionView.SupplementaryViewType, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)), \.0) { closure in { context, input in closure(context, input.1, .init(rawValue: input.2), context.model) } }
    }

    var collectionViewDidEndDisplayingItem: Function<(IndexPath, UICollectionViewCell), Void, (ListContext, IndexPath, UICollectionViewCell) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)), toClosure())
    }

    var collectionViewDidEndDisplayingSupplementaryView: Function<(UICollectionReusableView, String, IndexPath), Void, (ListContext, UICollectionReusableView, CollectionView.SupplementaryViewType, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))) { closure in { context, input in closure(context, input.0, .init(rawValue: input.1), input.2) } }
    }

    // MARK: - Handling Layout Changes
    var collectionViewTransitionLayoutForOldLayoutNewLayout: Function<(UICollectionViewLayout, UICollectionViewLayout), UICollectionViewTransitionLayout, (ListContext, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)), toClosure())
    }

    var collectionViewTargetContentOffset: Function<CGPoint, CGPoint, (ListContext, CGPoint) -> CGPoint> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:)), toClosure())
    }

    var collectionViewTargetIndexPathForMoveFromItem: Function<(IndexPath, IndexPath), IndexPath, (ListContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)), toClosure())
    }

    // MARK: - Managing Actions for Cells
    var collectionViewShouldShowMenuForItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)), toClosure())
    }

    var collectionViewCanPerformActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Bool, (ListModelContext, Selector, Any?, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)), \.0, toClosure())
    }

    var collectionViewPerformActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Void, (ListModelContext, Selector, Any?, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)), \.0, toClosure())
    }

    // MARK: - Managing Focus in a Collection View
    var collectionViewCanFocusItem: ModelFunction<IndexPath, Bool, (ListModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)), toClosure())
    }

    var collectionViewIndexPathForPreferredFocusedView: Function<Void, IndexPath?, (ListContext) -> IndexPath?> {
        toFunction(#selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
    }

    var collectionViewShouldUpdateFocusIn: Function<UICollectionViewFocusUpdateContext, Bool, (ListContext, UICollectionViewFocusUpdateContext) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:)), toClosure())
    }

    var collectionViewDidUpdateFocusInWith: Function<(UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (ListContext, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:)), toClosure())
    }

    // MARK: - Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    var collectionViewShouldSpringLoadItemAtWith: ModelFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (ListModelContext, UISpringLoadedInteractionContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)), \.0, toClosure())
    }

    // MARK: - Instance Methods
    @available(iOS 13.0, *)
    var collectionViewContextMenuConfigurationForItem: ModelFunction<(IndexPath, CGPoint), UIContextMenuConfiguration?, (ListModelContext, CGPoint, Model) -> UIContextMenuConfiguration> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:)), \.0, toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewPreviewForDismissingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewPreviewForHighlightingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewWillPerformPreviewActionForMenuWithAnimator: Function<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (ListContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
    }
}

// MARK: - Collection View Delegate Flow Layout
public extension ListAdapter where View: UICollectionView {
    // MARK: - Getting the Size of Items
    var collectionViewLayoutSizeForItem: ModelFunction<(IndexPath, UICollectionViewLayout), CGSize, (ListModelContext, UICollectionViewLayout, Model) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)), \.0, toClosure())
    }

    // MARK: - Getting the Section Spacing
    var collectionViewLayoutInsetForSection: SectionFunction<(Int, UICollectionViewLayout), UIEdgeInsets, (ListSectionContext, UICollectionViewLayout) -> UIEdgeInsets> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)), \.0, toClosure())
    }

    var collectionViewLayoutMinimumLineSpacingForSection: SectionFunction<(Int, UICollectionViewLayout), CGFloat, (ListSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)), \.0, toClosure())
    }

    var collectionViewLayoutMinimumInteritemSpacingForSection: SectionFunction<(Int, UICollectionViewLayout), CGFloat, (ListSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)), \.0, toClosure())
    }

    // MARK: - yGetting the Header and Footer Sizes
    var collectionViewLayoutReferenceSizeForHeaderInSection: SectionFunction<(Int, UICollectionViewLayout), CGSize, (ListSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)), \.0, toClosure())
    }

    var collectionViewLayoutReferenceSizeForFooterInSection: SectionFunction<(Int, UICollectionViewLayout), CGSize, (ListSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)), \.0, toClosure())
    }
}

#endif
