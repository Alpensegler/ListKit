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
                listUpdater.updateAllSnapshotSubSource()
                return snapshot
            }()
        }
        nonmutating set { listUpdater.snapshotValue = newValue }
    }
    
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        perform(animated: animated, completion: completion, contextUpdate: [update(context:)])
    }
    
    func performReloadCurrent(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        perform(animated: animated, completion: completion, contextUpdate: [{ $0.reloadCurrent() }])
    }
    
    func performReloadData(_ completion: ((Bool) -> Void)? = nil) {
        let snapshot = createSnapshot(with: source)
        self.snapshot = snapshot
        listUpdater.updateAllSnapshotSubSource()
        listUpdater.collectionContexts.forEach { reloadWith(context: $0, with: snapshot, completion: completion) }
        listUpdater.tableContexts.forEach { reloadWith(context: $0, with: snapshot, completion: completion) }
    }
    
    func collectionView(_ collectionView: UICollectionView, willUpdateWith change: ListChange) { }
    
    func tableView(_ tableView: UITableView, willUpdateWith change: ListChange) { }
    
    func startUpdate() {
        guard listUpdater.updateContextValue as? ListUpdater.Update<SourceSnapshot> == nil else { return }
        listUpdater.updateContextValue = ListUpdater.Update<SourceSnapshot>()
    }
    
    func endUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let update = listUpdater.updateContextValue as? ListUpdater.Update<SourceSnapshot> else { return }
        perform(animated: animated, completion: completion, snapshotUpdate: update.snapshot, contextUpdate: update.context)
        listUpdater.updateContextValue = nil
    }
}

extension ListUpdatable where Self: Source {
    func updateOrAddToContext(snapshotUpdate: [(inout SourceSnapshot) -> Void] = [], contextUpdate: [(UpdateContext<SourceSnapshot>) -> Void] = []) {
        if let update = listUpdater.updateContextValue as? ListUpdater.Update<SourceSnapshot> {
            update.snapshot += snapshotUpdate
            update.context += contextUpdate
        } else {
            perform(snapshotUpdate: snapshotUpdate, contextUpdate: contextUpdate)
        }
    }
    
    func reloadWith<List>(context: ListUpdater.Context<List>, with snapshot: SourceSnapshot, completion: ((Bool) -> Void)? = nil) {
        guard let listView = context.listView() else { return }
        context.setSnapshot(snapshot)
        context.reloadUpdate(self, listView)
        listView.reloadSynchronously(completion: completion)
    }
    
    func perform(animated: Bool = true, completion: ((Bool) -> Void)? = nil, snapshotUpdate: [(inout SourceSnapshot) -> Void] = [], contextUpdate: [(UpdateContext<SourceSnapshot>) -> Void]) {
        let rawSnapshot = snapshot
        let snapshot: SourceSnapshot
        if !snapshotUpdate.isEmpty {
            var rawSnapshot = rawSnapshot
            snapshotUpdate.forEach { $0(&rawSnapshot) }
            snapshot = rawSnapshot
        } else {
            snapshot = createSnapshot(with: source)
        }
        print("\n-------------------------------------------------------------------\n---update from")
        print("\(rawSnapshot)")
        print("--update to")
        print("\(snapshot)\n")
        listUpdater.updateAllSnapshotSubSource(snapshot)
        let updateContext = UpdateContext(rawSnapshot: rawSnapshot, snapshot: snapshot)
        contextUpdate.forEach { $0(updateContext) }
        print("---updates:")
        updateWith(updateContext: updateContext, animated: animated, completion: completion)
    }
    
    func updateWith(updateContext: UpdateContext<SourceSnapshot>, animated: Bool, completion: ((Bool) -> Void)?) {
        let changes = updateContext.getChanges()
        func update<List: ListView>(context: ListUpdater.Context<List>, updates: (List, ListChange) -> Void) {
            perform(changes: changes, from: updateContext.rawSnapshot, to: updateContext.snapshot, for: context, animated: animated, completion: completion, updates: updates)
        }
        
        listUpdater.collectionContexts.forEach { update(context: $0) { collectionView($0, willUpdateWith: $1) } }
        listUpdater.tableContexts.forEach { update(context: $0) { tableView($0, willUpdateWith: $1) } }
    }
    
    func perform<List: ListView>(changes: [ListChange], from rawSnapshot: SourceSnapshot, to snapshot: SourceSnapshot, for context: ListUpdater.Context<List>, animated: Bool, completion: ((Bool) -> Void)?, updates: (List, ListChange) -> Void) {
        guard let listView = context.listView() else { return }
        self.snapshot = rawSnapshot
        listView.perform(update: {
            self.snapshot = snapshot
            context.setSnapshot(snapshot)
            for change in changes {
                print(change)
                updates(listView, change)
                switch change.addingOffset(context.offset) {
                case let .section(index: index, change: .insert(associatedWith: assoc, reload: reload)):
                    if let assoc = assoc {
                        reload ? listView.reloadSections([index]) : listView.moveSection(assoc, toSection: index)
                    } else {
                        listView.insertSections([index])
                    }
                case let .section(index: index, change: .delete(associatedWith: assoc, _)):
                    guard assoc == nil else { continue }
                    listView.deleteSections([index])
                case let .item(indexPath: index, change: .insert(associatedWith: assoc, reload: reload)):
                    if let assoc = assoc {
                        reload ? listView.reloadItems(at: [index]) : listView.moveItem(at: assoc, to: index)
                    } else {
                        listView.insertItems(at: [index])
                    }
                case let .item(indexPath: index, change: .delete(associatedWith: assoc, _)):
                    guard assoc == nil else { continue }
                    listView.deleteItems(at: [index])
                case .reload:
                    fatalError("should not contain reload: type here")
                }
            }
            
        }, animation: .init(animated: animated), completion: completion)
    }
}

