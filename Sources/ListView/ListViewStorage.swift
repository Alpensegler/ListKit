//
//  ListViewStorage.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

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
        guard CustomCell.isSubclass(of: Cell.self) else {
            fatalError("\(CustomCell.self) is not subclass of \(Cell.self)")
        }
        let id = NSStringFromClass(CustomCell.self) + identifier
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
        guard CustomCell.isSubclass(of: Cell.self) else {
            fatalError("\(CustomCell.self) is not subclass of \(Cell.self)")
        }
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
        guard CustomCell.isSubclass(of: Cell.self) else {
            fatalError("\(CustomCell.self) is not subclass of \(Cell.self)")
        }
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
        guard CustomSupplementaryView.isSubclass(of: SupplementaryView.self) else {
            fatalError("\(CustomSupplementaryView.self) is not subclass of \(SupplementaryView.self)")
        }
        let id = NSStringFromClass(CustomSupplementaryView.self) + type.rawValue + identifier
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
        guard CustomSupplementaryView.isSubclass(of: SupplementaryView.self) else {
            fatalError("\(CustomSupplementaryView.self) is not subclass of \(SupplementaryView.self)")
        }
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

#endif
