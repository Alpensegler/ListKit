//
//  ListViewUpdateContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/23.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ListUpdatable {
    var listViewUpdateContext: ListUpdateContext { get }
}

private var listViewUpdatableUpdateContextKey: Void?

public extension ListUpdatable where Self: AnyObject {
    var listViewUpdateContext: ListUpdateContext {
        return Associator.getValue(key: &listViewUpdatableUpdateContextKey, from: self, initialValue: .init())
    }
}

public class ListUpdateContext {
    var isUpdating = false
    var updates = [() -> Void]()
    var insertItemsBlocks = [([IndexPath]) -> Void]()
    var deleteItemsBlocks = [([IndexPath]) -> Void]()
    var reloadItemsBlocks = [([IndexPath]) -> Void]()
    var moveItemBlocks = [(IndexPath, IndexPath) -> Void]()
    
    var insertSectionsBlocks = [(IndexSet) -> Void]()
    var deleteSectionsBlocks = [(IndexSet) -> Void]()
    var reloadSectionsBlocks = [(IndexSet) -> Void]()
    var moveSectionBlocks = [(Int, Int) -> Void]()
    var reloadContextBlocks = [() -> Void]()
    var indexForListView = [(AnyObject) -> Int?]()
    
    public init() { }
    
    init(updating: Bool) {
        self.isUpdating = updating
    }
    
    func addListView<List: ListView>(listView: List, offset: IndexPath, sectionCount: Int, cellCount: Int) {
        let index = indexForListView.lazy.compactMap { $0(listView) }.first
        if index == nil {
            let count = indexForListView.count
            indexForListView.append { [weak listView] in $0 === listView ? count : nil }
        }
        updateBlocks(at: index, &insertItemsBlocks, with: { [weak listView] in listView?.insertItems(at: $0.map { $0.addingOffset(offset) }) })
        updateBlocks(at: index, &deleteItemsBlocks, with: { [weak listView] in listView?.deleteItems(at: $0.map { $0.addingOffset(offset) }) })
        updateBlocks(at: index, &reloadItemsBlocks, with: { [weak listView] in listView?.reloadItems(at: $0.map { $0.addingOffset(offset) }) })
        updateBlocks(at: index, &moveItemBlocks, with: { [weak listView] in listView?.moveItem(at: $0.addingOffset(offset), to: $1.addingOffset(offset)) })
        updateBlocks(at: index, &insertSectionsBlocks, with: { [weak listView] in listView?.insertSections(IndexSet($0.map { $0 + offset.section })) })
        updateBlocks(at: index, &deleteSectionsBlocks, with: { [weak listView] in listView?.deleteSections(IndexSet($0.map { $0 + offset.section })) })
        updateBlocks(at: index, &reloadSectionsBlocks, with: { [weak listView] in listView?.reloadSections(IndexSet($0.map { $0 + offset.section })) })
        updateBlocks(at: index, &moveSectionBlocks, with: { [weak listView] in listView?.moveSection($0 + offset.section, toSection: $1 + offset.section) })
        updateBlocks(at: index, &reloadContextBlocks, with: { [weak listView] in
            if sectionCount > 0 {
                listView?.reloadSections(IndexSet(offset.section..<sectionCount + offset.section))
            } else {
                listView?.reloadItems(at: (0..<cellCount).map { IndexPath(item: $0 + offset.item, section: offset.section) })
            }
        })
    }
}

public extension ListUpdateContext {
    
    func startUpdate() {
        isUpdating = true
    }
    
    func endUpdate(completion: ((Bool) -> Void)? = nil) {
        updates.forEach { $0() }
        isUpdating = false
    }
    
    func reloadCurrentContext() {
        reloadContextBlocks.forEach { $0() }
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        waitOrUpdateImmediatly { [insertItemsBlocks] in insertItemsBlocks.forEach { $0(indexPaths) } }
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        waitOrUpdateImmediatly { [deleteItemsBlocks] in deleteItemsBlocks.forEach { $0(indexPaths) } }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        waitOrUpdateImmediatly { [reloadItemsBlocks] in reloadItemsBlocks.forEach { $0(indexPaths) } }
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        waitOrUpdateImmediatly { [moveItemBlocks] in moveItemBlocks.forEach { $0(indexPath, newIndexPath) } }
    }
    
    func insertSections(_ sections: IndexSet) {
        waitOrUpdateImmediatly { [insertSectionsBlocks] in insertSectionsBlocks.forEach { $0(sections) } }
    }
    
    func deleteSections(_ sections: IndexSet) {
        waitOrUpdateImmediatly { [deleteSectionsBlocks] in deleteSectionsBlocks.forEach { $0(sections) } }
    }
    
    func reloadSections(_ sections: IndexSet) {
        waitOrUpdateImmediatly { [reloadSectionsBlocks] in reloadSectionsBlocks.forEach { $0(sections) } }
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        waitOrUpdateImmediatly { [moveSectionBlocks] in moveSectionBlocks.forEach { $0(section, newSection) } }
    }
}

private extension ListUpdateContext {
    func waitOrUpdateImmediatly(_ block: @escaping () -> Void) {
        if isUpdating {
            updates.append(block)
        } else {
            block()
        }
    }
    
    func updateBlocks<T>(at index: Int?, _ blocks: inout [T], with item: T) {
        if let index = index {
            blocks[index] = item
        } else {
            blocks.append(item)
        }
    }
}
