//
//  SectionsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/3.
//

// swiftlint:disable comment_spacing

import Foundation

@propertyWrapper
public struct SectionedElements<C: Collection>: TypedListAdapter, ListCoordinator where C.Element: Collection {
    public typealias Element = C.Element.Element
    var indices = ContiguousArray<Int>()
    var value: ContiguousArray<ContiguousArray<Element>>
    var identifier: ((Element) -> AnyHashable)?
    var areEquivalent: ((Element, Element) -> Bool)?
    public var count = Count.sections(nil, [], nil)
    public var wrappedValue: C {
        didSet {
            value = wrappedValue.mapContiguous { $0.mapContiguous { $0 } }
            configCount()
        }
    }
    public var projectedValue: Self { self }

    init(value: C,
         identifier: ((Element) -> AnyHashable)? = nil,
         areEquivalent: ((Element, Element) -> Bool)? = nil
    ) {
        self.wrappedValue = value
        self.value = value.mapContiguous { $0.mapContiguous { $0 } }
        self.identifier = identifier
        self.areEquivalent = areEquivalent
    }
}

public extension SectionedElements {
    init(wrappedValue: C) {
        self.init(value: wrappedValue)
    }

    init(_ models: C) {
        self.init(value: models)
    }

    func diff<ID: Hashable>(id: @escaping (Element) -> ID, by areEquivalent: @escaping (Element, Element) -> Bool) -> SectionedElements<C> {
        .init(value: wrappedValue, identifier: { id($0) }, areEquivalent: areEquivalent)
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> SectionedElements<C> {
        .init(value: wrappedValue, areEquivalent: areEquivalent)
    }

    mutating func configCount() {
        count = .sections(nil, value.map { $0.count }, nil)
    }

    func model(at indexPath: IndexPath) -> Any {
        value[indexPath.section][indexPath.item]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}

public extension SectionedElements where Element: Equatable {
    init(wrappedValue: C) {
        self.init(value: wrappedValue, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(value: models, areEquivalent: ==)
    }
}

public extension SectionedElements where Element: Hashable {
    init(wrappedValue: C) {
        self.init(value: wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ models: C) {
        self.init(value: models, identifier: { $0 }, areEquivalent: ==)
    }
}
