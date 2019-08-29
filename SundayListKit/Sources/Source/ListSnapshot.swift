//
//  ListSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ListSnapshot: CollectionSnapshotType where Element: Source {
    associatedtype SubSource: Collection where SubSource.Element == Element
    
    var elementsSnapshots: [Element.SourceSnapshot] { get }
    var elementsOffsets: [IndexPath] { get }
    func index(of indexPath: IndexPath) -> Int
    func item(at indexPath: IndexPath) -> Element.Item
    
    mutating func deleteElement(at: Int)
    mutating func insertElement(element: Element, at: Int)
    mutating func reloadElement(element: Element, at: Int)
    
    init(_ source: SubSource)
}

extension Snapshot: ListSnapshot where SubSource: Collection, Element: Source, Item == Element.Item {
    public var elementsOffsets: [IndexPath] {
        return subSourceOffsets
    }
    
    public var elementsSnapshots: [Element.SourceSnapshot] {
        return subSnapshots as! [SubSource.Element.SourceSnapshot]
    }
    
    public func index(of indexPath: IndexPath) -> Int {
        return subSourceIndices[indexPath]
    }
    
    public func item(at indexPath: IndexPath) -> Element.Item {
        let index = subSourceIndices[indexPath]
        let offset = subSourceOffsets[index]
        let subSnapshot = elementsSnapshots[index]
        let indexPath = IndexPath(item: indexPath.item - offset.item, section: indexPath.section - offset.section)
        return elements[index].item(for: subSnapshot, at: indexPath)
    }
    
    mutating public func deleteElement(at: Int) {
        
    }
    
    mutating public func insertElement(element: Element, at: Int) {
        
    }
    
    mutating public func reloadElement(element: Element, at: Int) {
        
    }
}

public extension Snapshot where SubSource: Collection, SubSource.Element: Source, SubSource.Element.Item == Item {
    init(_ source: SubSource) {
        let subSourceCollection = source
        var subSource = [SubSource.Element]()
        var subSnapshots = [SnapshotType]()
        var subSourceIndices = [[Int]]()
        var subSourceOffsets = [IndexPath]()
        var offset = IndexPath(item: 0, section: 0)
        var lastSourceWasSection = false
        
        for source in subSourceCollection {
            let snapshot: SubSource.Element.SourceSnapshot
            if let updater = (source as? ListUpdatable)?.listUpdater {
                snapshot = updater.snapshotValue as? SubSource.Element.SourceSnapshot ?? {
                    let snapshot = source.createSnapshot(with: source.source)
                    updater.snapshotValue = snapshot
                    return snapshot
                }()
            } else {
                snapshot = source.createSnapshot(with: source.source)
            }
            Snapshot<SubSource, Item>.add(snapshot: snapshot, offset: &offset, lastSourceWasSection: &lastSourceWasSection, subSnapshots: &subSnapshots, subSourceIndices: &subSourceIndices, subSourceOffsets: &subSourceOffsets)
            subSource.append(source)
        }
        
        self.source = subSourceCollection
        self.subSource = subSource
        self.subSnapshots = subSnapshots
        self.subSourceIndices = subSourceIndices
        self.subSourceOffsets = subSourceOffsets
        self.isSectioned = true
    }
    
}

extension Snapshot: SubSourceContainSnapshot where SubSource: Collection, Element: Source, Item == Element.Item {
    mutating func removeSubSource(at index: Int) {
        subSnapshots.remove(at: index)
        subSource.remove(at: index)
        updateSubSourceIndex(from: index)
    }
    
    mutating func updateSubSource(with snapshot: SnapshotType, at index: Int) {
        subSnapshots[index] = snapshot
        updateSubSourceIndex(from: index)
    }
    
    mutating func updateSubSourceIndex(from index: Int) {
        print("before set:", self)
        var offset = subSourceOffsets[index]
        var lastSourceWasSection: Bool
        if index > 0 {
            let lastOffset = subSourceOffsets[index - 1]
            let distance = IndexPath(item: offset.item - lastOffset.item, section: offset.section - lastOffset.section)
            if distance.section > 0 {
                lastSourceWasSection = true
                subSourceIndices.removeSubrange(offset.section...)
            } else {
                lastSourceWasSection = false
                subSourceIndices[offset.section].removeSubrange(offset.item...)
                if offset.section + 1 < subSourceIndices.count {
                    subSourceIndices.removeSubrange((offset.section + 1)...)
                }
            }
        } else {
            lastSourceWasSection = false
            subSourceIndices.removeAll()
        }
        
        let snapshots = subSnapshots[index...]
        
        subSourceOffsets.removeSubrange(index...)
        subSnapshots.removeSubrange(index...)
        
        for snapshot in snapshots {
            Snapshot<SubSource, Item>.add(snapshot: snapshot, offset: &offset, lastSourceWasSection: &lastSourceWasSection, subSnapshots: &subSnapshots, subSourceIndices: &subSourceIndices, subSourceOffsets: &subSourceOffsets)
        }
        print("after set:", self)
    }
    
