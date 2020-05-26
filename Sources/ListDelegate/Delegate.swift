//
//  ClosureDelegate.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

import Foundation

struct Delegate<Object: AnyObject, Input, Output> {
    enum Index {
        case index(KeyPath<Input, Int>)
        case indexPath(KeyPath<Input, IndexPath>)
    }
    
    let selector: Selector
    let index: Index?
    var closure: ((Object, Input, Int, Int) -> Output)?
    
    init(index: Index? = nil, _ selector: Selector) {
        self.index = index
        self.selector = selector
        self.closure = nil
    }
}
