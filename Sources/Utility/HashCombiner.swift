//
//  HashCombiner.swift
//  ListKit
//
//  Created by Frain on 2020/1/16.
//

struct HashCombiner: Hashable {
    static var none: HashCombiner { .init() }
    
    var hashables: [AnyHashable]
    var isNone: Bool { hashables.isEmpty }
    
    func hash(into hasher: inout Hasher) {
        hashables.forEach { hasher.combine($0) }
    }
    
    init(_ hashable: AnyHashable...) {
        self.hashables = hashable
    }
    
    init(_ hashables: [AnyHashable]) {
        self.hashables = hashables
    }
}
