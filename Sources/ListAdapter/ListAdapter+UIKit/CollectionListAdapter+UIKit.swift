//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    func collectionViewCellForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        CollectionList(self).set(\.cellForItemAt) {
            closure($0.0, $0.0.itemValue)
        }
    }
    
    func collectionViewCell<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        _ closure: @escaping (Cell, CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionViewCellForItem { (context, item) in
            context.dequeueReusableCell(cellClass, identifier: identifier) {
                closure($0, context, item)
            }
        }
    }
}

//Collection View Data Source
public extension CollectionListAdapter {
    //Getting Views for Items
    @discardableResult
    func collectionViewSupplementaryViewForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CollectionView.SupplementaryViewType) -> UICollectionReusableView
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.viewForSupplementaryElementOfKindAt) { closure($0.0, .init($0.1.0)) }
    }

    //Reordering Items
    @discardableResult
    func collectionViewCanMoveItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.canMoveItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewMoveItem(
        _ closure: @escaping (CollectionContext<SourceBase>, IndexPath, IndexPath) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.moveItemAtTo) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Configuring an Index
    @discardableResult
    func collectionViewIndexTitles(
        _ closure: @escaping (CollectionContext<SourceBase>) -> [String]?
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.indexTitles) { closure($0.0) }
    }
    
    @discardableResult
    func collectionViewIndexPathForIndexTitle(
        _ closure: @escaping (CollectionContext<SourceBase>, String, Int) -> IndexPath
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.indexPathForIndexTitleAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//Collection View Delegate
public extension CollectionListAdapter {
    //Managing the Selected Cells
    @discardableResult
    func collectionViewShouldSelectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldSelectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidSelectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didSelectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewShouldDeselectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldDeselectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidDeselectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didDeselectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewShouldBeginMultipleSelectionInteractionForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewDidBeginMultipleSelectionInteractionAtForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewDidEndMultipleSelectionInteraction(
        _ closure: @escaping (CollectionContext<SourceBase>) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didEndMultipleSelectionInteraction) { closure($0.0) }
    }
    
    //Managing Cell Highlighting
    @discardableResult
    func collectionViewShouldHighlightItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldHighlightItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidHighlightItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didHighlightItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidUnhighlightItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didUnhighlightItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Tracking the Addition and Removal of Views
    @discardableResult
    func collectionViewWillDisplayForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UICollectionViewCell, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.willDisplayForItemAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewWillDisplaySupplementaryView(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CollectionView.SupplementaryViewType, UICollectionReusableView, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.willDisplaySupplementaryViewForElementKindAt) {
            closure($0.0, .init($0.1.1), $0.1.0, $0.0.itemValue)
        }
    }
    
    @discardableResult
    func collectionViewDidEndDisplayingItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UICollectionViewCell, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didEndDisplayingForItemAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidEndDisplayingSupplementaryView(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CollectionView.SupplementaryViewType, UICollectionReusableView, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didEndDisplayingSupplementaryViewForElementOfKindAt) {
            closure($0.0, .init($0.1.1), $0.1.0, $0.0.itemValue)
        }
    }
    
    //Handling Layout Changes
    @discardableResult
    func collectionViewTransitionLayoutForOldLayoutNewLayout(
        _ closure: @escaping (CollectionContext<SourceBase>, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.transitionLayoutForOldLayoutNewLayout) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func collectionViewTargetContentOffset(
        _ closure: @escaping (CollectionContext<SourceBase>, CGPoint) -> CGPoint
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.targetContentOffsetForProposedContentOffset) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func collectionViewTargetIndexPathForMoveFromItem(
        _ closure: @escaping (CollectionContext<SourceBase>, IndexPath, IndexPath) -> IndexPath
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.targetIndexPathForMoveFromItemAtToProposedIndexPath) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Managing Actions for Cells
    @discardableResult
    func collectionViewShouldShowMenuForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldShowMenuForItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewCanPerformActionWithSender(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Selector, Any?, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.canPerformActionForItemAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewPerformActionWithSender(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Selector, Any?, Item) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.performActionForItemAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    //Managing Focus in a Collection View
    func collectionViewCanFocusItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.canFocusItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewIndexPathForPreferredFocusedView(
        _ closure: @escaping (CollectionContext<SourceBase>) -> IndexPath?
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.indexPathForPreferredFocusedView) { closure($0.0) }
    }
    
    @discardableResult
    func collectionViewShouldUpdateFocusIn(
        _ closure: @escaping (CollectionContext<SourceBase>, UICollectionViewFocusUpdateContext) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldUpdateFocusIn) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func collectionViewDidUpdateFocusInWith(
        _ closure: @escaping (CollectionContext<SourceBase>, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.didUpdateFocusInWith) { closure($0.0, $0.1.0, $0.1.1) }
    }

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    @discardableResult
    func collectionViewShouldSpringLoadItemAtWith(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UISpringLoadedInteractionContext, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.shouldSpringLoadItemAtWith) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    //Instance Methods
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewContextMenuConfigurationForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CGPoint, Item) -> UIContextMenuConfiguration
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.contextMenuConfigurationForItemAtPoint) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewPreviewForDismissingContextMenuWithConfiguration(
        _ closure: @escaping (CollectionContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.previewForDismissingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewPreviewForHighlightingContextMenuWithConfiguration(
        _ closure: @escaping (CollectionContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.previewForHighlightingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewWillPerformPreviewActionForMenuWithAnimator(
        _ closure: @escaping (CollectionContext<SourceBase>, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.willPerformPreviewActionForMenuWithAnimator) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//Collection View Delegate Flow Layout
public extension CollectionListAdapter {
    //Getting the Size of Items
    @discardableResult
    func collectionViewLayoutSizeForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UICollectionViewLayout, Item) -> CGSize
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.layoutSizeForItemAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    //Getting the Section Spacing
    @discardableResult
    func collectionViewLayoutInset(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> UIEdgeInsets
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.layoutInsetForSectionAt) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func collectionViewLayoutMinimumLineSpacing(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGFloat
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.layoutMinimumLineSpacingForSectionAt) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func collectionViewLayoutMinimumInteritemSpacing(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGFloat
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.layoutMinimumInteritemSpacingForSectionAt) { closure($0.0, $0.1.0) }
    }
    
    //Getting the Header and Footer Sizes
    @discardableResult
    func collectionViewLayoutReferenceSizeForHeader(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGSize
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.layoutReferenceSizeForHeaderInSection) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func collectionViewLayoutReferenceSizeForFooterIn(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGSize
    ) -> CollectionList<SourceBase> {
        collectionList.set(\.layoutReferenceSizeForFooterInSection) { closure($0.0, $0.1.0) }
    }
}

#endif
