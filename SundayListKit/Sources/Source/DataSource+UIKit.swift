//
//  DataSource+UIKit.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

public extension DataSource where Self: CollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return listSupplementaryView(for: self[collectionView, indexPath], kind: SupplementaryViewType(kind)) ?? .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let context = self[collectionView, indexPath]
        return canMoveViewModel(viewModel(for: context), context: context)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveViewModel(viewModel(for: (self[collectionView, sourceIndexPath])), to: self[collectionView, destinationIndexPath])
    }
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return indexTitles(for: self[collectionView])
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        return indexPath(forIndexTitle: title, context: self[collectionView], at: index)
    }
}

public extension DataSource where Self: TableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return title(for: tableView, supplementaryViewType: .header, section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return title(for: tableView, supplementaryViewType: .footer, section: section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let context = self[tableView, indexPath]
        return canEditViewModel(viewModel(for: context), context: context)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let context = self[tableView, indexPath]
        return canMoveViewModel(viewModel(for: context), context: context)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexTitles(for: self[tableView])
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return indexPath(forIndexTitle: title, context: self[tableView], at: index).item
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = self[tableView, indexPath]
        commitEdit(editingStyle, context: context, for: viewModel(for: context))
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveViewModel(viewModel(for: (self[tableView, sourceIndexPath])), to: self[tableView, destinationIndexPath])
    }
}

public extension DataSource where Self: TableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return listSupplementaryView(for: self[tableView, IndexPath(section: section)], kind: .header)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return listSupplementaryView(for: self[tableView, IndexPath(section: section)], kind: .footer)
    }
}
