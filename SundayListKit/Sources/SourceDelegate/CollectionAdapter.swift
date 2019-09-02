//
//  CollectionAdapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/29.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol CollectionAdapter: CollectionDataSource, ScrollViewDelegate {
    //Managing the Selected Cells
    func collectionContext(_ context: CollectionListContext, shouldSelectItem item: Item) -> Bool
    func collectionContext(_ context: CollectionListContext, didSelectItem item: Item)
    func collectionContext(_ context: CollectionListContext, shouldDeselectItem item: Item) -> Bool
    func collectionContext(_ context: CollectionListContext, didDeselectItem item: Item)
    
    //Managing Cell Highlighting
    func collectionContext(_ context: CollectionListContext, shouldHighlightItem item: Item) -> Bool
    func collectionContext(_ context: CollectionListContext, didHighlightItem item: Item)
    func collectionContext(_ context: CollectionListContext, didUnhighlightItem item: Item)
    
    //Tracking the Addition and Removal of Views
    func collectionContext(_ context: CollectionListContext, willDisplay cell: UICollectionViewCell, forItem item: Item)
    func collectionContext(_ context: CollectionListContext, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind kind: SupplementaryViewType, item: Item)
    func collectionContext(_ context: CollectionListContext, didEndDisplaying cell: UICollectionViewCell)
    func collectionContext(_ context: CollectionListContext, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind kind: SupplementaryViewType)
    
    //Handling Layout Changes
    func collectionContext(_ context: CollectionListContext, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
    func collectionContext(_ context: CollectionListContext, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint
    func collectionContext(_ context: CollectionListContext, targetIndexPathForMoveFromItem item: Item, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
    
    //Managing Actions for Cells
    func collectionContext(_ context: CollectionListContext, shouldShowMenuForItem item: Item) -> Bool
    func collectionContext(_ context: CollectionListContext, canPerformAction action: Selector, forItem item: Item, withSender sender: Any?) -> Bool
    func collectionContext(_ context: CollectionListContext, performAction action: Selector, forItem item: Item, withSender sender: Any?)
    
    //Managing Focus in a Collection View
    func collectionContext(_ context: CollectionListContext, canFocusItem item: Item) -> Bool
    func collectionContext(_ context: CollectionListContext, shouldUpdateFocusIn focusUpdateContext: UICollectionViewFocusUpdateContext) -> Bool
    func collectionContext(_ context: CollectionListContext, didUpdateFocusIn focusUpdateContext: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    func indexPathForPreferredFocusedView(in context: CollectionListContext) -> IndexPath?
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionContext(_ context: CollectionListContext, shouldSpringLoadItem item: Item, with interactionContext: UISpringLoadedInteractionContext) -> Bool

    //Getting the Size of Items
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, sizeForItem item: Item) -> CGSize
    
    //Getting the Section Spacing
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    //header size
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
}

public extension CollectionAdapter {
    //Managing the Selected Cells
    func collectionContext(_ context: CollectionListContext, shouldSelectItem item: Item) -> Bool { return true }
    func collectionContext(_ context: CollectionListContext, didSelectItem item: Item) { }
    func collectionContext(_ context: CollectionListContext, shouldDeselectItem item: Item) -> Bool { return true }
    func collectionContext(_ context: CollectionListContext, didDeselectItem item: Item) { }
    
    //Managing Cell Highlighting
    func collectionContext(_ context: CollectionListContext, shouldHighlightItem item: Item) -> Bool { return true }
    func collectionContext(_ context: CollectionListContext, didHighlightItem item: Item) { }
    func collectionContext(_ context: CollectionListContext, didUnhighlightItem item: Item) { }
    
    //Tracking the Addition and Removal of Views
    func collectionContext(_ context: CollectionListContext, willDisplay cell: UICollectionViewCell, forItem item: Item) { }
    func collectionContext(_ context: CollectionListContext, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind kind: SupplementaryViewType, item: Item) { }
    func collectionContext(_ context: CollectionListContext, didEndDisplaying cell: UICollectionViewCell) { }
    func collectionContext(_ context: CollectionListContext, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind kind: SupplementaryViewType) { }
    
    //Handling Layout Changes
    func collectionContext(_ context: CollectionListContext, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout { return .init(currentLayout: fromLayout, nextLayout: toLayout) }
    func collectionContext(_ context: CollectionListContext, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint { return  proposedContentOffset }
    func collectionContext(_ context: CollectionListContext, targetIndexPathForMoveFromItem item: Item, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath { return proposedIndexPath }
    
    //Managing Actions for Cells
    func collectionContext(_ context: CollectionListContext, shouldShowMenuForItem item: Item) -> Bool { return false }
    func collectionContext(_ context: CollectionListContext, canPerformAction action: Selector, forItem item: Item, withSender sender: Any?) -> Bool { return false }
    func collectionContext(_ context: CollectionListContext, performAction action: Selector, forItem item: Item, withSender sender: Any?) { }
    
    //Managing Focus in a Collection View
    func collectionContext(_ context: CollectionListContext, canFocusItem item: Item) -> Bool { return context.listView.allowsSelection }
    func collectionContext(_ context: CollectionListContext, shouldUpdateFocusIn focusUpdateContext: UICollectionViewFocusUpdateContext) -> Bool { return true }
    func collectionContext(_ context: CollectionListContext, didUpdateFocusIn focusUpdateContext: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) { }
    func indexPathForPreferredFocusedView(in context: CollectionListContext) -> IndexPath? { return nil }
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionContext(_ context: CollectionListContext, shouldSpringLoadItem item: Item, with interactionContext: UISpringLoadedInteractionContext) -> Bool { return true }

    //Getting the Size of Items
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, sizeForItem item: Item) -> CGSize { return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero  }
    
    //Getting the Section Spacing
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { return (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero }
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0 }
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0 }
    
    //header size
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { return (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero }
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero }
}

public extension CollectionAdapter where SubSource: Collection, SubSource.Element: CollectionAdapter, Item == SubSource.Element.Item {
    //Managing the Selected Cells
    func collectionContext(_ context: CollectionListContext, shouldSelectItem item: Item) -> Bool {
        return context.elementShouldSelectItem()
    }
    
    func collectionContext(_ context: CollectionListContext, didSelectItem item: Item) {
        context.elementDidSelectItem()
    }
    
    func collectionContext(_ context: CollectionListContext, shouldDeselectItem item: Item) -> Bool {
        return context.elementShouldDeselectItem()
    }
    
    func collectionContext(_ context: CollectionListContext, didDeselectItem item: Item) {
        context.elementDidDeselectItem()
    }
    
    //Tracking the Addition and Removal of Views
    func collectionContext(_ context: CollectionListContext, willDisplay cell: UICollectionViewCell, forItem item: Item) {
        context.elementWillDisplay(cell: cell)
    }
    
    func collectionContext(_ context: CollectionListContext, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind kind: SupplementaryViewType, item: Item) {
        context.elementWillDisplaySupplementaryView(view: view, forElementKind: kind)
    }
    
    func collectionContext(_ context: CollectionListContext, didEndDisplaying cell: UICollectionViewCell) {
        context.elementDidEndDisplaying(cell: cell)
    }
    
    func collectionContext(_ context: CollectionListContext, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind kind: SupplementaryViewType) {
        context.elementDidEndDisplayingSupplementaryView(view: view, forElementOfKind: kind)
    }

    //Getting the Size of Items
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, sizeForItem item: Item) -> CGSize {
        return context.elementsizeForItem(collectionViewLayout: collectionViewLayout)
    }
    
    //header size
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return context.elementreferenceSizeForHeaderInSection(collectionViewLayout: collectionViewLayout)
    }
    
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return context.elementreferenceSizeForFooterInSection(collectionViewLayout: collectionViewLayout)
    }
}

