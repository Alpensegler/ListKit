//
//  CollectionListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    func collectionViewCellForItem(
        _ closure: @escaping (CollectionIndexPathContext<SourceBase>, Item) -> UICollectionViewCell
    ) -> CollectionList<SourceBase> {
        toCollectionList().set(\.collectionViewDataSources.cellForItemAt) {
            closure($0.0, $0.0.itemValue)
        }
    }
}

public extension CollectionListAdapter {
    @discardableResult
    func apply(by collectionView: UICollectionView) -> CollectionList<SourceBase> {
        let collectionList = self.collectionList
        collectionList.listCoordinator.applyBy(listView: collectionView)
        return collectionList
    }
}

//Collection Data Source
public extension CollectionListAdapter where Self: UpdatableDataSource {
    @discardableResult
    func collectionViewViewForSupplementary(
        _ closure: @escaping (CollectionIndexPathContext<SourceBase>, CollectionView.SupplementaryViewType) -> UICollectionReusableView
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.viewForSupplementaryElementOfKindAt) { closure($0.0, .init($0.1.0)) }
    }
}

//Collection Delegate
public extension CollectionListAdapter where Self: UpdatableDataSource {
    
    @discardableResult
    func collectionViewDidSelectItem(
        _ closure: @escaping (CollectionIndexPathContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didSelectItemAt) { closure($0.0, $0.0.itemValue) }
    }
}


#endif
