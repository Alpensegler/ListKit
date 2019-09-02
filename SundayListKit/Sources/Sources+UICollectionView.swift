//
//  Sources+UICollectionView.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias CollectionSources<SubSource, Item> = Sources<SubSource, Item, UICollectionView>
public typealias AnyCollectionSources = CollectionSources<Any, Any>

public extension Sources where UIViewType == UICollectionView {
    private init<Value: CollectionDataSource>(_source: @escaping () -> Value) where Value.SubSource == SubSource, Value.Item == Item {
        self = _source().eraseToSources().castViewType()
        
        collectionViewWillUpdate = { (_source() as? ListUpdatable)?.collectionView($0, willUpdateWith: $1) }
        collectionCellForItem = { _source().collectionContext($0, cellForItem: $1) }
        collectionSupplementaryView = { _source().collectionContext($0, viewForSupplementaryElementOfKind: $1, item: $2) }
    }
    
    init<Value: CollectionDataSource>(_ source: @escaping @autoclosure () -> Value) where Value.SubSource == SubSource, Value.Item == Item {
        self.init(_source: source)
    }
    
    init<Value: CollectionAdapter>(_ source: @escaping @autoclosure () -> Value) where Value.SubSource == SubSource, Value.Item == Item {
        self.init(_source: source)
        
        collectionDidSelectItem = { source().collectionContext($0, didSelectItem: $1) }
        collectionDidDeselectItem = { source().collectionContext($0, didDeselectItem: $1) }
        collectionWillDisplayItem = { source().collectionContext($0, willDisplay: $1, forItem: $2) }
        
        collectionSizeForItem = { source().collectionContext($0, layout: $1, sizeForItem: $2) }
        collectionSizeForHeader = { source().collectionContext($0, layout: $1, referenceSizeForHeaderInSection: $2) }
        collectionSizeForFooter = { source().collectionContext($0, layout: $1, referenceSizeForFooterInSection: $2) }
    }
}

public extension CollectionDataSource {
    func eraseToCollectionSources() -> CollectionSources<SubSource, Item> {
        return .init(self)
    }
}

public extension CollectionAdapter {
    func eraseToCollectionSources() -> CollectionSources<SubSource, Item> {
        return .init(self)
    }
}

public extension Source {
    func provideCollectionCell(_ provider: @escaping (CollectionContext<SubSource, Item>, Item) -> UICollectionViewCell) -> CollectionSources<SubSource, Item> {
        var sources = eraseToSources()
        sources.collectionCellForItem = provider
        return sources.castViewType()
    }
    
    func provideCell<CustomCell: UICollectionViewCell>(
        _ cellClass: CustomCell.Type,
        identifier: String = "",
        configuration: @escaping (CustomCell, Item) -> Void
    ) -> CollectionSources<SubSource, Item> {
        return provideCollectionCell { context, item in
            context.dequeueReusableCell(withCellClass: cellClass, identifier: identifier) {
                configuration($0, item)
            }
        }
    }
}
    
public extension CollectionDataSource {
    func observeOnCollectionViewUpdate(_ provider: @escaping (UICollectionView, ListChange) -> Void) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionViewWillUpdate = provider
        return sources
    }
    
    func provideCollectionView(_ provider: @escaping () -> UICollectionView) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionView = provider
        return sources
    }
    
    func provideSupplementaryView(_ provider: @escaping (CollectionContext<SubSource, Item>, SupplementaryViewType, Item) -> UICollectionReusableView) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionSupplementaryView = provider
        return sources
    }
    
    func onSelectItem(_ selection: @escaping (CollectionContext<SubSource, Item>, Item) -> Void) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionDidSelectItem = selection
        return sources
    }
    
    func onDeselectItem(_ deselection: @escaping (CollectionContext<SubSource, Item>, Item) -> Void) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionDidDeselectItem = deselection
        return sources
    }
    
    func onWillDisplayItem(_ display: @escaping (CollectionContext<SubSource, Item>, UICollectionViewCell, Item) -> Void) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionWillDisplayItem = display
        return sources
    }
    
    func provideSizeForItem(_ provider: @escaping (CollectionContext<SubSource, Item>, UICollectionViewLayout, Item) -> CGSize) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionSizeForItem = provider
        return sources
    }
    
    func provideSizeForHeader(_ provider: @escaping (CollectionContext<SubSource, Item>, UICollectionViewLayout, Int) -> CGSize) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionSizeForHeader = provider
        return sources
    }
    
    func provideSizeForFooter(_ provider: @escaping (CollectionContext<SubSource, Item>, UICollectionViewLayout, Int) -> CGSize) -> CollectionSources<SubSource, Item> {
        var sources = eraseToCollectionSources()
        sources.collectionSizeForFooter = provider
        return sources
    }
}

extension Sources: CollectionDataSource where UIViewType == UICollectionView {
    public func collectionContext(_ context: CollectionListContext, cellForItem item: Item) -> UICollectionViewCell {
        return collectionCellForItem(context, item)
    }
    
    public func collectionContext(_ context: CollectionListContext, viewForSupplementaryElementOfKind kind: SupplementaryViewType, item: Item) -> UICollectionReusableView? {
        return collectionSupplementaryView?(context, kind, item)
    }
    
    public func eraseToCollectionSources() -> Sources<SubSource, Item, UICollectionView> {
        return self
    }
}

extension Sources: CollectionAdapter where UIViewType == UICollectionView {
    public func collectionContext(_ context: CollectionListContext, didSelectItem item: Item) {
        collectionDidSelectItem?(context, item)
    }
    
    public func tableContext(_ context: CollectionListContext, didDeselectItem item: Item) {
        collectionDidSelectItem?(context, item)
    }
    
    public func collectionContext(_ context: CollectionListContext, willDisplay cell: UICollectionViewCell, forItem item: Item) {
        collectionWillDisplayItem?(context, cell, item)
    }
    
    public func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, sizeForItem item: Item) -> CGSize {
        return collectionSizeForItem?(context, collectionViewLayout, item)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
            ?? .zero
    }
    
    public func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return collectionSizeForHeader?(context, collectionViewLayout, section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize
            ?? .zero
    }
    
    public func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return collectionSizeForFooter?(context, collectionViewLayout, section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize
            ?? .zero
    }
}

#if iOS13
import SwiftUI

public extension Sources where UIViewType == UICollectionView {
    func makeCoordinator() -> UIViewType.Coordinator {
        return makeCollectionCoordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let collectionView = self.collectionView?() ?? UICollectionView(frame: .zero, collectionViewLayout: .init())
        context.coordinator.setListView(collectionView)
        return collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        performReloadData()
    }
}

#endif
