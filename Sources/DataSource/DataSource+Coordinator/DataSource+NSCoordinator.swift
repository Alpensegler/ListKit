//
//  DataSource+NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

import Foundation

public extension NSDataSource where SourceBase: NSDataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: NSCoordinator(sourceBase))
    }

    func itemContext<List: ListView>(
        for listView: List,
        at indexPath: IndexPath
    ) -> [ListItemContext<List>] {
        _itemContext(for: listView, at: indexPath)
    }

    func itemContext<List: ListView>(
        for listView: List,
        at index: Int
    ) -> [ListItemContext<List>] {
        _itemContext(for: listView, at: .init(item: index))
    }
}
