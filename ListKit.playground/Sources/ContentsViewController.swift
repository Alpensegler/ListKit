
import ListKit
#if !os(macOS)
import UIKit

public class ContentsViewController: UIViewController, TableListAdapter {
    public typealias Content = (title: String, viewController: UIViewController.Type)
    public var models = [Content]()

    public var list: TableList {
        CollectionElements(models)
            .cellForRow { context, model -> UITableViewCell in
                let labelCell = context.dequeueReusableCell(UITableViewCell.self)
                labelCell.textLabel?.text = model.title
                return labelCell
            }
            .didSelectRow { [unowned navigationController] context, model in
                context.deselect(animated: true)
                let viewController = model.viewController.init()
                viewController.title = model.title
                navigationController?.pushViewController(viewController, animated: true)
            }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.adapted(by: self)
        title = "Contents"
    }

    #if EXAMPLE
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        models = [
            ("SimpleList", SimpleListViewController.self),
            ("SectionList", SectionListViewControlle.self),
            ("NestedList", NestedListViewController.self),
            ("IdentifiableSectionList", IdentifiableSectionListViewController.self),
//            ("CoreDataListViewController", CoreDataListViewController.self),
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

#else
import AppKit

public class ContentsViewController: NSViewController, CollectionListAdapter {

    public typealias Content = (title: String, viewController: NSViewController.Type)
    public var models = [Content]()

    public var list: CollectionList {
        CollectionElements(models)
            .itemForRepresentedObjectAt { context, element in
                let item = context.makeItem(MyCollectionViewItem.self)
                item.configure(with: element.title)
                return item
            }
            .didSelectItems { context, element in
                context.deselect(animated: false)
            }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 100, height: 100)
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10

        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColors = [NSColor.windowBackgroundColor]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isSelectable = true
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.adapted(by: self)
    }

    #if EXAMPLE
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        models = [
            ("SimpleList", ContentsViewController.self),
            ("SectionList", ContentsViewController.self),
            ("NestedList", ContentsViewController.self),
            ("IdentifiableSectionList", ContentsViewController.self),
            ("TestList", ContentsViewController.self),
        ]

    }
    #endif
}

class MyCollectionViewItem: NSCollectionViewItem {
    private lazy var customTextField = NSTextField(labelWithString: "")

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        customTextField.alignment = .center
        customTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customTextField)

        // 设置约束使得 NSTextField 在视图中居中
        NSLayoutConstraint.activate([
            customTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            // 可以根据需要添加宽度和高度约束
        ])

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        ).cgColor
    }

    // 用于更新文本字段内容的方法
    func configure(with text: String) {
        customTextField.stringValue = text
    }
}

#endif
