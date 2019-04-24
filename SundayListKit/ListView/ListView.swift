//
//  ListView.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/24.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

public protocol ListView: class, Hashable {
    associatedtype Cell: UIView
    associatedtype SupplementaryView: UIView
    associatedtype Animation
    func reloadSynchronously()
    func perform(update: BatchUpdates, animation: Animation, completion: ((Bool) -> Void)?)
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func register(_ headerViewClass: AnyClass?, forHeaderViewReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forHeaderViewReuseIdentifier identifier: String)
    func register(_ footerViewClass: AnyClass?, forFooterViewReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forFooterViewReuseIdentifier identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> Cell
    func dequeueReusableHeaderView(withIdentifier identifier: String, indexPath: IndexPath) -> SupplementaryView
    func dequeueReusableFooterView(withIdentifier identifier: String, indexPath: IndexPath) -> SupplementaryView
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func reloadItems(at indexPaths: [IndexPath])
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func reloadSections(_ sections: IndexSet)
    func moveSection(_ section: Int, toSection newSection: Int)
    var defaultAnimation: Animation { get set }
    var defaultItemSize: ListSize { get }
}

private var listViewDefaultAnimationKey: Void?

public protocol ListViewAnimationOption {
    init()
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
