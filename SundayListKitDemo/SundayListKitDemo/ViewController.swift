//
//  ViewController.swift
//  SundayListKitDemo
//
//  Created by Frain on 2019/7/11.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import SundayListKit

class ViewController: UIViewController, TableListAdapter, CollectionListAdapter {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let _models = ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie"]
    
    typealias Item = String
    
    var source: [String] {
        var shuffledModels = _models.shuffled()
        shuffledModels.removeFirst()
        return shuffledModels.shuffled()
    }
    
    func tableContext(_ context: TableListContext, cellForItem item: String) -> UITableViewCell {
        return context.dequeueReusableCell(withCellClass: UITableViewCell.self) {
            $0.textLabel?.text = item
        }
    }
    
    func collectionContext(_ context: CollectionListContext, cellForItem item: String) -> UICollectionViewCell {
        return context.dequeueReusableCell(withCellClass: TextCell.self) {
            $0.label.text = item
        }
    }
    
    func collectionContext(_ context: CollectionListContext, layout collectionViewLayout: UICollectionViewLayout, sizeForItem item: String) -> CGSize {
        return CGSize(width: 125, height: 125)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.coordinator = tableCoordinator()
        collectionView.coordinator = collectionCoordinator()
        performUpdate(animated: true, completion: nil)
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        performUpdate(animated: true, completion: nil)
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
