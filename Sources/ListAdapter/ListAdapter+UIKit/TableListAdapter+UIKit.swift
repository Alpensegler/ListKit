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
        TableList(source: sourceBase).set(\.tableViewDataSources.cellForRowAt) {
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

public extension TableListAdapter where Self: UpdatableDataSource {
    @discardableResult
    func onTableViewDidSelectItem(
        _ closure: @escaping (TableIndexPathContext<SourceBase>, Item) -> Void
    ) -> Self {
        set(\.tableViewDelegates.didSelectRowAt) { closure($0.0, $0.0.itemValue) }
    }
    
    @discardableResult
    func apply(by tableView: UITableView) -> Self { self }
}


#endif
