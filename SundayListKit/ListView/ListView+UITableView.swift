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
    public typealias Coordinator = TableCoordinator
    
    public var defaultAnimation: UITableView.Animation {
        get { return Associator.getValue(key: &listViewDefaultAnimationKey, from: self) ?? .fade }
        set { Associator.set(value: newValue, key: &listViewDefaultAnimationKey, to: self) }
    }
    
    public func defaultSupplementraySize(for type: SupplementaryViewType) -> CGFloat {
        switch type {
        case .header: return sectionHeaderHeight
        case .footer: return sectionFooterHeight
        case .custom: return 0 as CGFloat
        }
    }
    
    public var defaultItemSize: CGFloat {
        return rowHeight
    }
    
    public func reloadSynchronously(completion: ((Bool) -> Void)? = nil) {
        reloadData()
        completion?(true)
    }
    
    public func perform(update: () -> Void, animation: Animation, completion: ((Bool) -> Void)?) {
        if #available(iOS 11.0, *) {
            performBatchUpdates(update, completion: completion)
        } else {
            beginUpdates()
            CATransaction.setCompletionBlock {
                completion?(true)
            }
            update()
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
    
    public func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String) {
        switch supplementaryViewType {
        case .header: register(supplementaryClass, forHeaderFooterViewReuseIdentifier: identifier)
        case .footer: register(supplementaryClass, forHeaderFooterViewReuseIdentifier: identifier)
        case .custom: fatalError("table view dose not support custom supplementary view type")
        }
    }
    
    public func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String) {
        switch supplementaryViewType {
        case .header: register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        case .footer: register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        case .custom: fatalError("table view dose not support custom supplementary view type")
        }
    }
    
    public func dequeueReusableSupplementaryView(type: SupplementaryViewType, withIdentifier identifier: String, indexPath: IndexPath) -> UITableViewHeaderFooterView? {
        switch type {
        case .header, .footer: return dequeueReusableHeaderFooterView(withIdentifier: identifier)
        case .custom: fatalError("table view dose not support custom supplementary view type")
        }
    }
    
    public func cellForItem(at indexPath: IndexPath) -> UITableViewCell? {
        return cellForRow(at: indexPath)
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
        
        public init(animated: Bool) {
            if animated {
                self.init()
            } else {
                self.init(allUsing: .none)
            }
        }
        
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


