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
    func elementsSnapshot(at indexPath: IndexPath) -> Element.SourceSnapshot
    func item(at indexPath: IndexPath) -> Element.Item
    
    init(_ source: SubSource)
}

extension Snapshot: ListSnapshot where SubSource: Collection, Element: Source, Item == Element.Item {
    public var elementsOffsets: [IndexPath] {
        return subSourceOffsets
    }
    
    public internal(set) var elementsSnapshots: [Element.SourceSnapshot] {
        get { return subSnapshots as! [SubSource.Element.SourceSnapshot] }
        set { subSnapshots = newValue }
    }
    
    public func elementsSnapshot(at indexPath: IndexPath) -> Element.SourceSnapshot {
        return elementsSnapshots[subSourceIndices[indexPath]]
    }
    
    public func element(at indexPath: IndexPath) -> Element {
        return elements[subSourceIndices[indexPath]]
    }
    
    public func item(at indexPath: IndexPath) -> Element.Item {
        let index = subSourceIndices[indexPath]
        let offset = subSourceOffsets[index]
        let indexPath = IndexPath(item: indexPath.item - offset.item, section: indexPath.section - offset.section)
        return elements[index].item(for: elementsSnapshots[index], at: indexPath)
    }
}

extension Snapshot: SubSourceContainSnapshot where SubSource: Collection, Element: Source, Item == Element.Item { }

public extension Snapshot where SubSource: Collection, SubSource.Element: Source, SubSource.Element.Item == Item {
    init(_ source: SubSource) {
        let subSourceCollection = source
        var subSource = [SubSource.Element]()
        var subSnapshots = [SubSource.Element.SourceSnapshot]()
        var subSourceIndices = [[Int]]()
        var subSourceOffsets = [IndexPath]()
        var offset = IndexPath(item: 0, section: 0)
        var lastSourceWasSection = false
        
        for source in subSourceCollection {
            let snapshot: SubSource.Element.SourceSnapshot
            if let updater = (source as? ListUpdatable)?.listUpdater {
                snapshot = updater.snapshotValue as? SubSource.Element.SourceSnapshot ?? {
                    let source = source.createSnapshot(with: source.source)
                    updater.snapshotValue = source
                    return source
                }()
            } else {
                snapshot = source.createSnapshot(with: source.source)
            }
            let sectionCount = snapshot.numbersOfSections()
            if sectionCount > 0 {
                if offset.item > 0 {
                    offset = IndexPath(item: 0, section: offset.section + 1)
                }
                subSourceOffsets.append(offset)
                lastSourceWasSection = true
                for i in 0..<sectionCount {
                    subSourceIndices.append(Array(repeating: subSource.lastIndex, count: snapshot.numbersOfItems(in: i)))
                }
                offset.section += sectionCount
            } else {
                subSourceOffsets.append(offset)
                lastSourceWasSection = false
                let cellCount = snapshot.numbersOfItems(in: 0)
                if subSourceIndices.isEmpty || lastSourceWasSection {
                    subSourceIndices.append(Array(repeating: subSource.lastIndex, count: cellCount))
                } else {
                    subSourceIndices[subSourceIndices.lastIndex].append(contentsOf: Array(repeating: subSource.lastIndex, count: cellCount))
                }
                offset.item += cellCount
            }
            subSource.append(source)
            subSnapshots.append(snapshot)
        }
        
        self.source = subSourceCollection
        self.subSource = subSource
        self.subSnapshots = subSnapshots
        self.subSourceIndices = subSourceIndices
        self.subSourceOffsets = subSourceOffsets
    }
    
}

public extension Source where SubSource: Collection, SourceSnapshot == Snapshot<SubSource, Item>, Element: Source, Element.Item == Item {
    func createSnapshot(with source: SubSource) -> SourceSnapshot { return .init(source) }
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return snapshot.item(at: indexPath)
    }
}


public extension UpdateContext where Snapshot: ListSnapshot {
    func insertElement(at index: Int) {
        let subSnapshot = snapshot.elementsSnapshots[index]
        let offset = snapshot.elementsOffsets[index]
        let numbersOfSection = subSnapshot.numbersOfSections()
        if numbersOfSection > 0 {
            (0..<numbersOfSection).forEach { insertSection($0 + offset.section) }
        } else {
            (0..<subSnapshot.numbersOfItems(in: 0)).forEach { insertItem(at: IndexPath(item: $0).addingOffset(offset)) }
        }
    }
    
    func deleteElement(at index: Int) {
        let subSnapshot = rawSnapshot.elementsSnapshots[index]
        let offset = rawSnapshot.elementsOffsets[index]
        let numbersOfSection = subSnapshot.numbersOfSections()
        if numbersOfSection > 0 {
            (0..<numbersOfSection).forEach { deleteSection($0 + offset.section) }
        } else {
            (0..<subSnapshot.numbersOfItems(in: 0)).forEach { deleteItem(at: IndexPath(item: $0).addingOffset(offset)) }
        }
    }
    
    func reloadElement(at index: Int) {
        let subSnapshot = snapshot.elementsSnapshots[index]
        let offset = snapshot.elementsOffsets[index]
        let rawSubSnapshot = rawSnapshot.elementsSnapshots[index]
        let (numbersOfSection, rawNumbersOfSection) = (subSnapshot.numbersOfSections(), rawSubSnapshot.numbersOfSections())
        if numbersOfSection > 0, rawNumbersOfSection > 0 {
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
        } else if numbersOfSection == 0, rawNumbersOfSection == 0 {
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
        if numbersOfSection > 0, rawNumbersOfSection > 0 {
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
        } else if numbersOfSection == 0, rawNumbersOfSection == 0 {
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
                changes[newIndex] = .insert(associatedWith: assoc, isReload: false)
                if let oldIndex = assoc {
                    moveElement(at: oldIndex, to: newIndex)
                } else {
                    insertElement(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                rawChanges[oldIndex] = .delete(associatedWith: assoc, isReload: false)
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
                        changes[newIndex] = .insert(associatedWith: assoc, isReload: false)
                    case (true, false):
                        moveElement(at: oldIndex, to: newIndex)
                        changes[newIndex] = .insert(associatedWith: assoc, isReload: false)
                    case (false, true):
                        reloadElement(at: newIndex)
                        changes[newIndex] = .insert(associatedWith: assoc, isReload: true)
                    case (false, false):
                        deleteElement(at: oldIndex)
                        insertElement(at: newIndex)
                        rawChanges[oldIndex] = .delete(associatedWith: assoc, isReload: false)
                        changes[newIndex] = .insert(associatedWith: assoc, isReload: false)
                    }
                } else {
                    insertElement(at: newIndex)
                    changes[newIndex] = .insert(associatedWith: assoc, isReload: false)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                rawChanges[oldIndex] = .delete(associatedWith: assoc, isReload: false)
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
                    rawChange.change = .delete(associatedWith: index, isReload: false)
                    change.change = .insert(associatedWith: rawIndex, isReload: false)
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
                    rawSnapshotChanges[0].values[rawIndex] = .delete(associatedWith: IndexPath(item: index), isReload: false)
                    snapshotChanges[0].values[rawIndex] = .insert(associatedWith: IndexPath(item: rawIndex), isReload: false)
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
