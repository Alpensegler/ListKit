//
//  Context+APPKit.swift
//  ListKit
//
//  Created by Frain on 2024/1/13.
//

#if os(macOS)
import AppKit

public extension ListIndexContext where Index == IndexPath, View: NSCollectionView {
    func select(animated: Bool, scrollPosition: View.ScrollPosition) {
        listView.selectItems(at: [rawIndex], scrollPosition: scrollPosition)
    }

    func deselect(animated: Bool) {
        listView.deselectItems(at: [rawIndex])
    }

    var item: View.Cell? {
        listView.item(at: rawIndex)
    }

    func makeItem<CustomItem: NSCollectionViewItem>(
        _ itemClass: CustomItem.Type,
        identifier: String = ""
    ) -> CustomItem {
        listView.makeItem(itemClass, identifier: identifier, indexPath: rawIndex)
    }

    func makeItem<CustomItem: NSCollectionViewItem>(
        _ itemClass: CustomItem.Type,
        nibName: String,
        bundle: Bundle? = nil
    ) -> CustomItem {
        listView.makeItem(itemClass, nibName: nibName, indexPath: rawIndex)
    }
}

public extension ListIndexContext where Index == IndexPath, View: NSCollectionView {
    func makeReusableSupplementaryView<SupplementaryView: NSView>(
        kind: NSCollectionView.SupplementaryElementKind,
        _ supplementaryClass: SupplementaryView.Type,
        identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "")
    ) -> SupplementaryView {
        guard let view = listView.makeSupplementaryView(ofKind: kind, withIdentifier: identifier, for: rawIndex) as? SupplementaryView else {
            fatalError("Unexpected supplementary view type")
        }
        return view
    }

    func makeReusableSupplementaryView<SupplementaryView: NSView>(
        kind: NSCollectionView.SupplementaryElementKind,
        _ supplementaryClass: SupplementaryView.Type,
        nibName: String,
        bundle: Bundle? = nil
    ) -> SupplementaryView {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: nibName)
        guard let view = listView.makeSupplementaryView(ofKind: kind, withIdentifier: identifier, for: rawIndex) as? SupplementaryView else {
            fatalError("Unexpected supplementary view type")
        }
        return view
    }
}


#endif
