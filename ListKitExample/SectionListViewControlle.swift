//
//  SectionListViewControlle.swift
//  ListKitExample
//
//  Created by Frain on 2020/5/12.
//

import UIKit
import ListKit

class SectionListViewControlle: ExampleViewController, CollectionListAdapter, UpdatableDataSource {
    static let emojis = (0x1F600...0x1F647).compactMap { UnicodeScalar($0) }
    static let numbers = (0...10)
    
    typealias Item = UnicodeScalar
    var source: [[Item]] {
        (0..<Int.random(in: 3...5)).map { _ in
            Array(Self.emojis.shuffled()[0..<Int.random(in: 20...30)])
        }
    }
    
    var collectionList: CollectionList<SectionListViewControlle> {
        collectionViewCellForItem(CenterLabelCell.self) { (cell, context, item) in
            cell.text = "\(item)"
        }
        .collectionViewLayoutSizeForItem { (_, _, _) -> CGSize in CGSize(width: 30, height: 30) }
        .collectionViewLayoutInsetForSection { (_, _) -> UIEdgeInsets in UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshAction()
        
        apply(by: collectionView)
    }
    
    override func refresh() {
        performUpdate()
    }
}
