//
//  SingleElement.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

// swiftlint:disable comment_spacing

import Foundation

@propertyWrapper
public struct SingleElement<Element>: TypedListAdapter, ListCoordinator {
    var areEquivalent: ((Element, Element) -> Bool)?
    public var wrappedValue: Element
    public var projectedValue: Self { self }

    init(value: Element, areEquivalent: ((Element, Element) -> Bool)? = nil) {
        self.wrappedValue = value
        self.areEquivalent = areEquivalent
    }
}

public extension SingleElement {
    var count: Count { .items(1) }

    init(wrappedValue: Element) {
        self.init(value: wrappedValue)
    }

    init(_ element: Element) {
        self.init(value: element)
    }

    func diff(by areEquivalent: @escaping (Element, Element) -> Bool) -> SingleElement<Element> {
        .init(value: wrappedValue, areEquivalent: areEquivalent)
    }

    func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        wrappedValue
    }

    func performUpdate(to coordinator: ListCoordinator) -> BatchUpdates {
        .reload(change: nil)
    }
}

public extension SingleElement where Element: Equatable {
    init(wrappedValue: Element) {
        self.init(value: wrappedValue, areEquivalent: ==)
    }

    init(_ element: Element) {
        self.init(value: element, areEquivalent: ==)
    }
}

public extension SingleElement where Element == Void {
    init() { self.init(()) }
}
