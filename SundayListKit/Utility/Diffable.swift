//
//  Diffable.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/24.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol Diffable {
    func isContentEqual(to diffable: Diffable) -> Bool
    var diffIdentifier: AnyHashable { get }
}

public extension Diffable where Self: Equatable {
    func isContentEqual(to object: Diffable) -> Bool {
        if let object = object as? Self {
            return object == self
        }
        return false
    }
}

public extension Diffable where Self: Hashable {
    var diffIdentifier: AnyHashable {
        return self
    }
}
