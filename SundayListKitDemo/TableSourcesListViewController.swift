//
//  TableSourcesListViewController.swift
//  SundayListKitDemo
//
//  Created by Frain on 2019/9/5.
//  Copyright © 2019 Frain. All rights reserved.
//

import SundayListKit

class TableSourcesListViewController: UIViewController, TableListAdapter {
    struct Section: TableListAdapter, Identifiable {
        var title: String
        var id: String { return title }
        
        var randomItem: String {
            return ["One", "Two", "Three", "Four", "Five"].randomElement()!
        }
        
        let listUpdater = ListUpdater()
        typealias Item = Any
        var source: TableListSources {
            return TableListSources(
                ItemSources(item: randomItem).provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 },
                ItemSources(item: randomItem).provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 },
                ItemSources(item: randomItem).provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 },
                ItemSources(item: randomItem).provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 }
            )
        }
        
        func tableContext(_ context: TableListContext, didSelectItem item: Any) {
            context.deselectItem(animated: true)
            performUpdate()
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet { setTableView(tableView) }
    }
    
    typealias Item = Any
    
    var source: TableListSources {
        return TableListSources(
            ItemSources(item: "title").provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 },
            ItemSources(item: "subTitle").provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 },
            SectionSources(items: ["content1", "content2", "content3"])
                .provideCell(UITableViewCell.self) { $0.textLabel?.text = $1 }
                .onSelectItem { (_, text: String) in print(text) },
            TableListSources(source: Section(title: "section"))
        )
    }
    
    @IBAction func onRefresh(_ sender: UIBarButtonItem) {
        performUpdate()
    }
}
