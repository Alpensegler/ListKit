//
//  NestedViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/18.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import ListKit

class NestedListViewController: ExampleViewController, UpdatableTableListAdapter {
    typealias Item = Any
    
    let nestedSources = Sources(items: 0..<10)
        .collectionViewCellForItem(CenterLabelCell.self) { (cell, context, item) in
            cell.text = "\(item)"
        }
    
    var source: AnyTableSources {
        AnyTableSources {
            Sources(item: nestedSources)
                .tableViewCellForRow(EmbeddedCell.self) { (cell, context, item) in
                    context.nestedAdapter(applyBy: cell.collectionView)
                }
                .tableViewHeightForRow { _, _ in return 100 }
            Sources(items: ["a", "b", "c"])
                .tableViewCellForRow()
                .tableViewHeightForRow { _, _ in return 50 }
        }
    }
    
    override func viewDidLoad() {
        apply(by: tableView)
    }
}


#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct NestedList_Preview: PreviewProvider {
    static var previews: some View {
        ExampleView(viewController: NestedListViewController())
    }
}

#endif
