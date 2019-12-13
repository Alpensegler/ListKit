//
//  ViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/13.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import ListKit

class ViewController: UIViewController, TableListAdapter, UpdatableDataSource {
    @IBOutlet weak var tableView: UITableView! { didSet { apply(by: tableView) } }
    
    typealias Item = Int
    var source: AnyTableList<Item> {
        AnySource {
            AnySource {
                Sources(item: 1)
                Sources(items: 0..<10)
            }
            Sources(item: 1)
            Sources(items: 0..<10)
        }.provideTableViewCell()
    }
}

