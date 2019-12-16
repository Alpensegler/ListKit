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
    @IBOutlet weak var tableView: UITableView!
    
    typealias Item = Any
    var source: AnyTableSources {
        AnyTableSources {
            Sources(items: ["a", "b", "c"])
                .tableViewCellForRow()
            Sources(items: [1, 2, 3])
                .tableViewCellForRow()
        }
    }
    
    override func viewDidLoad() {
        apply(by: tableView)
    }
}

