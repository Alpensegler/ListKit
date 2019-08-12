//
//  Sources+UITableView.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias TableSources<SubSource, Item, Snapshot: SnapshotType> = Sources<SubSource, Item, Snapshot, UITableView>

public extension Sources where UIViewType == UITableView {
    func provideHeader(_ provider: @escaping (TableContext<SourceSnapshot>, Int) -> UIView?) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.tableHeader = provider
        return sources
    }
    
    func provideFooter(_ provider: @escaping (TableContext<SourceSnapshot>, Int) -> UIView?) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.tableFooter = provider
        return sources
    }
    
    func onSelectItem(_ selection: @escaping (TableContext<SourceSnapshot>, Item) -> Void) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.tableDidSelectItem = selection
        return sources
    }
    
    func onWillDisplayItem(_ display: @escaping (TableContext<SourceSnapshot>, UITableViewCell, Item) -> Void) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.tableWillDisplayItem = display
        return sources
    }
    
    func provideHeightOfItem(_ provider: @escaping (TableContext<SourceSnapshot>, Item) -> CGFloat) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.tableHeightForItem = provider
        return sources
    }
    
    func provideHeightForHeader(_ provider: @escaping (TableContext<SourceSnapshot>, Int) -> CGFloat) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
        var sources = self
        sources.tableHeightForHeader = provider
        return sources
    }
    
    func provideHeightForFooter(_ provider: @escaping (TableContext<SourceSnapshot>, Int) -> CGFloat) -> Sources<SubSource, Item, SourceSnapshot, UIViewType> {
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
        return tableCoordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let tableView = UITableView()
        context.coordinator.setListView(tableView)
        return tableView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        performReload()
    }
}

#endif
