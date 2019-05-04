//
//  Adapter.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/10.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol Adapter: DataSource {
    //Managing the Selected Cells
    func shouldDeselect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool
    func didSelect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel)
    func shouldSelect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool
    func didDeselect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel)
    
    //Managing Cell Highlighting
    func shouldHighlightViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool
    func didHighlightViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel)
    func didUnhighlightViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel)
    
    //Tracking the Addition and Removal of Views
    func willDisplayViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel, cell: List.Cell)
    func willDisplaySupplementaryView<List: ListView>(context: ListIndexContext<List, Self>, view: List.SupplementaryView, kind: SupplementaryViewType)
    func didEndDisplayingCell<List: ListView>(context: ListIndexContext<List, Self>, cell: List.Cell)
    func didEndDisplayingSupplementaryView<List: ListView>(context: ListIndexContext<List, Self>, view: List.SupplementaryView, kind: SupplementaryViewType)
    
    //Handling Layout Changes
    func targetIndexPathForMoveFrom<List: ListView>(_ originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath, context: ListContext<List, Self>) -> IndexPath
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func shouldSpringLoadViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool
    
    //Getting the Size
    func sizeForViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> ListSize
    func supplementaryViewSize<List: ListView>(type: SupplementaryViewType, for context: ListIndexContext<List, Self>) -> ListSize
}

public extension Adapter {
    //Managing the Selected Cells
    func shouldSelect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool { return true }
    func didSelect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) { }
    func shouldDeselect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool { return true }
    func didDeselect<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) { }
    
    //Managing Cell Highlighting
    func shouldHighlightViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool { return true }
    func didHighlightViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) { }
    func didUnhighlightViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) { }
    
    //Tracking the Addition and Removal of Views
    func willDisplayViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel, cell: List.Cell) { }
    func willDisplaySupplementaryView<List: ListView>(context: ListIndexContext<List, Self>, view: List.SupplementaryView, kind: SupplementaryViewType) { }
    func didEndDisplayingCell<List: ListView>(context: ListIndexContext<List, Self>, cell: List.Cell) { }
    func didEndDisplayingSupplementaryView<List: ListView>(context: ListIndexContext<List, Self>, view: List.SupplementaryView, kind: SupplementaryViewType) { }
    
    //Handling Layout Changes
    func targetIndexPathForMoveFrom<List: ListView>(_ originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath, context: ListContext<List, Self>) -> IndexPath { return proposedIndexPath }
    
    //Controlling the Spring-Loading Behavior
    @available(iOS 11.0, *)
    func shouldSpringLoadViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> Bool { return true }
    
    //Getting the Size
    func sizeForViewModel<List: ListView>(context: ListIndexContext<List, Self>, viewModel: ViewModel) -> ListSize { return context.listView.defaultItemSize  }
    func supplementaryViewSize<List: ListView>(type: SupplementaryViewType, for context: ListIndexContext<List, Self>) -> ListSize { return context.listView.defaultSupplementraySize(for: type) }
}
