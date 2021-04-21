//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    typealias CollectionContext = ListContext<UICollectionView, Self>
    typealias CollectionItemContext = ListIndexContext<UICollectionView, Self, IndexPath>
    typealias CollectionSectionContext = ListIndexContext<UICollectionView, Self, Int>
    
    typealias CollectionFunction<Input, Output, Closure> = ListDelegate.Function<UICollectionView, Self, CollectionList<AdapterBase>, Input, Output, Closure>
    typealias CollectionItemFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UICollectionView, Self, CollectionList<AdapterBase>, Input, Output, Closure, IndexPath>
    typealias CollectionSectionFunction<Input, Output, Closure> = ListDelegate.IndexFunction<UICollectionView, Self, CollectionList<AdapterBase>, Input, Output, Closure, Int>
}

//Collection View Data Source
public extension DataSource {
    //Getting Views for Items
    var collectionViewCellForItem: CollectionItemFunction<IndexPath, UICollectionViewCell, (CollectionItemContext, Item) -> UICollectionViewCell> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), toClosure())
    }
    
    var collectionViewSupplementaryViewForItem: CollectionItemFunction<(IndexPath, String), UICollectionReusableView, (CollectionItemContext, CollectionView.SupplementaryViewType) -> UICollectionReusableView> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), \.0) { closure in { context, input in closure(context, .init(rawValue: input.1)) } }
    }

    //Reordering Items
    var collectionViewCanMoveItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)), toClosure())
    }
    
    var collectionViewMoveItem: CollectionFunction<(IndexPath, IndexPath), Void, (CollectionContext, IndexPath, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)), toClosure())
    }
    
    //Configuring an Index
    @available(iOS 14.0, *)
    var collectionViewIndexTitles: CollectionFunction<Void, [String]?, (CollectionContext) -> [String]?> {
        toFunction(#selector(UICollectionViewDataSource.indexTitles(for:)), toClosure())
    }
    
    @available(iOS 14.0, *)
    var collectionViewIndexPathForIndexTitle: CollectionFunction<(String, Int), IndexPath, (CollectionContext, String, Int) -> IndexPath> {
        toFunction(#selector(UICollectionViewDataSource.collectionView(_:indexPathForIndexTitle:at:)), toClosure())
    }
}

//Collection View Delegate
public extension DataSource {
    //Managing the Selected Cells
    var collectionViewShouldSelectItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)), toClosure())
    }
    
    var collectionViewDidSelectItem: CollectionItemFunction<IndexPath, Void, (CollectionItemContext, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)), toClosure())
    }
    
    var collectionViewShouldDeselectItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)), toClosure())
    }
    
    var collectionViewDidDeselectItem: CollectionItemFunction<IndexPath, Void, (CollectionItemContext, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)), toClosure())
    }
    
    @available(iOS 13.0, *)
    var collectionViewShouldBeginMultipleSelectionInteractionForItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)), toClosure())
    }
    
    @available(iOS 13.0, *)
    var collectionViewDidBeginMultipleSelectionInteractionAtForItem: CollectionItemFunction<IndexPath, Void, (CollectionItemContext, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)), toClosure())
    }
    
    @available(iOS 13.0, *)
    var collectionViewDidEndMultipleSelectionInteraction: CollectionFunction<Void, Void, (CollectionContext) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:)), toClosure())
    }
    
    //Managing Cell Highlighting
    var collectionViewShouldHighlightItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)), toClosure())
    }
    
    var collectionViewDidHighlightItem: CollectionItemFunction<IndexPath, Void, (CollectionItemContext, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)), toClosure())
    }
    
    var collectionViewDidUnhighlightItem: CollectionItemFunction<IndexPath, Void, (CollectionItemContext, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)), toClosure())
    }
    
    //Tracking the Addition and Removal of Views
    var collectionViewWillDisplayForItem: CollectionItemFunction<(IndexPath, UICollectionViewCell), Void, (CollectionItemContext, UICollectionViewCell, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)), \.0, toClosure())
    }
    
    var collectionViewWillDisplaySupplementaryView: CollectionItemFunction<(IndexPath, UICollectionReusableView, String), Void, (CollectionItemContext, UICollectionReusableView, CollectionView.SupplementaryViewType, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)), \.0) { closure in { context, input in closure(context, input.1, .init(rawValue: input.2), context.itemValue) } }
    }
    
    var collectionViewDidEndDisplayingItem: CollectionFunction<(IndexPath, UICollectionViewCell), Void, (CollectionContext, IndexPath, UICollectionViewCell) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)), toClosure())
    }
    
    var collectionViewDidEndDisplayingSupplementaryView: CollectionFunction<(UICollectionReusableView, String, IndexPath), Void, (CollectionContext, UICollectionReusableView, CollectionView.SupplementaryViewType, IndexPath) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))) { closure in { context, input in closure(context, input.0, .init(rawValue: input.1), input.2) } }
    }
    
    //Handling Layout Changes
    var collectionViewTransitionLayoutForOldLayoutNewLayout: CollectionFunction<(UICollectionViewLayout, UICollectionViewLayout), UICollectionViewTransitionLayout, (CollectionContext, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)), toClosure())
    }
    
    var collectionViewTargetContentOffset: CollectionFunction<CGPoint, CGPoint, (CollectionContext, CGPoint) -> CGPoint> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:)), toClosure())
    }
    
    var collectionViewTargetIndexPathForMoveFromItem: CollectionFunction<(IndexPath, IndexPath), IndexPath, (CollectionContext, IndexPath, IndexPath) -> IndexPath> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)), toClosure())
    }
    
    //Managing Actions for Cells
    var collectionViewShouldShowMenuForItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)), toClosure())
    }
    
    var collectionViewCanPerformActionWithSender: CollectionItemFunction<(IndexPath, Selector, Any?), Bool, (CollectionItemContext, Selector, Any?, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)), \.0, toClosure())
    }
    
    var collectionViewPerformActionWithSender: CollectionItemFunction<(IndexPath, Selector, Any?), Void, (CollectionItemContext, Selector, Any?, Item) -> Void> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)), \.0, toClosure())
    }
    
    //Managing Focus in a Collection View
    var collectionViewCanFocusItem: CollectionItemFunction<IndexPath, Bool, (CollectionItemContext, Item) -> Bool> {
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

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    var collectionViewShouldSpringLoadItemAtWith: CollectionItemFunction<(IndexPath, UISpringLoadedInteractionContext), Bool, (CollectionItemContext, UISpringLoadedInteractionContext, Item) -> Bool> {
        toFunction(#selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)), \.0, toClosure())
    }
    
    //Instance Methods
    @available(iOS 13.0, *)
    var collectionViewContextMenuConfigurationForItem: CollectionItemFunction<(IndexPath, CGPoint), UIContextMenuConfiguration?, (CollectionItemContext, CGPoint, Item) -> UIContextMenuConfiguration> {
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

//Collection View Delegate Flow Layout
public extension DataSource {
    //Getting the Size of Items
    var collectionViewLayoutSizeForItem: CollectionItemFunction<(IndexPath, UICollectionViewLayout), CGSize, (CollectionItemContext, UICollectionViewLayout, Item) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)), \.0, toClosure())
    }
    
    //Getting the Section Spacing
    var collectionViewLayoutInsetForSection: CollectionSectionFunction<(Int, UICollectionViewLayout), UIEdgeInsets, (CollectionSectionContext, UICollectionViewLayout) -> UIEdgeInsets> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)), \.0, toClosure())
    }
    
    var collectionViewLayoutMinimumLineSpacingForSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGFloat, (CollectionSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)), \.0, toClosure())
    }
    
    var collectionViewLayoutMinimumInteritemSpacingForSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGFloat, (CollectionSectionContext, UICollectionViewLayout) -> CGFloat> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)), \.0, toClosure())
    }
    
    //Getting the Header and Footer Sizes
    var collectionViewLayoutReferenceSizeForHeaderInSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGSize, (CollectionSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)), \.0, toClosure())
    }
    
    var collectionViewLayoutReferenceSizeForFooterInSection: CollectionSectionFunction<(Int, UICollectionViewLayout), CGSize, (CollectionSectionContext, UICollectionViewLayout) -> CGSize> {
        toFunction(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)), \.0, toClosure())
    }
}

#endif
