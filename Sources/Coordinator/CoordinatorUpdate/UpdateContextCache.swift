//
//  UpdateContextCache.swift
//  ListKit
//
//  Created by Frain on 2020/6/25.
//

struct UpdateContextCache<Value> {
    var dict = [ObjectIdentifier: Value]()
    var value: Value
    
    subscript(id: ObjectIdentifier?) -> Value {
        get {
            id.flatMap { dict[$0] } ?? value
        }
        set {
            if let id = id {
                dict[id] = newValue
            } else {
                value = newValue
            }
        }
    }
}
