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
    
    var contextSetups = [(ListContext<Source>) -> Void]()
    
    public let source: Source
    public let coordinatorStorage = CoordinatorStorage<Source>()
    
    public var updater: Updater<Source> { source.updater }
    public var sourceBase: Source { source }
    public var listCoordinator: ListCoordinator<Source> { sourceListCoordinator }
    public func makeListCoordinator() -> ListCoordinator<Source> {
        addToStorage(sourceBase.listCoordinator)
    }
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
}

#if os(iOS) || os(tvOS)
import UIKit

extension ScrollList: ListAdapter {
    static var rootKeyPath: ReferenceWritableKeyPath<Delegates, UIScrollViewDelegates> {
        \.scrollViewDelegates
    }
    
    static func toContext(
        _ view: UIScrollView, _ listContext: ListContext<Source>
    ) -> ScrollContext<Source> {
        .init(listView: view, coordinator: listContext.coordinator)
    }
    
    static func toSectionContext(
        _ view: UIScrollView,
        _ listContext: ListContext<Source>, section: Int
    ) -> Never {
        fatalError()
    }
    
    static func toItemContext(
        _ view: UIScrollView,
        _ listContext: ListContext<Source>,
        path: PathConvertible
    ) -> Never {
        fatalError()
    }
}

#endif