    static func add(snapshot: SnapshotType, offset: inout IndexPath, lastSourceWasSection: inout Bool, subSnapshots: inout [SnapshotType], subSourceIndices: inout [[Int]], subSourceOffsets: inout [IndexPath]) {
        if snapshot.isSectioned {
            let sectionCount = snapshot.numbersOfSections()
            if offset.item > 0 {
                offset = IndexPath(item: 0, section: offset.section + 1)
            }
            subSourceOffsets.append(offset)
            lastSourceWasSection = true
            for i in 0..<sectionCount {
                subSourceIndices.append(Array(repeating: subSnapshots.count, count: snapshot.numbersOfItems(in: i)))
            }
            offset.section += sectionCount
        } else {
            subSourceOffsets.append(offset)
            lastSourceWasSection = false
            let cellCount = snapshot.numbersOfItems(in: 0)
            if subSourceIndices.isEmpty || lastSourceWasSection {
                subSourceIndices.append(Array(repeating: subSnapshots.count, count: cellCount))
            } else {
                subSourceIndices[subSourceIndices.lastIndex].append(contentsOf: Array(repeating: subSnapshots.count, count: cellCount))
            }
            offset.item += cellCount
        }
        subSnapshots.append(snapshot)
    }
}

public extension Source where SubSource: Collection, SourceSnapshot == Snapshot<SubSource, Item>, Element: Source, Element.Item == Item {
    func createSnapshot(with source: SubSource) -> SourceSnapshot { return .init(source) }
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return snapshot.item(at: indexPath)
    }
}

public extension Source where Self: ListUpdatable, SubSource: Collection, SourceSnapshot == Snapshot<SubSource, Item>, Element: Source, Element.Item == Item {
    
}


public extension UpdateContext where Snapshot: ListSnapshot {
    func insertElement(at index: Int) {
        let subSnapshot = snapshot.elementsSnapshots[index]
        let offset = snapshot.elementsOffsets[index]
        if snapshot.isSectioned {
            (0..<subSnapshot.numbersOfSections()).forEach { insertSection($0 + offset.section) }
        } else {
            (0..<subSnapshot.numbersOfItems(in: 0)).forEach { insertItem(at: IndexPath(item: $0).addingOffset(offset)) }
        }
    }
    
    func deleteElement(at index: Int) {
        let subSnapshot = rawSnapshot.elementsSnapshots[index]
        let offset = rawSnapshot.elementsOffsets[index]
        if snapshot.isSectioned {
            (0..<subSnapshot.numbersOfSections()).forEach { deleteSection($0 + offset.section) }
        } else {
            (0..<subSnapshot.numbersOfItems(in: 0)).forEach { deleteItem(at: IndexPath(item: $0).addingOffset(offset)) }
        }
    }
    
    func reloadElement(at index: Int) {
        let subSnapshot = snapshot.elementsSnapshots[index]
        let offset = snapshot.elementsOffsets[index]
        let rawSubSnapshot = rawSnapshot.elementsSnapshots[index]
        let (numbersOfSection, rawNumbersOfSection) = (subSnapshot.numbersOfSections(), rawSubSnapshot.numbersOfSections())
        if snapshot.isSectioned, rawSnapshot.isSectioned {
            if numbersOfSection > rawNumbersOfSection {
                let start = rawNumbersOfSection - 1
                (start..<start + numbersOfSection - rawNumbersOfSection).forEach { insertSection($0 + offset.section) }
                (0..<rawNumbersOfSection).forEach { reloadSection($0 + offset.section) }
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                (start..<start + rawNumbersOfSection - numbersOfSection).forEach { deleteSection($0 + offset.section) }
                (0..<numbersOfSection).forEach { reloadSection($0 + offset.section) }
            } else {
                (0..<numbersOfSection).forEach { reloadSection($0 + offset.section) }
            }
        } else if !snapshot.isSectioned, !rawSnapshot.isSectioned {
            let (numbersOfItem, rawNumbersOfItem) = (subSnapshot.numbersOfItems(in: 0), rawSubSnapshot.numbersOfItems(in: 0))
            if numbersOfItem > rawNumbersOfItem {
                let start = rawNumbersOfItem - 1
                (start..<start + numbersOfItem - rawNumbersOfItem).forEach { insertItem(at: IndexPath(item: $0).addingOffset(offset)) }
                (0..<rawNumbersOfItem).forEach { reloadItem(at: IndexPath(item: $0).addingOffset(offset)) }
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                (start..<start + rawNumbersOfItem - numbersOfItem).forEach { deleteItem(at: IndexPath(item: $0).addingOffset(offset)) }
                (0..<numbersOfItem).forEach { reloadItem(at: IndexPath(item: $0).addingOffset(offset)) }
            } else {
                (0..<numbersOfItem).forEach { reloadItem(at: IndexPath(item: $0).addingOffset(offset)) }
            }
        } else {
            fatalError("source should always be sectioned of none sectioned")
        }
    }
    
