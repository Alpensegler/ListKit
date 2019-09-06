//
//  NestedListViewController.swift
//  SundayListKitDemo
//
//  Created by Frain on 2019/9/5.
//  Copyright © 2019 Frain. All rights reserved.
//

import SundayListKit

struct NestedCollectionElement: TableListAdapter, Identifiable {
    typealias Item = Int
    let source: Int
    var subSource: CollectionSectionSources<String>
    let listUpdater = ListUpdater()
    var id: Int { return source }
    
    init(source: Int, elements: [String]) {
        self.source = source
        self.subSource = SectionSources(items: elements)
            .provideCell(CenterLabelCell.self) { $0.text = $1 }
    }
    
    func tableContext(_ context: TableListContext, cellForItem item: Int) -> UITableViewCell {
        return context.dequeueReusableCell(withCellClass: EmbeddedCell.self) {
            setNestedCollectionView($0.collectionView, with: \.subSource)
        }
    }
    
    func tableContext(_ context: TableListContext, heightForItem item: Int) -> CGFloat {
        return 100
    }
}

class NestedListViewController: UIViewController, TableListAdapter {
    @IBOutlet weak var tableView: UITableView! {
        didSet { setTableView(tableView) }
    }
    typealias Item = Int
    var source: [NestedCollectionElement] {
        return [
            nestedCollectionElement(),
            nestedCollectionElement(),
            nestedCollectionElement(),
            nestedCollectionElement(),
            nestedCollectionElement(),
        ]
    }
    
    func nestedCollectionElement() -> NestedCollectionElement {
        return NestedCollectionElement(source: (0..<10).randomElement()!, elements: (0..<10).shuffled().map(String.init))
    }
    
    @IBAction func onRefresh(_ sender: UIBarButtonItem) {
        performUpdate()
    }
}


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
