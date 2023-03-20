//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

// swiftlint:disable large_tuple

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - Collection View Data Source
public extension DataSource {
    var cellForItem: IndexFunction<Self, UICollectionView, IndexPath, UICollectionViewCell, (ListIndexContext<UICollectionView, IndexPath>) -> UICollectionViewCell, IndexPath> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), toClosure())
    }
}

public extension ListAdapter where View: UICollectionView {
    // MARK: - Getting Views for Items
    var cellForItem: ModelFunction<IndexPath, UICollectionViewCell, (ListModelContext) -> UICollectionViewCell> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), toClosure())
    }

    var supplementaryViewForItem: ModelFunction<(IndexPath, String), UICollectionReusableView, (ListModelContext, CollectionView.SupplementaryViewType) -> UICollectionReusableView> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), \.0) { closure in { context, input in closure(context, .init(rawValue: input.1)) } }
    }

//    // MARK: - Reordering Items
//    var canMoveItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)), toClosure())
//    }
//
//    var moveItem: Function<(IndexPath, IndexPath), Void, (ListContext, IndexPath, IndexPath) -> Void> {
//        toFunction(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)), toClosure())
//    }
}

// MARK: - Collection View Delegate
public extension ListAdapter where View: UICollectionView {
    // MARK: - Managing the Selected Cells
    var shouldSelectItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)), toClosure())
    }

    var didSelectItem: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)), toClosure())
    }

    var shouldDeselectItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)), toClosure())
    }

    var didDeselectItem: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)), toClosure())
    }

//    @available(iOS 13.0, *)
//    var shouldBeginMultipleSelectionInteractionForItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var didBeginMultipleSelectionInteractionAtForItem: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var didEndMultipleSelectionInteraction: Function<Void, Void, (ListContext) -> Void> {
//        toFunction(#selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:)), toClosure())
//    }

    // MARK: - Managing Cell Highlighting
    var shouldHighlightItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)), toClosure())
    }

    var didHighlightItem: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)), toClosure())
    }

    var didUnhighlightItem: ModelFunction<IndexPath, Void, (ListModelContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)), toClosure())
    }

    // MARK: - Tracking the Addition and Removal of Views
    var willDisplayForItem: ModelFunction<(IndexPath, UICollectionViewCell), Void, (ListModelContext, UICollectionViewCell) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)), \.0, toClosure())
    }

    var willDisplaySupplementaryView: ModelFunction<(IndexPath, UICollectionReusableView, String), Void, (ListModelContext, UICollectionReusableView, CollectionView.SupplementaryViewType) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)), \.0) { closure in { context, input in closure(context, input.1, .init(rawValue: input.2)) } }
    }

    var didEndDisplayingItem: Function<(IndexPath, UICollectionViewCell), Void, (ListContext, IndexPath, UICollectionViewCell) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)), toClosure())
    }

    var didEndDisplayingSupplementaryView: Function<(UICollectionReusableView, String, IndexPath), Void, (ListContext, UICollectionReusableView, CollectionView.SupplementaryViewType, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))) { closure in { context, input in closure(context, input.0, .init(rawValue: input.1), input.2) } }
    }

//    // MARK: - Handling Layout Changes
//    var transitionLayoutForOldLayoutNewLayout: Function<(UICollectionViewLayout, UICollectionViewLayout), UICollectionViewTransitionLayout, (ListContext, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)), toClosure())
//    }
//
//    var targetContentOffset: Function<CGPoint, CGPoint, (ListContext, CGPoint) -> CGPoint> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:)), toClosure())
//    }
//
//    var targetIndexPathForMoveFromItem: Function<(IndexPath, IndexPath), IndexPath, (ListContext, IndexPath, IndexPath) -> IndexPath> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)), toClosure())
//    }
//
//    // MARK: - Managing Actions for Cells
//    var shouldShowMenuForItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)), toClosure())
//    }
//
//    var canPerformActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Bool, (ListModelContext, Selector, Any?) -> Bool> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)), \.0, toClosure())
//    }
//
//    var performActionWithSender: ModelFunction<(IndexPath, Selector, Any?), Void, (ListModelContext, Selector, Any?) -> Void> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)), \.0, toClosure())
//    }
//
//    // MARK: - Managing Focus in a Collection View
//    var canFocusItem: ModelFunction<IndexPath, Bool, (ListModelContext) -> Bool> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)), toClosure())
//    }
//
//    var indexPathForPreferredFocusedView: Function<Void, IndexPath?, (ListContext) -> IndexPath?> {
//        toFunction(#selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:)), toClosure())
//    }
//
//    var shouldUpdateFocusIn: Function<UICollectionViewFocusUpdateContext, Bool, (ListContext, UICollectionViewFocusUpdateContext) -> Bool> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:)), toClosure())
//    }
//
//    var didUpdateFocusInWith: Function<(UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator), Void, (ListContext, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:)), toClosure())
//    }
//
//    // MARK: - Controlling the Spring-Loading Behavior
//    @available(iOS 11.0, *)
//    var shouldSpringLoadItemAtWith: ModelFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (ListModelContext, UISpringLoadedInteractionContext) -> Bool> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)), \.0, toClosure())
//    }
//
//    // MARK: - Instance Methods
//    @available(iOS 13.0, *)
//    var contextMenuConfigurationForItem: ModelFunction<(IndexPath, CGPoint), UIContextMenuConfiguration?, (ListModelContext, CGPoint) -> UIContextMenuConfiguration> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:)), \.0, toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var previewForDismissingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var previewForHighlightingContextMenuWithConfiguration: Function<UIContextMenuConfiguration, UITargetedPreview, (ListContext, UIContextMenuConfiguration) -> UITargetedPreview> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:)), toClosure())
//    }
//
//    @available(iOS 13.0, *)
//    var willPerformPreviewActionForMenuWithAnimator: Function<(UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating), Void, (ListContext, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void> {
//        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:)), toClosure())
//    }
}

// MARK: - Collection View Delegate Flow Layout
public extension ListAdapter where View: UICollectionView {
    // MARK: - Getting the Size of Items
    var layoutSizeForItem: ModelFunction<(IndexPath, UICollectionViewLayout), CGSize, (ListModelContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)), \.0, toClosure())
    }

    // MARK: - Getting the Section Spacing
    var layoutInsetForSection: SectionFunction<(Int, UICollectionViewLayout), UIEdgeInsets, (ListSectionContext, UICollectionViewLayout) -> UIEdgeInsets> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)), \.0, toClosure())
    }

    var layoutMinimumLineSpacingForSection: SectionFunction<(Int, UICollectionViewLayout), CGFloat, (ListSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)), \.0, toClosure())
    }

    var layoutMinimumInteritemSpacingForSection: SectionFunction<(Int, UICollectionViewLayout), CGFloat, (ListSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)), \.0, toClosure())
    }

    // MARK: - yGetting the Header and Footer Sizes
    var layoutReferenceSizeForHeaderInSection: SectionFunction<(Int, UICollectionViewLayout), CGSize, (ListSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)), \.0, toClosure())
    }

    var layoutReferenceSizeForFooterInSection: SectionFunction<(Int, UICollectionViewLayout), CGSize, (ListSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)), \.0, toClosure())
    }
}

#endif
