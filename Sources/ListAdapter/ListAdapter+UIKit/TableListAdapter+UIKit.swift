//
//  TableListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    func provideTableViewCell(
        _ closure: @escaping (TableIndexPathContext<SourceBase>, Item) -> UITableViewCell = { (context, item) in
            context.dequeueReusableCell(UITableViewCell.self) {
                $0.textLabel?.text = "\(item)"
            }
        }
    ) -> TableList<SourceBase> {
        toTableList().set(\.tableViewDataSources.cellForRowAt) {
            closure($0.0, $0.0.itemValue)
        }
    }
    
    func provideTableViewCell<Cell: UITableViewCell>(
        _ cellClass: Cell.Type,
        identifier: String = "",
        _ closure: @escaping (Cell, TableIndexPathContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        provideTableViewCell { (context, item) in
            context.dequeueReusableCell(cellClass, identifier: identifier) {
                closure($0, context, item)
            }
        }
    }
}

public extension TableListAdapter {
    @discardableResult
    func onTableViewDidSelectItem(
        _ closure: @escaping (TableIndexPathContext<SourceBase>, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.tableViewDelegates.didSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    
    @discardableResult
    func onTableViewWillDisplayRow(
        _ closure: @escaping (TableIndexPathContext<SourceBase>, UITableViewCell, Item) -> Void
    ) -> TableList<SourceBase> {
        tableList.set(\.tableViewDelegates.willDisplayForRowAt) { closure($0.0, $0.1.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func apply(by tableView: UITableView) -> TableList<SourceBase> { tableList }
}


#endif
