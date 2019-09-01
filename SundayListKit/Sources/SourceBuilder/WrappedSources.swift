//
//  WrappedSources.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/11.
//  Copyright © 2019 Frain. All rights reserved.
//

import SwiftUI

@propertyWrapper
@dynamicMemberLookup
public struct Sources<SubSource, Item, SourceSnapshot: SnapshotType, UIViewType> {
    public internal(set) var listUpdater = ListUpdater()
    public var source: SubSource {
        get { return sourceClosure?() ?? sourceStored }
        nonmutating set {
            if sourceClosure != nil { return }
            sourceStored = newValue
        }
    }
    
    public var wrappedValue: SubSource {
        get { return source }
        nonmutating set { source = newValue }
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<SubSource, Value>) -> Value {
        get { return source[keyPath: keyPath] }
        nonmutating set { source[keyPath: keyPath] = newValue }
    }
    
    let sourceClosure: (() -> SubSource)!
    var sourceStored: SubSource! {
        get { return listUpdater.sourceValue as? SubSource }
        nonmutating set {
            listUpdater.sourceValue = newValue
            performUpdate(self)
        }
    }
    
    var diffable = AnyDiffable()
    
    //MARK: - Source
    var createSnapshotWith: (SubSource) -> SourceSnapshot
    var itemFor: (SourceSnapshot, IndexPath) -> Item
    var updateContext: (UpdateContext<SourceSnapshot>) -> Void
    var performUpdate: (Sources<SubSource, Item, SourceSnapshot, UIViewType>) -> Void = { $0.performUpdate() }
    
    //MARK: - collection adapter
    var collectionView: (() -> UICollectionView)? = nil
    var collectionViewWillUpdate: ((UICollectionView, ListChange) -> Void)? = nil
    
    var collectionCellForItem: ((CollectionContext<SourceSnapshot>, Item) -> UICollectionViewCell)! = nil
    var collectionSupplementaryView: ((CollectionContext<SourceSnapshot>, SupplementaryViewType, Item) -> UICollectionReusableView?)? = nil
    
    var collectionDidSelectItem: ((CollectionContext<SourceSnapshot>, Item) -> Void)? = nil
    var collectionWillDisplayItem: ((CollectionContext<SourceSnapshot>, UICollectionViewCell, Item) -> Void)? = nil
    
    var collectionSizeForItem: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Item) -> CGSize)? = nil
    var collectionSizeForHeader: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize)? = nil
    var collectionSizeForFooter: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize)? = nil
    
    //MARK: - table adapter
    var tableViewWillUpdate: ((UITableView, ListChange) -> Void)? = nil
    
    var tableCellForItem: ((TableContext<SourceSnapshot>, Item) -> UITableViewCell)! = nil
    var tableHeader: ((TableContext<SourceSnapshot>, Int) -> UIView?)? = nil
    var tableFooter: ((TableContext<SourceSnapshot>, Int) -> UIView?)? = nil
    
    var tableDidSelectItem: ((TableContext<SourceSnapshot>, Item) -> Void)? = nil
    var tableWillDisplayItem: ((TableContext<SourceSnapshot>, UITableViewCell, Item) -> Void)? = nil
    
    var tableHeightForItem: ((TableContext<SourceSnapshot>, Item) -> CGFloat)? = nil
    var tableHeightForHeader: ((TableContext<SourceSnapshot>, Int) -> CGFloat)? = nil
    var tableHeightForFooter: ((TableContext<SourceSnapshot>, Int) -> CGFloat)? = nil
}

extension Sources: View where UIViewType: ListView {
    public typealias Body = Never
    public typealias Coordinator = UIViewType.Coordinator
    public var body: Body { fatalError() }
}

extension Sources: UIViewRepresentable where UIViewType: ListView {
    public func makeCoordinator() -> UIViewType.Coordinator {
        fatalError()
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        fatalError()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        fatalError()
    }
}
