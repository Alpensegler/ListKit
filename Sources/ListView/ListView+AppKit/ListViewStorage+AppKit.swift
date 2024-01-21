//
//  ListViewStorage+AppKit.swift
//  ListKit
//
//  Created by Frain on 2024/1/13.
//

#if os(macOS)
import AppKit

public extension NSListView where Self: NSCollectionView {
    func makeItem<CustomItem: NSCollectionViewItem>(
        _ itemClass: CustomItem.Type,
        identifier: String,
        indexPath: IndexPath
    ) -> CustomItem {
        let id = NSUserInterfaceItemIdentifier(NSStringFromClass(CustomItem.self) + identifier)
        if !_storage.registeredItemIdentifiers.contains(id) {
            _storage.registeredItemIdentifiers.insert(id)
            self.register(itemClass, forItemWithIdentifier: id)
        }
        guard let item = self.makeItem(withIdentifier: id, for: indexPath) as? CustomItem else {
            fatalError("Unexpected item type for identifier \(id)")
        }
        return item
    }

    func makeItem<CustomItem: NSCollectionViewItem>(
        _ itemClass: CustomItem.Type,
        nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath
    ) -> CustomItem {
        let identifier = NSUserInterfaceItemIdentifier(nibName)
        if !_storage.registeredNibIdentifiers.contains(nibName) {
            _storage.registeredNibIdentifiers.insert(nibName)
            let nib = NSNib(nibNamed: nibName, bundle: bundle)
            self.register(nib, forItemWithIdentifier: identifier)
        }
        guard let item = self.makeItem(withIdentifier: identifier, for: indexPath) as? CustomItem else {
            fatalError("Unexpected item type for nib name \(nibName)")
        }
        return item
    }
}

public extension NSCollectionView {
    func makeReusableSupplementaryView<SupplementaryView: NSView>(
        kind: NSCollectionView.SupplementaryElementKind,
        _ supplementaryClass: SupplementaryView.Type,
        identifier: NSUserInterfaceItemIdentifier,
        indexPath: IndexPath
    ) -> SupplementaryView {
        let id = identifier
        if _storage.registeredSupplementaryIdentifiers[kind]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryIdentifiers[kind] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryIdentifiers[kind] = identifiers
            self.register(supplementaryClass, forSupplementaryViewOfKind: kind, withIdentifier: id)
        }
        guard let view = self.makeSupplementaryView(ofKind: kind, withIdentifier: id, for: indexPath) as? SupplementaryView else {
            fatalError("Unexpected supplementary view type for identifier \(id)")
        }
        return view
    }

    func makeReusableSupplementaryView<SupplementaryView: NSView>(
        kind: NSCollectionView.SupplementaryElementKind,
        _ supplementaryClass: SupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil,
        indexPath: IndexPath
    ) -> SupplementaryView {
        let id = NSUserInterfaceItemIdentifier(nibName + kind)
        if _storage.registeredSupplementaryNibName[kind]?.contains(id) != true {
            var identifiers = _storage.registeredSupplementaryNibName[kind] ?? .init()
            identifiers.insert(id)
            _storage.registeredSupplementaryNibName[kind] = identifiers
            let nib = NSNib(nibNamed: nibName, bundle: bundle)
            self.register(nib, forSupplementaryViewOfKind: kind, withIdentifier: id)
        }
        guard let view = self.makeSupplementaryView(ofKind: kind, withIdentifier: id, for: indexPath) as? SupplementaryView else {
            fatalError("Unexpected supplementary view type for nib name \(nibName)")
        }
        return view
    }
}

// Storage for registered identifiers
extension NSCollectionView {
    private struct AssociatedKeys {
        static var registeredItemIdentifiers = "registeredItemIdentifiers"
        static var registeredNibIdentifiers = "registeredNibIdentifiers"
        static var registeredSupplementaryIdentifiers = "registeredSupplementaryIdentifiers"
        static var registeredSupplementaryNibName = "registeredSupplementaryNibName"
    }
}



#endif
