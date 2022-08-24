import ListKit
import UIKit

public class ContentsViewController: UIViewController, UpdatableListAdapter {
    public typealias Model = (title: String, viewController: UIViewController.Type)
    public var source = [Model]()

    public var list: ListAdaptation<ContentsViewController, UITableView> {
        tableViewCellForRow { (context, item) -> UITableViewCell in
            let labelCell = context.dequeueReusableCell(UITableViewCell.self)
            labelCell.textLabel?.text = item.title
            return labelCell
        }
        tableViewDidSelectRow { [unowned navigationController] (context, item) in
            context.deselect(animated: true)
            let viewController = item.viewController.init()
            viewController.title = item.title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    public override func viewDidLoad() {
        apply(by: tableView)
        title = "Contents"
    }

    #if EXAMPLE
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        source = [
            ("DoubleList", DoubleListViewController.self),
            ("SectionList", SectionListViewControlle.self),
            ("NestedList", NestedListViewController.self),
            ("IdentifiableSectionList", IdentifiableSectionListViewController.self),
            ("CoreDataListViewController", CoreDataListViewController.self),
            ("TestList", TestListViewController.self),
        ]
    }
    #endif
}

// UI
extension ContentsViewController {
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
struct Contents_Preview: UIViewControllerRepresentable, PreviewProvider {
    static var previews: some View { Contents_Preview() }

    func makeUIViewController(context: Self.Context) -> UINavigationController {
        UINavigationController(rootViewController: ContentsViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) { }
}

#endif
