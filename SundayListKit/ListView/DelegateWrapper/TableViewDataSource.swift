//
//  TableViewDataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/29.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

final class UITableViewDataSourceWrapper: NSObject, UITableViewDataSource {
    let tableViewNumberOfRowsInSectionBlock: (UITableView, Int) -> Int
    let tableViewCellForRowAtBlock: (UITableView, IndexPath) -> UITableViewCell
    let numberOfSectionsBlock: (UITableView) -> Int
    let tableViewTitleForHeaderInSectionBlock: (UITableView, Int) -> String?
    let tableViewTitleForFooterInSectionBlock: (UITableView, Int) -> String?
    let tableViewCanEditRowAtBlock: (UITableView, IndexPath) -> Bool
    let tableViewCanMoveRowAtBlock: (UITableView, IndexPath) -> Bool
    let sectionIndexTitlesBlock: (UITableView) -> [String]?
    let tableViewSectionForSectionIndexTitleAtBlock: (UITableView, String, Int) -> Int
    let tableViewCommitforRowAtBlock: (UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void
    let tableViewMoveRowAtToBlock: (UITableView, IndexPath, IndexPath) -> Void
    
    init(_ dataSource: TableViewDataSource) {
        tableViewNumberOfRowsInSectionBlock = { [unowned dataSource] in dataSource.tableView($0, numberOfRowsInSection: $1) }
        tableViewCellForRowAtBlock = { [unowned dataSource] in dataSource.tableView($0, cellForRowAt: $1) }
        numberOfSectionsBlock = { [unowned dataSource] in dataSource.numberOfSections(in: $0) }
        tableViewTitleForHeaderInSectionBlock = { [unowned dataSource] in dataSource.tableView($0, titleForHeaderInSection: $1) }
        tableViewTitleForFooterInSectionBlock = { [unowned dataSource] in dataSource.tableView($0, titleForFooterInSection: $1) }
        tableViewCanEditRowAtBlock = { [unowned dataSource] in dataSource.tableView($0, canEditRowAt: $1) }
        tableViewCanMoveRowAtBlock = { [unowned dataSource] in dataSource.tableView($0, canMoveRowAt: $1) }
        sectionIndexTitlesBlock = { [unowned dataSource] in dataSource.sectionIndexTitles(for: $0) }
        tableViewSectionForSectionIndexTitleAtBlock = { [unowned dataSource] in dataSource.tableView($0, sectionForSectionIndexTitle: $1, at: $2) }
        tableViewCommitforRowAtBlock = { [unowned dataSource] in dataSource.tableView($0, commit: $1, forRowAt: $2) }
        tableViewMoveRowAtToBlock = { [unowned dataSource] in dataSource.tableView($0, moveRowAt: $1, to: $2) }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewNumberOfRowsInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCellForRowAtBlock(tableView, indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSectionsBlock(tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewTitleForHeaderInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewTitleForFooterInSectionBlock(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableViewCanEditRowAtBlock(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableViewCanMoveRowAtBlock(tableView, indexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitlesBlock(tableView)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return tableViewSectionForSectionIndexTitleAtBlock(tableView, title, index)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableViewCommitforRowAtBlock(tableView, editingStyle, indexPath)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableViewMoveRowAtToBlock(tableView, sourceIndexPath, destinationIndexPath)
    }
}

public protocol TableViewDataSource: class {
    //Providing the Number of Rows and Sections
    func numberOfSections(in tableView: UITableView) -> Int
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    //Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    
    //Inserting or Deleting Table Rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    
    //Reordering Table Rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    //Configuring an Index
    func sectionIndexTitles(for tableView: UITableView) -> [String]?
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
}

private var tableViewDataSourceKey: Void?

public extension TableViewDataSource {
    //Providing the Number of Rows and Sections
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    //Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return nil }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return nil }
    
    //Inserting or Deleting Table Rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    //Reordering Table Rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return false }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    //Configuring an Index
    func sectionIndexTitles(for tableView: UITableView) -> [String]? { return nil }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int { return index }
    
    var asTableViewDataSource: UITableViewDataSource {
        return Associator.getValue(key: &tableViewDataSourceKey, from: self, initialValue: UITableViewDataSourceWrapper(self))
    }
}
