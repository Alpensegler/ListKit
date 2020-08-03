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
    
    let storage: ListAdapterStorage<Source>
    let erasedGetter: (Self) -> ScrollList<AnySources>
    
    public var sourceBase: Source { source }
    public var source: Source {
        get { storage.source }
        nonmutating set { storage.source = newValue }
    }
    
    public var listUpdate: ListUpdate<SourceBase>.Whole { source.listUpdate }
    public var listOptions: ListOptions<Source> { source.listOptions }
    
    public var listCoordinator: ListCoordinator<Source> { storage.listCoordinator }
    public let listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void]
    
    public var coordinatorStorage: CoordinatorStorage<Source> { storage.coordinatorStorage }
    
    public var scrollList: ScrollList<SourceBase> { self }
    
    public var wrappedValue: Source {
        get { source }
        nonmutating set { source = newValue }
    }
    
    public var projectedValue: ScrollList<Source> {
        get { self }
        set { self = newValue }
    }
    
    public subscript<Value>(dynamicMember path: KeyPath<Source, Value>) -> Value {
        source[keyPath: path]
    }
    
    public subscript<Value>(dynamicMember path: WritableKeyPath<Source, Value>) -> Value {
        get { source[keyPath: path] }
        set { source[keyPath: path] = newValue }
    }
    
    init(
        listContextSetups: [(ListCoordinatorContext<SourceBase>) -> Void] = [],
        source: Source,
        erasedGetter: @escaping (Self) -> ScrollList<AnySources> = Self.defaultErasedGetter
    ) {
        self.listContextSetups = listContextSetups
        self.erasedGetter = erasedGetter
        self.storage = .init(source: source)
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
    typealias View = UIScrollView
    
    static var rootKeyPath: ReferenceWritableKeyPath<CoordinatorContext, UIScrollListDelegate> {
        \.scrollListDelegate
    }
}

#endif
