import UIKit
import ListKit

public class DoubleListViewController: UIViewController, TableListAdapter, CollectionListAdapter, UpdatableDataSource {
    private let _models = ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy", "Juhao", "Herry"]
    
    public typealias Item = String
    var toggle = false
    
    public var source: [String] {
        var shuffledModels = _models.shuffled()
        shuffledModels.removeFirst()
        shuffledModels.removeLast()
        return shuffledModels.shuffled()
    }
    
    public var tableList: TableList<DoubleListViewController> {
        tableViewCellForRow()
        .tableViewDidSelectRow { [unowned self] (context, item) in
            self.perform(.remove(at: context.item))
        }
    }
    
    public var collectionList: CollectionList<DoubleListViewController> {
        collectionListWithCacheSize(forItem: { context, item in
            print("fake calculating size for \(item)")
            return CGSize(width: 75, height: 75)
        }, CenterLabelCell.self, closure: { (cell, _, _, item) in
            cell.text = "\(item)"
        })
        .collectionViewLayoutInsetForSection { (_, _) in
            UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        apply(by: collectionView)
        apply(by: tableView)
        
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

//UI
extension DoubleListViewController {
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
        let halfHeight = view.bounds.height / 2
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: halfHeight)
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
        perform(.appendOrRemoveLast)
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
            self.perform(.append(content))
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
        UINavigationController(rootViewController: DoubleListViewController())
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) { }
}

#endif

public extension DoubleListViewController {
//    typealias Item = String
//
//    var source: [Item] {
//        [1, 2, 3].map { "\($0)" }
//    }
//
//    typealias Item = (Int, Bool)
//
//    var source: [Item] {
//        if toggle {
//            return [(1, true), (2, true), (3, true)]
//        } else {
//            return [(2, false), (3, false)]
//        }
//    }
//
//    var listUpdate: ListUpdate<DoubleListViewController>.Whole {
//        .diff(id: \.0) { $0.1 == $1.1 }
//    }
}

