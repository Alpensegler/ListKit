//
//  CoordinatorChange.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

class CoordinatorChange<Value, Related> {
    struct Unowned {
        unowned let change: CoordinatorChange<Value, Related>
    }
    
    enum State: Equatable {
        case change(moveAndRelod: Bool?)
        case reload
        case none
    }
    
    var index: Int
    var valueRelated: ValueRelated<Value, Related>
    var state = State.none
    
    lazy var offsets = [ObjectIdentifier: (section: Int, item: Int)]()
    lazy var otherAssociated = [ObjectIdentifier: Unowned]()
    
    unowned var associated: CoordinatorChange<Value, Related>?
    
    var value: Value { valueRelated.value }
    var related: Related { valueRelated.related }
    
    func indexPath(_ id: ObjectIdentifier) -> IndexPath {
        guard let (section, item) = offsets[id] else { return IndexPath(item: index) }
        return IndexPath(section: section, item: item + index)
    }
    
    func index(_ id: ObjectIdentifier) -> Int {
        guard let (section, _) = offsets[id] else { return index }
        return section + index
    }
    
    required init(valueRelated: ValueRelated<Value, Related>, index: Int) {
        self.valueRelated = valueRelated
        self.index = index
    }
}

extension CoordinatorChange: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        "\(value), \(index), \(state)"
    }
    
    var debugDescription: String {
        associated.map { "\(description), \($0.index)" } ?? description
    }
}
