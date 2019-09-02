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
public struct Sources<SubSource, Item, UIViewType> {
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
    var createSnapshotWith: (SubSource) -> Snapshot<SubSource, Item>
    var itemFor: (Snapshot<SubSource, Item>, IndexPath) -> Item
    var updateContext: (UpdateContext<SubSource, Item>) -> Void
    var performUpdate: (Sources<SubSource, Item, UIViewType>) -> Void = { $0.performUpdate() }
    
    //MARK: - collection adapter
    var collectionView: (() -> UICollectionView)? = nil
    var collectionViewWillUpdate: ((UICollectionView, ListChange) -> Void)? = nil
    
    var collectionCellForItem: ((CollectionContext<SubSource, Item>, Item) -> UICollectionViewCell)! = nil
    var collectionSupplementaryView: ((CollectionContext<SubSource, Item>, SupplementaryViewType, Item) -> UICollectionReusableView?)? = nil
    
    var collectionDidSelectItem: ((CollectionContext<SubSource, Item>, Item) -> Void)? = nil
    var collectionWillDisplayItem: ((CollectionContext<SubSource, Item>, UICollectionViewCell, Item) -> Void)? = nil
    
    var collectionSizeForItem: ((CollectionContext<SubSource, Item>, UICollectionViewLayout, Item) -> CGSize)? = nil
    var collectionSizeForHeader: ((CollectionContext<SubSource, Item>, UICollectionViewLayout, Int) -> CGSize)? = nil
    var collectionSizeForFooter: ((CollectionContext<SubSource, Item>, UICollectionViewLayout, Int) -> CGSize)? = nil
    
    //MARK: - table adapter
    var tableViewWillUpdate: ((UITableView, ListChange) -> Void)? = nil
    
    var tableCellForItem: ((TableContext<SubSource, Item>, Item) -> UITableViewCell)! = nil
    var tableHeader: ((TableContext<SubSource, Item>, Int) -> UIView?)? = nil
    var tableFooter: ((TableContext<SubSource, Item>, Int) -> UIView?)? = nil
    
    var tableDidSelectItem: ((TableContext<SubSource, Item>, Item) -> Void)? = nil
    var tableWillDisplayItem: ((TableContext<SubSource, Item>, UITableViewCell, Item) -> Void)? = nil
    
    var tableHeightForItem: ((TableContext<SubSource, Item>, Item) -> CGFloat)? = nil
    var tableHeightForHeader: ((TableContext<SubSource, Item>, Int) -> CGFloat)? = nil
    var tableHeightForFooter: ((TableContext<SubSource, Item>, Int) -> CGFloat)? = nil
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
