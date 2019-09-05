//
//  ListSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

extension Snapshot where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item {
    public var elementsOffsets: [IndexPath] {
        return subSourceOffsets
    }
    
    public var elementsSnapshots: [Snapshot<Element.SubSource, Element.Item>] {
        return subSnapshots as! [Snapshot<Element.SubSource, Element.Item>]
    }
    
    public func index(of indexPath: IndexPath) -> Int {
        let section = subSourceIndices[indexPath.section]
        switch section {
        case .section(let index, _): return index
        case .cell(let indices): return indices[indexPath.item]
        }
    }
    
    public func item(at indexPath: IndexPath) -> Element.Item {
        let index = self.index(of: indexPath)
        let offset = subSourceOffsets[index]
        let subSnapshot = elementsSnapshots[index]
        let indexPath = IndexPath(item: indexPath.item - offset.item, section: indexPath.section - offset.section)
        return elements[index].item(for: subSnapshot, at: indexPath)
    }
}

public extension Snapshot where SubSource: Collection, SubSource.Element: Source, SubSource.Element.Item == Item {
    init(_ source: SubSource) {
        self.subSource = []
        self.subSnapshots = []
        self.subSourceIndices = []
        self.subSourceOffsets = []
        self.isSectioned = true
        var offset = IndexPath(item: 0, section: 0)
        
        for source in source {
            let snapshot: Snapshot<Element.SubSource, Element.Item>
            if let updater = (source as? ListUpdatable)?.listUpdater {
                snapshot = updater.snapshotValue as? Snapshot<SubSource.Element.SubSource, SubSource.Element.Item> ?? {
                    let snapshot = source.createSnapshot(with: source.source)
                    updater.snapshotValue = snapshot
                    return snapshot
                }()
            } else {
                snapshot = source.createSnapshot(with: source.source)
            }
            add(snapshot: snapshot, offset: &offset)
            subSource.append(source)
        }
    }
    
}

extension Snapshot: SubSourceContainSnapshot where SubSource: Collection, Element: Source, Item == Element.Item {
    mutating func updateSubSource(with snapshot: SnapshotType?, at index: Int) {
        let rawSnapshot = subSnapshots[index]
        let offset = subSourceOffsets[index]
        if let snapshot = snapshot {
            subSnapshots[index] = snapshot
        } else {
            subSnapshots.remove(at: index)
            subSource.remove(at: index)
        }
        if rawSnapshot.isSectioned, snapshot?.isSectioned != false {
            let rawSectionCount = rawSnapshot.numbersOfSections()
            let sectionCount = snapshot?.numbersOfSections()
            if let snapshot = snapshot, let sectionCount = sectionCount {
                subSourceIndices.replaceSubrange(offset.section..<offset.section + rawSectionCount, with: (0..<sectionCount).map { .section(index, snapshot.numbersOfItems(in: $0)) })
            } else {
                subSourceIndices.removeSubrange(offset.section..<offset.section + rawSectionCount)
            }
            let countOffset = (sectionCount ?? 0) - rawSectionCount
            if index + 1 < subSourceOffsets.count, countOffset != 0 {
                for i in index + 1..<subSourceOffsets.count {
                    subSourceOffsets[i].addOffset(IndexPath(section: countOffset))
                }
            }
        } else if !rawSnapshot.isSectioned, snapshot?.isSectioned != true, case var .cell(indices) = subSourceIndices[offset.section] {
            let rawCellCount = rawSnapshot.numbersOfItems(in: 0)
            let cellCount = snapshot?.numbersOfItems(in: 0)
            func updateOffset() {
                subSourceIndices[offset.section] = .cell(indices)
                let countOffset = (cellCount ?? 0) - rawCellCount
                if index + 1 < subSourceOffsets.count, countOffset != 0 {
                    for i in index + 1 ..< subSourceOffsets.count {
                        if subSourceOffsets[i].section != offset.section { break }
                        subSourceOffsets[i].addOffset(IndexPath(item: countOffset))
                    }
                }
            }
            if let cellCount = cellCount {
                indices.replaceSubrange(offset.item..<offset.item + rawCellCount, with: Array(repeating: index, count: cellCount))
                updateOffset()
            } else {
                indices.removeSubrange(offset.item..<offset.item + rawCellCount)
                if indices.isEmpty {
                    subSourceIndices.remove(at: offset.section)
                    if index + 1 < subSourceOffsets.count {
                        for i in index + 1..<subSourceOffsets.count {
                            subSourceOffsets[i].addOffset(IndexPath(section: -1))
                        }
                    }
                } else {
                    updateOffset()
                }
            }
        } else {
            fatalError()
        }
    }
    
