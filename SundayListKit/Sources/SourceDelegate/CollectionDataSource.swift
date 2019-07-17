//
//  CollectionDataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/26.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol CollectionDataSource: Source {
    typealias CollectionListContext = CollectionContext<SourceSnapshot>
    
    func eraseToAnyCollectionSources() -> AnyCollectionSources
    
    //Getting Views for Items
    func collectionContext(_ context: CollectionListContext, cellForItem item: Item) -> UICollectionViewCell
    func collectionContext(_ context: CollectionListContext, viewForSupplementaryElementOfKind kind: SupplementaryViewType, item: Item) -> UICollectionReusableView?
    
    //Reordering Items
    func collectionContext(_ context: CollectionListContext, canMoveItem item: Item) -> Bool
    func collectionContext(_ context: CollectionListContext, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    //Configuring an Index
    func indexTitles(for context: CollectionListContext) -> [String]?
    func collectionContext(_ context: CollectionListContext, indexPathForIndexTitle title: String, at index: Int) -> IndexPath
}


public extension CollectionDataSource {
    //Getting Views for Items
    func collectionContext(_ context: CollectionListContext, viewForSupplementaryElementOfKind kind: SupplementaryViewType, item: Item) -> UICollectionReusableView? { return nil }
    
    //Reordering Items
    func collectionContext(_ context: CollectionListContext, canMoveItem item: Item) -> Bool { return true }
    func collectionContext(_ context: CollectionListContext, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    //Configuring an Index
    func indexTitles(for context: CollectionListContext) -> [String]? { return nil }
    func collectionContext(_ context: CollectionListContext, indexPathForIndexTitle title: String, at index: Int) -> IndexPath { return IndexPath(section: index) }
}
