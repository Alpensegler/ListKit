//
//  DifferingExtension.swift
//  SundayListKit
//
//  Created by Frain on 2019/6/23.
//  Copyright © 2019 Frain. All rights reserved.
//

extension CollectionDifference.Change {
    // Internal common field accessors
    internal var _element: ChangeElement {
        get {
            switch self {
            case .insert(offset: _, element: let e, associatedWith: _):
                return e
            case .remove(offset: _, element: let e, associatedWith: _):
                return e
            }
        }
    }
    
    internal var _offset: Int {
        get {
            switch self {
            case .insert(offset: let o, element: _, associatedWith: _):
                return o
            case .remove(offset: let o, element: _, associatedWith: _):
                return o
            }
        }
    }
    
    internal var _associatedOffset: Int? {
        get {
            switch self {
            case .insert(offset: _, element: _, associatedWith: let o):
                return o
            case .remove(offset: _, element: _, associatedWith: let o):
                return o
            }
        }
    }
}

public extension BidirectionalCollection where Element: Identifiable {
    func difference<C: BidirectionalCollection>(
        from other: C
        ) -> CollectionDifference<Element> where C.Element == Self.Element {
        #if iOS13
        return difference(from: other) { $0.id == $1.id }
        #else
        return diff(from: other) { $0.id == $1.id }
        #endif
    }
}

public extension BidirectionalCollection where Element: Identifiable, Element: Equatable {
    func difference<C: BidirectionalCollection>(
        from other: C
        ) -> CollectionDifference<Element> where C.Element == Self.Element {
        #if iOS13
        return difference(from: other) { $0 == $1 }
        #else
        return diff(from: other) { $0 == $1 }
        #endif
    }
}

public extension CollectionDifference where ChangeElement: Identifiable {
    func inferringMoves() -> CollectionDifference<ChangeElement> {
        return _inferrringMoves()
    }
}

public extension CollectionDifference where ChangeElement: Identifiable, ChangeElement: Hashable {
    func inferringMoves() -> CollectionDifference<ChangeElement> {
        return _inferrringMoves()
    }
}

extension CollectionDifference where ChangeElement: Identifiable {
    func _inferrringMoves() -> CollectionDifference<ChangeElement> {
        let uniqueRemovals: [ChangeElement.ID: Int?] = {
            var result = [ChangeElement.ID: Int?](minimumCapacity: Swift.min(removals.count, insertions.count))
            for removal in removals {
                let id = removal._element.id
                if result[id] != .none {
                    result[id] = .some(.none)
                } else {
                    result[id] = .some(removal._offset)
                }
            }
            return result.filter { (_, v) -> Bool in v != .none }
        }()
        
        let uniqueInsertions: [ChangeElement.ID: Int?] = {
            var result = [ChangeElement.ID: Int?](minimumCapacity: Swift.min(removals.count, insertions.count))
            for insertion in insertions {
                let element = insertion._element.id
                if result[element] != .none {
                    result[element] = .some(.none)
                } else {
                    result[element] = .some(insertion._offset)
                }
            }
            return result.filter { (_, v) -> Bool in v != .none }
        }()
        
        return CollectionDifference(map({ (change: Change) -> Change in
            switch change {
            case .remove(offset: let offset, element: let element, associatedWith: _):
                if uniqueRemovals[element.id] == nil {
                    return change
                }
                if let assoc = uniqueInsertions[element.id] {
                    return .remove(offset: offset, element: element, associatedWith: assoc)
                }
            case .insert(offset: let offset, element: let element, associatedWith: _):
                if uniqueInsertions[element.id] == nil {
                    return change
                }
                if let assoc = uniqueRemovals[element.id] {
                    return .insert(offset: offset, element: element, associatedWith: assoc)
                }
            }
            return change
        }))!
    }
}
