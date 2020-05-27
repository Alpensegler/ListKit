//
//  DoubleListViewController.swift
//  ListKitExample
//
//  Created by Frain on 2020/5/12.
//

import UIKit
import ListKit

class DoubleListViewController: ExampleViewController, TableListAdapter, CollectionListAdapter, UpdatableDataSource {
    
    private let _models = ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy"]
    
    typealias Item = String
    
    var source: [String] {
        var shuffledModels = _models.shuffled()
        shuffledModels.removeFirst()
        shuffledModels.removeLast()
        return shuffledModels.shuffled()
    }
    
    var tableList: TableList<DoubleListViewController> {
        tableViewCellForRow()
    }
    
    var collectionList: CollectionList<DoubleListViewController> {
        collectionViewCellForItem(CenterLabelCell.self) { (cell, _, item) in cell.text = "\(item)" }
        .collectionViewLayoutSizeForItem { (_, _, _) in CGSize(width: 75, height: 75) }
        .collectionViewLayoutInsetForSection { (_, _) in UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshAction { [unowned self] in self.performUpdate() }
        
        let halfHeight = view.bounds.height / 2
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: halfHeight)
        collectionView.frame = CGRect(x: 0, y: halfHeight, width: view.frame.width, height: halfHeight)
        
        apply(by: collectionView)
        apply(by: tableView)
    }
}


#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct DoubleList_Preview: PreviewProvider {
    static var previews: some View {
        ExampleView(viewController: DoubleListViewController())
    }
}

#endif
