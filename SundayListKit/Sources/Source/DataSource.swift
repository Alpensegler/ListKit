//
//  DataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol DataSource: ListData {
    func listSupplementaryView<List: ListView>(for context: ListIndexContext<List, Self>, kind: SupplementaryViewType) -> List.SupplementaryView?
    func title<List: ListView>(for listView: List, supplementaryViewType kind: SupplementaryViewType, section: Int) -> String?
    func canMoveViewModel<List: ListView>(_ viewModel: ViewModel, context: ListIndexContext<List, Self>) -> Bool
    func moveViewModel<List: ListView>(_ viewModel: ViewModel, to context: ListIndexContext<List, Self>)
    func indexTitles<List: ListView>(for context: ListContext<List, Self>) -> [String]?
    func indexPath<List: ListView>(forIndexTitle title: String, context: ListContext<List, Self>, at index: Int) -> IndexPath
    func canEditViewModel<List: ListView>(_ viewModel: ViewModel, context: ListIndexContext<List, Self>) -> Bool
    func commitEdit<List: ListView>(_ editingStyle: UITableViewCell.EditingStyle, context: ListIndexContext<List, Self>, for viewModel: ViewModel)
}

public extension DataSource {
    func listSupplementaryView<List: ListView>(for context: ListIndexContext<List, Self>, kind: SupplementaryViewType) -> List.SupplementaryView? { return nil }
    func title<List: ListView>(for listView: List, supplementaryViewType kind: SupplementaryViewType, section: Int) -> String? { return nil }
    func canMoveViewModel<List: ListView>(_ viewModel: ViewModel, context: ListIndexContext<List, Self>) -> Bool { return true }
    func canEditViewModel<List: ListView>(_ viewModel: ViewModel, context: ListIndexContext<List, Self>) -> Bool { return true }
    func moveViewModel<List: ListView>(_ viewModel: ViewModel, to context: ListIndexContext<List, Self>) { }
    func indexTitles<List: ListView>(for context: ListContext<List, Self>) -> [String]? { return nil }
    func indexPath<List: ListView>(forIndexTitle title: String, context: ListContext<List, Self>, at index: Int) -> IndexPath { return .default }
    func commitEdit<List: ListView>(_ editingStyle: UITableViewCell.EditingStyle, context: ListIndexContext<List, Self>, for viewModel: ViewModel) { }
}

public extension DataSource where Self: CollectionSource, Element: ListData, ViewModel == Element {
    func cellForViewModel<List: ListView>(for context: ListIndexContext<List, Self>, viewModel: ViewModel) -> List.Cell {
        let subcontext = context.subContext
        return viewModel.cellForViewModel(for: subcontext, viewModel: viewModel.viewModel(for: context.subContext))
    }
}
