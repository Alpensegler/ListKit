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
    var identifier: ((Element) -> AnyHashable)?
    var areEquivalent: ((Element, Element) -> Bool)?
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

    init(value: C,
         identifier: ((Element) -> AnyHashable)? = nil,
         areEquivalent: ((Element, Element) -> Bool)? = nil
    ) {
        self.value = .init(value)
        self.contexts = value.mapContiguous { $0.listCoordinatorContext }
        self.identifier = identifier
        self.areEquivalent = areEquivalent
        self.wrappedValue = value
        configCount()
    }
}

public extension ListAdapters {
    init(_ dataSources: C) {
        self.init(value: dataSources)
    }

    init(wrappedValue: C) {
        self.init(value: wrappedValue)
    }

    func diff<ID: Hashable>(id: @escaping (Element) -> ID, by areEquivalent: @escaping (Element, Element) -> Bool) -> ListAdapters<C> {
        .init(value: wrappedValue, identifier: { id($0) }, areEquivalent: areEquivalent)
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> ListAdapters<C> {
        .init(value: wrappedValue, areEquivalent: areEquivalent)
    }

    func model(at indexPath: IndexPath) -> Any {
        value[indices[indexPath.section].indices[indexPath.item]]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}

extension ListAdapters: DataSource where Element: DataSource { }
extension ListAdapters: TableList where Element: TableList { }
extension ListAdapters: CollectionList where Element: CollectionList { }
