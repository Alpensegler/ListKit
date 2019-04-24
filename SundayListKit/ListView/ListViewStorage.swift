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
    var registeredHeaderIdentifiers = Set<String>()
    var registeredFooterIdentifiers = Set<String>()
    var registeredHeaderNibNames = Set<String>()
    var registeredFooterNibNames = Set<String>()
    
    init(
        registeredCellIdentifiers: Set<String> = [],
        registeredNibNames: Set<String> = [],
        registeredHeaderIdentifiers: Set<String> = [],
        registeredFooterIdentifiers: Set<String> = [],
        registeredHeaderNibNames: Set<String> = [],
        registeredFooterNibNames: Set<String> = []
    ) {
        self.registeredCellIdentifiers = registeredCellIdentifiers
        self.registeredNibNames = registeredNibNames
        self.registeredHeaderIdentifiers = registeredHeaderIdentifiers
        self.registeredFooterIdentifiers = registeredFooterIdentifiers
        self.registeredHeaderNibNames = registeredHeaderNibNames
        self.registeredFooterNibNames = registeredFooterNibNames
    }
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
        let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath)
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
    
    func dequeueReusableHeaderView<CustomSupplementaryView: UIView>(
        withHeaderClass cellClass: CustomSupplementaryView.Type,
        identifier: String = "",
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView {
        assert(CustomSupplementaryView.isSubclass(of: SupplementaryView.self), "TBD")
        let id = identifierFor(class: CustomSupplementaryView.self, type: Self.headerType, identifier: identifier)
        if !_storage.registeredHeaderIdentifiers.contains(id) {
            _storage.registeredHeaderIdentifiers.insert(id)
            register(CustomSupplementaryView.self, forHeaderViewReuseIdentifier: id)
        }
        let header = dequeueReusableHeaderView(withIdentifier: id, indexPath: indexPath)
        (header as? CustomSupplementaryView).map(configuration)
        return header
    }
    
    func dequeueReusableHeaderView<CustomSupplementaryView: UIView>(
        withHeaderClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView {
        assert(CustomSupplementaryView.isSubclass(of: SupplementaryView.self), "TBD")
        let nib = UINib(nibName: nibName, bundle: bundle)
        let id = nibName + Self.headerType
        if !_storage.registeredHeaderNibNames.contains(id) {
            _storage.registeredHeaderNibNames.insert(id)
            register(nib, forHeaderViewReuseIdentifier: id)
        }
        let header = dequeueReusableHeaderView(withIdentifier: id, indexPath: indexPath)
        (header as? CustomSupplementaryView).map(configuration)
        return header
    }
    
    func dequeueReusableFooterView<CustomSupplementaryView: UIView>(
        withFooterClass cellClass: CustomSupplementaryView.Type,
        identifier: String = "",
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView {
        assert(CustomSupplementaryView.isSubclass(of: SupplementaryView.self), "TBD")
        let id = identifierFor(class: CustomSupplementaryView.self, type: Self.footerType, identifier: identifier)
        if !_storage.registeredFooterIdentifiers.contains(id) {
            _storage.registeredFooterIdentifiers.insert(id)
            register(CustomSupplementaryView.self, forHeaderViewReuseIdentifier: id)
        }
        let footer = dequeueReusableFooterView(withIdentifier: id, indexPath: indexPath)
        (footer as? CustomSupplementaryView).map(configuration)
        return footer
    }
    
    func dequeueReusableFooterView<CustomSupplementaryView: UIView>(
        withFooterClass cellClass: CustomSupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath,
        configuration: (CustomSupplementaryView) -> Void = { _ in }
    ) -> SupplementaryView {
        assert(CustomSupplementaryView.isSubclass(of: SupplementaryView.self), "TBD")
        let nib = UINib(nibName: nibName, bundle: bundle)
        let id = nibName + Self.footerType
        if !_storage.registeredFooterNibNames.contains(id) {
            _storage.registeredFooterNibNames.insert(id)
            register(nib, forFooterViewReuseIdentifier: id)
        }
        let footer = dequeueReusableFooterView(withIdentifier: id, indexPath: indexPath)
        (footer as? CustomSupplementaryView).map(configuration)
        return footer
    }
}

var listAdapterListViewStorageKey: Void?

extension ListView {
    var _storage: ListViewStorage {
        get {
            return Associator.getValue(key: &listAdapterListViewStorageKey, from: self, initialValue: .init())
        }
        set {
            Associator.set(value: newValue, key: &listAdapterListViewStorageKey, to: self)
        }
    }
}

private extension ListView {
    static var headerType: String { return "Header" }
    static var footerType: String { return "Footer" }
    
    func identifierFor(class: AnyClass, type: String = "", identifier: String) -> String {
        return NSStringFromClass(Cell.self) + identifier
    }
}
