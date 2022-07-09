// swiftlint:disable unused_closure_parameter

import ListKit
import UIKit

public class NestedListViewController: UIViewController, UpdatableTableListAdapter {
    public typealias Item = Any

    let nestedSources = Sources(items: 0..<10)
        .collectionViewCellForItem(CenterLabelCell.self) { (cell, context, item) in
            cell.text = "\(item)"
        }

    public var source: AnyTableSources {
        AnyTableSources {
            Sources(item: nestedSources)
                .tableViewCellForRow(EmbeddedCell.self) { (cell, context, item) in
                    context.nestedAdapter(applyBy: cell.collectionView)
                }
                .tableViewHeightForRow(100)
            Sources(items: ["a", "b", "c"])
                .tableViewCellForRow()
                .tableViewHeightForRow(50)
        }
    }

    public override func viewDidLoad() {
        apply(by: tableView)
    }
}

extension NestedListViewController {
    final class EmbeddedCell: UITableViewCell {
        lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
            view.backgroundColor = .clear
            view.alwaysBounceVertical = false
            view.alwaysBounceHorizontal = true
            self.contentView.addSubview(view)
            return view
        }()

        override func layoutSubviews() {
            super.layoutSubviews()
            collectionView.frame = contentView.frame
        }
    }

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
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return tableView
    }
}

#if canImport(SwiftUI) && EXAMPLE

import SwiftUI

@available(iOS 13.0, *)
struct NestedList_Preview: UIViewControllerRepresentable, PreviewProvider {
    static var previews: some View { NestedList_Preview() }

    func makeUIViewController(context: Self.Context) -> UINavigationController {
        UINavigationController(rootViewController: NestedListViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) {

    }
}

#endif
