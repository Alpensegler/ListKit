//
//  Context+AppKit+CallAsFuntion.swift
//  ListKit
//
//  Created by zouyanwei on 2024/1/21.
//

import Foundation
#if os(macOS)
import AppKit

// MARK: - CollectionView Related Functions
public extension IndexFunction where View: NSCollectionView, Index == IndexPath {
    func callAsFunction<Item: NSCollectionViewItem>(
        _ itemClass: Item.Type,
        identifier: String = "",
        configItem: @escaping (Item, ListIndexContext<View, Index>) -> Void = { _, _ in }
    ) -> Modifier<V, List> where Output == NSCollectionViewItem {
        toTarget { (context, _) in
            let item = context.makeItem(itemClass, identifier: identifier)
            configItem(item, context)
            return item
        }
    }

    func callAsFunction<Item: NSCollectionViewItem>(
        _ itemClass: Item.Type,
        identifier: String = "",
        configItem: @escaping (Item, ListIndexContext<View, Index>, List.Element) -> Void
    ) -> Modifier<V, List> where Output == NSCollectionViewItem, List: TypedListAdapter {
        toTarget { (context, _) in
            let item = context.makeItem(itemClass, identifier: identifier)
            configItem(item, context, context.element(for: List.self))
            return item
        }
    }
}

#endif
