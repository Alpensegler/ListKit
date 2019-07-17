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
            listUpdater.collectionContext.forEach { updateContext.commitUpdate(for: $0, animated: animated, offset: .default, completion: completion) }
            listUpdater.tableContext.forEach { updateContext.commitUpdate(for: $0, animated: animated, offset: .default, completion: completion) }
        } else {
            performReload(completion)
        }
    }
    func performReload(_ completion: ((Bool) -> Void)? = nil) {
        snapshot = createSnapshot(with: source)
        listUpdater.collectionContext.forEach { $0.reloadSynchronously(completion: completion) }
        listUpdater.tableContext.forEach { $0.reloadSynchronously(completion: completion) }
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

class ListUpdaterContext<List: ListView>: UpdateContextBase {
    weak var listView: List?
    var offset: IndexPath
    var isUpdating = false
    
    override func insertItems(at indexPaths: [IndexPath]) {
        super.insertItems(at: indexPaths.map { $0.addingOffset(offset) })
        if !isUpdating { update() }
    }
    
    override func deleteItems(at indexPaths: [IndexPath]) {
        super.deleteItems(at: indexPaths.map { $0.addingOffset(offset) })
        if !isUpdating { update() }
    }
    
    override func reloadItems(at indexPaths: [IndexPath]) {
        super.reloadItems(at: indexPaths.map { $0.addingOffset(offset) })
        if !isUpdating { update() }
    }
    
    override func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        super.moveItem(at: indexPath.addingOffset(offset), to: newIndexPath.addingOffset(offset))
        if !isUpdating { update() }
    }
    
    override func insertSections(_ sections: IndexSet) {
        super.insertSections(IndexSet(sections.map { $0 + offset.section }))
        if !isUpdating { update() }
    }
    
    override func deleteSections(_ sections: IndexSet) {
        super.deleteSections(IndexSet(sections.map { $0 + offset.section }))
        if !isUpdating { update() }
    }
    
    override func reloadSections(_ sections: IndexSet) {
        super.reloadSections(IndexSet(sections.map { $0 + offset.section }))
        if !isUpdating { update() }
    }
    
    override func moveSection(_ section: Int, toSection newSection: Int) {
        super.moveSection(section + offset.section, toSection: newSection + offset.section)
        if !isUpdating { update() }
    }
    
    func reloadSynchronously(completion: ((Bool) -> Void)? = nil) {
        listView?.reloadSynchronously(completion: completion)
    }
    
    func update() {
        guard let listView = listView else { return }
        performUpdate(listView: listView, animated: true)
        updates.removeAll()
    }
    
    func startUpdate() {
        isUpdating = true
    }
    
    func endUpdate() {
        isUpdating = false
        update()
    }
    
    init(listView: List, offset: IndexPath) {
        self.listView = listView
        self.offset = offset
    }
}


public class ListUpdater {
    var tableContext = [ListUpdaterContext<UITableView>]()
    var collectionContext = [ListUpdaterContext<UICollectionView>]()
    var snapshotValue: Any?
    
    public init() { }
    
    func startUpdate() {
        tableContext.forEach { $0.startUpdate() }
        collectionContext.forEach { $0.startUpdate() }
    }
    
    func endUpdate() {
        tableContext.forEach { $0.endUpdate() }
        collectionContext.forEach { $0.endUpdate() }
    }
    
    func reloadSynchronously() {
        tableContext.forEach { $0.reloadSynchronously() }
        collectionContext.forEach { $0.reloadSynchronously() }
    }

    func insertItems(at indexPaths: [IndexPath]) {
        tableContext.forEach { $0.insertItems(at: indexPaths) }
        collectionContext.forEach { $0.insertItems(at: indexPaths) }
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        tableContext.forEach { $0.deleteItems(at: indexPaths) }
        collectionContext.forEach { $0.deleteItems(at: indexPaths) }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        tableContext.forEach { $0.reloadItems(at: indexPaths) }
        collectionContext.forEach { $0.reloadItems(at: indexPaths) }
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        tableContext.forEach { $0.moveItem(at: indexPath, to: newIndexPath) }
        collectionContext.forEach { $0.moveItem(at: indexPath, to: indexPath) }
    }
    
    func insertSections(_ sections: IndexSet) {
        tableContext.forEach { $0.insertSections(sections) }
        collectionContext.forEach { $0.insertSections(sections) }
    }
    
    func deleteSections(_ sections: IndexSet) {
        tableContext.forEach { $0.deleteSections(sections) }
        collectionContext.forEach { $0.deleteSections(sections) }
    }
    
    func reloadSections(_ sections: IndexSet) {
        tableContext.forEach { $0.deleteSections(sections) }
        collectionContext.forEach { $0.deleteSections(sections) }
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        tableContext.forEach { $0.moveSection(section, toSection: newSection) }
        collectionContext.forEach { $0.moveSection(section, toSection: newSection) }
    }
}

private var listUpdatableUpdaterKey: Void?

public extension ListUpdatable where Self: AnyObject {
    var listUpdater: ListUpdater {
        return Associator.getValue(key: &listUpdatableUpdaterKey, from: self, initialValue: .init())
    }
}
