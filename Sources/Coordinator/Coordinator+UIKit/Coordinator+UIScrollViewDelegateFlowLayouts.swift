//
//  Coordinator+UIScrollViewDelegateFlowLayout.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(iOS) || os(tvOS)
import UIKit

class UICollectionViewDelegateFlowLayouts {
    typealias Delegate<Input, Output> = ListKit.Delegate<UICollectionView, Input, Output>
    
    //Getting the Size of Items
    var layoutSizeForItemAt = Delegate<(UICollectionViewLayout, IndexPath), CGSize>(
        index: .indexPath(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))
    )
    
    //Getting the Section Spacing
    var layoutInsetForSectionAt = Delegate<(UICollectionViewLayout, Int), UIEdgeInsets>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))
    )
    
    var layoutMinimumLineSpacingForSectionAt = Delegate<(UICollectionViewLayout, Int), CGFloat>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:))
    )
    
    var layoutMinimumInteritemSpacingForSectionAt = Delegate<(UICollectionViewLayout, Int), CGFloat>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))
    )
    
    //Getting the Header and Footer Sizes
    var layoutReferenceSizeForHeaderInSection = Delegate<(UICollectionViewLayout, Int), CGSize>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))
    )
    
    var layoutReferenceSizeForFooterInSection = Delegate<(UICollectionViewLayout, Int), CGSize>(
        index: .index(\.1),
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))
    )
    
    func add(by selectorSets: inout SelectorSets) {
        //Getting the Size of Items
        selectorSets.add(layoutSizeForItemAt)
        
        //Getting the Section Spacing
        selectorSets.add(layoutInsetForSectionAt)
        selectorSets.add(layoutMinimumLineSpacingForSectionAt)
        selectorSets.add(layoutMinimumInteritemSpacingForSectionAt)
        
        //Getting the Header and Footer Sizes
        selectorSets.add(layoutReferenceSizeForHeaderInSection)
        selectorSets.add(layoutReferenceSizeForFooterInSection)
    }
}

extension BaseCoordinator: UICollectionViewDelegateFlowLayout { }

public extension BaseCoordinator {
    //Getting the Size of Items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        apply(\.collectionViewDelegateFlowLayouts.layoutSizeForItemAt, object: collectionView, with: (collectionViewLayout, indexPath))
    }

    //Getting the Section Spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        apply(\.collectionViewDelegateFlowLayouts.layoutInsetForSectionAt, object: collectionView, with: (collectionViewLayout, section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        apply(\.collectionViewDelegateFlowLayouts.layoutMinimumLineSpacingForSectionAt, object: collectionView, with: (collectionViewLayout, section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        apply(\.collectionViewDelegateFlowLayouts.layoutMinimumInteritemSpacingForSectionAt, object: collectionView, with: (collectionViewLayout, section))
    }

    //Getting the Header and Footer Sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        apply(\.collectionViewDelegateFlowLayouts.layoutReferenceSizeForHeaderInSection, object: collectionView, with: (collectionViewLayout, section))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        apply(\.collectionViewDelegateFlowLayouts.layoutReferenceSizeForFooterInSection, object: collectionView, with: (collectionViewLayout, section))
    }
}

#endif
