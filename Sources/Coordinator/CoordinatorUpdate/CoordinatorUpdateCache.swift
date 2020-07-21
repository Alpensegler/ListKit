//
//  CoordinatorUpdateCache.swift
//  ListKit
//
//  Created by Frain on 2020/7/1.
//

struct UpdateContextCache<Value> {
    var dict = [ObjectIdentifier: Value]()
    var value: Value
    
    subscript(id: ObjectIdentifier?) -> Value {
        get {
            if let id = id {
                return dict[id] ?? {
                    dict[id] = value
                    return value
                }()
            } else {
                return value
            }
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
