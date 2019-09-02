//
//  Sources+UICollectionView.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias CollectionSources<SubSource, Item> = Sources<SubSource, Item, UICollectionView>
public typealias AnyCollectionSources = CollectionSources<Any, Any>

public extension CollectionDataSource {
    func eraseToAnyCollectionSources() -> AnyCollectionSources {
        return .init { self }
    }
}

public extension Sources where SubSource == Any, Item == Any, UIViewType == UICollectionView {
    private init<Value: CollectionDataSource>(_source: @escaping () -> Value) {
        sourceClosure = { _source().source }
        createSnapshotWith = { .init(_source().createSnapshot(with: $0 as! Value.SubSource)) }
        itemFor = { _source().item(for: $0.castToSnapshot(), at: $1) }
        updateContext = { _source().update(context: $0.castSnapshotType()) }
        
        sourceStored = nil
        collectionCellForItem = { _source().collectionContext($0.castSnapshotType(), cellForItem: $1 as! Value.Item) }
        collectionSupplementaryView = { (_source().collectionContext($0.castSnapshotType(), viewForSupplementaryElementOfKind: $1, item: $2 as! Value.Item)) }
    }
    
    init<Value: CollectionDataSource>(_ source: @escaping () -> Value) {
        self.init(_source: source)
    }
}

public extension Sources where UIViewType == Never {
    func provideCollectionCell(_ provider: @escaping (CollectionContext<SubSource, Item>, Item) -> UICollectionViewCell) -> Sources<SubSource, Item, UICollectionView> {
        return .init(self, cellProvider: provider)
    }
}

public extension Sources where UIViewType == UICollectionView {
    init(_ sources: Sources<SubSource, Item, Never>, cellProvider: @escaping (CollectionContext<SubSource, Item>, Item) -> UICollectionViewCell) {
        createSnapshotWith = sources.createSnapshotWith
        itemFor = sources.itemFor
        updateContext = sources.updateContext
        collectionCellForItem = cellProvider
        
        sourceClosure = sources.sourceClosure
        sourceStored = sources.sourceStored
        
        listUpdater = sources.listUpdater
        diffable = sources.diffable
    }
    
    func observeOnCollectionViewUpdate(_ provider: @escaping (UICollectionView, ListChange) -> Void) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionViewWillUpdate = provider
        return sources
    }
    
    func provideCollectionView(_ provider: @escaping () -> UICollectionView) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionView = provider
        return sources
    }
    
    func provideSupplementaryView(_ provider: @escaping (CollectionContext<SubSource, Item>, SupplementaryViewType, Item) -> UICollectionReusableView) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionSupplementaryView = provider
        return sources
    }
    
    func onSelectItem(_ selection: @escaping (CollectionContext<SubSource, Item>, Item) -> Void) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionDidSelectItem = selection
        return sources
    }
    
    func onWillDisplayItem(_ display: @escaping (CollectionContext<SubSource, Item>, UICollectionViewCell, Item) -> Void) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionWillDisplayItem = display
        return sources
    }
    
    func provideSizeForItem(_ provider: @escaping (CollectionContext<SubSource, Item>, UICollectionViewLayout, Item) -> CGSize) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionSizeForItem = provider
        return sources
    }
    
    func provideSizeForHeader(_ provider: @escaping (CollectionContext<SubSource, Item>, UICollectionViewLayout, Int) -> CGSize) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionSizeForHeader = provider
        return sources
    }
    
    func provideSizeForFooter(_ provider: @escaping (CollectionContext<SubSource, Item>, UICollectionViewLayout, Int) -> CGSize) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.collectionSizeForFooter = provider
        return sources
    }
}

extension CollectionSources: CollectionAdapter {
    public func collectionContext(_ context: CollectionListContext, cellForItem item: Item) -> UICollectionViewCell {
        return collectionCellForItem(context, item)
    }
    
    public func collectionContext(_ context: CollectionListContext, viewForSupplementaryElementOfKind kind: SupplementaryViewType, item: Item) -> UICollectionReusableView? {
        return collectionSupplementaryView?(context, kind, item)
    }
    
    public func collectionContext(_ context: CollectionListContext, didSelectItem item: Item) {
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