    func moveElement(at index: Int, to newIndex: Int) {
        let subSnapshot = snapshot.elementsSnapshots[newIndex]
        let offset = snapshot.elementsOffsets[newIndex]
        let rawSubSnapshot = rawSnapshot.elementsSnapshots[index]
        let rawOffset = rawSnapshot.elementsOffsets[index]
        let (numbersOfSection, rawNumbersOfSection) = (subSnapshot.numbersOfSections(), rawSubSnapshot.numbersOfSections())
        if snapshot.isSectioned, rawSnapshot.isSectioned {
            if numbersOfSection > rawNumbersOfSection {
                let start = rawNumbersOfSection - 1
                (start..<start + numbersOfSection - rawNumbersOfSection).forEach { insertSection($0 + offset.section) }
                for i in (0..<rawNumbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                (start..<start + rawNumbersOfSection - numbersOfSection).forEach { deleteSection($0 + offset.section) }
                for i in (0..<numbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
            } else {
                for i in (0..<numbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
            }
        } else if !snapshot.isSectioned, !rawSnapshot.isSectioned {
            let (numbersOfItem, rawNumbersOfItem) = (subSnapshot.numbersOfItems(in: 0), rawSubSnapshot.numbersOfItems(in: 0))
            if numbersOfItem > rawNumbersOfItem {
                let start = rawNumbersOfItem - 1
                (start..<start + numbersOfItem - rawNumbersOfItem).forEach { insertItem(at: IndexPath(item: $0).addingOffset(offset)) }
                for i in (0..<rawNumbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                (start..<start + rawNumbersOfItem - numbersOfItem).forEach { deleteItem(at: IndexPath(item: $0).addingOffset(offset)) }
                for i in (0..<numbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
            } else {
                for i in (0..<numbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
            }
        } else {
            fatalError("source should always be sectioned of none sectioned")
        }
    }
}

//Identifiable
public extension Source where SourceSnapshot: ListSnapshot, SourceSnapshot.Element: Identifiable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: ListSnapshot, Snapshot.Element: Identifiable {
    func diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        var rawChanges: [Change<Int>?] = (0..<rawSnapshot.elements.count).map { _ in nil }
        var changes: [Change<Int>?] = (0..<snapshot.elements.count).map { _ in nil }
        
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: _, associatedWith: let assoc):
                changes[newIndex] = .insert(associatedWith: assoc, reload: false)
                if let oldIndex = assoc {
                    moveElement(at: oldIndex, to: newIndex)
                } else {
                    insertElement(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                rawChanges[oldIndex] = .delete(associatedWith: assoc, reload: false)
                if assoc == nil {
                    deleteElement(at: oldIndex)
                }
            }
        }
        
        update(with: rawChanges, changes: changes)
    }
}

//Identifiable + Equatable {

public extension Source where SourceSnapshot: ListSnapshot, SourceSnapshot.Element: Diffable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: ListSnapshot, Snapshot.Element: Diffable {
    func diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        var rawChanges: [Change<Int>?] = (0..<rawSnapshot.elements.count).map { _ in nil }
        var changes: [Change<Int>?] = (0..<snapshot.elements.count).map { _ in nil }
        
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: let element, associatedWith: let assoc):
                if let oldIndex = assoc {
                    switch (rawSnapshot.elements[oldIndex] == element, oldIndex == newIndex) {
                    case (true, true):
                        changes[newIndex] = .insert(associatedWith: assoc, reload: false)
                    case (true, false):
                        moveElement(at: oldIndex, to: newIndex)
                        changes[newIndex] = .insert(associatedWith: assoc, reload: false)
                    case (false, true):
                        reloadElement(at: newIndex)
                        changes[newIndex] = .insert(associatedWith: assoc, reload: true)
                    case (false, false):
                        deleteElement(at: oldIndex)
                        insertElement(at: newIndex)
                        rawChanges[oldIndex] = .delete(associatedWith: assoc, reload: false)
                        changes[newIndex] = .insert(associatedWith: assoc, reload: false)
                    }
                } else {
                    insertElement(at: newIndex)
                    changes[newIndex] = .insert(associatedWith: assoc, reload: false)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                rawChanges[oldIndex] = .delete(associatedWith: assoc, reload: false)
                if assoc == nil {
                    deleteElement(at: oldIndex)
                }
            }
        }
        
        update(with: rawChanges, changes: changes)
    }
}

private extension UpdateContext where Snapshot: ListSnapshot, Snapshot.Element: Identifiable {
    func update(with rawChanges: [Change<Int>?], changes: [Change<Int>?]) {
        let rawUnchangedElement = rawChanges.enumerated().compactMap { $0.element == nil ? $0.offset : nil }
        let unchangedElement = changes.enumerated().compactMap { $0.element == nil ? $0.offset : nil }
        for (rawIndex, index) in zip(rawUnchangedElement, unchangedElement) {
            let offset = snapshot.elementsOffsets[index]
            let rawOffset = rawSnapshot.elementsOffsets[rawIndex]
            let updateContext = UpdateContext<Snapshot.Element.SourceSnapshot>(
                rawSnapshot: rawSnapshot.elementsSnapshots[rawIndex],
                snapshot: snapshot.elementsSnapshots[index]
            )
            snapshot.elements[index].update(context: updateContext)
            merge(context: updateContext, rawOffset: rawOffset, offset: offset)
        }
        
        for case let (index, .insert(rawIndex?, false)?) in changes.enumerated().lazy.compactMap({ $0 }) {
            let offset = snapshot.elementsOffsets[index]
            let rawOffset = rawSnapshot.elementsOffsets[rawIndex]
            let updateContext = UpdateContext<Snapshot.Element.SourceSnapshot>(
                rawSnapshot: rawSnapshot.elementsSnapshots[rawIndex],
                snapshot: snapshot.elementsSnapshots[index]
            )
            snapshot.elements[index].update(context: updateContext)
            merge(context: updateContext, rawOffset: rawOffset, offset: offset, isMove: true)
        }
    }
    
