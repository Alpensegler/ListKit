//
//  ListViewStorage.swift
//  ListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

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
