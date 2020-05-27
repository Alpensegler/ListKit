//
//  IdentifiableSectionListViewController.swift
//  ListKitExample
//
//  Created by Frain on 2020/5/23.
//

import UIKit
import ListKit

let members = [
    "Roy", "Pinlin", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy",
    "July", "Raynor", "Tonny", "Dooze", "Charlie", "Venry",
    "Bernard", "Mai", "Melissa", "Kippa", "Jerry"
]

struct Room {
    let name: String
    let people: [String]
    
    static var random: [Room] {
        var shuffled = members.shuffled()
        var rooms = [("Meeting", 6), ("River View", 4), ("Interview A", 2), ("Interview B", 2)].shuffled()
        var results = [Room]()
        
        while let (name, limit) = rooms.popLast() {
            let people = (0...Int.random(in: 0...limit)).compactMap { _ in shuffled.popLast() }
            results.append(.init(name: name, people: people))
        }
        
        return results.sorted { $0.people.count > $1.people.count }
    }
}

extension Room: TableListAdapter {
    typealias Item = String
    
    var source: [String] { people }
    var differ: Differ<Room> { .diff(id: \.name) }
    
    var tableList: TableList<Room> {
        tableViewCellForRow()
        .tableViewHeaderTitleForSection { _ in self.name }
    }
}

class IdentifiableSectionListViewController: ExampleViewController, UpdatableTableListAdapter {
    typealias Item = String
    
    var source: [Room] {
        Room.random
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apply(by: tableView)
        
        addRefreshAction { [unowned self] in self.performUpdate() }
    }
}
