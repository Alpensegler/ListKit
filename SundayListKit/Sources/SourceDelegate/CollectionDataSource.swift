//
//  CollectionDataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/26.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol CollectionDataSource: Source {
    typealias CollectionListContext = CollectionContext<SubSource, Item>
    
    func eraseToCollectionSources() -> CollectionSources<SubSource, Item>
    
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

public extension CollectionDataSource where SubSource: Collection, SubSource.Element: CollectionAdapter, Item == SubSource.Element.Item {
    //Getting Views for Items
    func collectionContext(_ context: CollectionListContext, cellForItem item: Item) -> UICollectionViewCell {
        return context.elementsCellForItem()
    }
    
    func collectionContext(_ context: CollectionListContext, viewForSupplementaryElementOfKind kind: SupplementaryViewType, item: Item) -> UICollectionReusableView? {
        return context.elementsViewForSupplementaryElementOfKind(kind: kind)
    }
}

public extension CollectionContext where SubSource: Collection, SubSource.Element: CollectionAdapter, Item == SubSource.Element.Item {
    func elementsCellForItem() -> UICollectionViewCell {
        return element.collectionContext(elementsContext(), cellForItem: elementsItem)
    }
    
    func elementsViewForSupplementaryElementOfKind(kind: SupplementaryViewType) -> UICollectionReusableView? {
        return element.collectionContext(elementsContext(), viewForSupplementaryElementOfKind: kind, item: elementsItem)
    }
}
