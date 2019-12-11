//
//  ListView+UIcollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/4/6.
//

#if os(iOS) || os(tvOS)
import UIKit

public typealias CollectionView = UICollectionView

extension UICollectionView: UIListView {
    public typealias Cell = UICollectionViewCell
    public typealias Animation = Bool
    public typealias Size = CGSize
}

public extension UICollectionView {
    var defaultAnimation: Bool {
        get { return Associator.getValue(key: &Self.listViewDefaultAnimationKey, from: self) ?? true }
        set { Associator.set(value: newValue, key: &Self.listViewDefaultAnimationKey, to: self) }
    }
    
    func reloadSynchronously(completion: ((Bool) -> Void)? = nil) {
        reloadData()
        layoutIfNeeded()
        completion?(true)
    }
    
    func perform(update: () -> Void, animation: Bool, completion: ((Bool) -> Void)? = nil) {
        if animation {
            performBatchUpdates(update, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                performBatchUpdates(update, completion: completion)
            }
        }
    }
    
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func register(supplementaryViewType: SupplementaryViewType, _ nib: UINib?, identifier: String) {
        register(nib, forSupplementaryViewOfKind: kind(for: supplementaryViewType), withReuseIdentifier: identifier)
    }
    
    func register(supplementaryViewType: SupplementaryViewType, _ supplementaryClass: AnyClass?, identifier: String) {
        register(supplementaryClass, forSupplementaryViewOfKind: kind(for: supplementaryViewType), withReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
}

public extension UICollectionView {
    enum SupplementaryViewType: Hashable {
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
}

extension UICollectionView {
    static var listViewDefaultAnimationKey: Void?
    
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

#endif
