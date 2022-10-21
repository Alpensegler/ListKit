// swiftlint:disable comment_spacing

import ListKit
import UIKit

//public class NestedListViewController: UIViewController, UpdatableListAdapter {
//    public typealias Model = Any
//
//    let nestedSources = Sources(models: 0..<10)
//        .cellForItem(CenterLabelCell.self) { (cell, context, model) in
//            cell.text = "\(model)"
//        }
//
//    public var source: AnyTableSources {
//        AnyTableSources {
//            Sources(model: nestedSources)
//                .cellForRow(EmbeddedCell.self) { (cell, context, model) in
//                    model.apply(by: cell.collectionView)
//                }
//                .heightForRow(100)
//            Sources(models: ["a", "b", "c"])
//                .cellForRow()
//                .heightForRow(50)
//        }
//    }
//
//    public override func viewDidLoad() {
//        apply(by: tableView)
//    }
//}
//
//extension NestedListViewController {
//    final class EmbeddedCell: UITableViewCell {
//        lazy var collectionView: UICollectionView = {
//            let layout = UICollectionViewFlowLayout()
//            layout.scrollDirection = .horizontal
//            let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
//            view.backgroundColor = .clear
//            view.alwaysBounceVertical = false
//            view.alwaysBounceHorizontal = true
//            self.contentView.addSubview(view)
//            return view
//        }()
//
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            collectionView.frame = contentView.frame
//        }
//    }
//
//    final class CenterLabelCell: UICollectionViewCell {
//        lazy private var label: UILabel = {
//            let view = UILabel()
//            view.backgroundColor = .clear
//            view.textAlignment = .center
//            view.textColor = .black
//            view.font = .boldSystemFont(ofSize: 18)
//            self.contentView.addSubview(view)
//            return view
//        }()
//
//        var text: String? {
//            get { return label.text }
//            set { label.text = newValue }
//        }
//
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            label.frame = contentView.bounds
//        }
//
//    }
//
//    var tableView: UITableView {
//        let tableView = UITableView(frame: view.bounds)
//        view.addSubview(tableView)
//        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        return tableView
//    }
//}
//
//#if canImport(SwiftUI) && EXAMPLE
//
//import SwiftUI
//
//@available(iOS 13.0, *)
//struct NestedList_Preview: UIViewControllerRepresentable, PreviewProvider {
//    static var previews: some View { NestedList_Preview() }
//
//    func makeUIViewController(context: Self.Context) -> UINavigationController {
//        UINavigationController(rootViewController: NestedListViewController())
//    }
//
//    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) {
//
//    }
//}
//
//#endif
