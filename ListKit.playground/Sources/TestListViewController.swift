#if !os(macOS)
import ListKit
import UIKit

// swiftlint:disable comment_spacing orphaned_doc_comment

public class TestListViewController: UIViewController, TableListAdapter {
    public var toggle = true

    @CollectionElements
    var collectionElements = [1.0, 2.0, 3.0]

    final class SingleListAdapter: TableListAdapter {
        var toggle = true

        public var list: TableList {
            buildList {
                if toggle {
                    SingleElement(true)
                        .cellForRow()
                        .didSelectRow { [unowned self] context in
                            context.deselect(animated: false)
                            toggle.toggle()
                            performUpdate()
                        }
                } else {
                    CollectionElements([false, false, false])
                        .cellForRow()
                        .didSelectRow { [unowned self] context in
                            context.deselect(animated: false)
                            toggle.toggle()
                            performUpdate()
                        }
                }
            }
            .headerTitleForSection("item")
        }
    }

    public var list: TableList {
        if toggle {
            SingleListAdapter()
            $collectionElements
                .cellForRow()
                .headerTitleForSection("items")
        }
        SectionedElements([[1, 2, 3], [1, 2, 3]])
            .cellForRow()
            .headerTitleForSection("sections")
        buildList {
            SingleElement("a")
                .cellForRow()
            SingleElement(2)
                .cellForRow()
            CollectionElements(["a", "b", "c"])
                .cellForRow()
        }
        .didSelectRow { context, element in
            print(element)
        }
        .headerTitleForSection("sources")
    }

    public override func viewDidLoad() {
        tableView.adapted(by: self)
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
//        itemsSource.perform(.remove(at: item))
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

#endif
