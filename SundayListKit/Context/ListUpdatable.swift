//
//  ListViewUpdateContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/23.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol Updatable {
    func addListViewToUpdater<List: ListView>(listView: List)
    func addListViewToUpdater<List: ListView>(listView: List, offset: IndexPath, sectionCount: Int, cellCount: Int)
    func performUpdate<List: ListView>(_ listView: List, animation: List.Animation, completion: ((Bool) -> Void)?)
}

public protocol Updater {
    associatedtype Value
    var updaters: [ListUpdater<Value>] { get }
}

public protocol ListUpdatable: Updatable, Updater, Source where Value == Self {
    var listsUpdater: ListsUpdater<Self> { get }
    func performUpdate(animated: Bool, completion: ((Bool) -> Void)?)
}

public extension ListUpdatable {
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        listsUpdater.updateList(animated: animated, completion: completion)
    }
    
    func performUpdate<List: ListView>(
        _ listView: List,
        animation: List.Animation = .init(animated: true),
        completion: ((Bool) -> Void)? = nil
    ) {
        let currentSnapshot = snapshot(for: listView)
        if didLoad(listView: listView) {
            let sourceSnapshot = self[snapshot: listView]
            self[snapshot: listView] = currentSnapshot
            listView.perform(update: {
                update(from: sourceSnapshot, to: .init(listView: listView, snapshot: currentSnapshot))
            }, animation: animation, completion: completion)
        } else {
            self[snapshot: listView] = currentSnapshot
            listView.reloadSynchronously()
        }
    }
    
    func performReload<List: ListView>(
        _ listView: List,
        animation: List.Animation = .init(animated: true),
        completion: ((Bool) -> Void)? = nil
    ) {
        let currentSnapshot = snapshot(for: listView)
        self[snapshot: listView] = currentSnapshot
        listView.reloadSynchronously()
    }
}

public extension ListUpdatable {
    var updaters: [ListUpdater<Value>] {
        return listsUpdater.updaters
    }
        
    func addListViewToUpdater<List: ListView>(listView: List, offset: IndexPath, sectionCount: Int, cellCount: Int) {
        listsUpdater.addListView(listView: listView, offset: offset, sectionCount: sectionCount, cellCount: cellCount)
    }
    
    func addListViewToUpdater<List: ListView>(listView: List) {
        listsUpdater.addListView(listView: listView)
    }
}

public final class ListUpdater<Value>: Updater {
    public var updaters: [ListUpdater<Value>] { return [self] }
    
    var isUpdating = false
    var updates = [() -> Void]()
    
    let insertItemsBlock: ([IndexPath]) -> Void
    let deleteItemsBlock: ([IndexPath]) -> Void
    let reloadItemsBlock: ([IndexPath]) -> Void
    let moveItemBlock: (IndexPath, IndexPath) -> Void
    
    let insertSectionsBlock: (IndexSet) -> Void
    let deleteSectionsBlock: (IndexSet) -> Void
    let reloadSectionsBlock: (IndexSet) -> Void
    let moveSectionBlock: (Int, Int) -> Void
    
    let reloadContextBlock: () -> Void
    
    let update: (Bool, ((Bool) -> Void)?) -> Void
    
    var isListView: (AnyObject) -> Bool
    
    init<List: ListView>(listView: List, offset: IndexPath, sectionCount: Int, cellCount: Int) {
        isListView = { [weak listView] in $0 === listView }
        update = { [weak listView] in listView?.performUpdate(animation: .init(animated: $0), completion: $1) }
        insertItemsBlock = { [weak listView] in listView?.insertItems(at: $0.map { $0.addingOffset(offset) }) }
        deleteItemsBlock = { [weak listView] in listView?.deleteItems(at: $0.map { $0.addingOffset(offset) }) }
        reloadItemsBlock = { [weak listView] in listView?.reloadItems(at: $0.map { $0.addingOffset(offset) }) }
        moveItemBlock = { [weak listView] in listView?.moveItem(at: $0.addingOffset(offset), to: $1.addingOffset(offset)) }
        insertSectionsBlock = { [weak listView] in listView?.insertSections(IndexSet($0.map { $0 + offset.section })) }
        deleteSectionsBlock = { [weak listView] in listView?.deleteSections(IndexSet($0.map { $0 + offset.section })) }
        reloadSectionsBlock = { [weak listView] in listView?.reloadSections(IndexSet($0.map { $0 + offset.section })) }
        moveSectionBlock = { [weak listView] in listView?.moveSection($0 + offset.section, toSection: $1 + offset.section) }
        reloadContextBlock = { [weak listView] in
            if sectionCount > 0 {
                listView?.reloadSections(IndexSet(offset.section..<sectionCount + offset.section))
            } else {
                listView?.reloadItems(at: (0..<cellCount).map { IndexPath(item: $0 + offset.item, section: offset.section) })
            }
        }
    }
    
