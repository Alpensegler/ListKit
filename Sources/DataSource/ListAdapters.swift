//
//  ListAdapters.swift
//  ListKit
//
//  Created by Frain on 2019/11/28.
//

// swiftlint:disable comment_spacing function_body_length opening_brace

import Foundation

@propertyWrapper
public struct ListAdapters<C: RangeReplaceableCollection>: TypedListAdapter, DataSourcesCoordinator where C.Element: ListAdapter {
    public typealias Element = C.Element
    public typealias View = Element.View
    var value: ContiguousArray<Element>
    let identifier: ((Element) -> AnyHashable)?
    let areEquivalent: ((Element, Element) -> Bool)?
    public var contexts: ContiguousArray<ListCoordinatorContext>
    public var contextsOffsets = ContiguousArray<Offset>()
    public var indices = ContiguousArray<(indices: [Int], index: Int?)>()
    public var subselectors = Set<Selector>()
    public var needSetupWithListView = false
    public var count = Count.items(0)
    public var wrappedValue: C {
        didSet {
            self.value = .init(wrappedValue)
            self.contexts = wrappedValue.mapContiguous { $0.listCoordinatorContext }
            configCount()
        }
    }
}

extension ListAdapters {
    init(
        _ wrappedValue: C,
        identifier: ((Element) -> AnyHashable)? = nil,
        areEquivalent: ((Element, Element) -> Bool)? = nil
    ) {
        self.value = .init(wrappedValue)
        self.contexts = wrappedValue.mapContiguous { $0.listCoordinatorContext }
        self.identifier = identifier
        self.areEquivalent = areEquivalent
        self.wrappedValue = wrappedValue
        configCount()
    }
}

public extension ListAdapters {
    init(wrappedValue: C) {
        self.init(wrappedValue)
    }

    init(_ dataSources: C) {
        self.init(dataSources, identifier: nil, areEquivalent: nil)
    }

    func diff<ID: Hashable>(id: @escaping (Element) -> ID, by areEquivalent: @escaping (Element, Element) -> Bool) -> ListAdapters<C> {
        .init(
            value: value,
            identifier: id,
            areEquivalent: areEquivalent,
            contexts: contexts,
            contextsOffsets: contextsOffsets,
            indices: indices,
            subselectors: subselectors,
            needSetupWithListView: needSetupWithListView,
            count: count,
            wrappedValue: wrappedValue
        )
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> ListAdapters<C> {
        .init(
            value: value,
            identifier: nil,
            areEquivalent: areEquivalent,
            contexts: contexts,
            contextsOffsets: contextsOffsets,
            indices: indices,
            subselectors: subselectors,
            needSetupWithListView: needSetupWithListView,
            count: count,
            wrappedValue: wrappedValue
        )
    }

    func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        value[indices[context.section].indices[context.item]]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}

public extension ListAdapters where Element: Equatable {
    init(wrappedValue: C) {
        self.init(wrappedValue, areEquivalent: ==)
    }

    init(_ listAdapters: C) {
        self.init(listAdapters, areEquivalent: ==)
    }
}

public extension ListAdapters where Element: Hashable {
    init(wrappedValue: C) {
        self.init(wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ listAdapters: C) {
        self.init(listAdapters, identifier: { $0 }, areEquivalent: ==)
    }
}

extension ListAdapters: TableList where Element: TableList { }
extension ListAdapters: CollectionList where Element: CollectionList { }
