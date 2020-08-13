import UIKit
import PlaygroundSupport
import ListKit

class NavigationController: UINavigationController {
    override func loadView() {
        super.loadView()
        
        view.frame = CGRect(origin: .zero, size: CGSize(width: 375, height: 812))
    }
}

let contentsViewController = ContentsViewController()
contentsViewController.source = [
    ("DoubleList", DoubleListViewController.self),
    ("SectionList", SectionListViewControlle.self),
    ("NestedList", NestedListViewController.self),
    ("IdentifiableSectionList", IdentifiableSectionListViewController.self),
    ("TestList", TestListViewController.self)
]

let navigationController = NavigationController(rootViewController: contentsViewController)

PlaygroundPage.current.liveView = navigationController.view
