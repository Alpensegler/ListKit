//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

// swiftlint:disable identifier_name large_tuple line_length

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    typealias CollectionContext = ListContext<UICollectionView, Self>
    typealias CollectionModelContext = ListIndexContext<UICollectionView, Self, IndexPath>
    typealias CollectionSectionContext = ListIndexContext<UICollectionView, Self, Int>

    typealias CollectionFunction<Input, Output, Closure> = ListDelegate.Function<UICollectionView, Self, CollectionList<AdapterBase>, Input, Output, Closure>
    typealias CollectionModelFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UICollectionView, Self, CollectionList<AdapterBase>, Input, Output, Closure, IndexPath>
    typealias CollectionSectionFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UICollectionView, Self, CollectionList<AdapterBase>, Input, Output, Closure, Int>
}

// MARK: - Collection View Data Source
public extension DataSource {
    // MARK: - Getting Views for Items
    var collectionViewCellForItem: CollectionModelFunction<IndexPath, UICollectionViewCell, (CollectionModelContext, Model) -> UICollectionViewCell> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), toClosure())
    }

    var collectionViewSupplementaryViewForItem: CollectionModelFunction<(IndexPath, String), UICollectionReusableView, (CollectionModelContext, CollectionView.SupplementaryViewType) -> UICollectionReusableView> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), \.0) { closure in { context, input in closure(context, .init(rawValue: input.1)) } }
    }

    // MARK: - Reordering Items
    var collectionViewCanMoveItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)), toClosure())
    }

    var collectionViewMoveItem: CollectionFunction<(IndexPath, IndexPath), Void, (CollectionContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)), toClosure())
    }
}

