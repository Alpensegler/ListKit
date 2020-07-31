//
//  CoordinatorChange.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

class CoordinatorChange<Value> {
    struct Unowned {
        unowned let change: CoordinatorChange<Value>
    }
    
    enum State: Equatable {
        case change(moveAndRelod: Bool?)
        case reload
    }
    
    let value: Value
    let index: Int
    var state: State
    
    var offsets = UpdateContextCache(value: (section: 0, item: 0))
    var associated = UpdateContextCache(value: nil as Unowned?)
    
    func indexPath(_ id: ObjectIdentifier?) -> IndexPath {
        let (section, item) = offsets[id]
        return IndexPath(section: section, item: item + index)
    }
    
    func index(_ id: ObjectIdentifier?) -> Int {
        offsets[id].section + index
    }
    
    subscript(id: ObjectIdentifier?) -> CoordinatorChange<Value>? {
        get { associated.value?.change ?? associated[id]?.change }
        set { associated[id] = newValue.map(Unowned.init(change:)) }
    }
    
    required init(_ value: Value, _ index: Int, moveAndReloadable: Bool = true) {
        self.value = value
        self.index = index
        self.state = .change(moveAndRelod: moveAndReloadable ? nil : false)
    }
}

extension CoordinatorChange: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        "\(value), \(index), \(state)"
    }
    
    var debugDescription: String {
        (associated.value?.change).map { "\(description), \($0.index)" } ?? description
    }
}
