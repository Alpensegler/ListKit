//
//  TableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

public protocol TableListAdapter: ScrollListAdapter {
    var tableList: TableList<AdapterBase> { get }
}

@propertyWrapper
public final class TableList<Source: DataSource>: ScrollList<Source>, TableListAdapter
where Source.AdapterBase == Source {
    public var tableList: TableList<Source> { self }
    public var projectedValue: TableList<Source> { self }
    public override var wrappedValue: Source {
        get { source }
        set { source = newValue }
    }
}

public extension TableListAdapter {
    @discardableResult
    func apply(
        by tableView: TableView,
        update: ListUpdate<SourceBase>.Whole?,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<AdapterBase> {
        let tableList = self.tableList
        tableView.listDelegate.setCoordinator(
            context: listCoordinatorContext,
            update: update,
            animated: animated,
            completion: completion
        )
        return tableList
    }

    @discardableResult
    func apply(
        by tableView: TableView,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) -> TableList<AdapterBase> {
        apply(by: tableView, update: listUpdate, animated: animated, completion: completion)
    }
}

extension TableList: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "TableList(\(source))" }
    public var debugDescription: String { "TableList(\(source))" }
}

public extension TableList where Source: ItemCachedDataSource {
    var base: TableList<Source.SourceBase.AdapterBase> {
        .init(source.sourceBase.adapterBase, listDelegate: listDelegate)
    }
}
