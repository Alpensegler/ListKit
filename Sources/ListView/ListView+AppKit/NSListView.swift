//
//  NSListView.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(macOS)
import AppKit

public protocol NSListView: NSView, ListView {
    associatedtype Cell: NSCollectionViewItem
    associatedtype Animation: ListViewAnimationOption
    associatedtype ScrollPosition
    associatedtype SupplementaryViewType

    func register(_ itemClass: AnyClass?, forItemWithIdentifier identifier: NSUserInterfaceItemIdentifier)
    func register(_ nib: NSNib?, forItemWithIdentifier identifier: NSUserInterfaceItemIdentifier)
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, forSupplementaryViewOfKind kind: NSCollectionView.SupplementaryElementKind, withIdentifier identifier: NSUserInterfaceItemIdentifier)
    func register(supplementaryViewType: SupplementaryViewType, _ nib: NSNib?, forSupplementaryViewOfKind kind: NSCollectionView.SupplementaryElementKind, withIdentifier identifier: NSUserInterfaceItemIdentifier)
    func makeItem(withIdentifier identifier: NSUserInterfaceItemIdentifier, for indexPath: IndexPath) -> Cell

    func item(at indexPath: IndexPath) -> Cell?

    func selectItems(at indexPaths: Set<IndexPath>, scrollPosition: ScrollPosition)
    func deselectItems(at indexPaths: Set<IndexPath>)

    var defaultAnimation: Animation { get set }
}

public protocol ListViewAnimationOption {
    init(animated: Bool)
}

#endif
