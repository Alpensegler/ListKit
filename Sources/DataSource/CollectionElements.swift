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

    init(value: C,
         identifier: ((Element) -> AnyHashable)? = nil,
         areEquivalent: ((Element, Element) -> Bool)? = nil
    ) {
        self.wrappedValue = value
        self.value = value.mapContiguous { $0 }
        self.areEquivalent = areEquivalent
    }
}

public extension CollectionElements {
    var count: Count { .items(value.count) }

    init(wrappedValue: C) {
        self.init(value: wrappedValue)
    }

    init(_ models: C) {
        self.init(wrappedValue: models)
    }

    func diff<ID: Hashable>(id: @escaping (Element) -> ID, by areEquivalent: @escaping (Element, Element) -> Bool) -> CollectionElements<C> {
        .init(value: wrappedValue, identifier: { id($0) }, areEquivalent: areEquivalent)
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> CollectionElements<C> {
        .init(value: wrappedValue, areEquivalent: areEquivalent)
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }

    func model(at indexPath: IndexPath) -> Any {
        value[indexPath.item]
    }
}

public extension CollectionElements where Element: Equatable {
    init(wrappedValue: C) {
        self.init(value: wrappedValue, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(value: models, areEquivalent: ==)
    }
}

public extension CollectionElements where Element: Hashable {
    init(wrappedValue: C) {
        self.init(value: wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(value: models, identifier: { $0 }, areEquivalent: ==)
    }
}
