//
//  TableAdapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/29.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol TableAdapter: TableDataSource, ScrollViewDelegate {
    //Configuring Rows for the Table View
    func tableContext(_ context: TableListContext, willDisplay cell: UITableViewCell, forItem item: Item)
    func tableContext(_ context: TableListContext, indentationLevelForItem item: Item) -> Int
    @available(iOS 11.0, *)
    func tableContext(_ context: TableListContext, shouldSpringLoadItem item: Item, with ineractionContext: UISpringLoadedInteractionContext) -> Bool
    
    //Responding to Row Selections
    func tableContext(_ context: TableListContext, willSelectItem item: Item) -> IndexPath?
    func tableContext(_ context: TableListContext, willDeselectItem item: Item) -> IndexPath?
    func tableContext(_ context: TableListContext, didSelectItem item: Item)
    func tableContext(_ context: TableListContext, didDeselectItem item: Item)
    
    //Providing Custom Header and Footer Views
    func tableContext(_ context: TableListContext, viewForHeaderInSection section: Int) -> UIView?
    func tableContext(_ context: TableListContext, viewForFooterInSection section: Int) -> UIView?
    func tableContext(_ context: TableListContext, willDisplayHeaderView view: UIView, forSection section: Int)
    func tableContext(_ context: TableListContext, willDisplayFooterView view: UIView, forSection section: Int)
    
    //Providing Header, Footer, and Row Heights
    func tableContext(_ context: TableListContext, heightForItem item: Item) -> CGFloat
    func tableContext(_ context: TableListContext, heightForHeaderInSection section: Int) -> CGFloat
    func tableContext(_ context: TableListContext, heightForFooterInSection section: Int) -> CGFloat
    
    //Estimating Heights for the Table's Content
    func tableContext(_ context: TableListContext, estimatedHeightForItem item: Item) -> CGFloat
    func tableContext(_ context: TableListContext, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    func tableContext(_ context: TableListContext, estimatedHeightForFooterInSection section: Int) -> CGFloat

    //Managing Accessory Views
    func tableContext(_ context: TableListContext, accessoryButtonTappedForItem item: Item)

    //Responding to Row Actions
    @available(iOS 11.0, *)
    func tableContext(_ context: TableListContext, leadingSwipeActionsConfigurationForItem item: Item) -> UISwipeActionsConfiguration?
    
    @available(iOS 11.0, *)
    func tableContext(_ context: TableListContext, trailingSwipeActionsConfigurationForItem item: Item) -> UISwipeActionsConfiguration?
    
    #if iOS13
    
    #else
    func tableContext(_ context: TableListContext, shouldShowMenuForItem item: Item) -> Bool
    func tableContext(_ context: TableListContext, canPerformAction action: Selector, forItem item: Item, withSender sender: Any?) -> Bool
    func tableContext(_ context: TableListContext, performAction action: Selector, forItem item: Item, withSender sender: Any?)
    func tableContext(_ context: TableListContext, editActionsForItem item: Item) -> [UITableViewRowAction]?
    #endif
    
    //Managing Table View Highlights
    func tableContext(_ context: TableListContext, shouldHighlightItem item: Item) -> Bool
    func tableContext(_ context: TableListContext, didHighlightItem item: Item)
    func tableContext(_ context: TableListContext, didUnhighlightItem item: Item)

    //Editing Table Rows
    func tableContext(_ context: TableListContext, willBeginEditingItem item: Item)
    func tableContext(_ context: TableListContext, didEndEditingItem item: Item?)
    func tableContext(_ context: TableListContext, editingStyleForItem item: Item) -> UITableViewCell.EditingStyle
    func tableContext(_ context: TableListContext, titleForDeleteConfirmationButtonForItem item: Item) -> String?
    func tableContext(_ context: TableListContext, shouldIndentWhileEditingItem item: Item) -> Bool
    
    //Reordering Table Rows
    func tableContext(_ context: TableListContext, targetIndexPathForMoveFromItem item: Item, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    
    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    
    //Managing Table View Focus
    func tableContext(_ context: TableListContext, canFocusItem item: Item) -> Bool
    func tableContext(_ context: TableListContext, shouldUpdateFocusIn updateContext: UITableViewFocusUpdateContext) -> Bool
    func tableContext(_ context: TableListContext, didUpdateFocusIn updateContext: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    func indexPathForPreferredFocusedView(in context: TableListContext) -> IndexPath?
}

public extension TableAdapter {
    //Configuring Rows for the Table View
    func tableContext(_ context: TableListContext, willDisplay cell: UITableViewCell, forItem item: Item) { }
    func tableContext(_ context: TableListContext, indentationLevelForItem item: Item) -> Int { return 0 }
    @available(iOS 11.0, *)
    func tableContext(_ context: TableListContext, shouldSpringLoadItem item: Item, with ineractionContext: UISpringLoadedInteractionContext) -> Bool { return true }
    
    //Responding to Row Selections
    func tableContext(_ context: TableListContext, willSelectItem item: Item) -> IndexPath? { return context.indexPath }
    func tableContext(_ context: TableListContext, willDeselectItem item: Item) -> IndexPath? { return context.indexPath }
    func tableContext(_ context: TableListContext, didSelectItem item: Item) { }
    func tableContext(_ context: TableListContext, didDeselectItem item: Item) { }
    
    //Providing Custom Header and Footer Views
    func tableContext(_ context: TableListContext, viewForHeaderInSection section: Int) -> UIView? { return nil }
    func tableContext(_ context: TableListContext, viewForFooterInSection section: Int) -> UIView? { return nil }
    func tableContext(_ context: TableListContext, willDisplayHeaderView view: UIView, forSection section: Int) { }
    func tableContext(_ context: TableListContext, willDisplayFooterView view: UIView, forSection section: Int) { }
    
    //Providing Header, Footer, and Row Heights
    func tableContext(_ context: TableListContext, heightForItem item: Item) -> CGFloat { return context.listView.rowHeight }
    func tableContext(_ context: TableListContext, heightForHeaderInSection section: Int) -> CGFloat { return context.listView.sectionHeaderHeight }
    func tableContext(_ context: TableListContext, heightForFooterInSection section: Int) -> CGFloat { return context.listView.sectionFooterHeight }
    
    //Estimating Heights for the Table's Content
    func tableContext(_ context: TableListContext, estimatedHeightForItem item: Item) -> CGFloat { return context.listView.estimatedRowHeight }
    func tableContext(_ context: TableListContext, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return context.listView.estimatedSectionHeaderHeight }
    func tableContext(_ context: TableListContext, estimatedHeightForFooterInSection section: Int) -> CGFloat { return context.listView.estimatedSectionFooterHeight }

    //Managing Accessory Views
    func tableContext(_ context: TableListContext, accessoryButtonTappedForItem item: Item) { }

    //Responding to Row Actions
    @available(iOS 11.0, *)
    func tableContext(_ context: TableListContext, leadingSwipeActionsConfigurationForItem item: Item) -> UISwipeActionsConfiguration? { return nil }
    
    @available(iOS 11.0, *)
    func tableContext(_ context: TableListContext, trailingSwipeActionsConfigurationForItem item: Item) -> UISwipeActionsConfiguration? { return nil }
    
    #if iOS13
    
    #else
    func tableContext(_ context: TableListContext, shouldShowMenuForItem item: Item) -> Bool { return false }
    func tableContext(_ context: TableListContext, canPerformAction action: Selector, forItem item: Item, withSender sender: Any?) -> Bool { return false }
    func tableContext(_ context: TableListContext, performAction action: Selector, forItem item: Item, withSender sender: Any?) { }
    func tableContext(_ context: TableListContext, editActionsForItem item: Item) -> [UITableViewRowAction]? { return nil }
    #endif
    
    //Managing Table View Highlights
    func tableContext(_ context: TableListContext, shouldHighlightItem item: Item) -> Bool { return true }
    func tableContext(_ context: TableListContext, didHighlightItem item: Item) { }
    func tableContext(_ context: TableListContext, didUnhighlightItem item: Item) { }

    //Editing Table Rows
    func tableContext(_ context: TableListContext, willBeginEditingItem item: Item) { }
    func tableContext(_ context: TableListContext, didEndEditingItem item: Item?) { }
    func tableContext(_ context: TableListContext, editingStyleForItem item: Item) -> UITableViewCell.EditingStyle { return context.cell?.editingStyle ?? .none }
    func tableContext(_ context: TableListContext, titleForDeleteConfirmationButtonForItem item: Item) -> String? { return nil }
    func tableContext(_ context: TableListContext, shouldIndentWhileEditingItem item: Item) -> Bool { return true }
    
    //Reordering Table Rows
    func tableContext(_ context: TableListContext, targetIndexPathForMoveFromItem item: Item, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath { return proposedDestinationIndexPath }
    
    //Tracking the Removal of Views
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
    
    //Managing Table View Focus
    func tableContext(_ context: TableListContext, canFocusItem item: Item) -> Bool { return true }
    func tableContext(_ context: TableListContext, shouldUpdateFocusIn updateContext: UITableViewFocusUpdateContext) -> Bool { return false }
    func tableContext(_ context: TableListContext, didUpdateFocusIn updateContext: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) { }
    func indexPathForPreferredFocusedView(in context: TableListContext) -> IndexPath? { return nil }
}

public extension TableAdapter where SubSource: Collection, SubSource.Element: TableAdapter, Item == SubSource.Element.Item {
    //Configuring Rows for the Table View
    func tableContext(_ context: TableListContext, willDisplay cell: UITableViewCell, forItem item: Item) { context.elementWillDisplay(cell: cell) }
    
    //Responding to Row Selections
    func tableContext(_ context: TableListContext, willSelectItem item: Item) -> IndexPath? { return context.elementWillSelectItem() }
    func tableContext(_ context: TableListContext, willDeselectItem item: Item) -> IndexPath? { return context.elementWillDeselectItem() }
    func tableContext(_ context: TableListContext, didSelectItem item: Item) { context.elementDidSelectItem() }
    func tableContext(_ context: TableListContext, didDeselectItem item: Item) { context.elementDidDeselectItem() }
    
    //Providing Custom Header and Footer Views
    func tableContext(_ context: TableListContext, viewForHeaderInSection section: Int) -> UIView? { return context.elementViewForHeaderInSection() }
    func tableContext(_ context: TableListContext, viewForFooterInSection section: Int) -> UIView? { return context.elementViewForFooterInSection() }
    func tableContext(_ context: TableListContext, willDisplayHeaderView view: UIView, forSection section: Int) { context.elementWillDisplayHeaderView(view: view) }
    func tableContext(_ context: TableListContext, willDisplayFooterView view: UIView, forSection section: Int) { context.elementWillDisplayFooterView(view: view) }
    
    //Providing Header, Footer, and Row Heights
    func tableContext(_ context: TableListContext, heightForItem item: Item) -> CGFloat { return context.elementHeightForItem() }
    func tableContext(_ context: TableListContext, heightForHeaderInSection section: Int) -> CGFloat { return context.elementHeightForHeader() }
    func tableContext(_ context: TableListContext, heightForFooterInSection section: Int) -> CGFloat { return context.elementHeightForFooter() }
    
    //Estimating Heights for the Table's Content
    func tableContext(_ context: TableListContext, estimatedHeightForItem item: Item) -> CGFloat { return context.elementEstimatedHeightForItem() }
    func tableContext(_ context: TableListContext, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return context.elementEstimatedHeightForHeaderInSection(section) }
    func tableContext(_ context: TableListContext, estimatedHeightForFooterInSection section: Int) -> CGFloat { return context.elementEstimatedHeightForFooterInSection(section) }
    
    //Managing Table View Highlights
    func tableContext(_ context: TableListContext, shouldHighlightItem item: Item) -> Bool { return context.elementShouldHighlightItem() }
    func tableContext(_ context: TableListContext, didHighlightItem item: Item) { context.elementDidHighlightItem() }
    func tableContext(_ context: TableListContext, didUnhighlightItem item: Item) { context.elementDidUnhighlightItem() }
}

public extension TableContext where SubSource: Collection, SubSource.Element: TableAdapter, Item == SubSource.Element.Item  {
    //Configuring Rows for the Table View
    func elementWillDisplay(cell: UITableViewCell) {
        element.tableContext(elementsContext(), willDisplay: cell, forItem: elementsItem)
    }
    
    //Responding to Row Selections
    func elementWillSelectItem() -> IndexPath? {
        let context = elementsContext()
        return element.tableContext(context, willSelectItem: elementsItem)?.addingOffset(context.offset)
    }
    
    func elementWillDeselectItem() -> IndexPath? {
        let context = elementsContext()
        return element.tableContext(context, willDeselectItem: elementsItem)?.addingOffset(context.offset)
    }
    
    func elementDidSelectItem() {
        element.tableContext(elementsContext(), didSelectItem: elementsItem)
    }
    
    func elementDidDeselectItem() {
        element.tableContext(elementsContext(), didDeselectItem: elementsItem)
    }
    
    //Providing Custom Header and Footer Views
    func elementViewForHeaderInSection() -> UIView? {
        let context = elementsContext()
        return element.tableContext(context, viewForHeaderInSection: context.section)
    }
    
    func elementViewForFooterInSection() -> UIView? {
        let context = elementsContext()
        return element.tableContext(context, viewForFooterInSection: context.section)
    }
    
    func elementWillDisplayHeaderView(view: UIView) {
        let context = elementsContext()
        element.tableContext(context, willDisplayHeaderView: view, forSection: context.section)
    }
    
    func elementWillDisplayFooterView(view: UIView) {
        let context = elementsContext()
        element.tableContext(context, willDisplayFooterView: view, forSection: context.section)
    }
    
    //Providing Header, Footer, and Row Heights
    func elementHeightForItem() -> CGFloat {
        return element.tableContext(elementsContext(), heightForItem: elementsItem)
    }
    
    func elementHeightForHeader() -> CGFloat {
        let context = elementsContext()
        return element.tableContext(context, heightForHeaderInSection: context.section)
    }
    
    func elementHeightForFooter() -> CGFloat {
        let context = elementsContext()
        return element.tableContext(context, heightForFooterInSection: context.section)
    }
    
    //Estimating Heights for the Table's Content
    func elementEstimatedHeightForItem() -> CGFloat {
        return element.tableContext(elementsContext(), estimatedHeightForItem: elementsItem)
    }
    
    func elementEstimatedHeightForHeaderInSection(_ section: Int) -> CGFloat {
        let context = elementsContext()
        return element.tableContext(context, estimatedHeightForHeaderInSection: context.section)
    }
    
    func elementEstimatedHeightForFooterInSection(_ section: Int) -> CGFloat {
        let context = elementsContext()
        return element.tableContext(context, estimatedHeightForFooterInSection: context.section)
    }
    
    //Managing Table View Highlights
    func elementShouldHighlightItem() -> Bool {
        return element.tableContext(elementsContext(), shouldHighlightItem: elementsItem)
    }
    
    func elementDidHighlightItem() {
        element.tableContext(elementsContext(), didHighlightItem: elementsItem)
    }
    
    func elementDidUnhighlightItem() {
        element.tableContext(elementsContext(), didUnhighlightItem: elementsItem)
    }
}
