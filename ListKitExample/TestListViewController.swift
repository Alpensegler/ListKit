//
//  TestViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/18.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import ListKit

class TestListViewController: ExampleViewController, UpdatableTableListAdapter {
    typealias Item = Any
    var source: AnyTableSources {
        AnyTableSources {
            Sources(item: 1.0)
                .tableViewCellForRow()
                .tableViewDidSelectRow { (context, item) in
                    context.deselectItem(animated: false)
                    print(item)
                }
                .tableViewHeaderTitleForSection { (context) -> String? in
                    "item"
                }
            Sources(items: ["a", "b", "c"])
                .tableViewCellForRow()
                .tableViewDidSelectRow { (context, item) in
                    context.deselectItem(animated: false)
                    print(item)
                }
                .tableViewHeaderTitleForSection { (context) -> String? in
                    "items"
                }
            Sources(sections: [[1, 2, 3], [1, 2, 3]])
                .tableViewCellForRow()
                .tableViewHeaderTitleForSection { (context) -> String? in
                    "sections"
                }
            AnyTableSources {
                Sources(item: 2)
                    .tableViewCellForRow()
                    .tableViewDidSelectRow { (context, item) in
                        context.deselectItem(animated: false)
                        print(item)
                    }
                Sources(items: ["a", "b", "c"])
                    .tableViewCellForRow()
                    .tableViewDidSelectRow { (context, item) in
                        context.deselectItem(animated: false)
                        print(item)
                    }
            }.tableViewHeaderTitleForSection { (context) -> String? in
                "sources"
            }
        }
    }
    
    override func viewDidLoad() {
        apply(by: tableView)
    }
}
