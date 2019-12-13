//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    func provideCollectionViewCell(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        toCollectionList().set(\.collectionViewDataSources.cellForItemAt) {
            closure($0.0, $0.0.itemValue)
        }
    }
    
    func provideCollectionViewCell<Cell: UICollectionViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        _ closure: @escaping (Cell, CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        provideCollectionViewCell { (context, item) in
            context.dequeueReusableCell(cellClass, identifier: identifier) {
                closure($0, context, item)
            }
        }
    }
}

public extension CollectionListAdapter {
    @discardableResult
    func apply(by collectionView: UICollectionView) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        collectionList.listCoordinator.applyBy(listView: collectionView)
        return collectionList
    }
}

//Collection View Data Source
public extension CollectionListAdapter {
    //Getting Views for Items
    @discardableResult
    func provideCollectionListSupplementaryView(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CollectionView.SupplementaryViewType) -> UICollectionReusableView
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.viewForSupplementaryElementOfKindAt) { closure($0.0, .init($0.1.0)) }
    }

    //Reordering Items
    @discardableResult
    func collectionViewCanMoveItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.canMoveItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewMoveItem(
        _ closure: @escaping (CollectionContext<SourceBase>, IndexPath, IndexPath) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.moveItemAtTo) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Configuring an Index
    @discardableResult
    func collectionViewIndexTitles(
        _ closure: @escaping (CollectionContext<SourceBase>) -> [String]?
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.indexTitles) { closure($0.0) }
    }
    
    @discardableResult
    func collectionViewIndexPathForIndexTitle(
        _ closure: @escaping (CollectionContext<SourceBase>, String, Int) -> IndexPath
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.indexPathForIndexTitleAt) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//Collection View Delegate
public extension CollectionListAdapter {
    //Managing the Selected Cells
    @discardableResult
    func collectionViewShouldSelectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldSelectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidSelectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didSelectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewShouldDeselectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldDeselectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidDeselectItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didDeselectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewShouldBeginMultipleSelectionInteraction(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewDidBeginMultipleSelectionInteractionAt(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didBeginMultipleSelectionInteractionAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewDidEndMultipleSelectionInteraction(
        _ closure: @escaping (CollectionContext<SourceBase>) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didEndMultipleSelectionInteraction) { closure($0.0) }
    }
    
    //Managing Cell Highlighting
    @discardableResult
    func collectionViewShouldHighlightItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldHighlightItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidHighlightItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didHighlightItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidUnhighlightItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didUnhighlightItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    //Tracking the Addition and Removal of Views
    @discardableResult
    func collectionViewWillDisplayForItemAt(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UICollectionViewCell, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.willDisplayForItemAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewWillDisplaySupplementaryView(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CollectionView.SupplementaryViewType, UICollectionReusableView, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.willDisplaySupplementaryViewForElementKindAt) {
            closure($0.0, .init($0.1.1), $0.1.0, $0.0.itemValue)
        }
    }
    
    @discardableResult
    func collectionViewDidEndDisplayingItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UICollectionViewCell, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didEndDisplayingForItemAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewDidEndDisplayingSupplementaryView(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CollectionView.SupplementaryViewType, UICollectionReusableView, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didEndDisplayingSupplementaryViewForElementOfKindAt) {
            closure($0.0, .init($0.1.1), $0.1.0, $0.0.itemValue)
        }
    }
    
