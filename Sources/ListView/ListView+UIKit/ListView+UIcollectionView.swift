//
//  ListView+UIcollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/4/6.
//

#if !os(macOS)
import UIKit

public typealias CollectionView = UICollectionView

extension UICollectionView: UIListView, SetuptableListView {
    public typealias Cell = UICollectionViewCell
    public typealias Animation = Bool

    func setup(with listDelegate: Delegate) {
        dataSource = listDelegate
        delegate = listDelegate
    }

    func isDelegate(_ listDelegate: Delegate) -> Bool {
        dataSource === listDelegate && delegate === listDelegate
    }
}

public extension UICollectionView {
    var defaultAnimation: Bool {
        get { Associator.getValue(key: &Self.listViewDefaultAnimationKey, from: self) ?? true }
        set { Associator.set(value: newValue, key: &Self.listViewDefaultAnimationKey, to: self) }
    }

    func adapted<Adapter: ListAdapter>(
        by listAdapter: Adapter,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) where Adapter.View: UICollectionView {
        listDelegate.setCoordinator(
            context: listAdapter.listCoordinatorContext,
            animated: animated,
            completion: completion
        )
    }

    func resetDelegates(toNil: Bool) {
        let temp = (dataSource, delegate)
        (dataSource, delegate) = (nil, nil)
        if toNil { return }
        (dataSource, delegate) = temp
    }

    func reloadSynchronously(animated: Bool = true) {
        if animated {
            reloadData()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            reloadData()
            CATransaction.commit()
        }
        if window != nil {
            layoutIfNeeded()
        }
    }

    func perform(_ update: () -> Void, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if animated {
            performBatchUpdates(update, completion: completion)
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            performBatchUpdates(update, completion: completion)
            CATransaction.commit()
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
    enum SupplementaryViewType: Hashable, RawRepresentable {
        case header
        case footer
        case custom(String)

        public init(rawValue: String) {
            switch rawValue {
            case UICollectionView.elementKindSectionHeader: self = .header
            case UICollectionView.elementKindSectionFooter: self = .footer
            default: self = .custom(rawValue)
            }
        }

        public var rawValue: String {
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
