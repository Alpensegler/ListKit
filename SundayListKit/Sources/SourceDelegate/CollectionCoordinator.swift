//
//  CollectionCoordinator.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

public class CollectionCoordinator: NSObject, ListViewCoordinator {
    public typealias List = UICollectionView
    public func setListView(_ listView: UICollectionView) { }
}

public extension CollectionDataSource where Self: ListUpdatable {
    func collectionCoordinator() -> CollectionCoordinator {
        return CollectionDataSourceCoordinator { self }
    }
}

public extension CollectionDataSource where Self: AnyObject, Self: ListUpdatable {
    func collectionCoordinator() -> CollectionCoordinator {
        return CollectionDataSourceCoordinator { self }
    }
}

public extension CollectionAdapter where Self: ListUpdatable {
    func collectionCoordinator() -> CollectionCoordinator {
        return CollectionAdapterCoordinator { self }
    }
}

public extension CollectionAdapter where Self: AnyObject, Self: ListUpdatable {
    func collectionCoordinator() -> CollectionCoordinator {
        return CollectionAdapterCoordinator { [unowned self] in self }
    }
}

#if iOS13
import SwiftUI

public extension CollectionDataSource where Self: ListUpdatable, Self: UIViewRepresentable, UIViewType == UICollectionView, Coordinator == CollectionCoordinator {
    func makeUIView(context: Context) -> UIViewType {
        let collectionView = UICollectionView()
        context.coordinator.setListView(collectionView)
        return collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        performReload()
    }
    
    func makeCoordinator() -> Coordinator {
        return collectionCoordinator()
    }
}

public extension CollectionDataSource where Self: AnyObject, Self: ListUpdatable, Self: UIViewRepresentable, UIViewType == UICollectionView, Coordinator == CollectionCoordinator {
    func makeCoordinator() -> Coordinator {
        return collectionCoordinator()
    }
}

public extension CollectionAdapter where Self: ListUpdatable, Self: UIViewRepresentable, UIViewType == UICollectionView, Coordinator == CollectionCoordinator {
    func makeCoordinator() -> Coordinator {
        return collectionCoordinator()
    }
}

public extension CollectionAdapter where Self: AnyObject, Self: ListUpdatable, Self: UIViewRepresentable, UIViewType == UICollectionView, Coordinator == CollectionCoordinator {
    func makeCoordinator() -> Coordinator {
        return collectionCoordinator()
    }
}

#endif

class CollectionDataSourceCoordinator<Snapshot>: CollectionCoordinator, UICollectionViewDataSource {
    var snapshot: Snapshot { return getSnapshot() }
    let getSnapshot: () -> Snapshot
    let setCollectionView: (UICollectionView) -> Void

    //Getting Item and Section Metrics
    let collectionViewNumberOfItemsInSection: (Snapshot, Int) -> Int
    let numberOfSectionsIn: (Snapshot) -> Int

    //Getting Views for Items
    let collectionViewCellForItemAt: (Snapshot, UICollectionView, IndexPath) -> UICollectionViewCell
    let collectionViewViewForSupplementaryElementOfKindAt: (Snapshot, UICollectionView, String, IndexPath) -> UICollectionReusableView

    //Reordering Items
    let collectionViewCanMoveItemAt: (Snapshot, UICollectionView, IndexPath) -> Bool
    let collectionViewMoveItemAtTo: (Snapshot, UICollectionView, IndexPath, IndexPath) -> Void
    
    //Configuring an Index
    let indexTitles: (Snapshot, UICollectionView) -> [String]?
    let collectionViewIndexPathForIndexTitleAt: (Snapshot, UICollectionView, String, Int) -> IndexPath
    
    override func setListView(_ collectionView: UICollectionView) {
        setCollectionView(collectionView)
        collectionView.didReload = false
        collectionView.dataSource = self
    }
    
