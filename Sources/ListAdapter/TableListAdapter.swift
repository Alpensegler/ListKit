//
//  TableListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

public protocol TableListAdapter: ScrollListAdapter {
    var tableList: TableList<SourceBase> { get }
}

@propertyWrapper
@dynamicMemberLookup
public struct TableList<Source: DataSource>: TableListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    var contextSetups: [(ListContext<Source>) -> Void]
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var tableList: TableList<Source> { self }
    public var listCoordinator: ListCoordinator<Source> { sourceListCoordinator }
    public func makeListCoordinator() -> ListCoordinator<Source> {
        addToStorage(source.listCoordinator)
    }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
}

public extension TableListAdapter {
    @discardableResult
    func apply(by tableView: TableView) -> TableList<SourceBase> {
        let tableList = self.tableList
//        tableView.setupWith(coordinator: tableList.listCoordinator)
        return tableList
    }
}

#if os(iOS) || os(tvOS)

extension TableList: ListAdapter {
    static var rootKeyPath: ReferenceWritableKeyPath<Delegates, UITableViewDelegates> {
        \.tableViewDelegates
    }
    
    static func toContext(
        _ view: TableView,
        _ listContext: ListContext<Source>
    ) -> TableContext<Source> {
        .init(listView: view, coordinator: listContext.coordinator)
    }
    
    static func toSectionContext(
        _ view: TableView,
        _ listContext: ListContext<Source>,
        section: Int
    ) -> TableSectionContext<Source> {
        .init(
            listView: view,
            coordinator: listContext.coordinator,
            section: section - listContext.sectionOffset,
            sectionOffset: listContext.sectionOffset
        )
    }
    
    static func toItemContext(
        _ view: TableView,
        _ listContext: ListContext<Source>,
        path: PathConvertible
    ) -> TableItemContext<Source> {
        .init(
            listView: view,
            coordinator: listContext.coordinator,
            section: path.section - listContext.sectionOffset,
            sectionOffset: listContext.sectionOffset,
            item: path.item - listContext.itemOffset,
            itemOffset: listContext.itemOffset
        )
    }
}

#endif
