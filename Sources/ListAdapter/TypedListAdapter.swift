//
//  TypedListAdapter.swift
//  ListKit
//
//  Created by Frain on 2023/6/10.
//

import Foundation

public protocol TypedListAdapter: ListAdapter where List: TypedListAdapter, Element == List.Element {
    associatedtype Element = List.Element

    func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element
}

public extension TypedListAdapter {
    func element<View>(at context: ListIndexContext<View, IndexPath>) -> Element {
        (context.context.coordinator as! List).element(at: context)
    }
}