extension ListUpdatable {
    
    func addCollectionContext(_ context: ListUpdater.Context<UICollectionView>) {
        guard let collectionView = context.listView() else { return }
        listUpdater.add(context: context, listView: collectionView, updatable: self)
        collectionView.reloadSynchronously()
    }
    
    func addTableContext(_ context: ListUpdater.Context<UITableView>) {
        guard let tableView = context.listView() else { return }
        listUpdater.add(context: context, listView: tableView, updatable: self)
        tableView.reloadSynchronously()
    }
}

public class ListUpdater {
    struct Context<List: ListView> {
        let offset: IndexPath
        let keyPath: ReferenceWritableKeyPath<ListUpdater, [Context<List>]>
        let reloadUpdate: (ListUpdatable, List) -> ()
        let listView: () -> List?
        let setSnapshot: (SnapshotType?) -> Void
    }
    
    class Update<T: SnapshotType> {
        var context = [(UpdateContext<T>) -> Void]()
        var snapshot = [(inout T) -> Void]()
    }
    
    var tableContexts = [Context<UITableView>]()
    var collectionContexts = [Context<UICollectionView>]()
    var sourceValue: Any?
    var updateContextValue: Any?
    var snapshotValue: Any?
    
    public init() { }
}

private extension ListUpdater {
    func updateAllSnapshotSubSource(_ container: Any? = nil, from index: Int = 0) {
        guard let subSourceContainer = (container ?? snapshotValue) as? SubSourceContainSnapshot else { return }
        for context in collectionContexts {
            guard let listView = context.listView() else { continue }
            updateSnapshotSubSource(context, listView: listView, subSourceContainer: subSourceContainer, from: index)
        }
        for context in tableContexts {
            guard let listView = context.listView() else { continue }
            updateSnapshotSubSource(context, listView: listView, subSourceContainer: subSourceContainer, from: index)
        }
    }
    
    func updateSnapshotSubSource<List: ListView>(_ context: Context<List>, listView: List, from index: Int = 0) {
        guard let subSourceContainer = snapshotValue as? SubSourceContainSnapshot else { return }
        updateSnapshotSubSource(context, listView: listView, subSourceContainer: subSourceContainer, from: index)
    }
    
    func updateSnapshotSubSource<List: ListView>(_ context: Context<List>, listView: List, subSourceContainer: SubSourceContainSnapshot, from index: Int) {
        for (index, source) in subSourceContainer.subSource[index...].enumerated().lazy.map({ ($0.offset + index, $0.element)}) {
            guard let updatable = source as? ListUpdatable else { continue }
            update(context: context, listView: listView, to: updatable, with: subSourceContainer, at: index)
        }
    }
    
    func add<List: ListView>(context: Context<List>, listView: List, updatable: ListUpdatable) {
        if let index = self[keyPath: context.keyPath].firstIndex(where: { $0.listView() === listView }) {
            self[keyPath: context.keyPath][index] = context
        } else {
            self[keyPath: context.keyPath].append(context)
        }
        context.reloadUpdate(updatable, listView)
        guard let subSourceContainer = snapshotValue as? SubSourceContainSnapshot else { return }
        for (index, source) in subSourceContainer.subSource.enumerated() {
            guard let updatable = source as? ListUpdatable else { continue }
            update(context: context, listView: listView, to: updatable, with: subSourceContainer, at: index)
        }
    }
    
    func update<List: ListView>(context: Context<List>, listView: List, to subUpdatable: ListUpdatable, with subSourceContainer: SubSourceContainSnapshot, at index: Int) {
        let offset = subSourceContainer.subSourceOffsets[index]
        let context = ListUpdater.Context(offset: offset, keyPath: context.keyPath, reloadUpdate: context.reloadUpdate, listView: context.listView) { [weak self] snapshot in
            guard let self = self, var subSourceContainer = self.snapshotValue as? SubSourceContainSnapshot else { return }
            subSourceContainer.updateSubSource(with: snapshot, at: index)
            self.snapshotValue = subSourceContainer
            self.updateAllSnapshotSubSource(from: index)
        }
        subUpdatable.listUpdater.add(context: context, listView: listView, updatable: subUpdatable)
    }
}

private var listUpdatableUpdaterKey: Void?

public extension ListUpdatable where Self: AnyObject {
    var listUpdater: ListUpdater {
        return Associator.getValue(key: &listUpdatableUpdaterKey, from: self, initialValue: .init())
    }
}
