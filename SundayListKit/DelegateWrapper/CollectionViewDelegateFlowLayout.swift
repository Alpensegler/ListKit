//
//  CollectionViewDelegateFlowLayout.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/31.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class UICollectionViewDelegateFlowLayoutWrapper: UICollectionDelegateWrapper, UICollectionViewDelegateFlowLayout {
    let collectionViewLayoutSizeForItemAtBlock: (UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize
    let collectionViewLayoutInsetForSectionAtBlock: (UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets
    let collectionViewLayoutMinimumLineSpacingForSectionAt: (UICollectionView, UICollectionViewLayout, Int) -> CGFloat
    let collectionViewLayoutMinimumInteritemSpacingForSectionAt: (UICollectionView, UICollectionViewLayout, Int) -> CGFloat
    let collectionViewLayoutReferenceSizeForHeaderInSection: (UICollectionView, UICollectionViewLayout, Int) -> CGSize
    let collectionViewLayoutReferenceSizeForFooterInSection: (UICollectionView, UICollectionViewLayout, Int) -> CGSize
    
    init(_ delegate: CollectionViewDelegateFlowLayout) {
        collectionViewLayoutSizeForItemAtBlock = { [unowned delegate] in delegate.collectionView($0, layout: $1, sizeForItemAt: $2) }
        collectionViewLayoutInsetForSectionAtBlock = { [unowned delegate] in delegate.collectionView($0, layout: $1, insetForSectionAt: $2) }
        collectionViewLayoutMinimumLineSpacingForSectionAt = { [unowned delegate] in delegate.collectionView($0, layout: $1, minimumLineSpacingForSectionAt: $2) }
        collectionViewLayoutMinimumInteritemSpacingForSectionAt = { [unowned delegate] in delegate.collectionView($0, layout: $1, minimumInteritemSpacingForSectionAt: $2) }
        collectionViewLayoutReferenceSizeForHeaderInSection = { [unowned delegate] in delegate.collectionView($0, layout: $1, referenceSizeForHeaderInSection: $2) }
        collectionViewLayoutReferenceSizeForFooterInSection = { [unowned delegate] in delegate.collectionView($0, layout: $1, referenceSizeForFooterInSection: $2) }
        super.init(delegate)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewLayoutSizeForItemAtBlock(collectionView, collectionViewLayout, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionViewLayoutInsetForSectionAtBlock(collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewLayoutMinimumLineSpacingForSectionAt(collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewLayoutMinimumInteritemSpacingForSectionAt(collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return collectionViewLayoutReferenceSizeForHeaderInSection(collectionView, collectionViewLayout, section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return collectionViewLayoutReferenceSizeForFooterInSection(collectionView, collectionViewLayout, section)
    }
}

public protocol CollectionViewDelegateFlowLayout: CollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
}

private var collectionViewDelegateFlowLayoutKey: Void?

public extension CollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero  }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { return (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { return (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero }
    
    var asCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
        return Associator.getValue(key: &collectionViewDelegateFlowLayoutKey, from: self, initialValue: UICollectionViewDelegateFlowLayoutWrapper(self))
    }
    
    var asCollectionViewDelegate: UICollectionViewDelegate {
        return asCollectionViewDelegateFlowLayout
    }
    
    var asScrollViewDelegate: UIScrollViewDelegate {
        return asCollectionViewDelegate
    }
}
