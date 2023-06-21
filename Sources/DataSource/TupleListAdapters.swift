//
//  TupleListAdapters.swift
//  ListKit
//
//  Created by Frain on 2023/3/7.
//

import Foundation

protocol TupleListAdaptersProtocol: TypedListAdapter {
    associatedtype FirstAdapter: TypedListAdapter
    associatedtype SecondAdapter: TypedListAdapter

    static func element<View>(
        at context: ListIndexContext<View, IndexPath>,
        for coordinatorContext: ListCoordinatorContext,
        at contextIndex: Int,
        lastIndex: Int
    ) -> Element
}

public struct TupleListAdapters<FirstAdapter: ListAdapter, SecondAdapter: ListAdapter>: ListAdapter, DataSourcesCoordinator where FirstAdapter.View == SecondAdapter.View {
    public typealias View = FirstAdapter.View
    public var contexts: ContiguousArray<ListCoordinatorContext>
    public var contextsOffsets = ContiguousArray<Offset>()
    public var indices = ContiguousArray<(indices: [Int], index: Int?)>()
    public var subselectors = Set<Selector>()
    public var count = Count.items(0)
    public var needSetupWithListView = false

    init(_ value: ContiguousArray<ListCoordinatorContext>) {
        self.contexts = value
        configCount()
    }
}

extension TupleListAdapters: TypedListAdapter where FirstAdapter: TypedListAdapter, SecondAdapter: TypedListAdapter {
    public typealias Element = ConditionalValue<FirstAdapter.Element, SecondAdapter.Element>
    public func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        let (coordinatorContext, contextIndex, index) = contextAndIndex(at: context.index)!
        let context = ListIndexContext(listView: context.listView, index: index, rawIndex: context.rawIndex, context: coordinatorContext)
        return Self.element(at: context, for: coordinatorContext, at: contextIndex, lastIndex: contexts.count - 1)
    }
}

extension TupleListAdapters: TupleListAdaptersProtocol where FirstAdapter: TypedListAdapter, SecondAdapter: TypedListAdapter {
    static func element<View>(
        at context: ListIndexContext<View, IndexPath>,
        for coordinatorContext: ListCoordinatorContext,
        at contextIndex: Int,
        lastIndex: Int
    ) -> Element {
        if contextIndex == lastIndex {
            return .second((coordinatorContext.coordinator as! SecondAdapter.List).element(at: context))
        } else if let firstType = FirstAdapter.self as? any TupleListAdaptersProtocol.Type {
            return .first(firstType.element(at: context, for: coordinatorContext, at: contextIndex, lastIndex: lastIndex - 1) as! FirstAdapter.Element)
        } else {
            return .first((coordinatorContext.coordinator as! FirstAdapter.List).element(at: context))
        }
    }
}

public extension TupleListAdapters {
    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}
