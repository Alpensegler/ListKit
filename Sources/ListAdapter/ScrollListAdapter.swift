//
//  ScrollListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol ScrollListAdapter: DataSource {
    var scrollList: ScrollList<SourceBase> { get }
}

public extension ScrollListAdapter {
    var scrollList: ScrollList<SourceBase> { ScrollList(source: sourceBase) }
}

@propertyWrapper
@dynamicMemberLookup
public struct ScrollList<Source: DataSource>: ScrollListAdapter, UpdatableDataSource
where Source.SourceBase == Source {
    public typealias Item = Source.Item
    public typealias SourceBase = Source
    let coordinatorSetups: [(ListCoordinator<Source>) -> Void]
    let storage = ListAdapterStorage<Source>()
    
    public let source: Source
    public var sourceBase: Source { source }
    public var differ: Differ<Source> { source.differ }
    public var listUpdate: Update<Item> { source.listUpdate }
    public var scrollList: ScrollList<SourceBase> { self }
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    public func makeListCoordinator() -> ListCoordinator<Source> { storage.listCoordinator }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(coordinatorSetups: [(ListCoordinator<Source>) -> Void] = [], source: Source) {
        self.coordinatorSetups = coordinatorSetups
        self.source = source
        storage.makeListCoordinator = makeCoordinator
    }
}

#if os(iOS) || os(tvOS)
import UIKit

extension ScrollList: ListAdapter {
    static var rootKeyPath: ReferenceWritableKeyPath<Coordinator, UIScrollListDelegate> {
        \.scrollListDelegate
    }
    
    static func toContext(
        _ view: UIScrollView, _ coordinator: ListCoordinator<Source>
    ) -> ScrollContext<Source> {
        .init(listView: view, coordinator: coordinator)
    }
    
    static func toSectionContext(
        _ view: UIScrollView,
        _ coordinator: ListCoordinator<Source>, section: Int
    ) -> Never {
        fatalError()
    }
    
    static func toItemContext(
        _ view: UIScrollView,
        _ coordinator: ListCoordinator<Source>,
        path: PathConvertible
    ) -> Never {
        fatalError()
    }
}

#endif
