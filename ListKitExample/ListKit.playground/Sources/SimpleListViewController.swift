// swiftlint: disable unused_closure_parameter

import ListKit
import UIKit

public class SimpleListViewController: UIViewController, TableListAdapter {
    private let _models = ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy", "Juhao", "Herry"]

    var toggle = false

    public var models: [String] {
        var shuffledModels = _models.shuffled()
        shuffledModels.removeFirst()
        shuffledModels.removeLast()
        return shuffledModels
    }

    public var list: TableList {
        CollectionElements(models)
            .cellForRow()
            .didSelectRow { _, _ in //[unowned self] context, element in
//                performUpdate(.remove(at: context.item))
            }
            .didEndDragging { _, bool in
                print("didEndDragging \(bool)")
            }
            .willBeginDragging { _ in
                print("didDrag")
            }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.adapted(by: self)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .refresh,
                target: self,
                action: #selector(refresh)
            ),
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(add)
            ),
        ]
    }
}

// UI
extension SimpleListViewController {
    final class CenterLabelCell: UICollectionViewCell {
        lazy private var label: UILabel = {
            let view = UILabel()
            view.backgroundColor = .clear
            view.textAlignment = .center
            view.textColor = .black
            view.font = .boldSystemFont(ofSize: 18)
            self.contentView.addSubview(view)
            return view
        }()

        var text: String? {
            get { return label.text }
            set { label.text = newValue }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            label.frame = contentView.bounds
        }
    }

    var tableView: UITableView {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.bounds.height)
        let tableView = UITableView(frame: frame)
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return tableView
    }

    var collectionView: UICollectionView {
        let halfHeight = view.bounds.height / 2
        let frame = CGRect(x: 0, y: halfHeight, width: view.frame.width, height: halfHeight)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .white
        return collectionView
    }

    @objc func refresh() {
        performUpdate()
    }

    @objc func add() {
        let alert = UIAlertController(title: "Add content", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Content"
            textField.selectAll(nil)
        }

        alert.addAction(UIAlertAction(title: "cancel", style: .cancel))

        let ok = UIAlertAction(title: "Done", style: .default) { [unowned self, unowned alert] _ in
            guard let content = alert.textFields?.first?.text, !content.isEmpty else { return }
//            self.perform(.append(content))
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

#if canImport(SwiftUI) && EXAMPLE

import SwiftUI

@available(iOS 13.0, *)
struct DoubleList_Preview: UIViewControllerRepresentable, PreviewProvider {
    static var previews: some View { DoubleList_Preview() }

    func makeUIViewController(context: Self.Context) -> UINavigationController {
        UINavigationController(rootViewController: SimpleListViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) { }
}

#endif

public extension SimpleListViewController {
//    static var toggle = true
//
//    typealias Item = (Int)
//
//    var listOptions: ListOptions { Self.toggle ? [] : .removeEmptySection }
//
//    var source: [Item] {
//        defer { Self.toggle.toggle() }
//        if Self.toggle {
//            return []
//        } else {
//            return [2, 3]//[(2, false), (3, false)]
//        }
//    }
//
//    var listUpdate: ListUpdate<DoubleListViewController>.Whole {
//        .diff(id: \.0) { $0.1 == $1.1 }
//    }
}
