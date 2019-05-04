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
    func reloadSynchronously()
    func perform(update: () -> Void, animation: Animation, completion: ((Bool) -> Void)?)
    func performUpdate(animation: Animation, completion: ((Bool) -> Void)?)
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String)
    func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> Cell
    func dequeueReusableSupplementaryView(type: SupplementaryViewType, withIdentifier identifier: String, indexPath: IndexPath) -> SupplementaryView?
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func reloadItems(at indexPaths: [IndexPath])
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func reloadSections(_ sections: IndexSet)
    func moveSection(_ section: Int, toSection newSection: Int)
    func defaultSupplementraySize(for type: SupplementaryViewType) -> ListSize
    var defaultAnimation: Animation { get set }
    var defaultItemSize: ListSize { get }
}

public extension ListView {
    func performUpdate(completion: ((Bool) -> Void)? = nil) {
        performUpdate(animation: defaultAnimation, completion: completion)
    }
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
}

public protocol ListSize {
    var height: CGFloat { get }
    var size: CGSize { get }
}

extension CGSize: ListSize {
    public var size: CGSize {
        return self
    }
}

extension CGFloat: ListSize {
    public var height: CGFloat {
        return self
    }
    
    public var size: CGSize {
        return CGSize(width: self, height: self)
    }
}
