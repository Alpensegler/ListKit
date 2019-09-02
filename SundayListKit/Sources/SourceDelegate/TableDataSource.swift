//
//  TableDataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/29.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol TableDataSource: Source {
    typealias TableListContext = TableContext<SubSource, Item>
    
    //Providing Cells, Headers, and Footers
    func tableContext(_ context:  TableListContext, cellForItem item: Item) -> UITableViewCell
    func tableContext(_ context:  TableListContext, titleForHeaderInSection section: Int) -> String?
    func tableContext(_ context:  TableListContext, titleForFooterInSection section: Int) -> String?
    
    //Inserting or Deleting Table Rows
    func tableContext(_ context:  TableListContext, commit editingStyle: UITableViewCell.EditingStyle, forItem item: Item)
    func tableContext(_ context:  TableListContext, canEditItem item: Item) -> Bool
    
    //Reordering Table Rows
    func tableContext(_ context:  TableListContext, canMoveItem item: Item) -> Bool
    func tableContext(_ context:  TableListContext, moveItem item: Item, to destinationIndexPath: IndexPath)
    
    //Configuring an Index
    func sectionIndexTitles(for context: TableListContext) -> [String]?
    func tableContext(_ context:  TableListContext, sectionForSectionIndexTitle title: String, at index: Int) -> Int
}


public extension TableDataSource {
    //Providing Cells, Headers, and Footers
    func tableContext(_ context:  TableListContext, titleForHeaderInSection section: Int) -> String? { return nil }
    func tableContext(_ context:  TableListContext, titleForFooterInSection section: Int) -> String? { return nil }
    
    //Inserting or Deleting Table Rows
    func tableContext(_ context:  TableListContext, commit editingStyle: UITableViewCell.EditingStyle, forItem item: Item) { }
    func tableContext(_ context:  TableListContext, canEditItem item: Item) -> Bool { return true }
    
    //Reordering Table Rows
    func tableContext(_ context:  TableListContext, canMoveItem item: Item) -> Bool { return true }
    func tableContext(_ context:  TableListContext, moveItem item: Item, to destinationIndexPath: IndexPath) { }
    
    //Configuring an Index
    func sectionIndexTitles(for context: TableListContext) -> [String]? { return nil }
    func tableContext(_ context:  TableListContext, sectionForSectionIndexTitle title: String, at index: Int) -> Int { return index }
}

public extension TableDataSource where SubSource: Collection, SubSource.Element: TableDataSource, Item == SubSource.Element.Item {
    //Providing Cells, Headers, and Footers
    func tableContext(_ context:  TableListContext, cellForItem item: Item) -> UITableViewCell {
        return context.elementCellForItem()
    }
    
    func tableContext(_ context:  TableListContext, titleForHeaderInSection section: Int) -> String? {
        return context.elementTitleForHeaderInSection()
    }
    
    func tableContext(_ context:  TableListContext, titleForFooterInSection section: Int) -> String? {
        return context.elementTitleForFooterInSection()
    }
}

public extension TableContext where SubSource: Collection, SubSource.Element: TableDataSource, Item == SubSource.Element.Item  {
    func elementCellForItem() -> UITableViewCell {
        return element.tableContext(elementsContext(), cellForItem: elementsItem)
    }
    
    func elementTitleForHeaderInSection() -> String? {
        let context = elementsContext()
        return element.tableContext(context, titleForHeaderInSection: context.section)
    }
    
    func elementTitleForFooterInSection() -> String? {
        let context = elementsContext()
        return element.tableContext(context, titleForFooterInSection: context.section)
    }
}
