//
//  SourceSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/1.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol SectionSnapshot: CollectionSnapshotType {
    associatedtype SubSource: Collection where SubSource.Element == Element
    typealias Item = Element
    func item(at indexPath: IndexPath) -> Item
    init(_ source: SubSource)
    
    mutating func deleteItem(at index: Int)
    mutating func insertItem(_ item: Item, at index: Int)
    mutating func reloadItem(_ item: Item, at index: Int)
}

extension Snapshot: SectionSnapshot where SubSource: Collection, SubSource.Element == Item {
    public init(_ source: SubSource) {
        self.subSource = Array(source)
        self.subSnapshots = []
        self.isSectioned = true
        resetIndicesAndOffset()
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        return elements[indexPath.item]
    }
    
    public mutating func deleteItem(at index: Int) {
        subSource.remove(at: index)
        resetIndicesAndOffset()
    }
    
    public mutating func insertItem(_ item: Item, at index: Int) {
        subSource.insert(item, at: index)
        resetIndicesAndOffset()
    }
    
    public mutating func reloadItem(_ item: Item, at index: Int) {
        subSource[index] = item
        resetIndicesAndOffset()
    }
    
    mutating func resetIndicesAndOffset() {
        subSourceIndices = [.cell(Array(subSource.indices))]
        subSourceOffsets = subSource.indices.map { IndexPath(item: $0) }
    }
}

public extension UpdateContext where Snapshot: SectionSnapshot {
    func insertItem(at index: Int) { insertItem(at: IndexPath(item: index)) }
    func deleteItem(at index: Int) { deleteItem(at: IndexPath(item: index)) }
    func reloadItem(at index: Int) { reloadItem(at: IndexPath(item: index)) }
    func moveItem(at index: Int, to newIndex: Int) { moveItem(at: IndexPath(item: index), to: IndexPath(item: newIndex)) }
}

public extension Source where SubSource: Collection, SourceSnapshot == Snapshot<SubSource, Item>, Element == Item {
    func createSnapshot(with source: SubSource) -> SourceSnapshot { return .init(source) }
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return snapshot.item(at: indexPath)
    }
}

public extension Source where SourceSnapshot: SectionSnapshot, Item == SourceSnapshot.Item, Self: ListUpdatable {
    func insert(item: Item, at index: Int) {
        updateOrAddToContext(snapshotUpdate: [{ $0.insertItem(item, at: index) }], contextUpdate: [{ $0.insertItem(at: index) }])
    }
    
    func reload(item: Item, at index: Int) {
        updateOrAddToContext(snapshotUpdate: [{ $0.reloadItem(item, at: index) }], contextUpdate: [{ $0.reloadItem(at: index) }])
    }
    
    func deleteItem(at index: Int) {
        updateOrAddToContext(snapshotUpdate: [{ $0.deleteItem(at: index) }], contextUpdate: [{ $0.deleteItem(at: index) }])
    }
}

//MARK: - Collection Diff

//ElementEquatable

public extension UpdateContext where Snapshot: SectionSnapshot {
    func diffUpdate(by areEquivalent: (Snapshot.SubSource.Element, Snapshot.SubSource.Element) -> Bool) {
        #if iOS13
        let diff = snapshot.elements.difference(from: rawSnapshot.elements, by: areEquivalent)
        #else
        let diff = snapshot.elements.diff(from: rawSnapshot.elements, by: areEquivalent)
        #endif
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, _, _):
                insertItem(at: newIndex)
            case .remove(offset: let oldIndex, _, _):
                deleteItem(at: oldIndex)
            }
        }
    }
    
    func diffUpdate<ID: Hashable>(idBy key: KeyPath<Snapshot.SubSource.Element, ID>) {
        diffUpdate(getID: { $0[keyPath: key] })
    }
    
    func diffUpdate<ID: Hashable>(getID key: (Snapshot.SubSource.Element) -> ID) {
        #if iOS13
        let diff = snapshot.elements.difference(from: rawSnapshot.elements) { key($0) == key($1) }.inferrringMoves(by: key)
        #else
        let diff = snapshot.elements.diff(from: rawSnapshot.elements) { key($0) == key($1) }.inferrringMoves(by: key)
        #endif
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: _, associatedWith: let assoc):
                if let oldIndex = assoc {
                    moveItem(at: oldIndex, to: newIndex)
                } else {
                    insertItem(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItem(at: oldIndex)
                }
            }
        }
    }
    
    func diffUpdate<ID: Hashable>(idBy key: KeyPath<Snapshot.SubSource.Element, ID>, by areEquivalent: (Snapshot.SubSource.Element, Snapshot.SubSource.Element) -> Bool) {
        diffUpdate(getID: { $0[keyPath: key] }, by: areEquivalent)
    }
    
    func diffUpdate<ID: Hashable>(getID key: (Snapshot.SubSource.Element) -> ID, by areEquivalent: (Snapshot.SubSource.Element, Snapshot.SubSource.Element) -> Bool) {
        #if iOS13
        let diff = snapshot.elements.difference(from: rawSnapshot.elements) { key($0) == key($1) && areEquivalent($0, $1) }.inferrringMoves(by: key)
        #else
        let diff = snapshot.elements.diff(from: rawSnapshot.elements) { key($0) == key($1) && areEquivalent($0, $1) }.inferrringMoves(by: key)
        #endif
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: let element, associatedWith: let assoc):
                if let oldIndex = assoc {
                    if oldIndex == newIndex {
                        reloadItem(at: newIndex)
                    } else if areEquivalent(rawSnapshot.elements[oldIndex], element) {
                        moveItem(at: oldIndex, to: newIndex)
                    } else {
                        deleteItem(at: oldIndex)
                        insertItem(at: newIndex)
                    }
                } else {
                    insertItem(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItem(at: oldIndex)
                }
            }
        }
    }
}


