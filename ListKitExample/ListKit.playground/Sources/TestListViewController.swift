import ListKit
import UIKit

// swiftlint:disable comment_spacing

public class TestListViewController: UIViewController, UpdatableTableListAdapter {
    public var toggle = true

    lazy var itemSource = ItemSource()
    lazy var itemsSource = Sources(items: [1.0, 2.0, 3.0], options: .removeEmptySection)
        .tableViewCellForRow()
        .tableViewDidSelectRow { [unowned self] (context, item) in
            self.batchRemove(at: context.item)
        }
        .tableViewHeaderTitleForSection("items")

    final class ItemSource: UpdatableTableListAdapter {
        // swiftlint: disable nesting
        public typealias Item = Any
        // swiftlint: enable nesting
        var toggle = true

        public var source: AnyTableSources {
            AnyTableSources {
                if toggle {
                    Sources(item: true)
                        .tableViewCellForRow()
                        .tableViewDidSelectRow { [unowned self] (context, _) in
                            context.deselectItem(animated: false)
                            self.toggle.toggle()
                            self.performUpdate()
                        }
                } else {
                    Sources(items: [false, false, false])
                        .tableViewCellForRow()
                        .tableViewDidSelectRow { (context, _) in
                            context.deselectItem(animated: false)
                            self.toggle.toggle()
                            self.performUpdate()
                        }
                }
            }
            .tableViewHeaderTitleForSection("item")
        }
    }

    public typealias Item = Any
    public var source: AnyTableSources {
        AnyTableSources {
            if toggle {
                itemSource
                itemsSource
            }
            Sources(sections: [[1, 2, 3], [1, 2, 3]])
                .tableViewCellForRow()
                .tableViewHeaderTitleForSection("sections")
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
            }.tableViewHeaderTitleForSection("sources")
        }
    }

    public override func viewDidLoad() {
        apply(by: tableView)
        configActions()
    }

    func configActions() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refresh)
        )
    }

    @objc func refresh() {
        toggle.toggle()
        performUpdate()
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
//
//public extension TestListViewController {
//    static var source = [AnyTableSources]()
//
//    typealias Item = Any
//    var source: [AnyTableSources] {
//        []
//    }
//
//    func configActions() {
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(
//                barButtonSystemItem: .add,
//                target: self,
//                action: #selector(add)
//            ),
//            UIBarButtonItem(
//                barButtonSystemItem: .refresh,
//                target: self,
//                action: #selector(refresh)
//            )
//        ]
//    }
//
//    @objc func add() {
//        let source = AnyTableSources {
//            itemsSource
//        }
//        perform(.append(source))
//    }
//
//    @objc func refresh() {
//        var update = ListUpdate<SourceBase>()
//        update.add(.subsource(itemsSource, update: [.append(4.0), .update(0.0, at: 0)]))
//        perform(update)
//
//        itemSource.toggle.toggle()
//        itemSource.performUpdate()
//    }
//}
