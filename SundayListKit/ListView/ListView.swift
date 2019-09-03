//
//  ListView.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/24.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

public protocol ListView: UIScrollView {
    associatedtype Cell: UIView
    associatedtype SupplementaryView: UIView
    associatedtype Animation: ListViewAnimationOption
    associatedtype Size
    associatedtype Coordinator: ListViewCoordinator where Coordinator.List == Self
    associatedtype ScrollPosition
    
    func reloadSynchronously(completion: ((Bool) -> Void)?)
    func perform(update: () -> Void, animation: Animation, completion: ((Bool) -> Void)?)
    
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> Cell
    func dequeueReusableSupplementaryView(type: SupplementaryViewType, withIdentifier identifier: String, indexPath: IndexPath) -> SupplementaryView?
    
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
    
    func defaultSupplementraySize(for type: SupplementaryViewType) -> Size
    var defaultAnimation: Animation { get set }
    var defaultItemSize: Size { get }
}

public protocol ListViewCoordinator: NSObject {
    associatedtype List: ListView
    func setListView(_ listView: List)
}

public protocol ListViewAnimationOption {
    init(animated: Bool)
}

public enum SupplementaryViewType: Hashable {
    case header
    case footer
    case custom(String)
    
    init(_ rawValue: String) {
        switch rawValue {
        case UICollectionView.elementKindSectionHeader: self = .header
        case UICollectionView.elementKindSectionFooter: self = .footer
        default: self = .custom(rawValue)
        }
    }
    
    var rawValue: String {
        switch self {
        case .header: return UICollectionView.elementKindSectionHeader
        case .footer: return UICollectionView.elementKindSectionFooter
        case .custom(let string): return string
        }
    }
}
