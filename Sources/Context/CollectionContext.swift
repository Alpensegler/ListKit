//
//  CollectionContext.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public struct CollectionContext<Source: DataSource>: Context {
    public let listView: UICollectionView
    public let coordinator: SourceListCoordinator<Source>
}

public struct CollectionIndexContext<Source: DataSource>: Context {
    public let listView: UICollectionView
    public let coordinator: SourceListCoordinator<Source>
    public let section: Int
    public let item: Int
}

#endif
