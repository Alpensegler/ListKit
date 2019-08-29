//
//  UpdateContext.swift
//  SundayListKit
//
//  Created by Frain on 2019/7/30.
//  Copyright © 2019 Frain. All rights reserved.
//

public enum Change<Index: IndexPathOffsetable>: IndexPathOffsetable, CustomStringConvertible {
    case insert(associatedWith: Index?, reload: Bool)
    case delete(associatedWith: Index?, reload: Bool)
    
    static var insert: Change<Index> { return .insert(associatedWith: nil, reload: false) }
    static var delete: Change<Index> { return .delete(associatedWith: nil, reload: false) }
    
    public func addingOffset(_ offset: IndexPath) -> Change<Index> {
        switch self {
        case let .insert(associatedWith: index, reload: isReload):
            return .insert(associatedWith: index?.addingOffset(offset), reload: isReload)
        case let .delete(associatedWith: index, reload: isReload):
            return .delete(associatedWith: index?.addingOffset(offset), reload: isReload)
        }
    }
    
    public var isMove: Bool {
        switch self {
        case let .insert(associatedWith: index, _): return index != nil
        case let .delete(associatedWith: index, _): return index != nil
        }
    }
    
    public var isReload: Bool {
        switch self {
        case let .insert(_, reload: isReload): return isReload
        case let .delete(_, reload: isReload): return isReload
        }
    }
    
    public var description: String {
        switch self {
        case let .insert(associatedWith: index, reload: reload):
            if reload { return "reload" }
            if let index = index { return "move insert " + String(describing: index) }
            return "insert"
        case let .delete(associatedWith: index, reload: reload):
            if reload { return "reload" }
            if let index = index { return "move delete " + String(describing: index) }
            return "delete"
        }
    }
}

public enum ListChange: Equatable, IndexPathOffsetable, CustomStringConvertible {
    case item(indexPath: IndexPath, change: Change<IndexPath>)
    case section(index: Int, change: Change<Int>)
    case reload
    
    public func addingOffset(_ offset: IndexPath) -> ListChange {
        switch self {
        case .item(let indexPath, let change): return .item(indexPath: indexPath.addingOffset(offset), change: change.addingOffset(offset))
        case .section(let index, let change): return .section(index: index.addingOffset(offset), change: change.addingOffset(offset))
        case .reload: return .reload
        }
    }
    
    public var description: String {
        switch self {
        case .item(let indexPath, let change): return "\(change) item at \(indexPath)"
        case .section(let index, let change): return "\(change) section at \(index)"
        case .reload: return "reload"
        }
    }
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
        switch (rawSnapshot.isSectioned, snapshot.isSectioned) {
        case (false, false):
            isSectioned = false
            rawSnapshotChanges = [.init(change: nil, values: (0..<rawSnapshot.numbersOfItems(in: 0)).map { _ in nil })]
            snapshotChanges = [.init(change: nil, values: (0..<snapshot.numbersOfItems(in: 0)).map { _ in nil })]
        case (true, true):
            isSectioned = true
            rawSnapshotChanges = (0..<rawSnapshot.numbersOfSections()).map { .init(change: nil, values: (0..<rawSnapshot.numbersOfItems(in: $0)).map { _ in nil }) }
            snapshotChanges = (0..<snapshot.numbersOfSections()).map { .init(change: nil, values: (0..<snapshot.numbersOfItems(in: $0)).map { _ in nil }) }
        default:
            fatalError("should not change from sectioned source to non sectioned source")
        }
    }
}

extension UpdateContext {
    
