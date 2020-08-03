//
//  ClosureDelegate.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

import Foundation

struct Delegate<Object: AnyObject, Input, Output, Index> {
    let selector: Selector
    let index: KeyPath<Input, Index>!
    var closure: ((Object, Input, CoordinatorContext, Int, Int) -> Output)?
    
    init(index: KeyPath<Input, Index>, _ selector: Selector) {
        self.index = index
        self.selector = selector
        self.closure = nil
    }
}

extension Delegate where Index == Void {
    init(_ selector: Selector) {
        self.index = nil
        self.selector = selector
        self.closure = nil
    }
}
