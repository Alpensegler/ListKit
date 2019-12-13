//
//  Coordinator+UITableViewDataSource.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

class UITableViewDataSources {
    typealias Delegate<Input, Output> = ListKit.Delegate<UITableView, Input, Output>

    //Providing Cells, Headers, and Footers
    var cellForRowAt = Delegate<IndexPath, UITableViewCell>(
        index: .indexPath(\.self),
        #selector(UITableViewDataSource.tableView(_:cellForRowAt:))
    )
    
    var titleForHeaderInSection = Delegate<Int, String?>(
        index: .index(\.self),
        #selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:))
    )
    
    var titleForFooterInSection = Delegate<Int, String?>(
        index: .index(\.self),
        #selector(UITableViewDataSource.tableView(_:titleForFooterInSection:))
    )
    
    //Inserting or Deleting Table Rows
    var commitForRowAt = Delegate<(UITableViewCell.EditingStyle, IndexPath), Void>(
        index: .indexPath(\.1),
        #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))
    )
    
    var canEditRowAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UITableViewDataSource.tableView(_:canEditRowAt:))
    )
    
    //Reordering Table Rows
    var canMoveRowAt = Delegate<IndexPath, Bool>(
        index: .indexPath(\.self),
        #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))
    )
    
    var moveRowAtTo = Delegate<(IndexPath, IndexPath), Void>(
        #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))
    )

    //Configuring an Index
    var sectionIndexTitles = Delegate<Void, [String]?>(
        #selector(UITableViewDataSource.sectionIndexTitles(for:))
    )
    
    var sectionForSectionIndexTitleAt = Delegate<(String, Int), Int>(
        #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:))
    )
    
    func add(by selectorSets: inout SelectorSets) {
        //Providing Cells, Headers, and Footers
        selectorSets.add(cellForRowAt)
        selectorSets.add(titleForHeaderInSection)
        selectorSets.add(titleForFooterInSection)
        
        //Inserting or Deleting Table Rows
        selectorSets.add(commitForRowAt)
        selectorSets.add(canEditRowAt)
        
        //Reordering Table Rows
        selectorSets.add(canMoveRowAt)
        selectorSets.add(moveRowAtTo)
        
        //Configuring an Index
        selectorSets.add(sectionIndexTitles)
        selectorSets.add(sectionForSectionIndexTitleAt)
    }
}

extension BaseCoordinator: UITableViewDataSource { }

public extension BaseCoordinator {
    //Providing the Number of Rows and Sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numbersOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        numbersOfSections()
    }
    
    //Providing Cells, Headers, and Footers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        apply(\.tableViewDataSources.cellForRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        apply(\.tableViewDataSources.titleForHeaderInSection, object: tableView, with: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        apply(\.tableViewDataSources.titleForFooterInSection, object: tableView, with: section)
    }

    //Inserting or Deleting Table Rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        apply(\.tableViewDataSources.commitForRowAt, object: tableView, with: (editingStyle, indexPath))
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDataSources.canEditRowAt, object: tableView, with: indexPath)
    }
    
    //Reordering Table Rows
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        apply(\.tableViewDataSources.canMoveRowAt, object: tableView, with: indexPath)
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        apply(\.tableViewDataSources.moveRowAtTo, object: tableView, with: (sourceIndexPath, destinationIndexPath))
    }

    //Configuring an Index
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        apply(\.tableViewDataSources.sectionIndexTitles, object: (tableView))
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        apply(\.tableViewDataSources.sectionForSectionIndexTitleAt, object: tableView, with: (title, index))
    }
}

#endif
