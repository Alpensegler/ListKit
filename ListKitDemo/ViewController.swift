//
//  ViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/13.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import ListKit

class ViewController: DemoViewController, UpdatableTableListAdapter {
    typealias Item = Any
    var source: AnyTableSources {
        AnyTableSources {
            page("nested", viewController: NestedViewController.self)
            page("test", viewController: TestViewController.self)
        }
    }
    
    override func viewDidLoad() {
        apply(by: tableView)
    }
    
    func page(_ title: String, viewController: UIViewController.Type) -> some TableListAdapter {
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
}
