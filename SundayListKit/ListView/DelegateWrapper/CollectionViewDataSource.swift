//
//  CollectionViewDataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/31.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class UICollectionViewDataSourceWrapper: NSObject, UICollectionViewDataSource {
    let collectionViewNumberOfItemsInSection: (UICollectionView, Int) -> Int
    let collectionViewCellForItemAt: (UICollectionView, IndexPath) -> UICollectionViewCell
    let numberOfSectionsIn: (UICollectionView) -> Int
    let collectionViewViewForSupplementaryElementOfKindAt: (UICollectionView, String, IndexPath) -> UICollectionReusableView
    let collectionViewCanMoveItemAt: (UICollectionView, IndexPath) -> Bool
    let collectionViewMoveItemAtTo: (UICollectionView, IndexPath, IndexPath) -> Void
    let indexTitles: (UICollectionView) -> [String]?
    let collectionViewIndexPathForIndexTitleAt: (UICollectionView, String, Int) -> IndexPath
    
    init(_ dataSource: CollectionViewDataSource) {
        collectionViewNumberOfItemsInSection = { [unowned dataSource] in dataSource.collectionView($0, numberOfItemsInSection: $1) }
        collectionViewCellForItemAt = { [unowned dataSource] in dataSource.collectionView($0, cellForItemAt: $1) }
        numberOfSectionsIn = { [unowned dataSource] in dataSource.numberOfSections(in: $0) }
        collectionViewViewForSupplementaryElementOfKindAt = { [unowned dataSource] in dataSource.collectionView($0, viewForSupplementaryElementOfKind: $1, at: $2) }
        collectionViewCanMoveItemAt = { [unowned dataSource] in dataSource.collectionView($0, canMoveItemAt: $1) }
        collectionViewMoveItemAtTo = { [unowned dataSource] in dataSource.collectionView($0, moveItemAt: $1, to: $2) }
        indexTitles = { [unowned dataSource] in dataSource.indexTitles(for: $0) }
        collectionViewIndexPathForIndexTitleAt = { [unowned dataSource] in dataSource.collectionView($0, indexPathForIndexTitle: $1, at: $2) }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewNumberOfItemsInSection(collectionView, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionViewCellForItemAt(collectionView, indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSectionsIn(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionViewViewForSupplementaryElementOfKindAt(collectionView, kind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return collectionViewCanMoveItemAt(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        return collectionViewMoveItemAtTo(collectionView, sourceIndexPath, destinationIndexPath)
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return indexTitles(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        return collectionViewIndexPathForIndexTitleAt(collectionView, title, index)
    }
}

public protocol CollectionViewDataSource: class {
    //Getting Item and Section Metrics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func numberOfSections(in collectionView: UICollectionView) -> Int
    
    //Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    
    //Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    //Configuring an Index
    func indexTitles(for collectionView: UICollectionView) -> [String]?
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath
    
    var asCollectionViewDataSource: UICollectionViewDataSource { get }
}

private var collectionViewDataSourceKey: Void?

public extension CollectionViewDataSource {
    //Getting Item and Section Metrics
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    //Getting Views for Items
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView { return .init() }
    
    //Reordering Items
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool { return true }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    //Configuring an Index
    func indexTitles(for collectionView: UICollectionView) -> [String]? { return nil }
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath { return IndexPath(item: 0, section: 0) }
    
    var asCollectionViewDataSource: UICollectionViewDataSource {
        return Associator.getValue(key: &collectionViewDataSourceKey, from: self, initialValue: UICollectionViewDataSourceWrapper(self) )
    }
}
