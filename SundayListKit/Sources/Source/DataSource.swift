//
//  DataSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol DataSource: Source {
    func item(at indexPath: IndexPath) -> Item
    func numbersOfSections() -> Int
    func numbersOfItems(in section: Int) -> Int
}

public struct DataSourceSnapshot {
    let indices: [Int]
    
    public init<Value: DataSource>(_ source: Value) {
        indices = (0..<source.numbersOfSections()).map { source.numbersOfItems(in: $0) }
    }
}

extension DataSourceSnapshot: SnapshotType {
    public func numbersOfSections() -> Int {
        return indices.count
    }
    
    public func numbersOfItems(in section: Int) -> Int {
        return indices[safe: section] ?? 0
    }
}

public extension DataSource {
    var source: Void {
        return ()
    }
    
    func numbersOfSections() -> Int {
        return 1
    }
    
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return item(at: indexPath)
    }
    
    func createSnapshot(with source: Void) -> DataSourceSnapshot {
        return .init(self)
    }
    
    func update(context: UpdateContext<SourceSnapshot>) {
        context.reloadCurrent()
    }
}

public extension DataSource where Self: ListUpdatable {
    func insertItems(at indexPaths: [IndexPath]) {
        listUpdater.insertItems(at: indexPaths)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        listUpdater.deleteItems(at: indexPaths)
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        listUpdater.reloadItems(at: indexPaths)
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        listUpdater.moveItem(at: indexPath, to: newIndexPath)
    }
    
    func insertSections(_ sections: IndexSet) {
        listUpdater.insertSections(sections)
    }
    
    func deleteSections(_ sections: IndexSet) {
        listUpdater.deleteSections(sections)
    }
    
    func reloadSections(_ sections: IndexSet) {
        listUpdater.reloadSections(sections)
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        listUpdater.moveSection(section, toSection: newSection)
    }
    
    func startUpdate() {
        listUpdater.startUpdate()
    }
    
    func endUpdate() {
        listUpdater.endUpdate()
    }
}