public extension CollectionContext where SubSource: Collection, SubSource.Element: CollectionAdapter, Item == SubSource.Element.Item {
    //Managing the Selected Cells
    func elementShouldSelectItem() -> Bool {
        return element.collectionContext(elementsContext(), shouldSelectItem: elementsItem)
    }
    
    func elementDidSelectItem() {
        element.collectionContext(elementsContext(), didSelectItem: elementsItem)
    }
    
    func elementShouldDeselectItem() -> Bool {
        return element.collectionContext(elementsContext(), shouldDeselectItem: elementsItem)
    }
    
    func elementDidDeselectItem() {
        element.collectionContext(elementsContext(), didDeselectItem: elementsItem)
    }
    
    //Tracking the Addition and Removal of Views
    func elementWillDisplay(cell: UICollectionViewCell) {
        element.collectionContext(elementsContext(), willDisplay: cell, forItem: elementsItem)
    }
    
    func elementWillDisplaySupplementaryView(view: UICollectionReusableView, forElementKind kind: SupplementaryViewType) {
        element.collectionContext(elementsContext(), willDisplaySupplementaryView: view, forElementKind: kind, item: elementsItem)
    }
    
    func elementDidEndDisplaying(cell: UICollectionViewCell) {
        element.collectionContext(elementsContext(), didEndDisplaying: cell)
    }
    
    func elementDidEndDisplayingSupplementaryView(view: UICollectionReusableView, forElementOfKind kind: SupplementaryViewType) {
        element.collectionContext(elementsContext(), didEndDisplayingSupplementaryView: view, forElementOfKind: kind)
    }

    //Getting the Size of Items
    func elementsizeForItem(collectionViewLayout: UICollectionViewLayout) -> CGSize {
        return element.collectionContext(elementsContext(), layout: collectionViewLayout, sizeForItem: elementsItem)
    }
    
    //header size
    func elementreferenceSizeForHeaderInSection(collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let context = elementsContext()
        return element.collectionContext(context, layout: collectionViewLayout, referenceSizeForHeaderInSection: context.section)
    }
    
    func elementreferenceSizeForFooterInSection(collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let context = elementsContext()
        return element.collectionContext(context, layout: collectionViewLayout, referenceSizeForFooterInSection: context.section)
    }
}
