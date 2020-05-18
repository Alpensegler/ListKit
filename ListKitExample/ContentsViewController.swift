//
//  ViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/13.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import ListKit

class ContentsViewController: ExampleViewController, UpdatableTableListAdapter {
    typealias Item = (title: String, viewController: UIViewController.Type)
    var source: [Item] = [
        ("DoubleList", DoubleListViewController.self),
        ("SectionList", SectionListViewControlle.self),
        ("NestedList", NestedListViewController.self),
        ("TestList", TestListViewController.self)
    ]
    
    var tableList: TableList<ContentsViewController> {
        tableViewCellForRow { (context, item) -> UITableViewCell in
            let labelCell = context.dequeueReusableCell(UITableViewCell.self)
            labelCell.textLabel?.text = item.title
            return labelCell
        }
        .tableViewDidSelectRow { [unowned navigationController] (context, item) in
            context.deselectItem(animated: true)
            let viewController = item.viewController.init()
            viewController.title = item.title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        apply(by: tableView)
        title = "Contents"
    }
}
