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
    public typealias Coordinator = CollectionCoordinator
    
    public var defaultAnimation: Bool {
        get { return Associator.getValue(key: &listViewDefaultAnimationKey, from: self) ?? true }
        set { Associator.set(value: newValue, key: &listViewDefaultAnimationKey, to: self) }
    }
    
    public var defaultItemSize: CGSize {
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
    
    public func defaultSupplementraySize(for type: SupplementaryViewType) -> CGSize {
        switch type {
        case .header: return (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        case .footer: return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
        case .custom: return CGSize.zero
        }
    }
    
    public func reloadSynchronously(completion: ((Bool) -> Void)? = nil) {
        reloadData()
        layoutIfNeeded()
        completion?(true)
    }
    
    public func perform(update: () -> Void, animation: Bool, completion: ((Bool) -> Void)? = nil) {
        if animation {
            performBatchUpdates(update, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                performBatchUpdates(update, completion: completion)
            }
        }
    }
    
    public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String) {
        register(nib, forSupplementaryViewOfKind: kind(for: supplementaryViewType), withReuseIdentifier: identifier)
    }
    
    public func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String) {
        register(supplementaryClass, forSupplementaryViewOfKind: kind(for: supplementaryViewType), withReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func dequeueReusableSupplementaryView(type: SupplementaryViewType, withIdentifier identifier: String, indexPath: IndexPath) -> UICollectionReusableView? {
        return dequeueReusableSupplementaryView(ofKind: kind(for: type), withReuseIdentifier: identifier, for: indexPath)
    }
}

private extension UICollectionView {
    func kind(for kind: SupplementaryViewType) -> String {
        switch kind {
        case .header: return UICollectionView.elementKindSectionHeader
        case .footer: return UICollectionView.elementKindSectionFooter
        case .custom(let kind): return kind
        }
    }
}

extension Bool: ListViewAnimationOption {
    public init(animated: Bool) {
        self = animated
    }
}
