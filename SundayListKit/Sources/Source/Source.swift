//
//  Source.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol Source {
    associatedtype Item
    associatedtype SubSource = [Item]
    associatedtype Snapshot: SourceSnapshot = SectionSnapshot<Self, Item>
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item
    func source<List: ListView>(for listView: List) -> SubSource
    func snapshot<List: ListView>(for listView: List) -> Snapshot
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>)
}

public protocol ListData: Source {
    associatedtype ViewModel = Item
    
    func viewModel<List: ListView>(for context: ListIndexContext<List, Self>) -> ViewModel
    func cellForViewModel<List: ListView>(for context: ListIndexContext<List, Self>, viewModel: ViewModel) -> List.Cell
}

public protocol MultiSectionSource: Source { }

public protocol SourceSnapshot {
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
}

public extension Source where Self: SourceSnapshot {
    func snapshot<List: ListView>(for listView: List) -> Self {
        return self
    }
}
