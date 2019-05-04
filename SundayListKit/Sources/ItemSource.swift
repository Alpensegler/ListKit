//
//  ItemSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/8.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

public protocol ItemSource: Source, SourceSnapshot where SubSource == Item, Item == Element {
    associatedtype Element = Self
    func source<List: ListView>(for listView: List) -> Item
}
public protocol ItemData: ItemSource, ListData where ViewModel == Item { }

public extension ItemSource {
    func numbersOfSections() -> Int {
        return 0
    }
    
    func numbersOfItems(in section: Int) -> Int {
        return 1
    }
    
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return source(for: context.listView)
    }
}

public extension ItemSource where SubSource == Self {
    func source<List: ListView>(for listView: List) -> Item {
        return self
    }
}

public extension ItemData {
    func viewModel<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return source(for: context.listView)
    }
}

public extension Source where Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

public extension Source where Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

public extension Source where Snapshot: Identifiable, Snapshot.IdentifiedValue: Equatable, Snapshot: Equatable {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        context.update(from: snapshot)
    }
}