    mutating func add(snapshot: SnapshotType, offset: inout IndexPath) {
        if snapshot.isSectioned {
            if subSourceIndices.last != nil {
                offset = IndexPath(item: 0, section: offset.section + 1)
            }
            for i in 0..<snapshot.numbersOfSections() {
                subSourceIndices.append(.section(subSnapshots.count, snapshot.numbersOfItems(in: i)))
            }
            subSourceOffsets.append(offset)
        } else {
            let cellCount = snapshot.numbersOfItems(in: 0)
            switch subSourceIndices.last {
            case .cell(var cells)?:
                offset = IndexPath(item: offset.item + 1, section: offset.section)
                cells.append(contentsOf: Array(repeating: subSnapshots.count, count: cellCount))
                subSourceIndices[subSourceIndices.lastIndex] = .cell(cells)
            case .section?:
                let sectionCount = subSnapshots[subSnapshots.lastIndex].numbersOfSections()
                offset = IndexPath(item: 0, section: offset.section + max(sectionCount, 1))
                fallthrough
            case .none:
                subSourceIndices.append(.cell(Array(repeating: subSnapshots.count, count: cellCount)))
            }
            subSourceOffsets.append(offset)
        }
        subSnapshots.append(snapshot)
    }
}

public extension Source where SubSource: Collection, Element: Source, Element.Item == Item {
    func createSnapshot(with source: SubSource) -> Snapshot<SubSource, Item> { return .init(source) }
    func item(for snapshot: Snapshot<SubSource, Item>, at indexPath: IndexPath) -> Item {
        return snapshot.item(at: indexPath)
    }
}

public extension Source where Self: ListUpdatable, SubSource: Collection, Element: Source, Element.Item == Item {
    
}


public extension UpdateContext where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item {
    func insertElement(at index: Int) {
        let subSnapshot = snapshot.elementsSnapshots[index]
        let offset = snapshot.elementsOffsets[index]
        if subSnapshot.isSectioned {
            (0..<subSnapshot.numbersOfSections()).forEach { insertSection($0 + offset.section) }
        } else {
            (0..<subSnapshot.numbersOfItems(in: 0)).forEach { insertItem(at: IndexPath(item: $0).addingOffset(offset), isListItem: true) }
        }
    }
    
    func deleteElement(at index: Int) {
        let subSnapshot = rawSnapshot.elementsSnapshots[index]
        let offset = rawSnapshot.elementsOffsets[index]
        if subSnapshot.isSectioned {
            (0..<subSnapshot.numbersOfSections()).forEach { deleteSection($0 + offset.section) }
        } else {
            (0..<subSnapshot.numbersOfItems(in: 0)).forEach { deleteItem(at: IndexPath(item: $0).addingOffset(offset), isListItem: true) }
        }
    }
    
