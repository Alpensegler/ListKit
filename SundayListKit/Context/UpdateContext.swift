//
//  UpdateContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/30.
//  Copyright © 2019 Frain. All rights reserved.
//

public enum Change<Index: IndexPathOffsetable>: IndexPathOffsetable {
    case insert(associatedWith: Index?, isReload: Bool)
    case delete(associatedWith: Index?, isReload: Bool)
    
    static var insert: Change<Index> { return .insert(associatedWith: nil, isReload: false) }
    static var delete: Change<Index> { return .delete(associatedWith: nil, isReload: false) }
    
    public func addingOffset(_ offset: IndexPath) -> Change<Index> {
        switch self {
        case let .insert(associatedWith: index, isReload: isReload):
            return .insert(associatedWith: index?.addingOffset(offset), isReload: isReload)
        case let .delete(associatedWith: index, isReload: isReload):
            return .delete(associatedWith: index?.addingOffset(offset), isReload: isReload)
        }
    }
}

public enum ListChange: Equatable {
    case item(indexPath: IndexPath, change: Change<IndexPath>)
    case section(index: Int, change: Change<Int>)
    case reload
}

public struct UpdateContext<Snapshot: SnapshotType> {
    class SectionChanges {
        var change: Change<Int>?
        var values: [Change<IndexPath>?]
        
        init(change: Change<Int>?, values: [Change<IndexPath>?]) {
            self.change = change
            self.values = values
        }
        
        func addingOffset(_ offset: IndexPath) -> SectionChanges {
            return .init(change: change?.addingOffset(offset), values: values.map { $0?.addingOffset(offset) })
        }
    }
    
    public let rawSnapshot: Snapshot
    public let snapshot: Snapshot
    let isSectioned: Bool
    let rawSnapshotChanges: [SectionChanges]
    let snapshotChanges: [SectionChanges]
    
    init(rawSnapshot: Snapshot, snapshot: Snapshot) {
        self.rawSnapshot = rawSnapshot
        self.snapshot = snapshot
        switch (rawSnapshot.numbersOfSections(), snapshot.numbersOfSections()) {
        case (0, 0):
            isSectioned = false
            rawSnapshotChanges = [.init(change: nil, values: (0..<rawSnapshot.numbersOfItems(in: 0)).map { _ in nil })]
            snapshotChanges = [.init(change: nil, values: (0..<snapshot.numbersOfItems(in: 0)).map { _ in nil })]
        case let (rawSection, section) where rawSection > 0 && section > 0:
            isSectioned = true
            rawSnapshotChanges = (0..<rawSection).map { .init(change: nil, values: (0..<rawSnapshot.numbersOfItems(in: $0)).map { _ in nil }) }
            snapshotChanges = (0..<section).map { .init(change: nil, values: (0..<snapshot.numbersOfItems(in: $0)).map { _ in nil }) }
        default:
            fatalError("should not change from sectioned source to non sectioned source")
        }
    }
}

extension UpdateContext {
    
    func getChanges() -> [ListChange] {
        var sectionDelete = [ListChange]()
        var itemsDelete = [ListChange]()
        for sectionIndex in rawSnapshotChanges.indices.reversed() {
            let section = rawSnapshotChanges[sectionIndex]
            if let change = section.change {
                sectionDelete.append(.section(index: sectionIndex, change: change))
            } else {
                for itemIndex in section.values.indices.reversed() {
                    guard let change = section.values[itemIndex] else { continue }
                    itemsDelete.append(.item(indexPath: IndexPath(item: itemIndex, section: sectionIndex), change: change))
                }
            }
        }
        var sectionInsert = [ListChange]()
        var itemsInsert = [ListChange]()
        for sectionIndex in snapshotChanges.indices {
            let section = snapshotChanges[sectionIndex]
            if let change = section.change {
                sectionInsert.append(.section(index: sectionIndex, change: change))
            } else {
                for itemIndex in section.values.indices {
                    guard let change = section.values[itemIndex] else { continue }
                    itemsInsert.append(.item(indexPath: IndexPath(item: itemIndex, section: sectionIndex), change: change))
                }
            }
        }
        return sectionDelete + sectionInsert + itemsDelete + itemsInsert
    }
    
