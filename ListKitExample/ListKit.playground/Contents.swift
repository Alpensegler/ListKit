import ListKit
import PlaygroundSupport
import UIKit

let contentsViewController = ContentsViewController()
contentsViewController.source = [
    ("DoubleList", DoubleListViewController.self),
    ("SectionList", SectionListViewControlle.self),
    ("NestedList", NestedListViewController.self),
    ("IdentifiableSectionList", IdentifiableSectionListViewController.self),
    ("CoreDataListViewController", CoreDataListViewController.self),
    ("TestList", TestListViewController.self)
]

let navigationController = UINavigationController(rootViewController: contentsViewController)
navigationController.view.frame = CGRect(origin: .zero, size: CGSize(width: 375, height: 812))
PlaygroundPage.current.liveView = navigationController.view
