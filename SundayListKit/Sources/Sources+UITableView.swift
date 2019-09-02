//
//  Sources+UITableView.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias TableSources<SubSource, Item> = Sources<SubSource, Item, UITableView>

public extension Sources where UIViewType == UITableView {
    func observeOnTableViewUpdate(_ provider: @escaping (UITableView, ListChange) -> Void) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableViewWillUpdate = provider
        return sources
    }
    
    func provideHeader(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> UIView?) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableHeader = provider
        return sources
    }
    
    func provideFooter(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> UIView?) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableFooter = provider
        return sources
    }
    
    func onSelectItem(_ selection: @escaping (TableContext<SubSource, Item>, Item) -> Void) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableDidSelectItem = selection
        return sources
    }
    
    func onWillDisplayItem(_ display: @escaping (TableContext<SubSource, Item>, UITableViewCell, Item) -> Void) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableWillDisplayItem = display
        return sources
    }
    
    func provideHeightOfItem(_ provider: @escaping (TableContext<SubSource, Item>, Item) -> CGFloat) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableHeightForItem = provider
        return sources
    }
    
    func provideHeightForHeader(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> CGFloat) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableHeightForHeader = provider
        return sources
    }
    
    func provideHeightForFooter(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> CGFloat) -> Sources<SubSource, Item, UIViewType> {
        var sources = self
        sources.tableHeightForFooter = provider
        return sources
    }
}

extension TableSources: TableAdapter {
    public func tableContext(_ context: TableListContext, cellForItem item: Item) -> UITableViewCell {
        return tableCellForItem(context, item)
    }
    
    public func tableContext(_ context: TableListContext, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeader?(context, section)
    }
    
    public func tableContext(_ context: TableListContext, viewForFooterInSection section: Int) -> UIView? {
        return tableFooter?(context, section)
    }
    
    public func tableContext(_ context: TableListContext, didSelectItem item: Item) {
        tableDidSelectItem?(context, item)
    }
    
    public func tableContext(_ context: TableListContext, willDisplay cell: UITableViewCell, forItem item: Item) {
        tableWillDisplayItem?(context, cell, item)
    }
    
    public func tableContext(_ context: TableListContext, heightForItem item: Item) -> CGFloat {
        return tableHeightForItem?(context, item) ?? context.listView.rowHeight
    }
    
    public func tableContext(_ context: TableListContext, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeightForHeader?(context, section) ?? context.listView.sectionHeaderHeight
    }
    
    public func tableContext(_ context: TableListContext, heightForFooterInSection section: Int) -> CGFloat {
        return tableHeightForFooter?(context, section) ?? context.listView.sectionFooterHeight
    }
}


#if iOS13
import SwiftUI

public extension Sources where UIViewType == UITableView {
    func makeCoordinator() -> UIViewType.Coordinator {
        return makeTableCoordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let tableView = UITableView()
        context.coordinator.setListView(tableView)
        return tableView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        performReloadData()
    }
}

#endif
