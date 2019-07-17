//
//  UpdateContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/30.
//  Copyright © 2019 Frain. All rights reserved.
//

public class UpdateContextBase {
    class Updates {
        var insertItems = [IndexPath]()
        var deleteItems = [IndexPath]()
        var reloadItems = [IndexPath]()
        var moveItem = [(from: IndexPath, to: IndexPath)]()
        var insertSections = IndexSet()
        var deleteSections = IndexSet()
        var reloadSections = IndexSet()
        var moveSection = [(from: Int, to: Int)]()
        
        var reloadItemsInNextUpdate = [IndexPath]()
        var reloadSectionsInNextUpdate = IndexSet()
    }
    
    var updates = Updates()
    var hasUpdate: Bool {
        return !updates.isEmpty
    }
    
    func insertItems(at indexPaths: [IndexPath]) { updates.insertItems += indexPaths }
    func deleteItems(at indexPaths: [IndexPath]) { updates.deleteItems += indexPaths }
    func reloadItems(at indexPaths: [IndexPath]) { updates.reloadItems += indexPaths }
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) { updates.moveItem.append((indexPath, newIndexPath)) }
    func insertSections(_ sections: IndexSet) { updates.insertSections.formUnion(sections) }
    func deleteSections(_ sections: IndexSet) { updates.deleteSections.formUnion(sections) }
    func reloadSections(_ sections: IndexSet) { updates.reloadSections.formUnion(sections) }
    func moveSection(_ section: Int, toSection newSection: Int) { updates.moveSection.append((section, newSection)) }
    
    func reloadItemsInNextUpdate(at indexPaths: [IndexPath]) { updates.reloadItemsInNextUpdate += indexPaths }
    func reloadSectionsInNextUpdate(_ sections: IndexSet) { updates.reloadSectionsInNextUpdate.formUnion(sections) }
    
    func performUpdate<List: ListView>(listView: List, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if updates.isSingleUpdate {
            CATransaction.begin()
            CATransaction.setCompletionBlock { completion?(true) }
            _updates(listView: listView, animated: animated, updates: updates)
            CATransaction.commit()
        } else {
            let hasNext = updates.hasNextUpdate
            listView.perform(update: {
                _updates(listView: listView, animated: animated, updates: updates)
            }, animation: .init(animated: animated), completion: hasNext ? nil : completion)
            guard hasNext else { return }
            listView.perform(update: {
                listView.reloadItems(at: updates.reloadItemsInNextUpdate)
                listView.reloadSections(updates.reloadSectionsInNextUpdate)
            }, animation: .init(animated: animated), completion: completion)
        }
    }
    
    private func _updates<List: ListView>(listView: List, animated: Bool, updates: Updates) {
        listView.insertItems(at: updates.insertItems)
        listView.deleteItems(at: updates.deleteItems)
        listView.reloadItems(at: updates.reloadItems)
        updates.moveItem.forEach { listView.moveItem(at: $0.from, to: $0.to) }
        listView.insertSections(updates.insertSections)
        listView.deleteSections(updates.deleteSections)
        listView.reloadSections(updates.reloadSections)
        updates.moveSection.forEach { listView.moveSection($0.from, toSection: $0.to) }
    }
}

public class UpdateContext<Snapshot: SnapshotType>: UpdateContextBase {
    public var rawSnapshot: Snapshot
    public var snapshot: Snapshot
    lazy var isSectioned: Bool = {
        switch (rawSnapshot.numbersOfSections(), snapshot.numbersOfSections()) {
        case (0, 0):
            return false
        case let (rawSection, section) where rawSection > 0 && section > 0:
            return true
        default:
            fatalError("should not change from sectioned source to non sectioned source")
        }
    }()
    
    lazy var rawSnapshotIndices: [(index: Int, isMove: Bool?)] = {
        if isSectioned {
            return (0..<rawSnapshot.numbersOfSections()).map { ($0, nil) }
        } else {
            return (0..<rawSnapshot.numbersOfItems(in: 0)).map { ($0, nil) }
        }
    }()
    
    lazy var snapshotIndices: [(index: Int, isMove: Bool?)] = {
        if isSectioned {
            return (0..<snapshot.numbersOfSections()).map { ($0, nil) }
        } else {
            return (0..<snapshot.numbersOfItems(in: 0)).map { ($0, nil) }
        }
    }()
    
    override func insertItems(at indexPaths: [IndexPath]) {
        super.insertItems(at: indexPaths)
        if !isSectioned { indexPaths.forEach { snapshotIndices[$0.item].isMove = false } }
    }
    
    override func deleteItems(at indexPaths: [IndexPath]) {
        super.deleteItems(at: indexPaths)
        if !isSectioned { indexPaths.forEach { rawSnapshotIndices[$0.item].isMove = false } }
    }
    
    override func reloadItems(at indexPaths: [IndexPath]) {
        super.reloadItems(at: indexPaths)
        if !isSectioned {
            indexPaths.forEach {
                rawSnapshotIndices[$0.item].isMove = false
                snapshotIndices[$0.item].isMove = false
            }
        }
    }
    
