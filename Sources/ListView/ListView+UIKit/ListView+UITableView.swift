//
//  ListView+UITableView.swift
//  ListKit
//
//  Created by Frain on 2019/4/6.
//

#if os(iOS) || os(tvOS)
import UIKit

private var listViewDefaultAnimationKey: Void?

public typealias TableView = UITableView

extension UITableView: UIListView {
    public typealias Cell = UITableViewCell
}

public extension UITableView {
    
    var defaultAnimation: Animation {
        get { return Associator.getValue(key: &listViewDefaultAnimationKey, from: self) ?? .fade }
        set { Associator.set(value: newValue, key: &listViewDefaultAnimationKey, to: self) }
    }
    
    func setupWith(coordinator: BaseCoordinator) {
        dataSource = coordinator
        delegate = coordinator
    }
    
    func reloadSynchronously() {
        reloadData()
        layoutIfNeeded()
    }
    
    func perform(update: () -> Void, animated: Bool, completion: ((Bool) -> Void)?) {
        func _update() {
            if #available(iOS 11.0, *) {
                performBatchUpdates(update, completion: completion)
            } else {
                beginUpdates()
                CATransaction.setCompletionBlock { completion?(true) }
                update()
                endUpdates()
            }
        }
        if animated {
            _update()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _update()
            CATransaction.commit()
        }
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: defaultAnimation.insertRows)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        deleteRows(at: indexPaths, with: defaultAnimation.deleteRows)
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        reloadRows(at: indexPaths, with: defaultAnimation.reloadRows)
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        moveRow(at: indexPath, to: newIndexPath)
    }
    
    func insertSections(_ sections: IndexSet) {
        insertSections(sections, with: defaultAnimation.insertSections)
    }
    
    func deleteSections(_ sections: IndexSet) {
        deleteSections(sections, with: defaultAnimation.deleteSections)
    }
    
    func reloadSections(_ sections: IndexSet) {
        reloadSections(sections, with: defaultAnimation.reloadSections)
    }
    
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: ScrollPosition) {
        selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(at indexPath: IndexPath, animated: Bool) {
        deselectRow(at: indexPath, animated: animated)
    }
    
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String) {
        switch supplementaryViewType {
        case .header: register(supplementaryClass, forHeaderFooterViewReuseIdentifier: identifier)
        case .footer: register(supplementaryClass, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
    
    func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String) {
        switch supplementaryViewType {
        case .header: register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        case .footer: register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
    
    func cellForItem(at indexPath: IndexPath) -> UITableViewCell? {
        cellForRow(at: indexPath)
    }
}

public extension UITableView {
    enum SupplementaryViewType: String {
        case header
        case footer
    }
    
    struct Animation: ListViewAnimationOption {
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

#endif
