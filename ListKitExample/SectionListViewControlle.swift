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
    var source: [[UnicodeScalar]] {
        (0..<Int.random(in: 2...4)).map { _ in
            Array(Self.emojis.shuffled()[0..<Int.random(in: 20...30)])
        }
    }
    
    var collectionList: CollectionList<SectionListViewControlle> {
        collectionViewCellForItem(CenterLabelCell.self) { (cell, _, item) in cell.text = "\(item)" }
        .collectionViewLayoutSizeForItem { (_, _, _) in CGSize(width: 30, height: 30) }
        .collectionViewLayoutInsetForSection { (_, _) in UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10) }
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

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct SectionList_Preview: PreviewProvider {
    static var previews: some View {
        ExampleView(viewController: SectionListViewControlle())
    }
}

#endif
