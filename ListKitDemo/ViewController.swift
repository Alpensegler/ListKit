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
    
    typealias Item = Any
    var source: AnyTableSources {
        AnyTableSources {
            Sources(items: ["a", "b", "c"])
                .tableViewCellForRow()
                .tableViewDidSelectRow { (context, item) in
                    context.deselectItem(animated: false)
                    print(item)
                }
                .tableViewHeaderTitleForSection { (context) -> String? in
                    "title"
                }
            Sources(sections: [[1, 2, 3], [1, 2, 3]])
                .tableViewCellForRow()
                .tableViewHeaderTitleForSection { (context) -> String? in
                    "title2"
                }
        }
    }
}

