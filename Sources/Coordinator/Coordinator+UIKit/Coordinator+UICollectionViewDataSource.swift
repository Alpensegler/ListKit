//
//  Coordinator+UICollectionViewDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

typealias CollectionDataSource<Input, Output> = Delegate<UICollectionView, Input, Output>

class UICollectionViewDataSources {
    //Getting Views for Items
    var cellForItemAt = CollectionDataSource<IndexPath, UICollectionViewCell>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:))
    )
    
    var viewForSupplementaryElementOfKindAt = CollectionDataSource<(String, IndexPath), UICollectionReusableView>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:))
    )

    //Reordering Items
    var canMoveItemAt = CollectionDataSource<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:))
    )
    
    var moveItemAtTo = CollectionDataSource<(IndexPath, IndexPath), Void>(
        #selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:))
    )
    
    //Configuring an Index
    var indexTitles = CollectionDataSource<Void, [String]?>(
        #selector(UICollectionViewDataSource.indexTitles(for:))
    )
    
    var indexPathForIndexTitleAt = CollectionDataSource<(String, Int), IndexPath>(
        #selector(UICollectionViewDataSource.collectionView(_:indexPathForIndexTitle:at:))
    )
    
    func add(by selectorSets: inout SelectorSets) {
        //Getting Views for Items
        selectorSets.add(cellForItemAt)
        selectorSets.add(viewForSupplementaryElementOfKindAt)

        //Reordering Items
        selectorSets.add(canMoveItemAt)
        selectorSets.add(moveItemAtTo)

        //Configuring an Index
        selectorSets.add(indexTitles)
        selectorSets.add(indexPathForIndexTitleAt)
    }
}

extension BaseCoordinator: UICollectionViewDataSource { }

public extension BaseCoordinator {
    //Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numbersOfItems(in: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        numbersOfSections()
    }
    
    //Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        apply(\.collectionViewDataSources.cellForItemAt, object: collectionView, with: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        apply(\.collectionViewDataSources.viewForSupplementaryElementOfKindAt, object: collectionView, with: (kind, indexPath))
    }
    
    //Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        apply(\.collectionViewDataSources.canMoveItemAt, object: collectionView, with: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(\.collectionViewDataSources.moveItemAtTo, object: collectionView, with: (sourceIndexPath, destinationIndexPath))
    }

    //Configuring an Index
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        apply(\.collectionViewDataSources.indexTitles, object: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        apply(\.collectionViewDataSources.indexPathForIndexTitleAt, object: collectionView, with: (title, index))
    }
}

#endif