public extension Source where SourceSnapshot: SectionSnapshot, Item == SourceSnapshot.Item, Item: Equatable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: SectionSnapshot, Snapshot.Item: Equatable {
    func diffUpdate() {
        #if iOS13
        let diff = snapshot.elements.difference(from: rawSnapshot.elements)
        #else
        let diff = snapshot.elements.diff(from: rawSnapshot.elements)
        #endif
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, _, _):
                insertItem(at: newIndex)
            case .remove(offset: let oldIndex, _, _):
                deleteItem(at: oldIndex)
            }
        }
    }
}

//ElementHashable
public extension Source where SourceSnapshot: SectionSnapshot, Item == SourceSnapshot.Item, Item: Hashable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: SectionSnapshot, Snapshot.Item: Hashable {
    func diffUpdate() {
        #if iOS13
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        #else
        let diff = snapshot.elements.diff(from: rawSnapshot.elements).inferringMoves()
        #endif
        
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: _, associatedWith: let assoc):
                if let oldIndex = assoc {
                    moveItem(at: oldIndex, to: newIndex)
                } else {
                    insertItem(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItem(at: oldIndex)
                }
            }
        }
    }
}


//ElementIdentifiable
public extension Source where SourceSnapshot: SectionSnapshot, Item == SourceSnapshot.Item, Item: Identifiable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}


public extension UpdateContext where Snapshot: SectionSnapshot, Snapshot.Item: Identifiable {
    func diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: _, associatedWith: let assoc):
                if let oldIndex = assoc {
                    moveItem(at: oldIndex, to: newIndex)
                } else {
                    insertItem(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItem(at: oldIndex)
                }
            }
        }
    }
}

//ElementDiffable
public extension Source where SourceSnapshot: SectionSnapshot, Item == SourceSnapshot.Item, Item: Diffable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: SectionSnapshot, Snapshot.Item: Diffable {
    func diffUpdate() {
        _diffUpdate()
    }
    
    private func _diffUpdate() {
        let diff = snapshot.elements.difference(from: rawSnapshot.elements).inferringMoves()
        for change in diff {
            switch change {
            case .insert(offset: let newIndex, element: let element, associatedWith: let assoc):
                if let oldIndex = assoc {
                    if oldIndex == newIndex {
                        reloadItem(at: newIndex)
                    } else if rawSnapshot.elements[oldIndex] == element {
                        moveItem(at: oldIndex, to: newIndex)
                    } else {
                        deleteItem(at: oldIndex)
                        insertItem(at: newIndex)
                    }
                } else {
                    insertItem(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItem(at: oldIndex)
                }
            }
        }
    }
}

//ElementIdentifiable + Hashable
public extension Source where SourceSnapshot: SectionSnapshot, Item == SourceSnapshot.Item, Item: Identifiable, Item: Hashable {
    func update(context: UpdateContext<SourceSnapshot>) {
        context.diffUpdate()
    }
}

public extension UpdateContext where Snapshot: SectionSnapshot, Snapshot.Item: Identifiable, Snapshot.Item: Hashable {
    
    func diffUpdate() {
        _diffUpdate()
    }
}
