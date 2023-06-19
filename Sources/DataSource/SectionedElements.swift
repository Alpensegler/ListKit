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
    var value: ContiguousArray<ContiguousArray<Element>>
    var indices = ContiguousArray<Int>()
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
}

extension SectionedElements {
    init(
        _ wrappedValue: C,
        identifier: ((Element) -> AnyHashable)? = nil,
        areEquivalent: ((Element, Element) -> Bool)? = nil
    ) {
        self.wrappedValue = wrappedValue
        self.value = wrappedValue.mapContiguous { $0.mapContiguous { $0 } }
        self.identifier = identifier
        self.areEquivalent = areEquivalent
        configCount()
    }
}

public extension SectionedElements {
    init(wrappedValue: C) {
        self.init(wrappedValue)
    }

    init(_ sections: C) {
        self.init(sections, identifier: nil, areEquivalent: nil)
    }

    func diff<ID: Hashable>(id: @escaping (Element) -> ID, by areEquivalent: @escaping (Element, Element) -> Bool) -> SectionedElements<C> {
        .init(value: value, indices: indices, identifier: { id($0) }, areEquivalent: areEquivalent, wrappedValue: wrappedValue)
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> SectionedElements<C> {
        .init(value: value, indices: indices, areEquivalent: areEquivalent, wrappedValue: wrappedValue)
    }

    mutating func configCount() {
        count = .sections(nil, value.map { $0.count }, nil)
    }

    func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        value[context.section][context.item]
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}

public extension SectionedElements where Element: Equatable {
    init(wrappedValue: C) {
        self.init(wrappedValue, areEquivalent: ==)
    }

    init(_ sections: C) {
        self.init(sections, areEquivalent: ==)
    }
}

public extension SectionedElements where Element: Hashable {
    init(wrappedValue: C) {
        self.init(wrappedValue, identifier: { $0 }, areEquivalent: ==)
    }

    init(_ sections: C) {
        self.init(sections, identifier: { $0 }, areEquivalent: ==)
    }
}
