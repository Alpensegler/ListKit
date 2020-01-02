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
    var delegatesSetups: [(ListCoordinator<Source>) -> Void]
    var cacheFromItem: ((Item) -> Any)? = nil
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var tableList: TableList<Source> { self }
    public func makeListCoordinator() -> ListCoordinator<Source> { makeAdapterCoordinator() }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(delegatesSetups: [(ListCoordinator<Source>) -> Void], source: Source) {
        self.delegatesSetups = delegatesSetups
        self.source = source
    }
}

public extension TableListAdapter {
    @discardableResult
    func apply(by tableView: TableView) -> TableList<SourceBase> {
        let tableList = self.tableList
        makeListCoordinator().setup(
            listView: tableView,
            objectIdentifier: ObjectIdentifier(tableView)
        )
        tableView.reloadSynchronously()
        return tableList
    }
}

#if os(iOS) || os(tvOS)

extension TableList: ListAdapter {
    static var rootKeyPath: ReferenceWritableKeyPath<BaseCoordinator, UITableListDelegate> {
        \.tableViewDelegates
    }
    
    static func toContext(
        _ view: TableView,
        _ coordinator: ListCoordinator<Source>
    ) -> TableContext<Source> {
        .init(listView: view, coordinator: coordinator)
    }
    
    static func toSectionContext(
        _ view: TableView,
        _ coordinator: ListCoordinator<Source>,
        section: Int
    ) -> TableSectionContext<Source> {
        let (sectionOffset, _) = coordinator.offset(for: view)
        return .init(
            listView: view,
            coordinator: coordinator,
            section: section - sectionOffset,
            sectionOffset: sectionOffset
        )
    }
    
    static func toItemContext(
        _ view: TableView,
        _ coordinator: ListCoordinator<Source>,
        path: PathConvertible
    ) -> TableItemContext<Source> {
        let (sectionOffset, itemOffset) = coordinator.offset(for: view)
        return .init(
            listView: view,
            coordinator: coordinator,
            section: path.section - sectionOffset,
            sectionOffset: sectionOffset,
            item: path.item - itemOffset,
            itemOffset: itemOffset
        )
    }
}

#endif
