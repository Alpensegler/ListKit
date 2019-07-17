//
//  ListViewStorage.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

class ListViewStorage {
    var registeredCellIdentifiers = Set<String>()
    var registeredNibNames = Set<String>()
    var registeredSupplementaryIdentifiers = [SupplementaryViewType: Set<String>]()
    var registeredSupplementaryNibName = [SupplementaryViewType: Set<String>]()
}

public extension ListView {
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        identifier: String = "",
        indexPath: IndexPath,
        configuration: (CustomCell) -> Void = { _ in }
    ) -> Cell {
        assert(CustomCell.isSubclass(of: Cell.self), "TBD")
        let id = identifierFor(class: CustomCell.self, identifier: identifier)
        if !_storage.registeredCellIdentifiers.contains(id) {
            _storage.registeredCellIdentifiers.insert(id)
            register(CustomCell.self, forCellReuseIdentifier: id)
        }
        let cell = dequeueReusableCell(withIdentifier: id, for: indexPath)
        (cell as? CustomCell).map(configuration)
        return cell
    }

    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        storyBoardIdentifier: String,
        indexPath: IndexPath,
        configuration: (CustomCell) -> Void = { _ in }
    ) -> Cell {
        assert(CustomCell.isSubclass(of: Cell.self), "TBD")
        let cell = dequeueReusableCell(withIdentifier: storyBoardIdentifier, for: indexPath)
        (cell as? CustomCell).map(configuration)
        return cell
    }
    
    func dequeueReusableCell<CustomCell: UIView>(
        withCellClass cellClass: CustomCell.Type,
        withNibName nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath,
        configuration: (CustomCell) -> Void = { _ in }
    ) -> Cell {
        assert(CustomCell.isSubclass(of: Cell.self), "TBD")
        let nib = UINib(nibName: nibName, bundle: bundle)
        if !_storage.registeredNibNames.contains(nibName) {
            _storage.registeredNibNames.insert(nibName)
            register(nib, forCellReuseIdentifier: nibName)
        }
        let cell = dequeueReusableCell(withIdentifier: nibName, for: indexPath)
        (cell as? CustomCell).map(configuration)
        return cell
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UIView>(
        type: SupplementaryViewType,
        withSupplementaryClass supplementaryClass: CustomSupplementaryView.Type,
        identifier: String = "",
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView {
        assert(CustomSupplementaryView.isSubclass(of: SupplementaryView.self), "TBD")
        let id = identifierFor(class: CustomSupplementaryView.self, type: type.rawValue, identifier: identifier)
        if _storage.registeredSupplementaryIdentifiers[type]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryIdentifiers[type] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryIdentifiers[type] = identifiers
            register(supplementaryViewType: type, supplementaryClass, identifier: id)
        }
        let supplementaryView = dequeueReusableSupplementaryView(type: type, withIdentifier: id, indexPath: indexPath) ?? CustomSupplementaryView()
        (supplementaryView as? CustomSupplementaryView).map(configuration)
        return supplementaryView as! SupplementaryView
    }
    
    func dequeueReusableSupplementaryView<CustomSupplementaryView: UIView>(
        type: SupplementaryViewType,
        withSupplementaryClass supplementaryClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView {
        assert(CustomSupplementaryView.isSubclass(of: SupplementaryView.self), "TBD")
        let nib = UINib(nibName: nibName, bundle: bundle)
        let id = nibName + type.rawValue
        if _storage.registeredSupplementaryNibName[type]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryNibName[type] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryNibName[type] = identifiers
            register(supplementaryViewType: type, nib, identifier: id)
        }
        let supplementaryView = dequeueReusableSupplementaryView(type: type, withIdentifier: id, indexPath: indexPath) ?? CustomSupplementaryView()
        (supplementaryView as? CustomSupplementaryView).map(configuration)
        return supplementaryView as! SupplementaryView
    }
}

var listViewStorageKey: Void?

extension ListView {
    var _storage: ListViewStorage {
        get { return Associator.getValue(key: &listViewStorageKey, from: self, initialValue: .init()) }
        set { Associator.set(value: newValue, key: &listViewStorageKey, to: self) }
    }
}

private extension ListView {
    func identifierFor(class: AnyClass, type: String = "", identifier: String) -> String {
        return NSStringFromClass(Cell.self) + identifier
    }
}
