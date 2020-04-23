//
//  ViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/13.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import ListKit

class ContentsViewController: DemoViewController, UpdatableTableListAdapter {
    typealias Item = (title: String, viewController: UIViewController.Type)
    lazy var source = [
        page("nested", NestedViewController.self),
        page("test", TestViewController.self)
    ]
    
    func page(_ title: String, _ viewController: UIViewController.Type) -> TableList<Sources<Item, Item>> {
        Sources(item: (title: title, viewController: viewController))
            .tableViewCellForRow { (context, item) -> UITableViewCell in
                let labelCell = context.dequeueReusableCell(UITableViewCell.self)
                labelCell.textLabel?.text = item.title
                return labelCell
            }
            .tableViewDidSelectRow { [unowned navigationController] (context, item) in
                navigationController?.pushViewController(item.viewController.init(), animated: true)
            }
    }
    
    override func viewDidLoad() {
        apply(by: tableView)
    }
}
