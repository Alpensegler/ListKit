//
//  IdentifiableSectionListViewController.swift
//  ListKitExample
//
//  Created by Frain on 2020/5/23.
//

import UIKit
import ListKit

struct Room {
    let name: String
    let people: [String]
}

extension Room: CollectionListAdapter {
    typealias Item = String
    
    var source: [String] { people }
    var listOptions: ListOptions<Room> { .diff(id: \.name) }
    
    var collectionList: CollectionList<Room> {
        collectionViewCellForItem(CenterLabelCell.self) { (cell, context, item) in
            cell.text = item
        }
        .collectionViewLayoutSizeForItem { (_, _, _) in
            CGSize(width: 70, height: 70)
        }
        .collectionViewLayoutInsetForSection { _, _ in
            UIEdgeInsets(top: 10, left: 10, bottom: 30, right: 10)
        }
        .collectionViewLayoutMinimumLineSpacingForSection { (_, _) in
            50
        }
        .collectionViewLayoutMinimumInteritemSpacingForSection { (_, _) in
            5
        }
        .collectionViewLayoutReferenceSizeForHeaderInSection { (_, _) in
            CGSize(width: UIScreen.main.bounds.width, height: 30)
        }
        .collectionViewSupplementaryViewForItem { [name] in
            let header = $0.dequeueReusableSupplementaryView(type: $1, TitleHeader.self)
            header.text = name
            return header
        }
    }
}

class IdentifiableSectionListViewController: ExampleViewController, UpdatableCollectionListAdapter {
    typealias Item = String
    
    var source: [Room] {
        Room.random
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apply(by: collectionView)
        
        addRefreshAction { [unowned self] in self.performUpdate() }
    }
}

extension Room: CustomStringConvertible {
    static let members = [
        "Roy", "Pinlin", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy",
        "July", "Raynor", "Tonny", "Dooze", "Charlie", "Venry",
        "Bernard", "Mai", "Melissa", "Kippa", "Jerry"
    ]
    
    static var random: [Room] {
        var shuffled = members.shuffled()
        var rooms = [
            ("Interview B", 2),
            ("Interview A", 2),
            ("River View", 4),
            ("Meeting", 6),
        ]
        var results = [Room]()
        
        while let (name, limit) = rooms.popLast() {
            let people = Bool.random() || Bool.random()
                ? (0...Int.random(in: 0..<limit)).compactMap { _ in shuffled.popLast() }
                : []
            results.append(.init(name, people))
        }
        
        return results
            .sorted { $0.people.count > $1.people.count }
    }
    
    
    init(_ name: String, _ people: [String]) {
        self.name = name
        self.people = people
    }
    
    var description: String { "Room(\"\(name)\", \(people))" }
}

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 13.0, *)
struct IdentifiableSectionList_Preview: PreviewProvider {
    static var previews: some View {
        ExampleView(viewController: IdentifiableSectionListViewController())
    }
}

#endif
