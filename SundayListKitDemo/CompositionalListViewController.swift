//
//  CompositionalListViewController.swift
//  SundayListKitDemo
//
//  Created by Frain on 2019/8/30.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import SundayListKit

class CompositionalListViewController: UIViewController, TableListAdapter {
    @IBOutlet weak var tableView: UITableView! {
        didSet { setTableView(tableView) }
    }
    
    var sourceOne = ListSources<String>(
        ItemSources<String>(item: "Roy"),
        SectionSources<String>(id: 3202, items: ["Zhiyi", "Frain"]),
        ListSources<String>(id: 4912,
            SectionSources<String>(id: 2018, items: ["Pinlin", "Jack"]),
            ItemSources<String>(item: "Coklie"),
            SectionSources<String>(id: 2019, items: ["Kubrick", "Jeremy"])
        )
    )
    
    var shuffledSource = ListSources<String>(
        ListSources<String>(id: 4912,
            ItemSources<String>(item: "Kubrick"),
            ItemSources<String>(item: "Coklie"),
            SectionSources<String>(id: 2018, items: ["Jack", "Pinlin"]),
            ItemSources<String>(item: "Jeremy")
        ),
        ItemSources<String>(item: "Roy"),
        SectionSources<String>(id: 3202, items: ["Frain", "Zhiyi"])
    )
    
    typealias Item = String
    var bool = true
    var source: ListSources<String> {
        defer { bool.toggle() }
        return bool ? sourceOne : shuffledSource
    }
    
    func tableContext(_ context: TableListContext, cellForItem item: String) -> UITableViewCell {
        return context.dequeueReusableCell(withCellClass: UITableViewCell.self) {
            $0.textLabel?.text = item
        }
    }
    
    @IBAction func onRefresh(_ sender: UIBarButtonItem) {
        performUpdate()
    }
}
