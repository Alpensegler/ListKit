//
//  ContextDifference.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/10.
//  Copyright © 2019 Frain. All rights reserved.
//

#if iOS13
import SwiftUI
#endif

//ElementEquatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Equatable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        #if iOS13
        let diff = self.snapshot.subSource.difference(from: snapshot.subSource)
        #else
        let diff = self.snapshot.subSource.diff(from: snapshot.subSource)
        #endif
        for change in diff {
            switch change {
            case .insert(offset: let newRow, _, _):
                insertItem(at: [newRow])
            case .remove(offset: let oldRow, _, _):
                deleteItems(at: [oldRow])
            }
        }
    }
}

//ElementHashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Hashable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        #if iOS13
        let diff = self.snapshot.subSource.difference(from: snapshot.subSource).inferringMoves()
        #else
        let diff = self.snapshot.subSource.diff(from: snapshot.subSource).inferringMoves()
        #endif
        
        for change in diff {
            switch change {
            case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                if let oldRow = assoc {
                    moveItem(at: oldRow, to: newRow)
                } else {
                    insertItem(at: [newRow])
                }
            case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItems(at: [oldRow])
                }
            }
        }
    }
}

//ElementIdentifiable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        let diff = self.snapshot.subSource.difference(from: snapshot.subSource).inferringMoves()
        for change in diff {
            switch change {
            case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                if let oldRow = assoc {
                    moveItem(at: oldRow, to: newRow)
                } else {
                    insertItem(at: [newRow])
                }
            case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItems(at: [oldRow])
                }
            }
        }
    }
}

//ElementDiffable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        _update(from: snapshot)
    }
    
    private func _update(from snapshot: Snapshot) {
        let diff = self.snapshot.subSource.difference(from: snapshot.subSource).inferringMoves()
        for change in diff {
            switch change {
            case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                if let oldRow = assoc {
                    if oldRow == newRow {
                        reloadItems(at: [newRow])
                    } else {
                        if snapshot.subSource[oldRow].identifiedValue != self.snapshot.subSource[newRow].identifiedValue {
                            deleteItems(at: [oldRow])
                            insertItem(at: [newRow])
                        } else {
                            moveItem(at: oldRow, to: newRow)
                        }
                    }
                } else {
                    insertItem(at: [newRow])
                }
            case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItems(at: [oldRow])
                }
            }
        }
    }
}

//ElementIdentifiable + Equatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Element: Equatable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        __update(from: snapshot)
    }
    
    private func __update(from snapshot: Snapshot) {
        let diff = self.snapshot.subSource.difference(from: snapshot.subSource).inferringMoves()
        for change in diff {
            switch change {
            case .insert(offset: let newRow, element: _, associatedWith: let assoc):
                if let oldRow = assoc {
                    moveItem(at: oldRow, to: newRow)
                } else {
                    insertItem(at: [newRow])
                }
            case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItems(at: [oldRow])
                }
            }
        }
    }
}

//ElementDiffable + Equatable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Value.Item: Equatable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        _update(from: snapshot)
    }
}

//ElementIdentifiable + Hashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Element: Hashable {
    
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        __update(from: snapshot)
    }
}

//ElementDiffable + Hashable
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item.IdentifiedValue: Equatable, Value.Item: Hashable {
    
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        _update(from: snapshot)
    }
}

//Section Item Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        _sourceUpdate(from: snapshot)
    }
    
    private func _sourceUpdate(from snapshot: Snapshot) {
        let diff = self.snapshot.subSource.difference(from: snapshot.subSource).inferringMoves()
        for change in diff {
            switch change {
            case let .insert(offset: newRow, element: element, associatedWith: assoc):
                if let oldRow = assoc {
                    if oldRow != newRow {
                        moveItem(at: oldRow, to: newRow)
                    }
                    element.update(from: snapshot.snapshot(for: IndexPath(item: oldRow)), to: .init(listView: listView, snapshot: self.snapshot.snapshot(for: IndexPath(item: newRow)), offset: IndexPath(item: newRow)))
                } else {
                    insertItem(at: [newRow])
                }
            case .remove(offset: let oldRow, element: _, associatedWith: let assoc):
                if assoc == nil {
                    deleteItems(at: [oldRow])
                }
            }
        }
    }
}

//Section Item Equatable Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Value.Item: Equatable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        _sourceUpdate(from: snapshot)
    }
}

//Section Item EqualDiffable Diff
public extension Context where Value: CollectionSource, Value.Element == Value.Item, Value.Item: Identifiable, Value.Item: Source, Value.Item: Equatable, Value.Item.IdentifiedValue: Equatable {
    func update(from snapshot: Snapshot) {
        __baseUpdate(from: snapshot)
    }
    
    internal func __baseUpdate(from snapshot: Snapshot) {
        _sourceUpdate(from: snapshot)
    }
}