    func getChanges() -> [ListChange] {
        print("----- get chanes -----")
        var sectionDelete = [ListChange]()
        var itemsDelete = [ListChange]()
        var sectionMoveIndex = [Int: (changed: Bool, at: Int)]()
        for sectionIndex in rawSnapshotChanges.indices.reversed() {
            let section = rawSnapshotChanges[sectionIndex]
            var moveIndex: Int?
            if let change = section.change, case let .delete(associatedWith: index, reload: reload) = change {
                sectionDelete.append(.section(index: sectionIndex, change: change))
                if reload { continue }
                if let index = index {
                    moveIndex = index
                    sectionMoveIndex[index] = (false, sectionDelete.count - 1)
                }
            }
            for itemIndex in section.values.indices.reversed() {
                guard let change = section.values[itemIndex] else { continue }
                if let moveIndex = moveIndex {
                    sectionDelete[sectionDelete.count - 1] = .section(index: sectionIndex, change: .delete)
                    sectionMoveIndex[moveIndex] = (true, sectionDelete.count - 1)
                    break
                }
                itemsDelete.append(.item(indexPath: IndexPath(item: itemIndex, section: sectionIndex), change: change))
            }
        }
        var sectionInsert = [ListChange]()
        var itemsInsert = [ListChange]()
        for sectionIndex in snapshotChanges.indices {
            let section = snapshotChanges[sectionIndex]
            var moveIndex: Int?
            if let change = section.change, case let .insert(associatedWith: index, reload: reload) = change {
                sectionInsert.append(.section(index: sectionIndex, change: change))
                if reload { continue }
                print(sectionIndex, "before", index as Any, sectionInsert, sectionDelete, sectionMoveIndex)
                if let index = index {
                    if let move = sectionMoveIndex[sectionIndex], move.changed {
                        sectionInsert[sectionInsert.count - 1] = .section(index: sectionIndex, change: .insert)
                        continue
                    }
                    moveIndex = index
                }
            }
            for itemIndex in section.values.indices {
                guard let change = section.values[itemIndex] else { continue }
                if let moveIndex = moveIndex {
                    sectionInsert[sectionInsert.count - 1] = .section(index: sectionIndex, change: .insert)
                    sectionMoveIndex[sectionIndex].map { sectionDelete[$0.at] = .section(index: moveIndex, change: .delete) }
                    print(sectionIndex, "after", sectionInsert, sectionDelete)
                    break
                }
                itemsInsert.append(.item(indexPath: IndexPath(item: itemIndex, section: sectionIndex), change: change))
            }
        }
        return sectionDelete + sectionInsert + itemsDelete + itemsInsert
    }
}

public extension UpdateContext {
    func reloadCurrent() {
        if isSectioned {
            let (numbersOfSection, rawNumbersOfSection) = (snapshot.numbersOfSections(), rawSnapshot.numbersOfSections())
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
        rawSnapshotChanges[indexPath.section].values[indexPath.item] = .delete(associatedWith: indexPath, reload: true)
        snapshotChanges[indexPath.section].values[indexPath.item] = .insert(associatedWith: indexPath, reload: true)
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        rawSnapshotChanges[indexPath.section].values[indexPath.item] = .delete(associatedWith: newIndexPath, reload: false)
        snapshotChanges[newIndexPath.section].values[newIndexPath.item] = .insert(associatedWith: indexPath, reload: false)
    }
    
    func insertSection(_ section: Int) {
        snapshotChanges[section].change = .insert
    }
    
    func deleteSection(_ section: Int) {
        rawSnapshotChanges[section].change = .delete
    }
    
    func reloadSection(_ section: Int) {
        rawSnapshotChanges[section].change = .delete(associatedWith: section, reload: true)
        snapshotChanges[section].change = .insert(associatedWith: section, reload: true)
    }
    
    func moveSection(_ section: Int, toSection newSection: Int) {
        rawSnapshotChanges[section].change = .delete(associatedWith: newSection, reload: false)
        snapshotChanges[newSection].change = .insert(associatedWith: section, reload: false)
    }
    
    func moveAndReloadSection(_ section: Int, toSection newSection: Int) {
        rawSnapshotChanges[section].change = .delete(associatedWith: newSection, reload: true)
        snapshotChanges[newSection].change = .insert(associatedWith: section, reload: true)
    }
}
