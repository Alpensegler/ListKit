//
//  Sources+UICollectionView.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/31.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias CollectionSources<SubSource, Item, Snapshot: SnapshotType> = Sources<SubSource, Item, Snapshot, UICollectionView>
public typealias AnyCollectionSources = CollectionSources<Any, Any, AnySourceSnapshot>

public extension CollectionDataSource {
    func eraseToAnyCollectionSources() -> AnyCollectionSources {
        return .init { self }
    }
}

public extension Sources where SubSource == Any, Item == Any, SourceSnapshot: AnySourceSnapshotType, UIViewType == UICollectionView {
    private init<Value: CollectionDataSource>(_source: @escaping () -> Value) {
        sourceClosure = { _source().source }
        createSnapshotWith = { .init(_source().createSnapshot(with: $0 as! Value.SubSource)) }
        itemFor = { _source().item(for: $0.base as! Value.SourceSnapshot, at: $1) }
        updateContext = { _source().update(context: .init(rawSnapshot: $0.rawSnapshot.base as! Value.SourceSnapshot, snapshot: $0.snapshot.base as! Value.SourceSnapshot)) }
        
        sourceStored = nil
        collectionCellForItem = { _source().collectionContext(.init($0), cellForItem: $1 as! Value.Item) }
        collectionSupplementaryView = { (_source().collectionContext(.init($0), viewForSupplementaryElementOfKind: $1, item: $2 as! Value.Item)) }
    }
    
    init<Value: CollectionDataSource>(_ source: @escaping () -> Value) {
        self.init(_source: source)
    }
}

public extension Sources where UIViewType == Never {
    func provideCollectionCell(_ provider: @escaping (CollectionContext<SourceSnapshot>, Item) -> UICollectionViewCell) -> Sources<SubSource, Item, SourceSnapshot, UICollectionView> {
        return .init(self, cellProvider: provider)
    }
}

public extension Sources where UIViewType == UICollectionView {
    init(_ sources: Sources<SubSource, Item, SourceSnapshot, Never>, cellProvider: @escaping (CollectionContext<SourceSnapshot>, Item) -> UICollectionViewCell) {
        sourceClosure = sources.sourceClosure
        sourceStored = sources.sourceStored
        
        listUpdater = sources.listUpdater
        diffable = sources.diffable
        
        createSnapshotWith = sources.createSnapshotWith
        itemFor = sources.itemFor
        updateContext = sources.updateContext
        collectionCellForItem = cellProvider
    }
    
    func provideCollectionView(_ provider: @escaping () -> UICollectionView) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.collectionView = provider
        return sources
    }
    
    func provideSupplementaryView(_ provider: @escaping (CollectionContext<SourceSnapshot>, SupplementaryViewType, Item) -> UICollectionReusableView) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.collectionSupplementaryView = provider
        return sources
    }
    
    func onSelectItem(_ selection: @escaping (CollectionContext<SourceSnapshot>, Item) -> Void) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.collectionDidSelectItem = selection
        return sources
    }
    
    func onWillDisplayItem(_ display: @escaping (CollectionContext<SourceSnapshot>, UICollectionViewCell, Item) -> Void) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.collectionWillDisplayItem = display
        return sources
    }
    
    func provideSizeForItem(_ provider: @escaping (CollectionContext<SourceSnapshot>, UICollectionViewLayout, Item) -> CGSize) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.collectionSizeForItem = provider
        return sources
    }
    
    func provideSizeForHeader(_ provider: @escaping (CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.collectionSizeForHeader = provider
        return sources
    }
    
    func provideSizeForFooter(_ provider: @escaping (CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
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
        return collectionCoordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let collectionView = self.collectionView?() ?? UICollectionView(frame: .zero, collectionViewLayout: .init())
        context.coordinator.setListView(collectionView)
        return collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        performReload()
    }
}

#endif

fileprivate extension CollectionContext {
    init<AnySourceSnapshot: AnySourceSnapshotType>(_ context: CollectionContext<AnySourceSnapshot>) {
        snapshot = context.snapshot.base as! Snapshot
        indexPath = context.indexPath
        offset = context.offset
        listView = context.listView
    }
}