    func perform<List: ListView>(changes: [ListChange], for listView: List, offset: IndexPath, animated: Bool, completion: ((Bool) -> Void)? = nil, setData: () -> Void) {
        listView.perform(update: {
            setData()
            for change in changes {
                switch change {
                case let .section(index: index, change: .insert(associatedWith: assoc, isReload: isReload)):
                    if let assoc = assoc {
                        isReload ? listView.reloadSections([index]) : listView.moveSection(assoc, toSection: index)
                    } else {
                        listView.insertSections([index])
                    }
                case let .section(index: index, change: .delete(associatedWith: assoc, _)):
                    guard assoc == nil else { continue }
                    listView.deleteSections([index])
                case let .item(indexPath: index, change: .insert(associatedWith: assoc, isReload: isReload)):
                    if let assoc = assoc {
                        isReload ? listView.reloadItems(at: [index]) : listView.moveItem(at: assoc, to: index)
                    } else {
                        listView.insertItems(at: [index])
                    }
                case let .item(indexPath: index, change: .delete(associatedWith: assoc, _)):
                    guard assoc == nil else { continue }
                    listView.deleteItems(at: [index])
                case .reload:
                    fatalError("should not contain reload type here")
                }
            }
            
        }, animation: .init(animated: animated), completion: completion)
    }
}

public extension UpdateContext {
    func reloadCurrent() {
        let (numbersOfSection, rawNumbersOfSection) = (snapshot.numbersOfSections(), rawSnapshot.numbersOfSections())
        if isSectioned {
            if numbersOfSection > rawNumbersOfSection {
                let start = rawNumbersOfSection - 1
                (start..<start + numbersOfSection - rawNumbersOfSection).forEach(insertSection(_:))
                (0..<rawNumbersOfSection).forEach(reloadSection(_:))
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                (start..<start + rawNumbersOfSection - numbersOfSection).forEach(deleteSection(_:))
                (0..<numbersOfSection).forEach(reloadSection(_:))
            } else {
                (0..<numbersOfSection).forEach(reloadSection(_:))
            }
        } else {
            let (numbersOfItem, rawNumbersOfItem) = (snapshot.numbersOfItems(in: 0), rawSnapshot.numbersOfItems(in: 0))
            if numbersOfItem > rawNumbersOfItem {
                let start = rawNumbersOfItem - 1
                (start..<start + numbersOfItem - rawNumbersOfItem).forEach { insertItem(at: IndexPath(item: $0)) }
                (0..<rawNumbersOfItem).forEach { reloadItem(at: (IndexPath(item: $0))) }
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                (start..<start + rawNumbersOfItem - numbersOfItem).forEach { deleteItem(at: IndexPath(item: $0)) }
                (0..<numbersOfItem).forEach { reloadItem(at: IndexPath(item: $0)) }
            } else {
                (0..<numbersOfItem).forEach { reloadItem(at: IndexPath(item: $0)) }
            }
        }
    }
}

extension UpdateContext {
    
    func insertItem(at indexPath: IndexPath) {
        snapshotChanges[indexPath.section].values[indexPath.item] = .insert
    }
    
    func deleteItem(at indexPath: IndexPath) {
        rawSnapshotChanges[indexPath.section].values[indexPath.item] = .delete
    }
    
    func reloadItem(at indexPath: IndexPath) {
        rawSnapshotChanges[indexPath.section].values[indexPath.item] = .delete(associatedWith: indexPath, isReload: true)
        snapshotChanges[indexPath.section].values[indexPath.item] = .insert(associatedWith: indexPath, isReload: true)
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        rawSnapshotChanges[indexPath.section].values[indexPath.item] = .delete(associatedWith: newIndexPath, isReload: false)
        snapshotChanges[newIndexPath.section].values[newIndexPath.item] = .insert(associatedWith: indexPath, isReload: false)
    }
    
    func insertSection(_ section: Int) {
        snapshotChanges[section].change = .insert
    }
    
    func deleteSection(_ section: Int) {
        rawSnapshotChanges[section].change = .delete
    }
    
    func reloadSection(_ section: Int) {
        rawSnapshotChanges[section].change = .delete(associatedWith: section, isReload: true)
        snapshotChanges[section].change = .insert(associatedWith: section, isReload: true)
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        rawSnapshotChanges[section].change = .delete(associatedWith: newSection, isReload: false)
        snapshotChanges[newSection].change = .insert(associatedWith: section, isReload: false)
    }
}
