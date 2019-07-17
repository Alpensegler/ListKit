//
//  ListSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/11.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ListSnapshot: CollectionSnapshot where SubSource.Element: Source, SubSource.Element.Item == Item {
    var elementsSnapshots: [SubSource.Element.SourceSnapshot] { get }
    var elementsOffsets: [IndexPath] { get }
    func elementsSnapshot(at indexPath: IndexPath) -> SubSource.Element.SourceSnapshot
    func item(at indexPath: IndexPath) -> Item
}

extension Snapshot: ListSnapshot where SubSource: Collection, SubSource.Element: Source, SubSource.Element.Item == Item {
    public var elementsOffsets: [IndexPath] {
        return subSourceOffsets
    }
    
    public func elementsSnapshot(at indexPath: IndexPath) -> SubSource.Element.SourceSnapshot {
        return elementsSnapshots[subSourceIndices[indexPath]]
    }
    
    public func element(at indexPath: IndexPath) -> SubSource.Element {
        
        
        return elements[subSourceIndices[indexPath]]
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        let index = subSourceIndices[indexPath]
        let offset = subSourceOffsets[index]
        let indexPath = IndexPath(item: indexPath.item - offset.item, section: indexPath.section - offset.section)
        return elements[index].item(for: elementsSnapshots[index], at: indexPath)
    }
}

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
            let snapshot = source.createSnapshot(with: source.source)
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
            insertSections(IndexSet((0..<numbersOfSection).map { $0 + offset.section }))
        } else {
            insertItems(at: (0..<subSnapshot.numbersOfItems(in: 0)).map { IndexPath(item: $0).addingOffset(offset) })
        }
    }
    
    func deleteElement(at index: Int) {
        let subSnapshot = rawSnapshot.elementsSnapshots[index]
        let offset = rawSnapshot.elementsOffsets[index]
        let numbersOfSection = subSnapshot.numbersOfSections()
        if numbersOfSection > 0 {
            deleteSections(IndexSet((0..<numbersOfSection).map { $0 + offset.section }))
        } else {
            deleteItems(at: (0..<subSnapshot.numbersOfItems(in: 0)).map { IndexPath(item: $0).addingOffset(offset) })
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
                insertSections(IndexSet((start..<start + numbersOfSection - rawNumbersOfSection).map { $0 + offset.section }))
                reloadSections(IndexSet((0..<rawNumbersOfSection).map { $0 + offset.section }))
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                deleteSections(IndexSet((start..<start + rawNumbersOfSection - numbersOfSection).map { $0 + offset.section }))
                reloadSections(IndexSet((0..<numbersOfSection).map { $0 + offset.section }))
            } else {
                reloadSections(IndexSet((0..<numbersOfSection).map { $0 + offset.section }))
            }
        } else if numbersOfSection == 0, rawNumbersOfSection == 0 {
            let (numbersOfItem, rawNumbersOfItem) = (subSnapshot.numbersOfItems(in: 0), rawSubSnapshot.numbersOfItems(in: 0))
            if numbersOfItem > rawNumbersOfItem {
                let start = rawNumbersOfItem - 1
                insertItems(at: (start..<start + numbersOfItem - rawNumbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
                reloadItems(at: (0..<rawNumbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                deleteItems(at: (start..<start + rawNumbersOfItem - numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
                reloadItems(at: (0..<numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
            } else {
                reloadItems(at: (0..<numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
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
                insertSections(IndexSet((start..<start + numbersOfSection - rawNumbersOfSection).map { $0 + offset.section }))
                for i in (0..<rawNumbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                deleteSections(IndexSet((start..<start + rawNumbersOfSection - numbersOfSection).map { $0 + offset.section }))
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
                insertItems(at: (start..<start + numbersOfItem - rawNumbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
                for i in (0..<rawNumbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                deleteItems(at: (start..<start + rawNumbersOfItem - numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
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
    
    func moveElementAndReload(at index: Int, to newIndex: Int) {
        let subSnapshot = snapshot.elementsSnapshots[newIndex]
        let offset = snapshot.elementsOffsets[newIndex]
        let rawSubSnapshot = rawSnapshot.elementsSnapshots[index]
        let rawOffset = rawSnapshot.elementsOffsets[index]
        let (numbersOfSection, rawNumbersOfSection) = (subSnapshot.numbersOfSections(), rawSubSnapshot.numbersOfSections())
        if numbersOfSection > 0, rawNumbersOfSection > 0 {
            if numbersOfSection > rawNumbersOfSection {
                let start = rawNumbersOfSection - 1
                insertSections(IndexSet((start..<start + numbersOfSection - rawNumbersOfSection).map { $0 + offset.section }))
                for i in (0..<rawNumbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
                reloadSectionsInNextUpdate(IndexSet((0..<rawNumbersOfSection).map { $0 + offset.section }))
            } else if rawNumbersOfSection > numbersOfSection {
                let start = numbersOfSection - 1
                deleteSections(IndexSet((start..<start + rawNumbersOfSection - numbersOfSection).map { $0 + offset.section }))
                for i in (0..<numbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
                reloadSectionsInNextUpdate(IndexSet((0..<numbersOfSection).map { $0 + offset.section }))
            } else {
                for i in (0..<numbersOfSection) {
                    moveSection(i + rawOffset.section, toSection: i + offset.section)
                }
                reloadSectionsInNextUpdate(IndexSet((0..<numbersOfSection).map { $0 + offset.section }))
            }
        } else if numbersOfSection == 0, rawNumbersOfSection == 0 {
            let (numbersOfItem, rawNumbersOfItem) = (subSnapshot.numbersOfItems(in: 0), rawSubSnapshot.numbersOfItems(in: 0))
            if numbersOfItem > rawNumbersOfItem {
                let start = rawNumbersOfItem - 1
                insertItems(at: (start..<start + numbersOfItem - rawNumbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
                for i in (0..<rawNumbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
                reloadItemsInNextUpdate(at: (0..<rawNumbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
            } else if rawNumbersOfItem > numbersOfItem {
                let start = numbersOfItem - 1
                deleteItems(at: (start..<start + rawNumbersOfItem - numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
                for i in (0..<numbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
                reloadItemsInNextUpdate(at: (0..<numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
            } else {
                for i in (0..<numbersOfItem) {
                    moveItem(at: IndexPath(item: i).addingOffset(rawOffset), to: IndexPath(item: i).addingOffset(offset))
                }
                reloadItemsInNextUpdate(at: (0..<numbersOfItem).map { IndexPath(item: $0).addingOffset(offset) })
            }
        }
    }
}

//Identifiable
public extension Source where SourceSnapshot: ListSnapshot, SourceSnapshot.SubSource.Element: Identifiable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: ListSnapshot, Snapshot.SubSource.Element: Identifiable {
    func diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        var operates = (0..<rawSnapshot.elements.count).map { Optional.some((isMove: false, index: $0)) }
        
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: _, associatedWith: let assoc):
                if let oldIndex = assoc {
                    operates.insert((true, oldIndex), at: newIndex)
                } else {
                    insertElement(at: newIndex)
                    operates.insert(nil, at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteElement(at: oldIndex)
                }
                operates.remove(at: oldIndex)
            }
        }
        
        update(with: operates)
    }
}

//Identifiable + Equatable {

public extension Source where SourceSnapshot: ListSnapshot, SourceSnapshot.SubSource.Element: Diffable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: ListSnapshot, Snapshot.SubSource.Element: Diffable {
    func diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        var operates = (0..<rawSnapshot.elements.count).map { Optional.some((isMove: false, index: $0)) }
        
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: let element, associatedWith: let assoc):
                if let oldIndex = assoc {
                    switch (rawSnapshot.elements[oldIndex] == element, oldIndex == newIndex) {
                    case (true, true):
                        operates.insert((false, oldIndex), at: newIndex)
                    case (true, false):
                        operates.insert((true, oldIndex), at: newIndex)
                    case (false, true):
                        reloadElement(at: newIndex)
                        operates.insert(nil, at: newIndex)
                    case (false, false):
                        moveElementAndReload(at: oldIndex, to: newIndex)
                        operates.insert(nil, at: newIndex)
                    }
                } else {
                    insertElement(at: newIndex)
                    operates.insert(nil, at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteElement(at: oldIndex)
                }
                operates.remove(at: oldIndex)
            }
        }
        
        update(with: operates)
    }
}

private extension UpdateContext where Snapshot: ListSnapshot, Snapshot.SubSource.Element: Identifiable {
    func update(with operates: [(isMove: Bool, index: Int)?]) {
        for case let (indexArg, moveArg?) in zip(snapshot.elements.enumerated(), operates) {
            let (index, element) = indexArg
            let (isMove, rawIndex) = moveArg
            let offset = snapshot.elementsOffsets[index]
            let rawOffset = rawSnapshot.elementsOffsets[rawIndex]
            let updateContext = UpdateContext<Snapshot.SubSource.Element.SourceSnapshot>(
                rawSnapshot: rawSnapshot.elementsSnapshots[rawIndex],
                snapshot: snapshot.elementsSnapshots[index]
            )
            element.update(context: updateContext)
            
            if isMove {
                let rawNoneOperateIndices = rawSnapshotIndices.enumerated().lazy.compactMap { $0.element.isMove == nil ? $0.offset : nil }
                let noneOperateIndices = snapshotIndices.enumerated().lazy.compactMap { $0.element.isMove == nil ? $0.offset : nil }
                let sequence = zip(rawNoneOperateIndices, noneOperateIndices)
                if updateContext.isSectioned {
                    updateContext.moveAllSectionReloadToNextUpdate()
                    for (oldIndex, newIndex) in sequence {
                        updateContext.moveSection(oldIndex, toSection: newIndex)
                    }
                } else {
                    updateContext.moveAllItemReloadToNextUpdate()
                    for (oldIndex, newIndex) in sequence {
                        updateContext.moveItem(at: .init(item: oldIndex), to: .init(item: newIndex))
                    }
                }
            }
            updates.mergeWith(updates: updateContext.updates, rawOffset: rawOffset, offset: offset)
        }
    }
}


private extension Array {
    var lastIndex: Int {
        return Swift.max(endIndex - 1, 0)
    }
}