// MARK: - Collection View Delegate
public extension DataSource {
    // MARK: - Managing the Selected Cells
    var collectionViewShouldSelectItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)), toClosure())
    }

    var collectionViewDidSelectItem: CollectionModelFunction<IndexPath, Void, (CollectionModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)), toClosure())
    }

    var collectionViewShouldDeselectItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)), toClosure())
    }

    var collectionViewDidDeselectItem: CollectionModelFunction<IndexPath, Void, (CollectionModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewShouldBeginMultipleSelectionInteractionForItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewDidBeginMultipleSelectionInteractionAtForItem: CollectionModelFunction<IndexPath, Void, (CollectionModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewDidEndMultipleSelectionInteraction: CollectionFunction<Void, Void, (CollectionContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }

    // MARK: - Managing Cell Highlighting
    var collectionViewShouldHighlightItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)), toClosure())
    }

    var collectionViewDidHighlightItem: CollectionModelFunction<IndexPath, Void, (CollectionModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)), toClosure())
    }

    var collectionViewDidUnhighlightItem: CollectionModelFunction<IndexPath, Void, (CollectionModelContext, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)), toClosure())
    }

    // MARK: - Tracking the Addition and Removal of Views
    var collectionViewWillDisplayForItem: CollectionModelFunction<(IndexPath, UICollectionViewCell), Void, (CollectionModelContext, UICollectionViewCell, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)), \.0, toClosure())
    }

    var collectionViewWillDisplaySupplementaryView: CollectionModelFunction<(IndexPath, UICollectionReusableView, String), Void, (CollectionModelContext, UICollectionReusableView, CollectionView.SupplementaryViewType, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)), \.0) { closure in { context, input in closure(context, input.1, .init(rawValue: input.2), context.model) } }
    }

    var collectionViewDidEndDisplayingItem: CollectionFunction<(IndexPath, UICollectionViewCell), Void, (CollectionContext, IndexPath, UICollectionViewCell) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)), toClosure())
    }

    var collectionViewDidEndDisplayingSupplementaryView: CollectionFunction<(UICollectionReusableView, String, IndexPath), Void, (CollectionContext, UICollectionReusableView, CollectionView.SupplementaryViewType, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))) { closure in { context, input in closure(context, input.0, .init(rawValue: input.1), input.2) } }
    }

    // MARK: - Handling Layout Changes
    var collectionViewTransitionLayoutForOldLayoutNewLayout: CollectionFunction<(UICollectionViewLayout, UICollectionViewLayout), UICollectionViewTransitionLayout, (CollectionContext, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)), toClosure())
    }

    var collectionViewTargetContentOffset: CollectionFunction<CGPoint, CGPoint, (CollectionContext, CGPoint) -> CGPoint> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:)), toClosure())
    }

    var collectionViewTargetIndexPathForMoveFromItem: CollectionFunction<(IndexPath, IndexPath), IndexPath, (CollectionContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)), toClosure())
    }

    // MARK: - Managing Actions for Cells
    var collectionViewShouldShowMenuForItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)), toClosure())
    }

    var collectionViewCanPerformActionWithSender: CollectionModelFunction<(IndexPath, Selector, Any?), Bool, (CollectionModelContext, Selector, Any?, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)), \.0, toClosure())
    }

    var collectionViewPerformActionWithSender: CollectionModelFunction<(IndexPath, Selector, Any?), Void, (CollectionModelContext, Selector, Any?, Model) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)), \.0, toClosure())
    }

    // MARK: - Managing Focus in a Collection View
    var collectionViewCanFocusItem: CollectionModelFunction<IndexPath, Bool, (CollectionModelContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)), toClosure())
    }

    var collectionViewIndexPathForPreferredFocusedView: CollectionFunction<Void, IndexPath?, (CollectionContext) -> IndexPath?> {
        toFunction(#selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
    }

    var collectionViewShouldUpdateFocusIn: CollectionFunction<UICollectionViewFocusUpdateContext, Bool, (CollectionContext, UICollectionViewFocusUpdateContext) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:)), toClosure())
    }

    var collectionViewDidUpdateFocusInWith: CollectionFunction<(UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (CollectionContext, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:)), toClosure())
    }

    // MARK: - Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    var collectionViewShouldSpringLoadItemAtWith: CollectionModelFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (CollectionModelContext, UISpringLoadedInteractionContext, Model) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)), \.0, toClosure())
    }

    // MARK: - Instance Methods
    @available(iOS 13.0, *)
    var collectionViewContextMenuConfigurationForItem: CollectionModelFunction<(IndexPath, CGPoint), UIContextMenuConfiguration?, (CollectionModelContext, CGPoint, Model) -> UIContextMenuConfiguration> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:)), \.0, toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewPreviewForDismissingContextMenuWithConfiguration: CollectionFunction<UIContextMenuConfiguration, UITargetedPreview, (CollectionContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewPreviewForHighlightingContextMenuWithConfiguration: CollectionFunction<UIContextMenuConfiguration, UITargetedPreview, (CollectionContext, UIContextMenuConfiguration) -> UITargetedPreview> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
    }

    @available(iOS 13.0, *)
    var collectionViewWillPerformPreviewActionForMenuWithAnimator: CollectionFunction<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (CollectionContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
    }
}

// MARK: - Collection View Delegate Flow Layout
public extension DataSource {
    // MARK: - Getting the Size of Items
    var collectionViewLayoutSizeForItem: CollectionModelFunction<(IndexPath, UICollectionViewLayout), CGSize, (CollectionModelContext, UICollectionViewLayout, Model) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)), \.0, toClosure())
    }

    // MARK: - Getting the Section Spacing
    var collectionViewLayoutInsetForSection: CollectionSectionFunction<(Int, UICollectionViewLayout), UIEdgeInsets, (CollectionSectionContext, UICollectionViewLayout) -> UIEdgeInsets> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)), \.0, toClosure())
    }

    var collectionViewLayoutMinimumLineSpacingForSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGFloat, (CollectionSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)), \.0, toClosure())
    }

    var collectionViewLayoutMinimumInteritemSpacingForSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGFloat, (CollectionSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)), \.0, toClosure())
    }

    // MARK: - yGetting the Header and Footer Sizes
    var collectionViewLayoutReferenceSizeForHeaderInSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGSize, (CollectionSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)), \.0, toClosure())
    }

    var collectionViewLayoutReferenceSizeForFooterInSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGSize, (CollectionSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)), \.0, toClosure())
    }
}

#endif