    //Handling Layout Changes
    @discardableResult
    func collectionViewTransitionLayoutForOldLayoutNewLayout(
        _ closure: @escaping (CollectionContext<SourceBase>, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.transitionLayoutForOldLayoutNewLayout) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func collectionViewTargetContentOffset(
        _ closure: @escaping (CollectionContext<SourceBase>, CGPoint) -> CGPoint
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.targetContentOffsetForProposedContentOffset) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func collectionViewTargetIndexPathForMoveFromItem(
        _ closure: @escaping (CollectionContext<SourceBase>, IndexPath, IndexPath) -> IndexPath
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.targetIndexPathForMoveFromItemAtToProposedIndexPath) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    //Managing Actions for Cells
    @discardableResult
    func collectionViewShouldShowMenuForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldShowMenuForItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewCanPerformActionWithSender(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Selector, Any?, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.canPerformActionForItemAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewPerformActionWithSender(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Selector, Any?, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.performActionForItemAtWithSender) { closure($0.0, $0.1.0, $0.1.2, $0.0.itemValue) }
    }
    
    //Managing Focus in a Collection View
    func collectionViewCanFocusItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.canFocusItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func collectionViewIndexPathForPreferredFocusedView(
        _ closure: @escaping (CollectionContext<SourceBase>) -> IndexPath?
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.indexPathForPreferredFocusedView) { closure($0.0) }
    }
    
    @discardableResult
    func collectionViewShouldUpdateFocusIn(
        _ closure: @escaping (CollectionContext<SourceBase>, UICollectionViewFocusUpdateContext) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldUpdateFocusIn) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func collectionViewDidUpdateFocusInWith(
        _ closure: @escaping (CollectionContext<SourceBase>, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didUpdateFocusInWith) { closure($0.0, $0.1.0, $0.1.1) }
    }

    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    @discardableResult
    func collectionViewShouldSpringLoadItemAtWith(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UISpringLoadedInteractionContext, Item) -> Bool
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.shouldSpringLoadItemAtWith) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    //Instance Methods
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewContextMenuConfigurationForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, CGPoint, Item) -> UIContextMenuConfiguration
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.contextMenuConfigurationForItemAtPoint) { closure($0.0, $0.1.1, $0.0.itemValue) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewPreviewForDismissingContextMenuWithConfiguration(
        _ closure: @escaping (CollectionContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.previewForDismissingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewPreviewForHighlightingContextMenuWithConfiguration(
        _ closure: @escaping (CollectionContext<SourceBase>, UIContextMenuConfiguration) -> UITargetedPreview
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.previewForHighlightingContextMenuWithConfiguration) { closure($0.0, $0.1) }
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func collectionViewWillPerformPreviewActionForMenuWithAnimator(
        _ closure: @escaping (CollectionContext<SourceBase>, UIContextMenuConfiguration, UIContextMenuInteractionCommitAnimating) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.willPerformPreviewActionForMenuWithAnimator) { closure($0.0, $0.1.0, $0.1.1) }
    }
}

//Collection View Delegate Flow Layout
public extension CollectionListAdapter {
    //Getting the Size of Items
    @discardableResult
    func collectionViewLayoutSizeForItem(
        _ closure: @escaping (CollectionItemContext<SourceBase>, UICollectionViewLayout, Item) -> CGSize
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegateFlowLayouts.layoutSizeForItemAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    //Getting the Section Spacing
    @discardableResult
    func collectionViewLayoutInset(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> UIEdgeInsets
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegateFlowLayouts.layoutInsetForSectionAt) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func collectionViewLayoutMinimumLineSpacing(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGFloat
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegateFlowLayouts.layoutMinimumLineSpacingForSectionAt) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func collectionViewLayoutMinimumInteritemSpacing(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGFloat
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegateFlowLayouts.layoutMinimumInteritemSpacingForSectionAt) { closure($0.0, $0.1.0) }
    }
    
    //Getting the Header and Footer Sizes
    @discardableResult
    func collectionViewLayoutReferenceSizeForHeader(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGSize
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegateFlowLayouts.layoutReferenceSizeForHeaderInSection) { closure($0.0, $0.1.0) }
    }
    
    @discardableResult
    func collectionViewLayoutReferenceSizeForFooterIn(
        _ closure: @escaping (CollectionSectionContext<SourceBase>, UICollectionViewLayout) -> CGSize
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegateFlowLayouts.layoutReferenceSizeForFooterInSection) { closure($0.0, $0.1.0) }
    }
}

#endif
