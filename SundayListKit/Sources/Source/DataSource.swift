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
    public var isSectioned: Bool {
        return true
    }
    
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
        updateOrAddToContext(contextUpdate: indexPaths.map { index in { $0.insertItem(at: index) } })
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        updateOrAddToContext(contextUpdate: indexPaths.map { index in { $0.deleteItem(at: index) } })
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        updateOrAddToContext(contextUpdate: indexPaths.map { index in { $0.reloadItem(at: index) } })
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        updateOrAddToContext(contextUpdate: [{ $0.moveItem(at: indexPath, to: newIndexPath) }])
    }
    
    func insertSections(_ sections: IndexSet) {
        updateOrAddToContext(contextUpdate: sections.map { index in { $0.insertSection(index) } })
    }
    
    func deleteSections(_ sections: IndexSet) {
        updateOrAddToContext(contextUpdate: sections.map { index in { $0.deleteSection(index) } })
    }
    
    func reloadSections(_ sections: IndexSet) {
        updateOrAddToContext(contextUpdate: sections.map { index in { $0.reloadSection(index) } })
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        updateOrAddToContext(contextUpdate: [{ $0.moveSection(section, toSection: newSection) }])
    }
}



