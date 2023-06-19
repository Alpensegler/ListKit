//
//  ModelsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

// swiftlint:disable opening_brace

import Foundation

@propertyWrapper
public struct CollectionElements<C: Collection>: TypedListAdapter, ListCoordinator {
    public typealias Element = C.Element
    var value: ContiguousArray<Element>
    var identifier: ((Element) -> AnyHashable)?
    var areEquivalent: ((Element, Element) -> Bool)?
    public var wrappedValue: C {
        didSet {
            value = wrappedValue.mapContiguous { $0 }
        }
    }
    public var projectedValue: Self { self }
}

extension CollectionElements {
    init(
        _ wrappedValue: C,
        identifier: ((Element) -> AnyHashable)? = nil,
        areEquivalent: ((Element, Element) -> Bool)? = nil
    ) {
        self.wrappedValue = wrappedValue
        self.value = wrappedValue.mapContiguous { $0 }
        self.areEquivalent = areEquivalent
    }
}

public extension CollectionElements {
    var count: Count { .items(value.count) }

    init(wrappedValue: C) {
        self.init(wrappedValue)
    }

    init(_ collection: C) {
        self.init(collection, identifier: nil, areEquivalent: nil)
    }

    func diff<ID: Hashable>(id: @escaping (Element) -> ID, by areEquivalent: @escaping (Element, Element) -> Bool) -> CollectionElements<C> {
        .init(value: value, identifier: { id($0) }, areEquivalent: areEquivalent, wrappedValue: wrappedValue)
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> CollectionElements<C> {
        .init(value: value, areEquivalent: areEquivalent, wrappedValue: wrappedValue)
    }

    func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        value[context.item]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}

public extension CollectionElements where Element: Equatable {
    init(wrappedValue: C) {
        self.init(wrappedValue, areEquivalent: ==)
    }

    init(_ collection: C) {
        self.init(collection, areEquivalent: ==)
    }
}

public extension CollectionElements where Element: Hashable {
    init(wrappedValue: C) {
        self.init(wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ collection: C) {
        self.init(collection, identifier: { $0 }, areEquivalent: ==)
    }
}
