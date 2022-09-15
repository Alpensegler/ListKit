import ListKit
import UIKit

public class ContentsViewController: UIViewController, UpdatableListAdapter {
    public typealias Model = (title: String, viewController: UIViewController.Type)
    public var source = [Model]()

    public var list: ListAdaptation<ContentsViewController, UITableView> {
        cellForRow { (context, model) -> UITableViewCell in
            let labelCell = context.dequeueReusableCell(UITableViewCell.self)
            labelCell.textLabel?.text = model.title
            return labelCell
        }
        didSelectRow { [unowned navigationController] (context, model) in
            context.deselect(animated: true)
            let viewController = model.viewController.init()
            viewController.title = model.title
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
//            ("NestedList", NestedListViewController.self),
            ("IdentifiableSectionList", IdentifiableSectionListViewController.self),
//            ("CoreDataListViewController", CoreDataListViewController.self),
//            ("TestList", TestListViewController.self),
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
