//
//  ListAdapter+NSCollectionView.swift
//  ListKit
//
//  Created by Frain on 2023/8/1.
//

#if os(macOS)
import AppKit

// MARK: - Collection View Data Source
public extension ListAdapter {
    var itemForRepresentedObjectAt: IndexFunction<NSCollectionView, List, IndexPath, NSCollectionViewItem, (ListIndexContext<NSCollectionView, IndexPath>) -> NSCollectionViewItem, IndexPath> {
        toFunction(#selector(NSCollectionViewDataSource.collectionView(_:itemForRepresentedObjectAt:)), toClosure())
    }
}

public extension ListAdapter where View: NSCollectionView {
    var supplementaryViewForItem: ElementFunction<(IndexPath, String), NSView, (ElementContext, CollectionView.SupplementaryViewType) -> NSView> {
        toFunction(#selector(NSCollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), \.0) { closure in { context, input in closure(context, .init(rawValue: input.1)) } }
    }
}

// MARK: - Collection View Delegate
public extension ListAdapter where View: NSCollectionView {
    // MARK: - Managing the Selection
    @available(macOS 10.11, *)
    var shouldSelectItem: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:shouldSelectItemsAt:)), toClosure())
    }
    
    @available(macOS 10.11, *)
    var shouldDeselectItems: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:shouldDeselectItemsAt:)), toClosure())
    }
    
    @available(macOS 10.11, *)
    var didSelectItems: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:didSelectItemsAt:)), toClosure())
    }
    
    @available(macOS 10.11, *)
    var didDeselectItems: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:didDeselectItemsAt:)), toClosure())
    }
    
    // MARK: - Managing Item Highlighting
    var shouldChangeItems: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:shouldChangeItemsAt:to:)), toClosure())
    }
    
    var didChangeItems: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:didChangeItemsAt:to:)), toClosure())
    }
    
    // MARK: - Tracking the Addition and Removal of Items
    @available(macOS 10.11, *)
    var willDisplayItem: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:willDisplay:forRepresentedObjectAt:)), toClosure())
    }
    
    @available(macOS 10.11, *)
    var didEndDisplayingItem: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:didEndDisplaying:forRepresentedObjectAt:)), toClosure())
    }
    
    @available(macOS 10.11, *)
    var willDisplaySupplementaryView: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:willDisplay:forRepresentedObjectAt:)), toClosure())
    }
    
    @available(macOS 10.11, *)
    var didEndDisplayingSupplementaryView: ElementFunction<IndexPath, Void, (ElementContext) -> Void> {
        toFunction(#selector(NSCollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)), toClosure())
    }
    
    // MARK: - Handling Layout Changes
    
    // MARK: - Drag and Drop Support
    
    // MARK: - Legacy Collection View Support
}

#endif
