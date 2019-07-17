//
//  SourceSnapshot.swift
//  SundayListKit
//
//  Created by Frain on 2019/8/1.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol SectionSnapshot: CollectionSnapshot where Item == SubSource.Element {
    func item(at indexPath: IndexPath) -> Item
}

extension Snapshot: SectionSnapshot where SubSource: Collection, SubSource.Element == Item {
    public init(_ source: SubSource) {
        self.source = source
        self.subSource = Array(source)
        self.subSnapshots = []
        self.subSourceIndices = [Array(subSource.indices)]
        self.subSourceOffsets = subSource.indices.map { IndexPath(item: $0) }
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        return elements[indexPath.item]
    }
}

public extension UpdateContext where Snapshot: SectionSnapshot {
    func insertElement(at index: Int) { insertItems(at: [IndexPath(item: index)]) }
    func deleteElement(at index: Int) { deleteItems(at: [IndexPath(item: index)]) }
    func reloadElement(at index: Int) { reloadItems(at: [IndexPath(item: index)]) }
    func moveElement(at index: Int, to newIndex: Int) { moveItem(at: IndexPath(item: index), to: IndexPath(item: newIndex)) }
    func moveElementAndReload(at index: Int, to newIndex: Int) {
        moveItem(at: IndexPath(item: index), to: IndexPath(item: newIndex))
        reloadItemsInNextUpdate(at: [IndexPath(item: index)])
    }
}

public extension Source where SubSource: Collection, SourceSnapshot == Snapshot<SubSource, Item>, Element == Item {
    func createSnapshot(with source: SubSource) -> SourceSnapshot { return .init(source) }
    func item(for snapshot: SourceSnapshot, at indexPath: IndexPath) -> Item {
        return snapshot.item(at: indexPath)
    }
}

//MARK: - Collection Diff

//ElementEquatable
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
                insertElement(at: newIndex)
            case .remove(offset: let oldIndex, _, _):
                deleteElement(at: oldIndex)
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
                    moveElement(at: oldIndex, to: newIndex)
                } else {
                    insertElement(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteElement(at: oldIndex)
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
                    moveElement(at: oldIndex, to: newIndex)
                } else {
                    insertElement(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteElement(at: oldIndex)
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
                        reloadElement(at: newIndex)
                    } else if rawSnapshot.elements[oldIndex] == element {
                        moveElement(at: oldIndex, to: newIndex)
                    } else {
                        moveElementAndReload(at: oldIndex, to: newIndex)
                    }
                } else {
                    insertElement(at: newIndex)
                }
            case .remove(offset: let oldIndex, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteElement(at: oldIndex)
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
