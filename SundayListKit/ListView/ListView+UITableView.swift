//
//  ListView+UITableView.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

private var listViewDefaultAnimationKey: Void?

extension UITableView: ListView {
    public typealias Cell = UITableViewCell
    public typealias SupplementaryView = UITableViewHeaderFooterView
    public typealias Size = CGFloat
    
    public func reloadSynchronously() {
        reloadData()
    }
    
    public func perform(update: BatchUpdates, animation: Animation, completion: ((Bool) -> Void)?) {
        func __update() {
            // Update items.
            if update.insertItems.count > 0 {
                insertRows(at: update.insertItems, with: animation.insertRows)
            }
            if update.deleteItems.count > 0 {
                deleteRows(at: update.deleteItems, with: animation.deleteRows)
            }
            if update.reloadItems.count > 0 {
                reloadRows(at: update.reloadItems, with: animation.reloadRows)
            }
            for move in update.moveItems {
                moveRow(at: move.from, to: move.to)
            }
            
            // Update sections.
            if update.insertSections.count > 0 {
                insertSections(update.insertSections, with: animation.insertSections)
            }
            if update.deleteSections.count > 0 {
                deleteSections(update.deleteSections, with: animation.deleteSections)
            }
            if update.reloadSections.count > 0 {
                reloadSections(update.reloadSections, with: animation.reloadSections)
            }
            for move in update.moveSections {
                moveSection(move.from, toSection: move.to)
            }
        }
        
        if #available(iOS 11.0, *) {
            performBatchUpdates(__update, completion: completion)
        } else {
            beginUpdates()
            CATransaction.setCompletionBlock {
                completion?(true)
            }
            __update()
            endUpdates()
        }
    }
    
    public func insertItems(at indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: defaultAnimation.insertRows)
    }
    
    public func deleteItems(at indexPaths: [IndexPath]) {
        deleteRows(at: indexPaths, with: defaultAnimation.deleteRows)
    }
    
    public func reloadItems(at indexPaths: [IndexPath]) {
        reloadRows(at: indexPaths, with: defaultAnimation.reloadRows)
    }
    
    public func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        moveRow(at: indexPath, to: newIndexPath)
    }
    
    public func insertSections(_ sections: IndexSet) {
        insertSections(sections, with: defaultAnimation.insertSections)
    }
    
    public func deleteSections(_ sections: IndexSet) {
        deleteSections(sections, with: defaultAnimation.deleteSections)
    }
    
    public func reloadSections(_ sections: IndexSet) {
        reloadSections(sections, with: defaultAnimation.reloadSections)
    }

    
    public func register(_ headerViewClass: AnyClass?, forHeaderViewReuseIdentifier identifier: String) {
        register(headerViewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forHeaderViewReuseIdentifier identifier: String) {
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func register(_ footerViewClass: AnyClass?, forFooterViewReuseIdentifier identifier: String) {
        register(footerViewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forFooterViewReuseIdentifier identifier: String) {
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func dequeueReusableFooterView(withIdentifier identifier: String, indexPath: IndexPath) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) ?? .init()
    }
    
    public func dequeueReusableHeaderView(withIdentifier identifier: String, indexPath: IndexPath) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) ?? .init()
    }
    
    public var defaultAnimation: UITableView.Animation {
        get {
            return Associator.getValue(key: &listViewDefaultAnimationKey, from: self) ?? .fade
        }
        set {
            Associator.set(value: newValue, key: &listViewDefaultAnimationKey, to: self)
        }
    }
    
    public var defaultItemSize: ListSize {
        return rowHeight
    }
}

extension UITableView {
    public struct Animation: ListViewAnimationOption {
        let deleteSections: RowAnimation
        let insertSections: RowAnimation
        let reloadSections: RowAnimation
        let deleteRows: RowAnimation
        let insertRows: RowAnimation
        let reloadRows: RowAnimation
        
        public init(
            deleteSections: RowAnimation = .none,
            insertSections: RowAnimation = .none,
            reloadSections: RowAnimation = .none,
            deleteRows: RowAnimation = .none,
            insertRows: RowAnimation = .none,
            reloadRows: RowAnimation = .none
        ) {
            self.deleteSections = deleteSections
            self.insertSections = insertSections
            self.reloadSections = reloadSections
            self.deleteRows = deleteRows
            self.insertRows = insertRows
            self.reloadRows = reloadRows
        }
        
        public init() {
            self.init(allUsing: .automatic)
        }
        
        init(allUsing animation: RowAnimation) {
            deleteSections = animation
            insertSections = animation
            reloadSections = animation
            deleteRows = animation
            insertRows = animation
            reloadRows = animation
        }
    }
}

public extension UITableView.Animation {
    static let fade = UITableView.Animation(allUsing: .fade)
    static let right = UITableView.Animation(allUsing: .right)
    static let left = UITableView.Animation(allUsing: .left)
    static let top = UITableView.Animation(allUsing: .top)
    static let bottom = UITableView.Animation(allUsing: .bottom)
    static let none = UITableView.Animation(allUsing: .none)
    static let middle = UITableView.Animation(allUsing: .middle)
    static let automatic = UITableView.Animation(allUsing: .automatic)
}


