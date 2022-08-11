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

    func modelContext<List: ListView>(
        for listView: List,
        at indexPath: IndexPath
    ) -> [ListModelContext<List>] {
        _modelContext(for: listView, at: indexPath)
    }

    func modelContext<List: ListView>(
        for listView: List,
        at index: Int
    ) -> [ListModelContext<List>] {
        _modelContext(for: listView, at: .init(item: index))
    }
}
