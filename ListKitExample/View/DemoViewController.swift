//
//  DemoViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/18.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return tableView
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return collectionView
    }()
}
