//
//  ListUpdatable.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/23.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ListUpdatable {
    var listUpdater: ListUpdater { get }
    func performUpdate(animated: Bool, completion: ((Bool) -> Void)?)
}

public extension ListUpdatable where Self: Source {
    var snapshot: SourceSnapshot {
        get {
            return rawSnapshot ?? {
                let snapshot = createSnapshot(with: source)
                listUpdater.snapshotValue = snapshot
                return snapshot
            }()
        }
        nonmutating set { listUpdater.snapshotValue = newValue }
    }
    
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let sourceSnapshot = rawSnapshot {
            let snapshot = createSnapshot(with: source)
            self.snapshot = snapshot
            let updateContext = UpdateContext(rawSnapshot: sourceSnapshot, snapshot: snapshot)
            update(context: updateContext)
            let changes = updateContext.getChanges()
            if !listUpdater.onChangeObservers.isEmpty {
                changes.forEach { change in listUpdater.onChangeObservers.forEach { $0(change) } }
            }
            listUpdater.collectionContext.forEach {
                guard let listView = $0.listView else { return }
                updateContext.perform(changes: changes, for: listView, offset: $0.offset, animated: animated, completion: completion)
            }
            listUpdater.tableContext.forEach {
                guard let listView = $0.listView else { return }
                updateContext.perform(changes: changes, for: listView, offset: $0.offset, animated: animated, completion: completion)
            }
        } else {
            performReload(completion)
        }
    }
    func performReload(_ completion: ((Bool) -> Void)? = nil) {
        snapshot = createSnapshot(with: source)
        listUpdater.reloadSynchronously(completion)
    }
    
    func observeOnChange(_ change: @escaping (ListChange) -> Void) {
        listUpdater.onChangeObservers.append(change)
    }
}

extension ListUpdatable where Self: Source {
    var rawSnapshot: SourceSnapshot? { return listUpdater.snapshotValue as? SourceSnapshot }
}

extension ListUpdatable {
    func setCollectionView(_ collectionView: UICollectionView, offset: IndexPath = .default) {
        if let index = listUpdater.collectionContext.firstIndex(where: { $0.listView === collectionView }) {
            listUpdater.collectionContext[index].offset = offset
        } else {
            listUpdater.collectionContext.append(.init(listView: collectionView, offset: offset))
        }
    }
    
    func setTableView(_ tableView: UITableView, offset: IndexPath = .default) {
        if let index = listUpdater.tableContext.firstIndex(where: { $0.listView === tableView }) {
            listUpdater.tableContext[index].offset = offset
        } else {
            listUpdater.tableContext.append(.init(listView: tableView, offset: offset))
        }
    }
}


public class ListUpdater {
    class Context<List: ListView> {
        weak var listView: List?
        var offset: IndexPath
        
        init(listView: List, offset: IndexPath) {
            self.listView = listView
            self.offset = offset
        }
    }
    
    var tableContext = [Context<UITableView>]()
    var collectionContext = [Context<UICollectionView>]()
    var snapshotValue: Any?
    var currentSnapshotValue: Any?
    var sourceValue: Any?
    var onChangeObservers = [(ListChange) -> Void]()
    
    var isUpdating = false
    
    public init() { }
    
    func startUpdate() {
        isUpdating = true
    }
    
    func endUpdate() {
        isUpdating = false
    }
    
    public func reloadSynchronously(_ completion: ((Bool) -> Void)? = nil) {
        tableContext.forEach { $0.listView?.reloadSynchronously(completion: completion) }
        collectionContext.forEach { $0.listView?.reloadSynchronously(completion: completion) }
    }

    //TODO
    func insertItems(at indexPaths: [IndexPath]) {
        
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        
    }
    
    func insertSections(_ sections: IndexSet) {
        
    }
    
    func deleteSections(_ sections: IndexSet) {
        
    }
    
    func reloadSections(_ sections: IndexSet) {
        
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        
    }
}

private var listUpdatableUpdaterKey: Void?

public extension ListUpdatable where Self: AnyObject {
    var listUpdater: ListUpdater {
        return Associator.getValue(key: &listUpdatableUpdaterKey, from: self, initialValue: .init())
    }
}
