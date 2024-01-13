//
//  ListViewStorage.swift
//  ListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//


#if os(macOS)
import AppKit

class CollectionViewStorage {
    var registeredItemIdentifiers: Set<NSUserInterfaceItemIdentifier> = []
    var registeredNibIdentifiers: Set<String> = []
    var registeredSupplementaryIdentifiers: [NSCollectionView.SupplementaryElementKind: Set<NSUserInterfaceItemIdentifier>] = [:]
    var registeredSupplementaryNibName: [NSCollectionView.SupplementaryElementKind: Set<NSUserInterfaceItemIdentifier>] = [:]
}

private var listViewStorageKey: Void?

extension NSListView {
    var _storage: CollectionViewStorage {
        get { Associator.getValue(key: &listViewStorageKey, from: self, initialValue: .init()) }
        set { Associator.set(value: newValue, key: &listViewStorageKey, to: self) }
    }
}

#else

class ListViewStorage {
    var registeredCellIdentifiers = Set<String>()
    var registeredNibNames = Set<String>()
    var registeredSupplementaryIdentifiers = [AnyHashable: Set<String>]()
    var registeredSupplementaryNibName = [AnyHashable: Set<String>]()
}

private var listViewStorageKey: Void?

extension UIListView {
    var _storage: ListViewStorage {
        get { Associator.getValue(key: &listViewStorageKey, from: self, initialValue: .init()) }
        set { Associator.set(value: newValue, key: &listViewStorageKey, to: self) }
    }
}

#endif
