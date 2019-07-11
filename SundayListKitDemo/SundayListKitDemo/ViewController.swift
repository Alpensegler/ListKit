//
//  ViewController.swift
//  SundayListKitDemo
//
//  Created by Frain on 2019/7/11.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import SundayListKit

final class ViewController: UIViewController, TableListAdapter, CollectionListAdapter {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let _models = ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie"]
    
    typealias Item = String

    func source<List>(for listView: List) -> [ViewController.Item] where List : ListView {
        var shuffledModels = _models.shuffled()
        shuffledModels.removeFirst()
        return shuffledModels.shuffled()
    }
    
    func cellForViewModel<List>(for context: ListIndexContext<List, ViewController>, viewModel: String) -> List.Cell where List: ListView {
        if context.listView === tableView {
            return context.dequeueReusableCell(withCellClass: UITableViewCell.self) {
                $0.textLabel?.text = viewModel
            }
        } else {
            return context.dequeueReusableCell(withCellClass: TextCell.self) {
                $0.label.text = viewModel
            }
        }
    }
    
    func sizeForViewModel<List>(context: ListIndexContext<List, ViewController>, viewModel: String) -> ListSize where List : ListView {
        if context.listView === tableView { return context.listView.defaultItemSize }
        return CGSize(width: 125, height: 125)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.listDelegate = self
        collectionView.listDelegate = self
        performUpdate()
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        performUpdate()
    }
}

class TextCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension TextCell {
    func configure() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: frame.width),
            contentView.widthAnchor.constraint(equalToConstant: frame.height),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
