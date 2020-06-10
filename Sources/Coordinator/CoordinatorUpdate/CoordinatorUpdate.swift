//
//  CoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/6/4.
//

import Foundation

enum UpdateType {
    case insert((() -> Void)?)
    case remove((() -> Void)?)
    case reload((() -> Void)?)
    case batchUpdates(ListUpdates)
}

class CoordinatorUpdateContext {
    lazy var uniqueChange: Mapping<[AnyHashable: Any?]> = ([:], [:])
    lazy var unhandled = ContiguousArray<CoordinatorUpdate>()
}

protocol CoordinatorUpdate: AnyObject {
    
}

protocol DiffableCoordinatorUpdate: CoordinatorUpdate {
    associatedtype Value
    associatedtype Related
    associatedtype DiffChange: CoordinatorChange<Value, Related>
}
