//
//  Sources+UITableView.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public typealias TableSources<SubSource, Item> = Sources<SubSource, Item, UITableView>
public typealias AnyTableSources = TableSources<Any, Any>

public extension Sources where UIViewType == UITableView {
    private init<Value: TableDataSource>(_source: @escaping () -> Value) where Value.SubSource == SubSource, Value.Item == Item {
        self = _source().eraseToSources().castViewType()
        
        tableViewWillUpdate = { (_source() as? ListUpdatable)?.tableView($0, willUpdateWith: $1) }
        tableCellForItem = { _source().tableContext($0, cellForItem: $1) }
        tableTitleForHeader = { _source().tableContext($0, titleForHeaderInSection: $1) }
        tableTitleForFooter = { _source().tableContext($0, titleForFooterInSection: $1) }
    }
    
    init<Value: TableDataSource>(_ source: @escaping @autoclosure () -> Value) where Value.SubSource == SubSource, Value.Item == Item {
        self.init(_source: source)
    }
    
    init<Value: TableAdapter>(_ source: @escaping @autoclosure () -> Value) where Value.SubSource == SubSource, Value.Item == Item {
        self.init(_source: source)
        
        tableHeader = { source().tableContext($0, viewForHeaderInSection: $1) }
        tableFooter = { source().tableContext($0, viewForFooterInSection: $1) }
        
        tableWillDisplayHeaderView = { source().tableContext($0, willDisplayHeaderView: $1, forSection: $2) }
        tableWillDisplayFooterView = { source().tableContext($0, willDisplayFooterView: $1, forSection: $2) }
        
        tableDidSelectItem = { source().tableContext($0, didSelectItem: $1) }
        tableDidDeselectItem = { source().tableContext($0, didDeselectItem: $1) }
        tableWillDisplayItem = { source().tableContext($0, willDisplay: $1, forItem: $2) }
        
        tableViewDidHighlightItem = { source().tableContext($0, didHighlightItem: $1) }
        tableViewDidUnhighlightItem = { source().tableContext($0, didUnhighlightItem: $1) }
        
        tableHeightForItem = { source().tableContext($0, heightForItem: $1) }
        tableHeightForHeader = { source().tableContext($0, heightForHeaderInSection: $1) }
        tableHeightForFooter = { source().tableContext($0, heightForFooterInSection: $1) }
    }
}

public extension TableDataSource {
    func eraseToTableSources() -> Sources<SubSource, Item, UITableView> {
        return .init(self)
    }
}

public extension TableAdapter {
    func eraseToTableSources() -> Sources<SubSource, Item, UITableView> {
        return .init(self)
    }
}

public extension Source {
    func provideTableCell(_ provider: @escaping (TableContext<SubSource, Item>, Item) -> UITableViewCell) -> TableSources<SubSource, Item> {
        var sources = eraseToSources()
        sources.tableCellForItem = provider
        return sources.castViewType()
    }
    
    func provideCell<CustomCell: UITableViewCell>(
        _ cellClass: CustomCell.Type,
        identifier: String = "",
        configuration: @escaping (CustomCell, Item) -> Void
    ) -> TableSources<SubSource, Item> {
        return provideTableCell { context, item in
            context.dequeueReusableCell(withCellClass: cellClass, identifier: identifier) {
                configuration($0, item)
            }
        }
    }
}

public extension TableDataSource {
    func observeOnTableViewUpdate(_ provider: @escaping (UITableView, ListChange) -> Void) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableViewWillUpdate = provider
        return sources
    }
    
    func provideHeader(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> UIView?) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableHeader = provider
        return sources
    }
    
    func provideFooter(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> UIView?) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableFooter = provider
        return sources
    }
    
    func onSelectItem(_ selection: @escaping (TableContext<SubSource, Item>, Item) -> Void) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableDidSelectItem = selection
        return sources
    }
    
    func onWillDisplayItem(_ display: @escaping (TableContext<SubSource, Item>, UITableViewCell, Item) -> Void) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableWillDisplayItem = display
        return sources
    }
    
    func provideHeightOfItem(_ provider: @escaping (TableContext<SubSource, Item>, Item) -> CGFloat) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableHeightForItem = provider
        return sources
    }
    
    func provideHeightForHeader(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> CGFloat) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableHeightForHeader = provider
        return sources
    }
    
    func provideHeightForFooter(_ provider: @escaping (TableContext<SubSource, Item>, Int) -> CGFloat) -> TableSources<SubSource, Item> {
        var sources = eraseToTableSources()
        sources.tableHeightForFooter = provider
        return sources
    }
}

extension Sources: TableDataSource where UIViewType == UITableView {
    public func eraseToTableSources() -> Sources<SubSource, Item, UITableView> {
        return self
    }
    
    public func tableContext(_ context: TableListContext, cellForItem item: Item) -> UITableViewCell {
        return tableCellForItem(context, item)
    }
    
    public func tableContext(_ context: TableListContext, titleForHeaderInSection section: Int) -> String? {
        return tableTitleForHeader?(context, section)
    }
    
    public func tableContext(_ context: TableListContext, titleForFooterInSection section: Int) -> String? {
        return tableTitleForFooter?(context, section)
    }
}

extension Sources: TableListDataSource where UIViewType == UITableView { }

extension Sources: TableAdapter where UIViewType == UITableView {
    public func tableContext(_ context: TableListContext, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeader?(context, section)
    }
    
    public func tableContext(_ context: TableListContext, viewForFooterInSection section: Int) -> UIView? {
        return tableFooter?(context, section)
    }
    
    public func tableContext(_ context: TableListContext, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableWillDisplayHeaderView?(context, view, section)
    }
    
    public func tableContext(_ context: TableListContext, willDisplayFooterView view: UIView, forSection section: Int) {
        tableWillDisplayFooterView?(context, view, section)
    }
    
    public func tableContext(_ context: TableListContext, didSelectItem item: Item) {
        tableDidSelectItem?(context, item)
    }
    
    public func tableContext(_ context: TableListContext, didDeselectItem item: Item) {
        tableDidDeselectItem?(context, item)
    }
    
    public func tableContext(_ context: TableListContext, willDisplay cell: UITableViewCell, forItem item: Item) {
        tableWillDisplayItem?(context, cell, item)
    }
    
    public func tableContext(_ context: TableListContext, didHighlightItem item: Item) {
        tableViewDidHighlightItem?(context, item)
    }
    
    public func tableContext(_ context: TableListContext, didUnhighlightItem item: Item) {
        tableViewDidUnhighlightItem?(context, item)
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

extension Sources: TableListAdapter where UIViewType == UITableView { }


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