    override func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        super.moveItem(at: indexPath, to: newIndexPath)
        if !isSectioned {
            rawSnapshotIndices[indexPath.item].isMove = true
            snapshotIndices[newIndexPath.item].isMove = true
        }
    }
    
    override func insertSections(_ sections: IndexSet) {
        super.insertSections(sections)
        if isSectioned { sections.forEach { snapshotIndices[$0].isMove = false } }
    }
    
    override func deleteSections(_ sections: IndexSet) {
        super.deleteSections(sections)
        if isSectioned { sections.forEach { rawSnapshotIndices[$0].isMove = false }}
    }
    
    override func reloadSections(_ sections: IndexSet) {
        super.reloadSections(sections)
        if isSectioned {
            sections.forEach {
                rawSnapshotIndices[$0].isMove = false
                snapshotIndices[$0].isMove = false
            }
        }
    }
    
    override func moveSection(_ section: Int, toSection newSection: Int) {
        super.moveSection(section, toSection: newSection)
        if isSectioned {
            rawSnapshotIndices[section].isMove = true
            snapshotIndices[section].isMove = true
        }
    }
    
    func commitUpdate<List: ListView>(for context: ListUpdaterContext<List>, animated: Bool, offset: IndexPath, completion: ((Bool) -> Void)?) {
        guard let listView = context.listView else { return }
        if !listView.didReload {
            listView.reloadSynchronously(completion: completion)
        } else {
            performUpdate(listView: listView, animated: animated, completion: completion)
        }
        context.offset = offset
    }
    
    func moveAllItemReloadToNextUpdate() {
        updates.reloadItemsInNextUpdate += updates.reloadItems
        updates.reloadItems.removeAll()
    }
    
    func moveAllSectionReloadToNextUpdate() {
        updates.reloadSectionsInNextUpdate.formUnion(updates.reloadSections)
        updates.reloadSections.removeAll()
    }
    
    init(rawSnapshot: Snapshot, snapshot: Snapshot) {
        self.rawSnapshot = rawSnapshot
        self.snapshot = snapshot
    }
}

public extension UpdateContext {
    func reloadCurrent() {
        let (numbersOfSection, rawNumbersOfSection) = (snapshot.numbersOfSections(), rawSnapshot.numbersOfSections())
        if isSectioned {
            if numbersOfSection > rawNumbersOfSection {
                let start = rawNumbersOfSection - 1
                insertSections(IndexSet((start..<start + numbersOfSection - rawNumbersOfSection)))
                reloadSections(IndexSet((0..<rawNumbersOfSection)))
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                deleteSections(IndexSet((start..<start + rawNumbersOfSection - numbersOfSection)))
                reloadSections(IndexSet((0..<numbersOfSection)))
            } else {
                reloadSections(IndexSet((0..<numbersOfSection)))
            }
        } else {
            let (numbersOfItem, rawNumbersOfItem) = (snapshot.numbersOfItems(in: 0), rawSnapshot.numbersOfItems(in: 0))
            if numbersOfItem > rawNumbersOfItem {
                let start = rawNumbersOfItem - 1
                insertItems(at: (start..<start + numbersOfItem - rawNumbersOfItem).map { IndexPath(item: $0) })
                reloadItems(at: (0..<rawNumbersOfItem).map { IndexPath(item: $0) })
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                deleteItems(at: (start..<start + rawNumbersOfItem - numbersOfItem).map { IndexPath(item: $0) })
                reloadItems(at: (0..<numbersOfItem).map { IndexPath(item: $0) })
            } else {
                reloadItems(at: (0..<numbersOfItem).map { IndexPath(item: $0) })
            }
        }
    }
}

extension UpdateContextBase.Updates {
    var hasNextUpdate: Bool {
        return !reloadItemsInNextUpdate.isEmpty || !reloadSectionsInNextUpdate.isEmpty
    }
    
    var isEmpty: Bool {
        return insertItems.isEmpty
            && deleteItems.isEmpty
            && reloadItems.isEmpty
            && moveItem.isEmpty
            && insertSections.isEmpty
            && deleteSections.isEmpty
            && reloadSections.isEmpty
            && moveSection.isEmpty
            && reloadItemsInNextUpdate.isEmpty
            && reloadSectionsInNextUpdate.isEmpty
    }
    
    var isSingleUpdate: Bool {
        return insertItems.count
            + deleteItems.count
            + reloadItems.count
            + moveItem.count
            + insertSections.count
            + deleteSections.count
            + reloadSections.count
            + moveSection.count
            + reloadItemsInNextUpdate.count
            + reloadSectionsInNextUpdate.count
        == 1
    }
    
    func removeAll() {
        insertItems.removeAll()
        deleteItems.removeAll()
        reloadItems.removeAll()
        moveItem.removeAll()
        insertSections.removeAll()
        deleteSections.removeAll()
        reloadSections.removeAll()
        moveSection.removeAll()
        reloadItemsInNextUpdate.removeAll()
        reloadSectionsInNextUpdate.removeAll()
    }
    
    func mergeWith(updates: UpdateContextBase.Updates, rawOffset: IndexPath = .default, offset: IndexPath = .default) {
        insertItems.append(contentsOf: updates.insertItems.lazy.map { $0.addingOffset(offset) })
        deleteItems.append(contentsOf: updates.deleteItems.lazy.map { $0.addingOffset(rawOffset) })
        reloadItems.append(contentsOf: updates.reloadItems.lazy.map { $0.addingOffset(offset) })
        moveItem.append(contentsOf: updates.moveItem.lazy.map { ($0.from.addingOffset(rawOffset), $0.to.addingOffset(offset)) })
        insertSections.formUnion(IndexSet(updates.insertSections.lazy.map { $0 + offset.section }))
        deleteSections.formUnion(IndexSet(updates.deleteSections.lazy.map { $0 + rawOffset.section }))
        reloadSections.formUnion(IndexSet(updates.reloadSections.lazy.map { $0 + offset.section }))
        moveSection.append(contentsOf: updates.moveSection.lazy.map { ($0.from + rawOffset.section, to: $0.to + offset.section) })
        reloadItemsInNextUpdate.append(contentsOf: reloadItemsInNextUpdate.lazy.map { $0.addingOffset(offset) })
        reloadSectionsInNextUpdate.formUnion(IndexSet(updates.reloadSectionsInNextUpdate.lazy.map { $0 + offset.section }))
    }
}
