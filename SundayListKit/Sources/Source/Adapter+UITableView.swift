//
//  Adapter+UITableView.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Adapter where Self: TableViewDelegate {
    //Configuring Rows for the Table View
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let context = self[tableView, indexPath]
        willDisplayViewModel(context: context, viewModel: viewModel(for: context), cell: cell)
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        let context = self[tableView, indexPath]
        return shouldSpringLoadViewModel(context: context, viewModel: viewModel(for: context))
    }
    
    //Responding to Row Selections
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let context = self[tableView, indexPath]
        return shouldSelect(context: context, viewModel: viewModel(for: context)) ? indexPath : nil
    }
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let context = self[tableView, indexPath]
        return shouldDeselect(context: context, viewModel: viewModel(for: context)) ? indexPath : nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let context = self[tableView, indexPath]
        didSelect(context: context, viewModel: viewModel(for: context))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let context = self[tableView, indexPath]
        didDeselect(context: context, viewModel: viewModel(for: context))
    }
    
    //Providing Custom Header and Footer Views
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        willDisplaySupplementaryView(context: self[tableView, IndexPath(section: section)], view: view, kind: .header)
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        willDisplaySupplementaryView(context: self[tableView, IndexPath(section: section)], view: view, kind: .footer)
    }
    
    //Providing Header, Footer, and Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let context = self[tableView, indexPath]
        return sizeForViewModel(context: context, viewModel: viewModel(for: context)).height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return supplementaryViewSize(type: .header, for: self[tableView, IndexPath(section: section)]).height
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return supplementaryViewSize(type: .footer, for: self[tableView, IndexPath(section: section)]).height
    }
    
    //Managing Table View Highlights
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let context = self[tableView, indexPath]
        return shouldHighlightViewModel(context: context, viewModel: viewModel(for: context))
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let context = self[tableView, indexPath]
        didHighlightViewModel(context: context, viewModel: viewModel(for: context))
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let context = self[tableView, indexPath]
        didUnhighlightViewModel(context: context, viewModel: viewModel(for: context))
    }
    
    //Reordering Table Rows
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return targetIndexPathForMoveFrom(sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath, context: self[tableView])
    }
    
    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        didEndDisplayingCell(context: self[tableView, indexPath], cell: cell)
    }
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        didEndDisplayingSupplementaryView(context: self[tableView, IndexPath(section: section)], view: view, kind: .header)
    }
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        didEndDisplayingSupplementaryView(context: self[tableView, IndexPath(section: section)], view: view, kind: .header)
    }
}
