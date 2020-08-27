import UIKit
import ListKit

public class TestListViewController: UIViewController, UpdatableTableListAdapter {
    public var toggle = true
    
    lazy var itemSource = AnyTableSources.capture { [unowned self] in
        if self.toggle {
            Sources(item: 1.0)
                .tableViewCellForRow()
                .tableViewDidSelectRow { (context, item) in
                    context.deselectItem(animated: false)
                    print(item)
                }
        } else {
            Sources(item: 2.0)
                .tableViewCellForRow()
                .tableViewDidSelectRow { (context, item) in
                    context.deselectItem(animated: false)
                    print(item)
                }
        }
    }
    .tableViewHeaderTitleForSection { (context) -> String? in
        "item"
    }
    
    lazy var itemsSource = Sources(items: ["a", "b", "c"])
        .tableViewCellForRow()
        .tableViewDidSelectRow { [unowned self] (context, item) in
            self.batchRemove(at: context.item)
        }
        .tableViewHeaderTitleForSection { (context) -> String? in
            "items"
        }
    
    public typealias Item = Any
    public var source: AnyTableSources {
        AnyTableSources {
            itemSource
            itemsSource
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refresh)
        )
    }
    
    @objc func refresh() {
        toggle.toggle()
        itemSource.performUpdate()
    }
    
    func batchRemove(at item: Int) {
        itemsSource.perform(.remove(at: item))
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
