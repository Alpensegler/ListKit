import UIKit
import ListKit

public class TestListViewController: UIViewController, UpdatableTableListAdapter {
    public var toggle = true
    
    public typealias Item = Any
    public var source: AnyTableSources {
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
            if toggle {
                Sources(items: ["a", "b", "c"])
                    .tableViewCellForRow()
                    .tableViewDidSelectRow { (context, item) in
                        context.deselectItem(animated: false)
                        print(item)
                    }
                    .tableViewHeaderTitleForSection { (context) -> String? in
                        "items"
                    }
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
    
    public override func viewDidLoad() {
        apply(by: tableView)
        
        let item = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = item
    }
    
    @objc func refresh() {
        toggle.toggle()
        performUpdate()
    }
}

extension TestListViewController {
    var tableView: UITableView {
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return tableView
    }
}

#if canImport(SwiftUI) && EXAMPLE

import SwiftUI

@available(iOS 13.0, *)
struct TestList_Preview: UIViewControllerRepresentable, PreviewProvider {
    static var previews: some View { TestList_Preview() }
    
    func makeUIViewController(context: Self.Context) -> UINavigationController {
        UINavigationController(rootViewController: TestListViewController())
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) {
        
    }
}

#endif

//extension TestListViewController {
//    var source: AnyTableSources {
//        AnyTableSources {
//            if toggle {
//                Sources(item: "b")
//                    .tableViewCellForRow()
//                    .tableViewDidSelectRow { (context, item) in
//                        context.deselectItem(animated: false)
//                        print(item)
//                    }
//            }
//            Sources(id: 1, items: ["a", "b", "c"])
//                .tableViewCellForRow()
//                .tableViewDidSelectRow { (context, item) in
//                    context.deselectItem(animated: false)
//                    print(item)
//                }
//                .tableViewHeaderTitleForSection { (context) -> String? in
//                    "sources"
//                }
//        }
//    }
//}
