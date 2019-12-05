//
//  TypeHashable.swift
//  ListKit
//
//  Created by Frain on 2019/11/18.
//

struct TypeHashable: Hashable {
    let type: Any.Type
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(type, to: UnsafePointer<Int>.self))
    }
    
    static func == (lhs: TypeHashable, rhs: TypeHashable) -> Bool {
        lhs.type == rhs.type
    }
    
    var isAny: Bool {
        type == Any.self
    }
}
