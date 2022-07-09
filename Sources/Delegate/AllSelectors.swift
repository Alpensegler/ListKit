//
//  AllSelectors.swift
//  ListKit
//
//  Created by Frain on 2019/12/13.
//

#if os(iOS) || os(tvOS)
import UIKit

let allSelectors: Set<Selector> = {
    var selectors: Set<Selector> = [
        #selector(UIScrollViewDelegate.scrollViewDidScroll(_:)),
        #selector(UIScrollViewDelegate.scrollViewDidZoom(_:)),
        #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)),
        #selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)),
        #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)),
        #selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)),
        #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)),
        #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)),
        #selector(UIScrollViewDelegate.viewForZooming(in:)),
        #selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:)),
        #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:)),
        #selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)),
        #selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:)),

        #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)),
        #selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)),
        #selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)),
        #selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)),

        #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)),
        #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)),
        #selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)),
        #selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:)),
        #selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)),
        #selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)),
        #selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)),
        #selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)),
        #selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:)),
        #selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:)),
        #selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:)),

        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)),

        #selector(UITableViewDataSource.tableView(_:cellForRowAt:)),
        #selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)),
        #selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)),
        #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)),
        #selector(UITableViewDataSource.tableView(_:canEditRowAt:)),
        #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)),
        #selector(UITableViewDataSource.tableView(_:moveRowAt:to:)),
        #selector(UITableViewDataSource.sectionIndexTitles(for:)),
        #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)),

        #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)),
        #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:willSelectRowAt:)),
        #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)),
        #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)),
        #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)),
        #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)),
        #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)),
        #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)),
        #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)),
        #selector(UITableViewDelegate.tableView(_:heightForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)),
        #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)),
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)),
        #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)),
        #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)),
        #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)),
        #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)),
        #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)),
        #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)),
        #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)),
        #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)),
        #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)),
        #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)),
        #selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)),
        #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)),
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)),
        #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)),
        #selector(UITableViewDelegate.tableView(_:canFocusRowAt:)),
        #selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)),
        #selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)),
        #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)),
    ]

    guard #available(iOS 11.0, *) else { return selectors }
    selectors.formUnion([
        #selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:)),
        #selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:)),
        #selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)),
        #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)),
        #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)),
    ])

    guard #available(iOS 13.0, *) else { return selectors }
    selectors.formUnion([
        #selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:)),
        #selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:)),
        #selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:)),
        #selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:)),
        #selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:)),
        #selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:)),
        #selector(UICollectionViewDelegate.collectionView(_:willPerformPreviewActionForMenuWith:animator:)),
        #selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)),
        #selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)),
        #selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)),
        #selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:)),
        #selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)),
        #selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)),
        #selector(UITableViewDelegate.tableView(_:willPerformPreviewActionForMenuWith:animator:)),
    ])

    return selectors
}()
#endif
