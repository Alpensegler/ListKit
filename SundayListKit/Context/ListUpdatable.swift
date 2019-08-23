//
//  ListUpdatable.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/23.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ListUpdatable {
    var listUpdater: ListUpdater { get }
    func collectionView(_ collectionView: UICollectionView, willUpdateWith change: ListChange)
    func tableView(_ tableView: UITableView, willUpdateWith change: ListChange)
}

public extension ListUpdatable where Self: Source {
    var snapshot: SourceSnapshot {
        get {
            return listUpdater.snapshotValue as? SourceSnapshot ?? {
                let snapshot = createSnapshot(with: source)
                listUpdater.snapshotValue = snapshot
                return snapshot
            }()
        }
        nonmutating set { listUpdater.snapshotValue = newValue }
    }
    
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        perform(animated: animated, completion: completion) { update(context: $0) }
    }
    
    func performReloadCurrent(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        perform(animated: animated, completion: completion) { $0.reloadCurrent() }
    }
    
    func performReloadData(_ completion: ((Bool) -> Void)? = nil) {
        snapshot = createSnapshot(with: source)
        listUpdater.collectionContexts.lazy.compactMap { $0.listView() }.forEach {
            collectionView($0, willUpdateWith: .reload)
            $0.reloadSynchronously(completion: completion)
        }
        listUpdater.tableContexts.lazy.compactMap { $0.listView() }.forEach {
            tableView($0, willUpdateWith: .reload)
            $0.reloadSynchronously(completion: completion)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willUpdateWith change: ListChange) { }
    
    func tableView(_ tableView: UITableView, willUpdateWith change: ListChange) { }
}

extension ListUpdatable where Self: Source {
    func perform(animated: Bool, completion: ((Bool) -> Void)?, with update: (UpdateContext<SourceSnapshot>) -> Void) {
        let rawSnapshot = snapshot
        let snapshot = createSnapshot(with: source)
        let updateContext = UpdateContext(rawSnapshot: rawSnapshot, snapshot: snapshot)
        update(updateContext)
        updateWith(updateContext: updateContext, animated: animated, completion: completion)
    }
    
    func updateWith(updateContext: UpdateContext<SourceSnapshot>, animated: Bool, completion: ((Bool) -> Void)?) {
        let changes = updateContext.getChanges()
        func update<List: ListView>(context: ListUpdater.Context<List>, updates: (List, ListChange) -> Void) {
            guard let listView = context.listView() else { return }
            self.snapshot = updateContext.rawSnapshot
            updateContext.perform(changes: changes, for: listView, offset: context.offset, animated: animated, completion: completion) {
                self.snapshot = updateContext.snapshot
                changes.forEach { updates(listView, $0) }
            }
        }
        
        listUpdater.collectionContexts.forEach { update(context: $0) { collectionView($0, willUpdateWith: $1) } }
        listUpdater.tableContexts.forEach { update(context: $0) { tableView($0, willUpdateWith: $1) } }
    }
}

extension ListUpdatable {
    typealias ListContext<List: ListView> = ListUpdater.Context<List>
    
    func addCollectionContext(_ context: ListContext<UICollectionView>) {
        guard let collectionView = context.listView() else { return }
        _add(context: context, to: listUpdater, listView: collectionView)
        collectionView.reloadSynchronously()
    }
    
    func addTableContext(_ context: ListContext<UITableView>) {
        guard let tableView = context.listView() else { return }
        _add(context: context, to: listUpdater, listView: tableView)
        tableView.reloadSynchronously()
    }
    
    func _add<List: ListView>(context: ListContext<List>, to listUpdater: ListUpdater, listView: List) {
        if let index = listUpdater[keyPath: context.keyPath].firstIndex(where: { $0.listView() === listView }) {
            listUpdater[keyPath: context.keyPath][index] = context
        } else {
            listUpdater[keyPath: context.keyPath].append(context)
        }
        context.update(self, listView)
    }
    
    func _updateSnapshotSubSource<List: ListView>(_ context: ListContext<List>, listView: List) {
        guard let subSourceContainer = listUpdater.snapshotValue as? SubSourceContainSnapshot else { return }
        for (index, source) in subSourceContainer.subSource.enumerated() {
            guard let updatable = source as? ListUpdatable else { continue }
            let offset = subSourceContainer.subSourceOffsets[index]
            let rawSnapshot = subSourceContainer.subSnapshots[index]
            let context = ListUpdater.Context(offset: offset, keyPath: context.keyPath, update: context.update, listView: context.listView) { [rawSnapshot] snapshot in
                let rawSectionCount = rawSnapshot.numbersOfSections()
                let sectionCount = snapshot.numbersOfSections()
                if sectionCount > 0, rawSectionCount > 0 {
                    
                } else if sectionCount < 0, rawSectionCount < 0 {
                    
                }
            }
            updatable._add(context: context, to: updatable.listUpdater, listView: listView)
        }
    }
}

public class ListUpdater {
    struct Context<List: ListView> {
        let offset: IndexPath
        let keyPath: ReferenceWritableKeyPath<ListUpdater, [Context<List>]>
        let update: (ListUpdatable, List) -> ()
        let listView: () -> List?
        let snapshotSetter: (SnapshotType) -> Void
    }
    
    var tableContexts = [Context<UITableView>]()
    var collectionContexts = [Context<UICollectionView>]()
    var sourceValue: Any?
    var updateContextValue: Any?
    var snapshotValue: Any?
    
    var isUpdating = false
    
    public init() { }
    
    func startUpdate() {
        isUpdating = true
    }
    
    func endUpdate() {
        isUpdating = false
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