    init<Coordinator: CollectionDataSource & ListUpdatable>(_ coordinator: @escaping () -> Coordinator) where Coordinator.SourceSnapshot == Snapshot {
        getSnapshot = { coordinator().snapshot }
        setCollectionView = { coordinator().setCollectionView($0) }
        
        collectionViewNumberOfItemsInSection = { $0.numbersOfItems(in: $1) }
        numberOfSectionsIn = { $0.numbersOfSections() }
        
        collectionViewCellForItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), cellForItem: coordinator().item(for: $0, at: $2)) }
        collectionViewViewForSupplementaryElementOfKindAt = { (coordinator().collectionContext(.init(listView: $1, indexPath: $3, snapshot: $0), viewForSupplementaryElementOfKind: .init($2), item: coordinator().item(for: $0, at: $3)) ?? .init()) }
        
        collectionViewCanMoveItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), canMoveItem: coordinator().item(for: $0, at: $2)) }
        collectionViewMoveItemAtTo = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), moveItemAt: $2, to: $3) }
        
        indexTitles = { coordinator().indexTitles(for: .init(listView: $1, indexPath: .default, snapshot: $0)) }
        collectionViewIndexPathForIndexTitleAt = { coordinator().collectionContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), indexPathForIndexTitle: $2, at: $3) }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewNumberOfItemsInSection(snapshot, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionViewCellForItemAt(snapshot, collectionView, indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSectionsIn(snapshot)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionViewViewForSupplementaryElementOfKindAt(snapshot, collectionView, kind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return collectionViewCanMoveItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        return collectionViewMoveItemAtTo(snapshot, collectionView, sourceIndexPath, destinationIndexPath)
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return indexTitles(snapshot, collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        return collectionViewIndexPathForIndexTitleAt(snapshot, collectionView, title, index)
    }
}

final class CollectionAdapterCoordinator<Snapshot>: CollectionDataSourceCoordinator<Snapshot>, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //Managing the Selected Cells
    let collectionViewShouldSelectItemAt:  (Snapshot, UICollectionView, IndexPath) -> Bool
    let collectionViewDidSelectItemAt: (Snapshot, UICollectionView, IndexPath) -> Void
    let collectionViewShouldDeselectItemAt:  (Snapshot, UICollectionView, IndexPath) -> Bool
    let collectionViewDidDeselectItemAt: (Snapshot, UICollectionView, IndexPath) -> Void
    
    //Managing Cell Highlighting
    let collectionViewShouldHighlightItemAt: (Snapshot, UICollectionView, IndexPath) -> Bool
    let collectionViewDidHighlightItemAt: (Snapshot, UICollectionView, IndexPath) -> Void
    let collectionViewDidUnhighlightItemAt: (Snapshot, UICollectionView, IndexPath) -> Void

    //Tracking the Addition and Removal of Views
    let collectionViewWillDisplayForItemAt: (Snapshot, UICollectionView, UICollectionViewCell, IndexPath) -> Void
    let collectionViewWillDisplaySupplementaryViewForElementKindAt: (Snapshot, UICollectionView, UICollectionReusableView, String, IndexPath) -> Void
    let collectionViewDidEndDisplayingForItemAt: (Snapshot, UICollectionView, UICollectionViewCell, IndexPath) -> Void
    let collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAt: (Snapshot, UICollectionView, UICollectionReusableView, String, IndexPath) -> Void
    
    //Handling Layout Changes
    let collectionViewTransitionLayoutForOldLayoutNewLayout: (Snapshot, UICollectionView, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout
    let collectionViewTargetContentOffsetForProposedContentOffset: (Snapshot, UICollectionView, CGPoint) -> CGPoint
    let collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPath: (Snapshot, UICollectionView, IndexPath, IndexPath) -> IndexPath
    
    //Managing Actions for Cells
    let collectionViewShouldShowMenuForItemAt: (Snapshot, UICollectionView, IndexPath) -> Bool
    let collectionViewCanPerformActionForItemAtWithSender: (Snapshot, UICollectionView, Selector, IndexPath, Any?) -> Bool
    let collectionViewPerformActionForItemAtWithSender: (Snapshot, UICollectionView, Selector, IndexPath, Any?) -> Void
    
    //Managing Focus in a Collection View
    let collectionViewCanFocusItemAt: (Snapshot, UICollectionView, IndexPath) -> Bool
    let collectionViewShouldUpdateFocusIn: (Snapshot, UICollectionView, UICollectionViewFocusUpdateContext) -> Bool
    let collectionViewDidUpdateFocusInWith: (Snapshot, UICollectionView, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void
    let indexPathForPreferredFocusedView: (Snapshot, UICollectionView) -> IndexPath?

    //Controlling the Spring-Loading Behavior
    let anyCollectionViewShouldSpringLoadItemAtWith: Any?
    
    @available(iOS 11.0, *)
    var collectionViewShouldSpringLoadItemAtWith: ((Snapshot, UICollectionView, IndexPath, UISpringLoadedInteractionContext) -> Bool)? {
        return anyCollectionViewShouldSpringLoadItemAtWith as? (Snapshot, UICollectionView, IndexPath, UISpringLoadedInteractionContext) -> Bool
    }
    
    //Flow layout
    let collectionViewLayoutSizeForItemAt: (Snapshot, UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize
    let collectionViewLayoutInsetForSectionAt: (Snapshot, UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets
    let collectionViewLayoutMinimumLineSpacingForSectionAt: (Snapshot, UICollectionView, UICollectionViewLayout, Int) -> CGFloat
    let collectionViewLayoutMinimumInteritemSpacingForSectionAt: (Snapshot, UICollectionView, UICollectionViewLayout, Int) -> CGFloat
    let collectionViewLayoutReferenceSizeForHeaderInSection: (Snapshot, UICollectionView, UICollectionViewLayout, Int) -> CGSize
    let collectionViewLayoutReferenceSizeForFooterInSection: (Snapshot, UICollectionView, UICollectionViewLayout, Int) -> CGSize
    
    //ScrollView Delegate
    let scrollViewDidScroll: (UIScrollView) -> Void
    let scrollViewDidZoom: (UIScrollView) -> Void
    let scrollViewWillBeginDragging: (UIScrollView) -> Void
    let scrollViewWillEndDragging: (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void
    let scrollViewDidEndDragging: (UIScrollView, Bool) -> Void
    let scrollViewWillBeginDecelerating: (UIScrollView) -> Void
    let scrollViewDidEndDecelerating: (UIScrollView) -> Void
    let scrollViewDidEndScrollingAnimation: (UIScrollView) -> Void
    let viewForZooming: (UIScrollView) -> UIView?
    let scrollViewWillBeginZooming: (UIScrollView, UIView?) -> Void
    let scrollViewDidEndZooming: (UIScrollView, UIView?, CGFloat) -> Void
    let scrollViewShouldScrollToTop: (UIScrollView) -> Bool
    let scrollViewDidScrollToTop: (UIScrollView) -> Void
    let scrollViewDidChangeAdjustedContentInset: (UIScrollView) -> Void
    
    override func setListView(_ collectionView: UICollectionView) {
        super.setListView(collectionView)
        collectionView.delegate = self
    }
    
    override init<Coordinator: CollectionAdapter & ListUpdatable>(_ coordinator: @escaping () -> Coordinator) where Coordinator.SourceSnapshot == Snapshot {
        collectionViewShouldHighlightItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldHighlightItem: coordinator().item(for: $0, at: $2)) }
        collectionViewDidHighlightItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), didHighlightItem: coordinator().item(for: $0, at: $2)) }
        collectionViewDidUnhighlightItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), didUnhighlightItem: coordinator().item(for: $0, at: $2)) }
        collectionViewShouldSelectItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldSelectItem: coordinator().item(for: $0, at: $2)) }
        collectionViewShouldDeselectItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldDeselectItem: coordinator().item(for: $0, at: $2)) }
        collectionViewDidSelectItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), didSelectItem: coordinator().item(for: $0, at: $2)) }
        collectionViewDidDeselectItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), didDeselectItem: coordinator().item(for: $0, at: $2)) }
        collectionViewWillDisplayForItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $3, snapshot: $0), willDisplay: $2, forItem: coordinator().item(for: $0, at: $3)) }
        collectionViewWillDisplaySupplementaryViewForElementKindAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $4, snapshot: $0), willDisplaySupplementaryView: $2, forElementKind: .init($3), item: coordinator().item(for: $0, at: $4)) }
        collectionViewDidEndDisplayingForItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $3, snapshot: $0), didEndDisplaying: $2) }
        collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $4, snapshot: $0), didEndDisplayingSupplementaryView: $2, forElementOfKind: .init($3)) }
        collectionViewShouldShowMenuForItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldShowMenuForItem: coordinator().item(for: $0, at: $2)) }
        collectionViewCanPerformActionForItemAtWithSender = { coordinator().collectionContext(.init(listView: $1, indexPath: $3, snapshot: $0), canPerformAction: $2, forItem: coordinator().item(for: $0, at: $3), withSender: $4) }
        collectionViewPerformActionForItemAtWithSender = { coordinator().collectionContext(.init(listView: $1, indexPath: $3, snapshot: $0), performAction: $2, forItem: coordinator().item(for: $0, at: $3), withSender: $4) }
        collectionViewTransitionLayoutForOldLayoutNewLayout = { coordinator().collectionContext(.init(listView: $1, indexPath: .default, snapshot: $0), transitionLayoutForOldLayout: $2, newLayout: $3) }
        collectionViewCanFocusItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), canFocusItem: coordinator().item(for: $0, at: $2)) }
        collectionViewShouldUpdateFocusIn = { coordinator().collectionContext(.init(listView: $1, indexPath: .default, snapshot: $0), shouldUpdateFocusIn: $2) }
        collectionViewDidUpdateFocusInWith = { coordinator().collectionContext(.init(listView: $1, indexPath: .default, snapshot: $0), didUpdateFocusIn: $2, with: $3) }
        indexPathForPreferredFocusedView = { coordinator().indexPathForPreferredFocusedView(in: .init(listView: $1, indexPath: .default, snapshot: $0)) }
        collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPath = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), targetIndexPathForMoveFromItem: coordinator().item(for: $0, at: $2), toProposedIndexPath: $3) }
        collectionViewTargetContentOffsetForProposedContentOffset = { coordinator().collectionContext(.init(listView: $1, indexPath: .default, snapshot: $0), targetContentOffsetForProposedContentOffset: $2) }
        
        if #available(iOS 11.0, *) {
            anyCollectionViewShouldSpringLoadItemAtWith = { coordinator().collectionContext(.init(listView: $1, indexPath: $2, snapshot: $0), shouldSpringLoadItem: coordinator().item(for: $0, at: $2), with: $3) }
        } else {
            anyCollectionViewShouldSpringLoadItemAtWith = nil
        }

        collectionViewLayoutSizeForItemAt = { coordinator().collectionContext(.init(listView: $1, indexPath: $3, snapshot: $0), layout: $2, sizeForItem: coordinator().item(for: $0, at: $3)) }
        collectionViewLayoutInsetForSectionAt = { coordinator().collectionContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), layout: $2, insetForSectionAt: $3) }
        collectionViewLayoutMinimumLineSpacingForSectionAt = { coordinator().collectionContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), layout: $2, minimumLineSpacingForSectionAt: $3) }
        collectionViewLayoutMinimumInteritemSpacingForSectionAt = { coordinator().collectionContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), layout: $2, minimumInteritemSpacingForSectionAt: $3) }
        collectionViewLayoutReferenceSizeForHeaderInSection = { coordinator().collectionContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), layout: $2, referenceSizeForHeaderInSection: $3) }
        collectionViewLayoutReferenceSizeForFooterInSection = { coordinator().collectionContext(.init(listView: $1, indexPath: .init(section: $3), snapshot: $0), layout: $2, referenceSizeForFooterInSection: $3) }

        scrollViewDidScroll = { coordinator().scrollViewDidScroll($0) }
        scrollViewDidZoom = { coordinator().scrollViewDidZoom($0) }
        scrollViewWillBeginDragging = { coordinator().scrollViewWillBeginDragging($0) }
        scrollViewWillEndDragging = { coordinator().scrollViewWillEndDragging($0, withVelocity: $1, targetContentOffset: $2) }
        scrollViewDidEndDragging = { coordinator().scrollViewDidEndDragging($0, willDecelerate: $1) }
        scrollViewWillBeginDecelerating = { coordinator().scrollViewWillBeginDecelerating($0) }
        scrollViewDidEndDecelerating = { coordinator().scrollViewDidEndDecelerating($0) }
        scrollViewDidEndScrollingAnimation = { coordinator().scrollViewDidEndScrollingAnimation($0) }
        viewForZooming = { coordinator().viewForZooming(in: $0) }
        scrollViewWillBeginZooming = { coordinator().scrollViewWillBeginZooming($0, with: $1) }
        scrollViewDidEndZooming = { coordinator().scrollViewDidEndZooming($0, with: $1, atScale: $2) }
        scrollViewShouldScrollToTop = { coordinator().scrollViewShouldScrollToTop($0) }
        scrollViewDidScrollToTop = { coordinator().scrollViewDidScrollToTop($0) }
        scrollViewDidChangeAdjustedContentInset = { coordinator().scrollViewDidChangeAdjustedContentInset($0) }
        
        super.init(coordinator)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldHighlightItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
         collectionViewDidHighlightItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
         collectionViewDidUnhighlightItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldSelectItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldDeselectItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         collectionViewDidSelectItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
         collectionViewDidDeselectItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         collectionViewWillDisplayForItemAt(snapshot, collectionView, cell, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        collectionViewWillDisplaySupplementaryViewForElementKindAt(snapshot, collectionView, view, elementKind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         collectionViewDidEndDisplayingForItemAt(snapshot, collectionView, cell, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
         collectionViewDidEndDisplayingSupplementaryViewForElementOfKindAt(snapshot, collectionView, view, elementKind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
         return collectionViewShouldShowMenuForItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
         return collectionViewCanPerformActionForItemAtWithSender(snapshot, collectionView, action, indexPath, sender)
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
         collectionViewPerformActionForItemAtWithSender(snapshot, collectionView, action, indexPath, sender)
    }
    
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
         return collectionViewTransitionLayoutForOldLayoutNewLayout(snapshot, collectionView, fromLayout, toLayout)
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
         return collectionViewCanFocusItemAt(snapshot, collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
         return collectionViewShouldUpdateFocusIn(snapshot, collectionView, context)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
         collectionViewDidUpdateFocusInWith(snapshot, collectionView, context, coordinator)
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
         return indexPathForPreferredFocusedView(snapshot, collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
         return collectionViewTargetIndexPathForMoveFromItemAtToProposedIndexPath(snapshot, collectionView, originalIndexPath, proposedIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
         return collectionViewTargetContentOffsetForProposedContentOffset(snapshot, collectionView, proposedContentOffset)
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return collectionViewShouldSpringLoadItemAtWith?(snapshot, collectionView, indexPath, context) ?? true
    }
    
    //Flow layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewLayoutSizeForItemAt(snapshot, collectionView, collectionViewLayout, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionViewLayoutInsetForSectionAt(snapshot, collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewLayoutMinimumLineSpacingForSectionAt(snapshot, collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewLayoutMinimumInteritemSpacingForSectionAt(snapshot, collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return collectionViewLayoutReferenceSizeForHeaderInSection(snapshot, collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return collectionViewLayoutReferenceSizeForFooterInSection(snapshot, collectionView, collectionViewLayout, section)
    }
    
    //ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDidZoom(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDragging(scrollView, velocity, targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDragging(scrollView, decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForZooming(scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewWillBeginZooming(scrollView, view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDidEndZooming(scrollView, view, scale)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return scrollViewShouldScrollToTop(scrollView)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidScrollToTop(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDidChangeAdjustedContentInset(scrollView)
    }
}
