//
//  Sources.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/4.
//  Copyright © 2019 Frain. All rights reserved.
//

public struct Sources<SubSource, Item, SourceSnapshot: SnapshotType, UIViewType> {
    public internal(set) var listUpdater = ListUpdater()
    public var source: SubSource {
        get { return sourceClosure?() ?? sourceStored }
        set {
            if sourceClosure != nil { return }
            sourceStored = newValue
            performUpdate()
        }
    }
    
    let sourceClosure: (() -> SubSource)!
    var sourceStored: SubSource!
    
    var diffable = AnyDiffable()
    
    //MARK: - Source
    var createSnapshotWith: ((SubSource) -> SourceSnapshot)!
    var itemFor: ((SourceSnapshot, IndexPath) -> Item)!
    var updateContext: ((UpdateContext<SourceSnapshot>) -> Void)!
    
    //MARK: - collection adapter
    var collectionView: (() -> UICollectionView)? = nil
    
    var collectionCellForItem: ((CollectionContext<SourceSnapshot>, Item) -> UICollectionViewCell)! = nil
    var collectionSupplementaryView: ((CollectionContext<SourceSnapshot>, SupplementaryViewType, Item) -> UICollectionReusableView?)? = nil
    
    var collectionDidSelectItem: ((CollectionContext<SourceSnapshot>, Item) -> Void)? = nil
    var collectionWillDisplayItem: ((CollectionContext<SourceSnapshot>, UICollectionViewCell, Item) -> Void)? = nil
    
    var collectionSizeForItem: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Item) -> CGSize)? = nil
    var collectionSizeForHeader: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize)? = nil
    var collectionSizeForFooter: ((CollectionContext<SourceSnapshot>, UICollectionViewLayout, Int) -> CGSize)? = nil
    
    //MARK: - table adapter
    var tableCellForItem: ((TableContext<SourceSnapshot>, Item) -> UITableViewCell)! = nil
    var tableHeader: ((TableContext<SourceSnapshot>, Int) -> UIView?)? = nil
    var tableFooter: ((TableContext<SourceSnapshot>, Int) -> UIView?)? = nil
    
    var tableDidSelectItem: ((TableContext<SourceSnapshot>, Item) -> Void)? = nil
    var tableWillDisplayItem: ((TableContext<SourceSnapshot>, UITableViewCell, Item) -> Void)? = nil
    
    var tableHeightForItem: ((TableContext<SourceSnapshot>, Item) -> CGFloat)? = nil
    var tableHeightForHeader: ((TableContext<SourceSnapshot>, Int) -> CGFloat)? = nil
    var tableHeightForFooter: ((TableContext<SourceSnapshot>, Int) -> CGFloat)? = nil
    
    public mutating func updateWithReloadCurrent(source: SubSource, animated: Bool = true, _ completion: ((Bool) -> Void)? = nil) {
        self.sourceStored = source
        performReloadCurrent(animated: animated, completion)
    }
    
    public mutating func updateWithReload(source: SubSource, _ completion: ((Bool) -> Void)? = nil) {
        self.sourceStored = source
        performReload(completion)
    }
}
