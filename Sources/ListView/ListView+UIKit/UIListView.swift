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
    associatedtype Size
    associatedtype ScrollPosition
    associatedtype SupplementaryViewType
    
    func reloadSynchronously(completion: ((Bool) -> Void)?)
    func perform(update: () -> Void, animation: Animation, completion: ((Bool) -> Void)?)
    
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> Cell
    
    func cellForItem(at indexPath: IndexPath) -> Cell?
    
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func reloadItems(at indexPaths: [IndexPath])
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func reloadSections(_ sections: IndexSet)
    func moveSection(_ section: Int, toSection newSection: Int)
    
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: ScrollPosition)
    func deselectItem(at indexPath: IndexPath, animated: Bool)
    
    var defaultAnimation: Animation { get set }
}

public protocol ListViewAnimationOption {
    init(animated: Bool)
}

#endif
