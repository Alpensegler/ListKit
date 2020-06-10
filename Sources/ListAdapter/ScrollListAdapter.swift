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
    let storage = ListAdapterStorage<Source>()
    let erasedGetter: (Self) -> ScrollList<AnySources>
    
    public let source: Source
    public var sourceBase: Source { source }
    
    public var listUpdate: ListUpdate<Item> { source.listUpdate }
    public var listOptions: ListOptions<Source> { source.listOptions }
    
    public var listCoordinator: ListCoordinator<Source> { storage.listCoordinator }
    public let listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void]
    
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    
    public var scrollList: ScrollList<SourceBase> { self }
    
    public var wrappedValue: Source { source }
    public var projectedValue: Source.Source { source.source }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    init(
        listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] = [],
        source: Source,
        erasedGetter: @escaping (Self) -> ScrollList<AnySources> = Self.defaultErasedGetter
    ) {
        self.listContextSetups = listContextSetups
        self.source = source
        self.erasedGetter = erasedGetter
        storage.makeListCoordinator = { source.listCoordinator }
    }
}

extension ScrollList: ListAdapter {
    static var defaultErasedGetter: (Self) -> ScrollList<AnySources> {
        { .init(AnySources($0)) { $0 } }
    }
}

#if os(iOS) || os(tvOS)
import UIKit

extension ScrollList {
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, UIScrollListDelegate> {
        \.scrollListDelegate
    }
    
    static func toContext(
        _ view: UIScrollView, _ coordinator: ListCoordinator<Source>
    ) -> ScrollContext<Source> {
        .init(listView: view, coordinator: coordinator)
    }
    
    static func toSectionContext(
        _ view: UIScrollView,
        _ coordinator: ListCoordinator<Source>,
        _ section: Int,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Never {
        fatalError()
    }
    
    static func toItemContext(
        _ view: UIScrollView,
        _ coordinator: ListCoordinator<Source>,
        _ path: IndexPath,
        _ sectionOffset: Int,
        _ itemOffset: Int
    ) -> Never {
        fatalError()
    }
}

#endif