    func reloadElement(at index: Int) {
        let subSnapshot = snapshot.elementsSnapshots[index]
        let offset = snapshot.elementsOffsets[index]
        let rawSubSnapshot = rawSnapshot.elementsSnapshots[index]
        let (numbersOfSection, rawNumbersOfSection) = (subSnapshot.numbersOfSections(), rawSubSnapshot.numbersOfSections())
        if subSnapshot.isSectioned, rawSubSnapshot.isSectioned {
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
        } else if !subSnapshot.isSectioned, !rawSubSnapshot.isSectioned {
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
        if subSnapshot.isSectioned, rawSubSnapshot.isSectioned {
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
        } else if !subSnapshot.isSectioned, !rawSubSnapshot.isSectioned {
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
public extension Source where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item, SubSource.Element: Identifiable {
    func update(context: UpdateContext<SubSource, Item>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item, SubSource.Element: Identifiable {
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

public extension Source where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item, SubSource.Element: Diffable {
    func update(context: UpdateContext<SubSource, Item>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item, SubSource.Element: Diffable {
    func diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        var rawChanges: [Change<Int>?] = (0..<rawSnapshot.elements.count).map { _ in nil }
        var changes: [Change<Int>?] = (0..<snapshot.elements.count).map { _ in nil }
        
        //print("---diff:")
        for change in diff {
            //print(change)
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
        //print("--- merge finished")
        //print("rawSectionChanges", rawSnapshotChanges)
        //print("sectionChanges", snapshotChanges)
        //print("merge finished ---")
    }
}

private extension UpdateContext where SubSource: Collection, SubSource.Element: Source, Item == SubSource.Element.Item, SubSource.Element: Identifiable {
    func update(with rawChanges: [Change<Int>?], changes: [Change<Int>?]) {
        //print("--- before merge:")
        //print("rawChanges", rawChanges)
        //print("changes", changes)
        let rawUnchangedElement = rawChanges.enumerated().compactMap { $0.element == nil ? $0.offset : nil }
        let unchangedElement = changes.enumerated().compactMap { $0.element == nil ? $0.offset : nil }
        //print("rawUnchangedElement", rawUnchangedElement)
        //print("unchangedElement", unchangedElement)
        for (rawIndex, index) in zip(rawUnchangedElement, unchangedElement) {
            //print("- merge normal:")
            //print("rawUnchangedIndex \(rawIndex)", "unchangedIndex \(index)")
            let offset = snapshot.elementsOffsets[index]
            let rawOffset = rawSnapshot.elementsOffsets[rawIndex]
            let updateContext = UpdateContext<SubSource.Element.SubSource, SubSource.Element.Item>(
                rawSnapshot: rawSnapshot.elementsSnapshots[rawIndex],
                snapshot: snapshot.elementsSnapshots[index]
            )
            snapshot.elements[index].update(context: updateContext)
            //print("rawUnchangedIndex \(rawIndex)", "unchangedIndex \(index) - sub snapshot finish, start merge")
            merge(context: updateContext, rawOffset: rawOffset, offset: offset)
            //print("rawUnchangedIndex \(rawIndex)", "unchangedIndex \(index) - merge complete")
            //print("rawSectionChanges", rawSnapshotChanges)
            //print("sectionChanges", snapshotChanges)
        }
        
        for case let (index, .insert(rawIndex?, false)?) in changes.enumerated().lazy.compactMap({ $0 }) {
            //print("- merge move:")
            //print("moveIndex \(rawIndex)", "toIndex \(index)")
            let offset = snapshot.elementsOffsets[index]
            let rawOffset = rawSnapshot.elementsOffsets[rawIndex]
            let updateContext = UpdateContext<SubSource.Element.SubSource, SubSource.Element.Item>(
                rawSnapshot: rawSnapshot.elementsSnapshots[rawIndex],
                snapshot: snapshot.elementsSnapshots[index]
            )
            snapshot.elements[index].update(context: updateContext)
            //print("--moveIndex \(rawIndex)", "toIndex \(index) - sub snapshot finish, start merge")
            merge(context: updateContext, rawOffset: rawOffset, offset: offset, isMove: true)
            //print("moveIndex \(rawIndex)", "toIndex \(index) - merge complete--")
            //print("rawSectionChanges", rawSnapshotChanges)
            //print("sectionChanges", snapshotChanges)
        }
    }
    
    func merge(context: UpdateContext<SubSource.Element.SubSource, SubSource.Element.Item>, rawOffset: IndexPath, offset: IndexPath, isMove: Bool = false) {
        //print("rawSnapshotChanges", context.rawSnapshotChanges)
        //print("snapshotChanges", context.snapshotChanges)
        if context.isSectioned {
            if isMove {
                let unChangedRawSections = context.rawSnapshotChanges.enumerated().lazy.compactMap { $0.element.change == nil && !$0.element.isAllListChange ? $0.offset : nil }
                let unChangedSections = context.snapshotChanges.enumerated().lazy.compactMap { $0.element.change == nil && !$0.element.isAllListChange ? $0.offset : nil }
                //print(Array(unChangedRawSections), Array(unChangedSections))
                for (rawIndex, index) in zip(unChangedRawSections, unChangedSections) {
                    //print(rawIndex, index)
                    context.moveSection(rawIndex, toSection: index)
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
                let unChangedRawItems = context.rawSnapshotChanges[0].values.enumerated().lazy.compactMap { $0.element == nil ? $0.offset : nil }
                let unChangedItems = context.snapshotChanges[0].values.enumerated().lazy.compactMap { $0.element == nil ? $0.offset : nil }
                for (rawIndex, index) in zip(unChangedRawItems, unChangedItems) {
                    context.moveItem(at: IndexPath(item: rawIndex), to: IndexPath(item: index), isListItem: true)
                }
            }
            
            for index in 0..<context.rawSnapshot.numbersOfItems(in: 0) {
                rawSnapshotChanges[rawOffset.section].values[rawOffset.item + index] = context.rawSnapshotChanges[0].values[index]?.addingOffset(offset)
            }
            for index in 0..<context.snapshot.numbersOfItems(in: 0) {
                snapshotChanges[offset.section].values[offset.item + index] = context.snapshotChanges[0].values[index]?.addingOffset(rawOffset)
            }
        }
        //print("--------")
    }
}


private extension Array {
    var lastIndex: Int {
        return Swift.max(endIndex - 1, 0)
    }
}