    func merge(context: UpdateContext<Snapshot.Element.SourceSnapshot>, rawOffset: IndexPath, offset: IndexPath, isMove: Bool = false) {
        if context.isSectioned {
            if isMove {
                let unChangedRawSections = rawSnapshotChanges.enumerated().lazy.compactMap { $0.element.change == nil ? $0 : nil }
                let unChangedSections = snapshotChanges.enumerated().lazy.compactMap { $0.element.change == nil ? $0 : nil }
                for (rawArg, arg) in zip(unChangedRawSections, unChangedSections) {
                    let (rawIndex, rawChange) = rawArg
                    let (index, change) = arg
                    rawChange.change = .delete(associatedWith: index, reload: false)
                    change.change = .insert(associatedWith: rawIndex, reload: false)
                }
            }
            for section in 0..<context.rawSnapshot.numbersOfSections() {
                rawSnapshotChanges[section + rawOffset.section].change = context.rawSnapshotChanges[section].change?.addingOffset(offset)
                rawSnapshotChanges[section + rawOffset.section].values = context.rawSnapshotChanges[section].values.map { $0?.addingOffset(offset) }
            }
            for section in 0..<context.snapshot.numbersOfSections() {
                snapshotChanges[section + offset.section].change = context.snapshotChanges[section].change?.addingOffset(rawOffset)
                snapshotChanges[section + offset.section].values = context.snapshotChanges[section].values.map { $0?.addingOffset(rawOffset) }
            }
        } else {
            if isMove {
                let unChangedRawItems = rawSnapshotChanges[0].values.enumerated().lazy.compactMap { $0.element == nil ? $0.offset : nil }
                let unChangedItems = snapshotChanges[0].values.enumerated().lazy.compactMap { $0.element == nil ? $0.offset : nil }
                for (rawIndex, index) in zip(unChangedRawItems, unChangedItems) {
                    rawSnapshotChanges[0].values[rawIndex] = .delete(associatedWith: IndexPath(item: index), reload: false)
                    snapshotChanges[0].values[rawIndex] = .insert(associatedWith: IndexPath(item: rawIndex), reload: false)
                }
            }
            
            for index in 0..<context.rawSnapshot.numbersOfItems(in: 0) {
                rawSnapshotChanges[rawOffset.section].values[rawOffset.item + index] = context.rawSnapshotChanges[0].values[index]?.addingOffset(offset)
            }
            for index in 0..<context.snapshot.numbersOfItems(in: 0) {
                snapshotChanges[offset.section].values[offset.item + index] = context.snapshotChanges[0].values[index]?.addingOffset(rawOffset)
            }
        }
    }
}


private extension Array {
    var lastIndex: Int {
        return Swift.max(endIndex - 1, 0)
    }
}
