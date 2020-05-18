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
        collectionViewCellForItem { (context, item) -> UICollectionViewCell in
            let cell = context.dequeueReusableCell(CenterLabelCell.self)
            cell.text = item
            return cell
        }
    }
    
    override func viewDidLoad() {
        addRefreshAction()
        
        let halfHeight = view.bounds.height / 2
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: halfHeight)
        collectionView.frame = CGRect(x: 0, y: halfHeight, width: view.frame.width, height: halfHeight)
        
        apply(by: collectionView)
        apply(by: tableView)
    }
    
    override func refresh() {
        performUpdate()
    }
}
