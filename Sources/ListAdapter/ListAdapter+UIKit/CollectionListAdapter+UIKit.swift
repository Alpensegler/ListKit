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

public extension CollectionListAdapter where Self: UpdatableDataSource {
    @discardableResult
    func collectionViewViewForSupplementary(
        _ closure: @escaping (CollectionIndexPathContext<SourceBase>, CollectionView.SupplementaryViewType) -> UICollectionReusableView
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDataSources.viewForSupplementaryElementOfKindAt) { closure($0.0, .init($0.1.0)) }
    }
    
    @discardableResult
    func collectionViewDidSelectItem(
        _ closure: @escaping (CollectionIndexPathContext<SourceBase>, Item) -> Void
    ) -> CollectionList<SourceBase> {
        set(\.collectionViewDelegates.didSelectItemAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func apply(by collectionView: UICollectionView) -> Self { self }
}


#endif