    init<List: ListView>(listView: List) {
        isListView = { [weak listView] in $0 === listView }
        update = { [weak listView] in listView?.performUpdate(animation: .init(animated: $0), completion: $1) }
        insertItemsBlock = { [weak listView] in listView?.insertItems(at: $0) }
        deleteItemsBlock = { [weak listView] in listView?.deleteItems(at: $0) }
        reloadItemsBlock = { [weak listView] in listView?.reloadItems(at: $0) }
        moveItemBlock = { [weak listView] in listView?.moveItem(at: $0, to: $1) }
        insertSectionsBlock = { [weak listView] in listView?.insertSections($0) }
        deleteSectionsBlock = { [weak listView] in listView?.deleteSections($0) }
        reloadSectionsBlock = { [weak listView] in listView?.reloadSections($0) }
        moveSectionBlock = { [weak listView] in listView?.moveSection($0, toSection: $1) }
        reloadContextBlock = { [weak listView] in listView?.reloadSynchronously() }
    }
    
    func startUpdate() {
        isUpdating = true
    }
    
    func endUpdate(completion: ((Bool) -> Void)? = nil) {
        updates.forEach { $0() }
        isUpdating = false
    }
    
    func updateList(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        update(animated, completion)
    }
}

public class ListsUpdater<Value>: Updater {
    public var updaters = [ListUpdater<Value>]()
    
    public func addListView<List: ListView>(listView: List) {
        let updater = ListUpdater<Value>(listView: listView)
        if let index = updaters.firstIndex(where: { $0.isListView(listView) }) {
            updaters[index] = updater
        } else {
            updaters.append(updater)
        }
    }
    
    public func addListView<List: ListView>(listView: List, offset: IndexPath, sectionCount: Int, cellCount: Int) {
        let updater = ListUpdater<Value>(listView: listView, offset: offset, sectionCount: sectionCount, cellCount: cellCount)
        if let index = updaters.firstIndex(where: { $0.isListView(listView) }) {
            updaters[index] = updater
        } else {
            updaters.append(updater)
        }
    }
}

public extension Updater {
    func updateList(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        updaters.forEach { $0.updateList(animated: animated, completion: completion) }
    }
    
    func reloadCurrentContext() {
        waitOrUpdateImmediatly { $0.reloadContextBlock() }
    }
    
    func startUpdate() {
        for index in updaters.indices {
            updaters[index].startUpdate()
        }
    }
    
    func endUpdate(completion: ((Bool) -> Void)? = nil) {
        for index in updaters.indices {
            updaters[index].endUpdate(completion: completion)
        }
    }
}

public extension Updater where Value: CollectionSource, Value.Element == Value.Item {
    func insertItem(at indice: [Int]) {
        waitOrUpdateImmediatly { $0.insertItemsBlock(indice.map { IndexPath(item: $0) }) }
    }
    
    func deleteItems(at indice: [Int]) {
        waitOrUpdateImmediatly { $0.deleteItemsBlock(indice.map { IndexPath(item: $0) }) }
    }
    
    func reloadItems(at indice: [Int]) {
        waitOrUpdateImmediatly { $0.reloadItemsBlock(indice.map { IndexPath(item: $0) }) }
    }
    
    func moveItem(at index: Int, to newIndex: Int) {
        waitOrUpdateImmediatly { $0.moveItemBlock(IndexPath(item: index), IndexPath(item: newIndex)) }
    }
}

public extension Updater where Value: MultiSectionSource {
    func insertItems(at indexPaths: [IndexPath]) {
        waitOrUpdateImmediatly { $0.insertItemsBlock(indexPaths) }
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        waitOrUpdateImmediatly { $0.deleteItemsBlock(indexPaths) }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        waitOrUpdateImmediatly { $0.reloadItemsBlock(indexPaths) }
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        waitOrUpdateImmediatly { $0.moveItemBlock(indexPath, newIndexPath) }
    }
    
    func insertSections(_ sections: IndexSet) {
        waitOrUpdateImmediatly { $0.insertSectionsBlock(sections) }
    }
    
    func deleteSections(_ sections: IndexSet) {
        waitOrUpdateImmediatly { $0.deleteSectionsBlock(sections) }
    }
    
    func reloadSections(_ sections: IndexSet) {
        waitOrUpdateImmediatly { $0.reloadSectionsBlock(sections) }
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        waitOrUpdateImmediatly { $0.moveSectionBlock(section, newSection) }
    }
}

private var listViewUpdatableUpdateContextKey: Void?

public extension ListUpdatable where Self: AnyObject {
    var listsUpdater: ListsUpdater<Self> {
        return Associator.getValue(key: &listViewUpdatableUpdateContextKey, from: self, initialValue: .init())
    }
}

fileprivate extension Updater {
    func waitOrUpdateImmediatly(_ block: @escaping (ListUpdater<Value>) -> Void) {
        updaters.forEach { $0.waitOrUpdateImmediatly(block) }
    }
}

fileprivate extension ListUpdater {
    func waitOrUpdateImmediatly(_ block: @escaping (ListUpdater<Value>) -> Void) {
        if isUpdating {
            updates.append { [unowned self] in block(self) }
        } else {
            block(self)
        }
    }
}
