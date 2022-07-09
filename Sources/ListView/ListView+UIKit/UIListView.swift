//
//  ListView.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

#if os(iOS) || os(tvOS)
import UIKit

public protocol UIListView: UIScrollView, ListView {
    associatedtype Cell: UIView
    associatedtype Animation: ListViewAnimationOption
    associatedtype ScrollPosition
    associatedtype SupplementaryViewType

    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> Cell

    func cellForItem(at indexPath: IndexPath) -> Cell?

    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: ScrollPosition)
    func deselectItem(at indexPath: IndexPath, animated: Bool)

    var defaultAnimation: Animation { get set }
}

public protocol ListViewAnimationOption {
    init(animated: Bool)
}

#endif
