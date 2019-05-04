//
//  NeverSubSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol NeverSubSource: MultiSectionSource, SourceSnapshot where SubSource == Never {
    func item(at indexPath: IndexPath) -> Item
}

public protocol NeverSubDataSource: NeverSubSource, DataSource where ViewModel == Item { }

public extension NeverSubSource {
    func item<List: ListView>(for context: ListIndexContext<List, Self>) -> Item {
        return item(at: context.indexPath)
    }
    
    func source<List: ListView>(for listView: List) -> Never {
        fatalError("unimplemented")
    }
    
    func numbersOfSections() -> Int {
        return 1
    }
}

public extension NeverSubDataSource {
    func viewModel<List: ListView>(for context: ListIndexContext<List, Self>) -> ViewModel {
        return item(for: context)
    }
}

public extension NeverSubSource where Snapshot: AnyObject {
    func update<List: ListView>(from snapshot: Snapshot, to context: ListContext<List, Self>) {
        if snapshot !== context.snapshot {
            context.reloadCurrentContext()
        }
    }
}

