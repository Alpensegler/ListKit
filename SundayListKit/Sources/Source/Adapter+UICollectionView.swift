//
//  Adapter+UICollectionView.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

public extension Adapter where Self: CollectionViewDelegate {
    //Managing the Selected Cells
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let context = self[collectionView, indexPath]
        return shouldSelect(context: context, viewModel: viewModel(for: context))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let context = self[collectionView, indexPath]
        didSelect(context: context, viewModel: viewModel(for: context))
    }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let context = self[collectionView, indexPath]
        return shouldDeselect(context: context, viewModel: viewModel(for: context))
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let context = self[collectionView, indexPath]
        didDeselect(context: context, viewModel: viewModel(for: context))
    }
    
    //Managing Cell Highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let context = self[collectionView, indexPath]
        return shouldHighlightViewModel(context: context, viewModel: viewModel(for: context))
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let context = self[collectionView, indexPath]
        didHighlightViewModel(context: context, viewModel: viewModel(for: context))
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let context = self[collectionView, indexPath]
        didUnhighlightViewModel(context: context, viewModel: viewModel(for: context))
    }
    
    //Tracking the Addition and Removal of Views
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let context = self[collectionView, indexPath]
        willDisplayViewModel(context: context, viewModel: viewModel(for: context), cell: cell)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        willDisplaySupplementaryView(context: self[collectionView, indexPath], view: view, kind: .init(elementKind))
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        didEndDisplayingCell(context: self[collectionView, indexPath], cell: cell)
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        didEndDisplayingSupplementaryView(context: self[collectionView, indexPath], view: view, kind: .init(elementKind))
    }
    
    //Handling Layout Changes
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        targetIndexPathForMoveFrom(originalIndexPath, toProposedIndexPath: proposedIndexPath, context: self[collectionView])
    }
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        let context = self[collectionView, indexPath]
        return shouldSpringLoadViewModel(context: context, viewModel: viewModel(for: context))
    }
}

public extension Adapter where Self: CollectionViewDelegateFlowLayout {
    //Getting the Size of Items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let context = self[collectionView, indexPath]
        return sizeForViewModel(context: context, viewModel: viewModel(for: context)).size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return supplementaryViewSize(type: .header, for: self[collectionView, IndexPath(section: section)]).size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return supplementaryViewSize(type: .footer, for: self[collectionView, IndexPath(section: section)]).size
    }
}
