//
//  ListView+UIcollectionView.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/6.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

private var listViewDefaultAnimationKey: Void?

extension UICollectionView: ListView {
    public typealias Cell = UICollectionViewCell
    public typealias Animation = Bool
    public typealias SupplementaryView = UICollectionReusableView
    public typealias Size = CGSize
    
    public func reloadSynchronously() {
        reloadData()
        
        // Force a layout so that it is safe to call insert after this.
        layoutIfNeeded()
    }
    
    public func perform(update: BatchUpdates, animation: Bool, completion: ((Bool) -> Void)? = nil) {
        func __update() {
            // Update items.
            if !update.insertItems.isEmpty {
                self.insertItems(at: update.insertItems)
            }
            if !update.deleteItems.isEmpty {
                self.deleteItems(at: update.deleteItems)
            }
            if !update.reloadItems.isEmpty {
                self.reloadItems(at: update.reloadItems)
            }
            for move in update.moveItems {
                self.moveItem(at: move.from, to: move.to)
            }
            
            // Update sections.
            if !update.insertSections.isEmpty {
                self.insertSections(update.insertSections)
            }
            if !update.deleteSections.isEmpty {
                self.deleteSections(update.deleteSections)
            }
            if !update.reloadSections.isEmpty {
                self.reloadSections(update.reloadSections)
            }
            for move in update.moveSections {
                self.moveSection(move.from, toSection: move.to)
            }
        }
        if animation {
            performBatchUpdates(__update, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                performBatchUpdates(__update, completion: completion)
            }
        }
    }
    
    public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ headerViewClass: AnyClass?, forHeaderViewReuseIdentifier identifier: String) {
        register(headerViewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forHeaderViewReuseIdentifier identifier: String) {
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    public func register(_ footerViewClass: AnyClass?, forFooterViewReuseIdentifier identifier: String) {
        register(footerViewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forFooterViewReuseIdentifier identifier: String) {
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func dequeueReusableHeaderView(withIdentifier identifier: String, indexPath: IndexPath) -> UICollectionReusableView {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func dequeueReusableFooterView(withIdentifier identifier: String, indexPath: IndexPath) -> UICollectionReusableView {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath)
    }
    
    public var defaultAnimation: Bool {
        get {
            return Associator.getValue(key: &listViewDefaultAnimationKey, from: self) ?? true
        }
        set {
            Associator.set(value: newValue, key: &listViewDefaultAnimationKey, to: self)
        }
    }
    
    public var defaultItemSize: ListSize {
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
}
